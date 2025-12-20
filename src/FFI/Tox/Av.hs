-- | Raw bindings to @toxav.h@. "Network.Tox.C" is the safe API.
module FFI.Tox.Av where

import           Data.Int        (Int16, Int32)
import           Data.Word       (Word16, Word32, Word8)
import           FFI.Tox.Types   (AvAudioBitRateCb, AvAudioDataCb,
                                  AvAudioReceiveFrameCb, AvCallCb,
                                  AvCallStateCb, AvVideoBitRateCb,
                                  AvVideoReceiveFrameCb, ToxAvPtr, ToxPtr)
import           Foreign.C.Enum  (CErr)
import           Foreign.C.Types (CBool (..), CInt (..), CSize (..))
import           Foreign.Ptr     (FunPtr, Ptr)

foreign import ccall toxav_add_av_groupchat
    :: ToxPtr -> FunPtr AvAudioDataCb -> Ptr () -> IO Int32
foreign import ccall toxav_join_av_groupchat
    :: ToxPtr
    -> Word32
    -> Ptr Word8
    -> Word16
    -> FunPtr AvAudioDataCb
    -> Ptr ()
    -> IO Int32
foreign import ccall toxav_group_send_audio
    :: ToxPtr -> Word32 -> Ptr Int16 -> Word32 -> Word8 -> Word32 -> IO Int32
foreign import ccall toxav_groupchat_enable_av
    :: ToxPtr -> Word32 -> FunPtr AvAudioDataCb -> Ptr () -> IO Int32
foreign import ccall toxav_groupchat_disable_av :: ToxPtr -> Word32 -> IO Int32
foreign import ccall toxav_groupchat_av_enabled :: ToxPtr -> Word32 -> IO CBool
foreign import ccall toxav_new :: ToxPtr -> CErr -> IO ToxAvPtr
foreign import ccall toxav_kill :: ToxAvPtr -> IO ()
foreign import ccall toxav_get_tox :: ToxAvPtr -> IO ToxPtr
foreign import ccall toxav_iteration_interval :: ToxAvPtr -> IO Word32
foreign import ccall toxav_iterate :: ToxAvPtr -> IO ()
foreign import ccall toxav_audio_iteration_interval :: ToxAvPtr -> IO Word32
foreign import ccall toxav_audio_iterate :: ToxAvPtr -> IO ()
foreign import ccall toxav_video_iteration_interval :: ToxAvPtr -> IO Word32
foreign import ccall toxav_video_iterate :: ToxAvPtr -> IO ()
foreign import ccall toxav_call
    :: ToxAvPtr -> Word32 -> Word32 -> Word32 -> CErr -> IO CBool
foreign import ccall toxav_answer
    :: ToxAvPtr -> Word32 -> Word32 -> Word32 -> CErr -> IO CBool
foreign import ccall toxav_call_control
    :: ToxAvPtr -> Word32 -> CInt -> CErr -> IO CBool
foreign import ccall toxav_audio_send_frame
    :: ToxAvPtr
    -> Word32
    -> Ptr Int16
    -> CSize
    -> Word8
    -> Word32
    -> CErr
    -> IO CBool
foreign import ccall toxav_audio_set_bit_rate
    :: ToxAvPtr -> Word32 -> Word32 -> CErr -> IO CBool
foreign import ccall toxav_video_send_frame
    :: ToxAvPtr
    -> Word32
    -> Word16
    -> Word16
    -> Ptr Word8
    -> Ptr Word8
    -> Ptr Word8
    -> CErr
    -> IO CBool
foreign import ccall toxav_video_set_bit_rate
    :: ToxAvPtr -> Word32 -> Word32 -> CErr -> IO CBool
foreign import ccall toxav_callback_call
    :: ToxAvPtr -> FunPtr AvCallCb -> Ptr () -> IO ()
foreign import ccall toxav_callback_call_state
    :: ToxAvPtr -> FunPtr AvCallStateCb -> Ptr () -> IO ()
foreign import ccall toxav_callback_audio_bit_rate
    :: ToxAvPtr -> FunPtr AvAudioBitRateCb -> Ptr () -> IO ()
foreign import ccall toxav_callback_video_bit_rate
    :: ToxAvPtr -> FunPtr AvVideoBitRateCb -> Ptr () -> IO ()
foreign import ccall toxav_callback_audio_receive_frame
    :: ToxAvPtr -> FunPtr AvAudioReceiveFrameCb -> Ptr () -> IO ()
foreign import ccall toxav_callback_video_receive_frame
    :: ToxAvPtr -> FunPtr AvVideoReceiveFrameCb -> Ptr () -> IO ()
