-- | Raw bindings to @tox_log_level.h@. "Network.Tox.C" is the safe API.
module FFI.Tox.LogLevel where

import           Foreign.C.String (CString)
import           Foreign.C.Types  (CInt (..))

foreign import ccall tox_log_level_to_string :: CInt -> IO CString
