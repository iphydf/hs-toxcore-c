-- | C enums as Haskell sum types, marshalled by their real C values.
module Foreign.C.Enum
    ( CEnum (..)
    , CErr
    , callErrFun
    , callErrFun_
    , unknownCEnum
    ) where

import           Foreign.C.Types       (CInt)
import           Foreign.Marshal.Alloc (alloca)
import           Foreign.Ptr           (Ptr)
import           Foreign.Storable      (peek, poke)

-- | A Haskell type for a C enum. Error enums leave out their OK value.
class CEnum a where
    toCEnum   :: a -> CInt
    fromCEnum :: CInt -> a

-- | A C error out-parameter, which C sets to 0 on success.
type CErr = Ptr CInt

-- | Calls a C function with an error out-parameter.
callErrFun :: CEnum err => (CErr -> IO r) -> IO (Either err r)
callErrFun f = alloca $ \errPtr -> do
    poke errPtr 0
    result <- f errPtr
    err <- peek errPtr
    return $ if err == 0 then Right result else Left (fromCEnum err)

-- | 'callErrFun' for a function whose result only says whether it worked.
callErrFun_ :: CEnum err => (CErr -> IO r) -> IO (Either err ())
callErrFun_ f = fmap (() <$) (callErrFun f)

-- | A C value the bindings don't know, from a toxcore other than the one they
-- were generated for.
unknownCEnum :: String -> CInt -> a
unknownCEnum name value = error $ "unknown " <> name <> " value " <> show value
