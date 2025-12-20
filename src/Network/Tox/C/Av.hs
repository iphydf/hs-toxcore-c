-- | Audio and video calls with friends.
module Network.Tox.C.Av
    ( toxavIterationInterval
    , toxavIterate
    , toxavAudioIterationInterval
    , toxavAudioIterate
    , toxavVideoIterationInterval
    , toxavVideoIterate
    , toxavCall
    , toxavAnswer
    , toxavCallControl
    , toxavAudioSendFrame
    , toxavAudioSetBitRate
    , toxavVideoSendFrame
    , toxavVideoSetBitRate
    , toxavCallbackCall
    , toxavCallbackCallState
    , toxavCallbackAudioBitRate
    , toxavCallbackVideoBitRate
    , toxavCallbackAudioReceiveFrame
    , toxavCallbackVideoReceiveFrame
    ) where

import           Data.ByteString       (ByteString)
import           Data.Int              (Int16, Int32)
import           Data.Vector.Storable  (Vector)
import           Data.Word             (Word32)
import qualified FFI.Tox.Av            as Raw
import qualified FFI.Tox.Types         as Raw
import           Foreign.C.Enum        (callErrFun_, toCEnum)
import           Foreign.Marshal.Utils (toBool)
import           Foreign.Ptr           (nullPtr)
import           Network.Tox.C.Marshal (peekBytes, peekSizedVector,
                                        registerCallback, withSizedBytes,
                                        withSizedVector)
import           Network.Tox.C.Types   (AvBitRate (..), AvCallControl,
                                        AvChannels (..), AvErrAnswer,
                                        AvErrBitRateSet, AvErrCall,
                                        AvErrCallControl, AvErrSendFrame,
                                        AvFriendCallState (..), AvHeight (..),
                                        AvSamplingRate (..), AvWidth (..),
                                        FriendNumber (..), ToxAv (..))

-- | Returns the interval in milliseconds when the next 'toxavIterate' call
-- should be. If no call is active at the moment, this function returns 1000.
-- This function MUST be called from the same thread as 'toxavIterate'.
toxavIterationInterval :: ToxAv -> IO Word32
toxavIterationInterval (ToxAv av _) = Raw.toxav_iteration_interval av

-- | Main loop for the session. This function needs to be called in intervals of
-- @toxav_iteration_interval()@ milliseconds. It is best called in the
-- separate thread from tox_iterate.
toxavIterate :: ToxAv -> IO ()
toxavIterate (ToxAv av _) = Raw.toxav_iterate av

-- | Returns the interval in milliseconds when the next 'toxavAudioIterate' call
-- should be. If no call is active at the moment, this function returns 1000.
-- This function MUST be called from the same thread as 'toxavAudioIterate'.
toxavAudioIterationInterval :: ToxAv -> IO Word32
toxavAudioIterationInterval (ToxAv av _) = Raw.toxav_audio_iteration_interval av

-- | Main loop for the session. This function needs to be called in intervals of
-- @toxav_audio_iteration_interval()@ milliseconds. It is best called in a
-- separate thread from tox_iterate and 'toxavVideoIterate'. The thread
-- calling this function should have higher priority than the one calling
-- 'toxavVideoIterate' to prioritize audio over video.
toxavAudioIterate :: ToxAv -> IO ()
toxavAudioIterate (ToxAv av _) = Raw.toxav_audio_iterate av

-- | Returns the interval in milliseconds when the next 'toxavVideoIterate' call
-- should be. If no call is active at the moment, this function returns 1000.
-- This function MUST be called from the same thread as 'toxavVideoIterate'.
toxavVideoIterationInterval :: ToxAv -> IO Word32
toxavVideoIterationInterval (ToxAv av _) = Raw.toxav_video_iteration_interval av

-- | Main loop for the session. This function needs to be called in intervals of
-- @toxav_video_iteration_interval()@ milliseconds. It is best called in a
-- separate thread from tox_iterate and 'toxavAudioIterate'. The thread
-- calling this function should have lower priority than the one calling
-- 'toxavAudioIterate' to prioritize audio over video.
toxavVideoIterate :: ToxAv -> IO ()
toxavVideoIterate (ToxAv av _) = Raw.toxav_video_iterate av

-- | Call a friend. This will start ringing the friend.
--
-- It is the client's responsibility to stop ringing after a certain timeout,
-- if such behaviour is desired. If the client does not stop ringing, the
-- library will not stop until the friend is disconnected. Audio and video
-- receiving are both enabled by default.
--
-- * @friendNumber@: The friend number of the friend that should be called.
-- * @audioBitRate@: Audio bit rate in kbit\/sec. Set this to 0 to disable
--   audio sending.
-- * @videoBitRate@: Video bit rate in kbit\/sec. Set this to 0 to disable
--   video sending.
toxavCall
    :: ToxAv
    -> FriendNumber
    -> AvBitRate
    -> AvBitRate
    -> IO (Either AvErrCall ())
toxavCall (ToxAv av _) (FriendNumber friendNumber) (AvBitRate audioBitRate)
    (AvBitRate videoBitRate) =
    callErrFun_ $ Raw.toxav_call av friendNumber audioBitRate videoBitRate

-- | Accept an incoming call.
--
-- If answering fails for any reason, the call will still be pending and it is
-- possible to try and answer it later. Audio and video receiving are both
-- enabled by default.
--
-- * @friendNumber@: The friend number of the friend that is calling.
-- * @audioBitRate@: Audio bit rate in kbit\/sec. Set this to 0 to disable
--   audio sending.
-- * @videoBitRate@: Video bit rate in kbit\/sec. Set this to 0 to disable
--   video sending.
toxavAnswer
    :: ToxAv
    -> FriendNumber
    -> AvBitRate
    -> AvBitRate
    -> IO (Either AvErrAnswer ())
toxavAnswer (ToxAv av _) (FriendNumber friendNumber) (AvBitRate audioBitRate)
    (AvBitRate videoBitRate) =
    callErrFun_ $ Raw.toxav_answer av friendNumber audioBitRate videoBitRate

-- | Sends a call control command to a friend.
--
-- * @friendNumber@: The friend number of the friend this client is in a call
--   with.
-- * @control@: The control command to send.
toxavCallControl
    :: ToxAv -> FriendNumber -> AvCallControl -> IO (Either AvErrCallControl ())
toxavCallControl (ToxAv av _) (FriendNumber friendNumber) control =
    callErrFun_ $ Raw.toxav_call_control av friendNumber (toCEnum control)

-- | Send an audio frame to a friend.
--
-- The expected format of the PCM data is:
-- @[s1c1][s1c2][...][s2c1][s2c2][...]...@ Meaning: sample 1 for channel 1,
-- sample 1 for channel 2, ... For mono audio, this has no meaning, every
-- sample is subsequent. For stereo, this means the expected format is
-- LRLRLR... with samples for left and right alternating.
--
-- * @friendNumber@: The friend number of the friend to which to send an audio
--   frame.
-- * @pcm@: An array of audio samples. The size of this array must be
--   @sample_count * channels@.
-- * @sampleCount@: Number of samples in this frame. Valid numbers here are
--   @((sample rate) * (audio length) \/ 1000)@, where audio length can be
--   2.5, 5, 10, 20, 40 or 60 milliseconds.
-- * @channels@: Number of audio channels. Supported values are 1 and 2.
-- * @samplingRate@: Audio sampling rate used in this frame. Valid sampling
--   rates are 8000, 12000, 16000, 24000, or 48000.
toxavAudioSendFrame
    :: ToxAv
    -> FriendNumber
    -> Vector Int16
    -> Int
    -> AvChannels
    -> AvSamplingRate
    -> IO (Either AvErrSendFrame ())
toxavAudioSendFrame (ToxAv av _) (FriendNumber friendNumber) pcm sampleCount
    (AvChannels channels) (AvSamplingRate samplingRate) =
    withSizedVector "pcm" pcm (sampleCount * fromIntegral channels) $ \pcmPtr ->
        callErrFun_ $
            Raw.toxav_audio_send_frame av friendNumber pcmPtr
                (fromIntegral sampleCount)
                channels
                samplingRate

-- | Set the bit rate to be used in subsequent audio frames.
--
-- * @friendNumber@: The friend number of the friend for which to set the bit
--   rate.
-- * @bitRate@: The new audio bit rate in kbit\/sec. Set to 0 to disable.
toxavAudioSetBitRate
    :: ToxAv -> FriendNumber -> AvBitRate -> IO (Either AvErrBitRateSet ())
toxavAudioSetBitRate (ToxAv av _) (FriendNumber friendNumber)
    (AvBitRate bitRate) =
    callErrFun_ $ Raw.toxav_audio_set_bit_rate av friendNumber bitRate

-- | Send a video frame to a friend.
--
-- The video frame needs to be planar YUV420. Y \- plane should be of size:
-- @width * height@ U \- plane should be of size: @(width\/2) * (height\/2)@ V
-- \- plane should be of size: @(width\/2) * (height\/2)@
--
-- * @friendNumber@: The friend number of the friend to which to send a video
--   frame.
-- * @width@: Width of the frame in pixels.
-- * @height@: Height of the frame in pixels.
-- * @y@: Y (Luminance) plane data.
-- * @u@: U (Chroma) plane data.
-- * @v@: V (Chroma) plane data.
toxavVideoSendFrame
    :: ToxAv
    -> FriendNumber
    -> AvWidth
    -> AvHeight
    -> ByteString
    -> ByteString
    -> ByteString
    -> IO (Either AvErrSendFrame ())
toxavVideoSendFrame (ToxAv av _) (FriendNumber friendNumber) (AvWidth width)
    (AvHeight height) y u v =
    withSizedBytes "y" y (fromIntegral width * fromIntegral height) $ \yPtr ->
    withSizedBytes "u" u
        (fromIntegral width `div` 2 * fromIntegral height `div` 2) $ \uPtr ->
    withSizedBytes "v" v
        (fromIntegral width `div` 2 * fromIntegral height `div` 2) $ \vPtr ->
        callErrFun_ $
            Raw.toxav_video_send_frame av friendNumber width height yPtr uPtr
                vPtr

-- | Set the bit rate to be used in subsequent video frames.
--
-- * @friendNumber@: The friend number of the friend for which to set the bit
--   rate.
-- * @bitRate@: The new video bit rate in kbit\/sec. Set to 0 to disable.
toxavVideoSetBitRate
    :: ToxAv -> FriendNumber -> AvBitRate -> IO (Either AvErrBitRateSet ())
toxavVideoSetBitRate (ToxAv av _) (FriendNumber friendNumber)
    (AvBitRate bitRate) =
    callErrFun_ $ Raw.toxav_video_set_bit_rate av friendNumber bitRate

-- | Set the callback for the @call@ event.
--
-- * @friendNumber@: The friend number from which the call is incoming.
-- * @audioEnabled@: True if friend is sending audio.
-- * @videoEnabled@: True if friend is sending video.
toxavCallbackCall :: ToxAv -> (FriendNumber -> Bool -> Bool -> IO ()) -> IO ()
toxavCallbackCall (ToxAv toxAv callbacks) handler = do
    callback <- Raw.wrapAvCallCb callback'
    registerCallback callbacks "call" callback
        (Raw.toxav_callback_call toxAv callback nullPtr)
  where
    callback' _ friendNumber audioEnabled videoEnabled _ =
        handler
            (FriendNumber friendNumber)
            (toBool audioEnabled)
            (toBool videoEnabled)

-- | Set the callback for the @call_state@ event.
--
-- * @friendNumber@: The friend number for which the call state changed.
-- * @state@: The bitmask of the new call state which is guaranteed to be
--   different than the previous state. The state is set to 0 when the call is
--   paused. The bitmask represents all the activities currently performed by
--   the friend.
toxavCallbackCallState
    :: ToxAv -> (FriendNumber -> AvFriendCallState -> IO ()) -> IO ()
toxavCallbackCallState (ToxAv toxAv callbacks) handler = do
    callback <- Raw.wrapAvCallStateCb callback'
    registerCallback callbacks "call_state" callback
        (Raw.toxav_callback_call_state toxAv callback nullPtr)
  where
    callback' _ friendNumber state _ =
        handler (FriendNumber friendNumber) (AvFriendCallState state)

-- | Set the callback for the @audio_bit_rate@ event.
--
-- The event is triggered when the network becomes too saturated for current
-- bit rates at which point ToxAV suggests new bit rates.
--
-- * @friendNumber@: The friend number of the friend for which to set the bit
--   rate.
-- * @audioBitRate@: Suggested maximum audio bit rate in kbit\/sec.
toxavCallbackAudioBitRate
    :: ToxAv -> (FriendNumber -> AvBitRate -> IO ()) -> IO ()
toxavCallbackAudioBitRate (ToxAv toxAv callbacks) handler = do
    callback <- Raw.wrapAvAudioBitRateCb callback'
    registerCallback callbacks "audio_bit_rate" callback
        (Raw.toxav_callback_audio_bit_rate toxAv callback nullPtr)
  where
    callback' _ friendNumber audioBitRate _ =
        handler (FriendNumber friendNumber) (AvBitRate audioBitRate)

-- | Set the callback for the @video_bit_rate@ event.
--
-- The event is triggered when the network becomes too saturated for current
-- bit rates at which point ToxAV suggests new bit rates.
--
-- * @friendNumber@: The friend number of the friend for which to set the bit
--   rate.
-- * @videoBitRate@: Suggested maximum video bit rate in kbit\/sec.
toxavCallbackVideoBitRate
    :: ToxAv -> (FriendNumber -> AvBitRate -> IO ()) -> IO ()
toxavCallbackVideoBitRate (ToxAv toxAv callbacks) handler = do
    callback <- Raw.wrapAvVideoBitRateCb callback'
    registerCallback callbacks "video_bit_rate" callback
        (Raw.toxav_callback_video_bit_rate toxAv callback nullPtr)
  where
    callback' _ friendNumber videoBitRate _ =
        handler (FriendNumber friendNumber) (AvBitRate videoBitRate)

-- | Set the callback for the @audio_receive_frame@ event.
--
-- The callback can be called multiple times per single iteration depending on
-- the amount of queued frames in the buffer. The received format is the same
-- as in send function.
--
-- * @friendNumber@: The friend number of the friend who sent an audio frame.
-- * @pcm@: An array of audio samples (@sample_count * channels@ elements).
-- * @sampleCount@: The number of audio samples per channel in the PCM array.
-- * @channels@: Number of audio channels.
-- * @samplingRate@: Sampling rate used in this frame.
toxavCallbackAudioReceiveFrame
    :: ToxAv
    -> (FriendNumber
        -> Vector Int16
        -> Int
        -> AvChannels
        -> AvSamplingRate
        -> IO ())
    -> IO ()
toxavCallbackAudioReceiveFrame (ToxAv toxAv callbacks) handler = do
    callback <- Raw.wrapAvAudioReceiveFrameCb callback'
    registerCallback callbacks "audio_receive_frame" callback
        (Raw.toxav_callback_audio_receive_frame toxAv callback nullPtr)
  where
    callback' _ friendNumber pcm sampleCount channels samplingRate _ = do
        pcm' <- peekSizedVector pcm
            (fromIntegral sampleCount * fromIntegral channels)
        handler
            (FriendNumber friendNumber)
            pcm'
            (fromIntegral sampleCount)
            (AvChannels channels)
            (AvSamplingRate samplingRate)

-- | Set the callback for the @video_receive_frame@ event.
--
-- The size of plane data is derived from width and height as documented
-- below.
--
-- Strides represent padding for each plane that may or may not be present.
-- You must handle strides in your image processing code. Strides are negative
-- if the image is bottom-up hence why you MUST @abs()@ it when calculating
-- plane buffer size.
--
-- * @friendNumber@: The friend number of the friend who sent a video frame.
-- * @width@: Width of the frame in pixels.
-- * @height@: Height of the frame in pixels.
-- * @y@: Luminosity plane. @Size = MAX(width, abs(ystride)) * height@.
-- * @u@: U chroma plane. @Size = MAX((width+1)\/2, abs(ustride)) *
--   ((height+1)\/2)@.
-- * @v@: V chroma plane. @Size = MAX((width+1)\/2, abs(vstride)) *
--   ((height+1)\/2)@.
-- * @ystride@: Luminosity plane stride.
-- * @ustride@: U chroma plane stride.
-- * @vstride@: V chroma plane stride.
toxavCallbackVideoReceiveFrame
    :: ToxAv
    -> (FriendNumber
        -> AvWidth
        -> AvHeight
        -> ByteString
        -> ByteString
        -> ByteString
        -> Int32
        -> Int32
        -> Int32
        -> IO ())
    -> IO ()
toxavCallbackVideoReceiveFrame (ToxAv toxAv callbacks) handler = do
    callback <- Raw.wrapAvVideoReceiveFrameCb callback'
    registerCallback callbacks "video_receive_frame" callback
        (Raw.toxav_callback_video_receive_frame toxAv callback nullPtr)
  where
    callback' _ friendNumber width height y u v ystride ustride vstride _ = do
        y' <- peekBytes y
            (max
                (fromIntegral width)
                (abs (fromIntegral ystride)) * fromIntegral height)
        u' <- peekBytes u
            (max
                ((fromIntegral width + 1) `div` 2)
                (abs (fromIntegral ustride)) * ((fromIntegral
                height + 1) `div` 2))
        v' <- peekBytes v
            (max
                ((fromIntegral width + 1) `div` 2)
                (abs (fromIntegral vstride)) * ((fromIntegral
                height + 1) `div` 2))
        handler
            (FriendNumber friendNumber)
            (AvWidth width)
            (AvHeight height)
            y'
            u'
            v'
            ystride
            ustride
            vstride
