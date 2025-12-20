{-# LANGUAGE ScopedTypeVariables #-}
-- | Marshalling helpers for the generated bindings.
module Network.Tox.C.Marshal
    ( -- * Fixed-size byte strings
      FixedBytes (..)
    , fromBytes
    , withFixedBytes
    , withMaybeFixedBytes
    , getFixedBytes
    , getFixedBytesErr
    , getFixedBytesMaybe
    , peekFixedBytes
      -- * Byte strings and vectors
    , withBytesLen
    , withMaybeBytesLen
    , withSizedBytes
    , withMaybeSizedBytes
    , withSizedVector
    , getSized
    , getSizedErr
    , getBytesErr
    , peekBytes
    , peekSizedBytes
    , peekSizedString
    , peekNullableString
    , peekSizedVector
      -- * Lists
    , getList
    , iterateList
      -- * C objects
    , withNew
      -- * Callbacks
    , CallbackRegistry
    , newCallbackRegistry
    , registerCallback
    , freeCallbacks
      -- * Errors
    , invalidArgument
    ) where

import           Control.Exception            (bracket, throwIO)
import           Control.Monad                (void)
import           Data.ByteString              (ByteString)
import qualified Data.ByteString              as BS
import qualified Data.ByteString.Internal     as BS (create)
import           Data.IORef                   (IORef, atomicModifyIORef',
                                               newIORef, readIORef)
import           Data.Map.Strict              (Map)
import qualified Data.Map.Strict              as Map
import           Data.Proxy                   (Proxy (..))
import qualified Data.Vector.Storable         as Vector
import qualified Data.Vector.Storable.Mutable as MVector
import           Data.Word                    (Word32, Word8)
import           Foreign.C.Enum               (CEnum, CErr, callErrFun)
import           Foreign.C.String             (CString, peekCString,
                                               peekCStringLen)
import           Foreign.C.Types              (CBool)
import           Foreign.Marshal.Alloc        (allocaBytes)
import           Foreign.Marshal.Array        (allocaArray, copyArray,
                                               peekArray)
import           Foreign.Marshal.Utils        (toBool)
import           Foreign.Ptr                  (FunPtr, Ptr, castFunPtr, castPtr,
                                               freeHaskellFunPtr, nullPtr)
import           Foreign.Storable             (Storable)
import           GHC.IO.Exception             (IOErrorType (InvalidArgument),
                                               IOException (..))

-- | A byte string of a size C fixes, such as a public key.
class FixedBytes a where
    fixedSize       :: Proxy a -> Int
    toBytes         :: a -> ByteString
    -- | Only for bytes known to be 'fixedSize' long.
    unsafeFromBytes :: ByteString -> a

-- | The value of exactly 'fixedSize' bytes.
fromBytes :: forall a. FixedBytes a => ByteString -> Maybe a
fromBytes bytes
    | BS.length bytes == fixedSize (Proxy :: Proxy a) = Just (unsafeFromBytes bytes)
    | otherwise = Nothing

withFixedBytes :: FixedBytes a => a -> (Ptr Word8 -> IO r) -> IO r
withFixedBytes value f = BS.useAsCString (toBytes value) (f . castPtr)

-- | 'withFixedBytes', or NULL for 'Nothing'.
withMaybeFixedBytes :: FixedBytes a => Maybe a -> (Ptr Word8 -> IO r) -> IO r
withMaybeFixedBytes = maybe ($ nullPtr) withFixedBytes

-- | Runs a C function that writes the value into the buffer it's given.
getFixedBytes :: forall a r. FixedBytes a => (Ptr Word8 -> IO r) -> IO a
getFixedBytes f =
    unsafeFromBytes <$> BS.create (fixedSize (Proxy :: Proxy a)) (void . f)

getFixedBytesErr
    :: forall a err r. (FixedBytes a, CEnum err)
    => (Ptr Word8 -> CErr -> IO r) -> IO (Either err a)
getFixedBytesErr f =
    fmap unsafeFromBytes <$> getBytesErr (fixedSize (Proxy :: Proxy a)) f

-- | For a C function that returns whether it wrote the value.
getFixedBytesMaybe
    :: forall a. FixedBytes a => (Ptr Word8 -> IO CBool) -> IO (Maybe a)
getFixedBytesMaybe f =
    allocaBytes size $ \buf -> do
        written <- toBool <$> f buf
        if written
            then Just . unsafeFromBytes <$> BS.packCStringLen (castPtr buf, size)
            else return Nothing
  where
    size = fixedSize (Proxy :: Proxy a)

-- | Copies a value out of memory C owns.
peekFixedBytes :: forall a. FixedBytes a => Ptr Word8 -> IO a
peekFixedBytes ptr =
    unsafeFromBytes <$> BS.packCStringLen (castPtr ptr, fixedSize (Proxy :: Proxy a))

-- | Passes the bytes as a C array and its length.
withBytesLen :: Num n => ByteString -> (Ptr Word8 -> n -> IO r) -> IO r
withBytesLen bytes f =
    BS.useAsCStringLen bytes $ \(ptr, len) -> f (castPtr ptr) (fromIntegral len)

-- | 'withBytesLen', or NULL and 0 for 'Nothing'.
withMaybeBytesLen :: Num n => Maybe ByteString -> (Ptr Word8 -> n -> IO r) -> IO r
withMaybeBytesLen = maybe (\f -> f nullPtr 0) withBytesLen

-- | Passes bytes that C reads @size@ of, failing if there are fewer.
withSizedBytes :: String -> ByteString -> Int -> (Ptr Word8 -> IO r) -> IO r
withSizedBytes name bytes size f
    | BS.length bytes < size =
        invalidArgument $ name <> " is shorter than " <> show size <> " bytes"
    | otherwise = BS.useAsCString bytes (f . castPtr)

-- | 'withSizedBytes', or NULL for 'Nothing'.
withMaybeSizedBytes :: String -> Maybe ByteString -> Int -> (Ptr Word8 -> IO r) -> IO r
withMaybeSizedBytes name = maybe (const ($ nullPtr)) (withSizedBytes name)

-- | 'withSizedBytes' for a vector of samples.
withSizedVector
    :: Storable a => String -> Vector.Vector a -> Int -> (Ptr a -> IO r) -> IO r
withSizedVector name vector size f
    | Vector.length vector < size =
        invalidArgument $ name <> " is shorter than " <> show size <> " elements"
    | otherwise = Vector.unsafeWith vector f

-- | Asks C how long the bytes are, then for the bytes.
getSized :: Integral n => IO n -> (Ptr Word8 -> IO r) -> IO ByteString
getSized getSize getData = do
    size <- getSize
    BS.create (fromIntegral size) (void . getData)

getSizedErr
    :: (Integral n, CEnum err)
    => (CErr -> IO n) -> (Ptr Word8 -> CErr -> IO r) -> IO (Either err ByteString)
getSizedErr getSize getData = do
    sizeResult <- callErrFun getSize
    case sizeResult of
        Left err   -> return (Left err)
        Right size -> getBytesErr (fromIntegral size) getData

-- | Runs a C function that writes @size@ bytes. A size below 0 is a C length
-- check's to report.
getBytesErr
    :: CEnum err => Int -> (Ptr Word8 -> CErr -> IO r) -> IO (Either err ByteString)
getBytesErr size getData =
    allocaBytes size' $ \buf -> do
        result <- callErrFun (getData buf)
        traverse (const (BS.packCStringLen (castPtr buf, size'))) result
  where
    size' = max 0 size

-- | Copies @size@ bytes out of memory C owns, which may be null when empty.
peekBytes :: Ptr Word8 -> Int -> IO ByteString
peekBytes ptr size
    | ptr == nullPtr || size <= 0 = return BS.empty
    | otherwise = BS.packCStringLen (castPtr ptr, size)

-- | Copies bytes out of memory C owns, which may be null when empty.
peekSizedBytes :: Integral n => IO (Ptr Word8) -> IO n -> IO ByteString
peekSizedBytes getPtr getSize = do
    ptr <- getPtr
    size <- fromIntegral <$> getSize
    if ptr == nullPtr || size == 0
        then return BS.empty
        else BS.packCStringLen (castPtr ptr, size)

-- | A C string, which may be null when there is none.
peekNullableString :: CString -> IO String
peekNullableString ptr
    | ptr == nullPtr = return ""
    | otherwise = peekCString ptr

peekSizedString :: Integral n => IO CString -> IO n -> IO String
peekSizedString getPtr getSize = do
    ptr <- getPtr
    size <- fromIntegral <$> getSize
    if ptr == nullPtr then return "" else peekCStringLen (ptr, size)

-- | Copies samples out of memory C owns.
peekSizedVector :: Storable a => Ptr a -> Int -> IO (Vector.Vector a)
peekSizedVector ptr size
    | ptr == nullPtr || size <= 0 = return Vector.empty
    | otherwise = do
        vector <- MVector.new size
        MVector.unsafeWith vector $ \dst -> copyArray dst ptr size
        Vector.unsafeFreeze vector

-- | Asks C how many elements there are, then for the elements.
getList :: (Integral n, Storable a) => IO n -> (Ptr a -> IO r) -> IO [a]
getList getSize getData = do
    size <- fromIntegral <$> getSize
    allocaArray size $ \buf -> getData buf >> peekArray size buf

-- | The elements of a C container with a size and an indexed getter.
iterateList :: (p -> IO Word32) -> (p -> Word32 -> IO e) -> p -> IO [e]
iterateList getSize get container = do
    size <- getSize container
    mapM (get container) (take (fromIntegral size) [0 ..])

-- | Creates a C object for the action, and frees it after.
withNew
    :: CEnum err
    => (CErr -> IO (Ptr a)) -> (Ptr a -> IO ()) -> (Ptr a -> IO r) -> IO (Either err r)
withNew new free action = bracket (callErrFun new) (mapM_ free) (traverse action)

-- | The callbacks registered with a C object, freed when it is.
newtype CallbackRegistry = CallbackRegistry (IORef (Map String (FunPtr ())))

newCallbackRegistry :: IO CallbackRegistry
newCallbackRegistry = CallbackRegistry <$> newIORef Map.empty

-- | Runs @register@, then frees the callback it replaces for @event@.
registerCallback :: CallbackRegistry -> String -> FunPtr a -> IO () -> IO ()
registerCallback (CallbackRegistry ref) event callback register = do
    register
    old <- atomicModifyIORef' ref $ \callbacks ->
        (Map.insert event (castFunPtr callback) callbacks, Map.lookup event callbacks)
    mapM_ freeHaskellFunPtr old

-- | Frees all callbacks, once C can no longer call them.
freeCallbacks :: CallbackRegistry -> IO ()
freeCallbacks (CallbackRegistry ref) = readIORef ref >>= mapM_ freeHaskellFunPtr

-- | Fails for an argument C would read out of bounds.
invalidArgument :: String -> IO a
invalidArgument message =
    throwIO $ IOError Nothing InvalidArgument "toxcore-c" message Nothing Nothing
