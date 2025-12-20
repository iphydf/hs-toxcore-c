-- | Raw bindings to @tox_options.h@. "Network.Tox.C" is the safe API.
module FFI.Tox.Options where

import           Data.Word        (Word16, Word8)
import           FFI.Tox.Types    (LogCb, OptionsPtr)
import           Foreign.C.Enum   (CErr)
import           Foreign.C.String (CString)
import           Foreign.C.Types  (CBool (..), CInt (..), CSize (..))
import           Foreign.Ptr      (FunPtr, Ptr)

foreign import ccall tox_options_get_ipv6_enabled :: OptionsPtr -> IO CBool
foreign import ccall tox_options_set_ipv6_enabled
    :: OptionsPtr -> CBool -> IO ()
foreign import ccall tox_options_get_udp_enabled :: OptionsPtr -> IO CBool
foreign import ccall tox_options_set_udp_enabled :: OptionsPtr -> CBool -> IO ()
foreign import ccall tox_options_get_local_discovery_enabled
    :: OptionsPtr -> IO CBool
foreign import ccall tox_options_set_local_discovery_enabled
    :: OptionsPtr -> CBool -> IO ()
foreign import ccall tox_options_get_dht_announcements_enabled
    :: OptionsPtr -> IO CBool
foreign import ccall tox_options_set_dht_announcements_enabled
    :: OptionsPtr -> CBool -> IO ()
foreign import ccall tox_options_get_proxy_type :: OptionsPtr -> IO CInt
foreign import ccall tox_options_set_proxy_type :: OptionsPtr -> CInt -> IO ()
foreign import ccall tox_options_get_proxy_host :: OptionsPtr -> IO CString
foreign import ccall tox_options_set_proxy_host
    :: OptionsPtr -> CString -> IO CBool
foreign import ccall tox_options_get_proxy_port :: OptionsPtr -> IO Word16
foreign import ccall tox_options_set_proxy_port :: OptionsPtr -> Word16 -> IO ()
foreign import ccall tox_options_get_start_port :: OptionsPtr -> IO Word16
foreign import ccall tox_options_set_start_port :: OptionsPtr -> Word16 -> IO ()
foreign import ccall tox_options_get_end_port :: OptionsPtr -> IO Word16
foreign import ccall tox_options_set_end_port :: OptionsPtr -> Word16 -> IO ()
foreign import ccall tox_options_get_tcp_port :: OptionsPtr -> IO Word16
foreign import ccall tox_options_set_tcp_port :: OptionsPtr -> Word16 -> IO ()
foreign import ccall tox_options_get_hole_punching_enabled
    :: OptionsPtr -> IO CBool
foreign import ccall tox_options_set_hole_punching_enabled
    :: OptionsPtr -> CBool -> IO ()
foreign import ccall tox_options_get_savedata_type :: OptionsPtr -> IO CInt
foreign import ccall tox_options_set_savedata_type
    :: OptionsPtr -> CInt -> IO ()
foreign import ccall tox_options_get_savedata_data
    :: OptionsPtr -> IO (Ptr Word8)
foreign import ccall tox_options_set_savedata_data
    :: OptionsPtr -> Ptr Word8 -> CSize -> IO CBool
foreign import ccall tox_options_get_savedata_length :: OptionsPtr -> IO CSize
foreign import ccall tox_options_set_savedata_length
    :: OptionsPtr -> CSize -> IO ()
foreign import ccall tox_options_get_log_callback
    :: OptionsPtr -> IO (FunPtr LogCb)
foreign import ccall tox_options_set_log_callback
    :: OptionsPtr -> FunPtr LogCb -> IO ()
foreign import ccall tox_options_get_log_user_data :: OptionsPtr -> IO (Ptr ())
foreign import ccall tox_options_set_log_user_data
    :: OptionsPtr -> Ptr () -> IO ()
foreign import ccall tox_options_get_experimental_owned_data
    :: OptionsPtr -> IO CBool
foreign import ccall tox_options_set_experimental_owned_data
    :: OptionsPtr -> CBool -> IO ()
foreign import ccall tox_options_get_experimental_thread_safety
    :: OptionsPtr -> IO CBool
foreign import ccall tox_options_set_experimental_thread_safety
    :: OptionsPtr -> CBool -> IO ()
foreign import ccall tox_options_get_experimental_groups_persistence
    :: OptionsPtr -> IO CBool
foreign import ccall tox_options_set_experimental_groups_persistence
    :: OptionsPtr -> CBool -> IO ()
foreign import ccall tox_options_get_experimental_disable_dns
    :: OptionsPtr -> IO CBool
foreign import ccall tox_options_set_experimental_disable_dns
    :: OptionsPtr -> CBool -> IO ()
foreign import ccall tox_options_default :: OptionsPtr -> IO ()
foreign import ccall tox_options_copy :: OptionsPtr -> OptionsPtr -> IO ()
foreign import ccall tox_options_new :: CErr -> IO OptionsPtr
foreign import ccall tox_options_free :: OptionsPtr -> IO ()
foreign import ccall tox_proxy_type_to_string :: CInt -> IO CString
foreign import ccall tox_savedata_type_to_string :: CInt -> IO CString
foreign import ccall tox_err_options_new_to_string :: CInt -> IO CString
