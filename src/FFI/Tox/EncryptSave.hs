-- | Raw bindings to @toxencryptsave.h@. "Network.Tox.C" is the safe API.
module FFI.Tox.EncryptSave where

import           Data.Word        (Word32, Word8)
import           FFI.Tox.Types    (PassKeyPtr)
import           Foreign.C.Enum   (CErr)
import           Foreign.C.String (CString)
import           Foreign.C.Types  (CBool (..), CInt (..), CSize (..))
import           Foreign.Ptr      (FunPtr, Ptr)

foreign import ccall tox_pass_salt_length :: Word32
foreign import ccall tox_pass_key_length :: Word32
foreign import ccall tox_pass_encryption_extra_length :: Word32
foreign import ccall tox_err_key_derivation_to_string :: CInt -> IO CString
foreign import ccall tox_err_encryption_to_string :: CInt -> IO CString
foreign import ccall tox_err_decryption_to_string :: CInt -> IO CString
foreign import ccall tox_pass_encrypt
    :: Ptr Word8 -> CSize -> Ptr Word8 -> CSize -> Ptr Word8 -> CErr -> IO CBool
foreign import ccall tox_pass_decrypt
    :: Ptr Word8 -> CSize -> Ptr Word8 -> CSize -> Ptr Word8 -> CErr -> IO CBool
foreign import ccall tox_pass_key_free :: PassKeyPtr -> IO ()
foreign import ccall tox_pass_key_derive
    :: Ptr Word8 -> CSize -> CErr -> IO PassKeyPtr
foreign import ccall tox_pass_key_derive_with_salt
    :: Ptr Word8 -> CSize -> Ptr Word8 -> CErr -> IO PassKeyPtr
foreign import ccall tox_pass_key_encrypt
    :: PassKeyPtr -> Ptr Word8 -> CSize -> Ptr Word8 -> CErr -> IO CBool
foreign import ccall tox_pass_key_decrypt
    :: PassKeyPtr -> Ptr Word8 -> CSize -> Ptr Word8 -> CErr -> IO CBool
foreign import ccall tox_err_get_salt_to_string :: CInt -> IO CString
foreign import ccall tox_get_salt :: Ptr Word8 -> Ptr Word8 -> CErr -> IO CBool
foreign import ccall tox_is_data_encrypted :: Ptr Word8 -> IO CBool
foreign import ccall "&tox_pass_key_free" p_tox_pass_key_free
    :: FunPtr (PassKeyPtr -> IO ())
