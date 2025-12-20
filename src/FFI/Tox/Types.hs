-- | The C types the raw bindings share: opaque handles and callbacks.
module FFI.Tox.Types where

import           Data.Int         (Int16, Int32)
import           Data.Word        (Word16, Word32, Word64, Word8)
import           Foreign.C.String (CString)
import           Foreign.C.Types  (CBool (..), CInt (..), CSize (..))
import           Foreign.Ptr      (FunPtr, Ptr)

data EventStruct
type EventPtr = Ptr EventStruct

data EventConferenceConnectedStruct
type EventConferenceConnectedPtr = Ptr EventConferenceConnectedStruct

data EventConferenceInviteStruct
type EventConferenceInvitePtr = Ptr EventConferenceInviteStruct

data EventConferenceMessageStruct
type EventConferenceMessagePtr = Ptr EventConferenceMessageStruct

data EventConferencePeerListChangedStruct
type EventConferencePeerListChangedPtr =
    Ptr EventConferencePeerListChangedStruct

data EventConferencePeerNameStruct
type EventConferencePeerNamePtr = Ptr EventConferencePeerNameStruct

data EventConferenceTitleStruct
type EventConferenceTitlePtr = Ptr EventConferenceTitleStruct

data EventDhtNodesResponseStruct
type EventDhtNodesResponsePtr = Ptr EventDhtNodesResponseStruct

data EventFileChunkRequestStruct
type EventFileChunkRequestPtr = Ptr EventFileChunkRequestStruct

data EventFileRecvStruct
type EventFileRecvPtr = Ptr EventFileRecvStruct

data EventFileRecvChunkStruct
type EventFileRecvChunkPtr = Ptr EventFileRecvChunkStruct

data EventFileRecvControlStruct
type EventFileRecvControlPtr = Ptr EventFileRecvControlStruct

data EventFriendConnectionStatusStruct
type EventFriendConnectionStatusPtr = Ptr EventFriendConnectionStatusStruct

data EventFriendLosslessPacketStruct
type EventFriendLosslessPacketPtr = Ptr EventFriendLosslessPacketStruct

data EventFriendLossyPacketStruct
type EventFriendLossyPacketPtr = Ptr EventFriendLossyPacketStruct

data EventFriendMessageStruct
type EventFriendMessagePtr = Ptr EventFriendMessageStruct

data EventFriendNameStruct
type EventFriendNamePtr = Ptr EventFriendNameStruct

data EventFriendReadReceiptStruct
type EventFriendReadReceiptPtr = Ptr EventFriendReadReceiptStruct

data EventFriendRequestStruct
type EventFriendRequestPtr = Ptr EventFriendRequestStruct

data EventFriendStatusStruct
type EventFriendStatusPtr = Ptr EventFriendStatusStruct

data EventFriendStatusMessageStruct
type EventFriendStatusMessagePtr = Ptr EventFriendStatusMessageStruct

data EventFriendTypingStruct
type EventFriendTypingPtr = Ptr EventFriendTypingStruct

data EventGroupCustomPacketStruct
type EventGroupCustomPacketPtr = Ptr EventGroupCustomPacketStruct

data EventGroupCustomPrivatePacketStruct
type EventGroupCustomPrivatePacketPtr = Ptr EventGroupCustomPrivatePacketStruct

data EventGroupInviteStruct
type EventGroupInvitePtr = Ptr EventGroupInviteStruct

data EventGroupJoinFailStruct
type EventGroupJoinFailPtr = Ptr EventGroupJoinFailStruct

data EventGroupMessageStruct
type EventGroupMessagePtr = Ptr EventGroupMessageStruct

data EventGroupModerationStruct
type EventGroupModerationPtr = Ptr EventGroupModerationStruct

data EventGroupPasswordStruct
type EventGroupPasswordPtr = Ptr EventGroupPasswordStruct

data EventGroupPeerExitStruct
type EventGroupPeerExitPtr = Ptr EventGroupPeerExitStruct

data EventGroupPeerJoinStruct
type EventGroupPeerJoinPtr = Ptr EventGroupPeerJoinStruct

data EventGroupPeerLimitStruct
type EventGroupPeerLimitPtr = Ptr EventGroupPeerLimitStruct

data EventGroupPeerNameStruct
type EventGroupPeerNamePtr = Ptr EventGroupPeerNameStruct

data EventGroupPeerStatusStruct
type EventGroupPeerStatusPtr = Ptr EventGroupPeerStatusStruct

data EventGroupPrivacyStateStruct
type EventGroupPrivacyStatePtr = Ptr EventGroupPrivacyStateStruct

data EventGroupPrivateMessageStruct
type EventGroupPrivateMessagePtr = Ptr EventGroupPrivateMessageStruct

data EventGroupSelfJoinStruct
type EventGroupSelfJoinPtr = Ptr EventGroupSelfJoinStruct

data EventGroupTopicStruct
type EventGroupTopicPtr = Ptr EventGroupTopicStruct

data EventGroupTopicLockStruct
type EventGroupTopicLockPtr = Ptr EventGroupTopicLockStruct

data EventGroupVoiceStateStruct
type EventGroupVoiceStatePtr = Ptr EventGroupVoiceStateStruct

data EventSelfConnectionStatusStruct
type EventSelfConnectionStatusPtr = Ptr EventSelfConnectionStatusStruct

data EventsStruct
type EventsPtr = Ptr EventsStruct

data IterateOptionsStruct
type IterateOptionsPtr = Ptr IterateOptionsStruct

data OptionsStruct
type OptionsPtr = Ptr OptionsStruct

data PassKeyStruct
type PassKeyPtr = Ptr PassKeyStruct

data SystemStruct
type SystemPtr = Ptr SystemStruct

data ToxStruct
type ToxPtr = Ptr ToxStruct

data ToxAvStruct
type ToxAvPtr = Ptr ToxAvStruct
type AvAudioBitRateCb = ToxAvPtr -> Word32 -> Word32 -> Ptr () -> IO ()

foreign import ccall "wrapper" wrapAvAudioBitRateCb
    :: AvAudioBitRateCb -> IO (FunPtr AvAudioBitRateCb)

type AvAudioDataCb =
    Ptr ()
    -> Word32
    -> Word32
    -> Ptr Int16
    -> Word32
    -> Word8
    -> Word32
    -> Ptr ()
    -> IO ()
foreign import ccall "wrapper" wrapAvAudioDataCb
    :: AvAudioDataCb -> IO (FunPtr AvAudioDataCb)

type AvAudioReceiveFrameCb =
    ToxAvPtr
    -> Word32
    -> Ptr Int16
    -> CSize
    -> Word8
    -> Word32
    -> Ptr ()
    -> IO ()
foreign import ccall "wrapper" wrapAvAudioReceiveFrameCb
    :: AvAudioReceiveFrameCb -> IO (FunPtr AvAudioReceiveFrameCb)

type AvCallCb = ToxAvPtr -> Word32 -> CBool -> CBool -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapAvCallCb :: AvCallCb -> IO (FunPtr AvCallCb)

type AvCallStateCb = ToxAvPtr -> Word32 -> Word32 -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapAvCallStateCb
    :: AvCallStateCb -> IO (FunPtr AvCallStateCb)

type AvVideoBitRateCb = ToxAvPtr -> Word32 -> Word32 -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapAvVideoBitRateCb
    :: AvVideoBitRateCb -> IO (FunPtr AvVideoBitRateCb)

type AvVideoReceiveFrameCb =
    ToxAvPtr
    -> Word32
    -> Word16
    -> Word16
    -> Ptr Word8
    -> Ptr Word8
    -> Ptr Word8
    -> Int32
    -> Int32
    -> Int32
    -> Ptr ()
    -> IO ()
foreign import ccall "wrapper" wrapAvVideoReceiveFrameCb
    :: AvVideoReceiveFrameCb -> IO (FunPtr AvVideoReceiveFrameCb)

type ConferenceConnectedCb = ToxPtr -> Word32 -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapConferenceConnectedCb
    :: ConferenceConnectedCb -> IO (FunPtr ConferenceConnectedCb)

type ConferenceInviteCb =
    ToxPtr -> Word32 -> CInt -> Ptr Word8 -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapConferenceInviteCb
    :: ConferenceInviteCb -> IO (FunPtr ConferenceInviteCb)

type ConferenceMessageCb =
    ToxPtr -> Word32 -> Word32 -> CInt -> Ptr Word8 -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapConferenceMessageCb
    :: ConferenceMessageCb -> IO (FunPtr ConferenceMessageCb)

type ConferencePeerListChangedCb = ToxPtr -> Word32 -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapConferencePeerListChangedCb
    :: ConferencePeerListChangedCb -> IO (FunPtr ConferencePeerListChangedCb)

type ConferencePeerNameCb =
    ToxPtr -> Word32 -> Word32 -> Ptr Word8 -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapConferencePeerNameCb
    :: ConferencePeerNameCb -> IO (FunPtr ConferencePeerNameCb)

type ConferenceTitleCb =
    ToxPtr -> Word32 -> Word32 -> Ptr Word8 -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapConferenceTitleCb
    :: ConferenceTitleCb -> IO (FunPtr ConferenceTitleCb)

type FileChunkRequestCb =
    ToxPtr -> Word32 -> Word32 -> Word64 -> CSize -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapFileChunkRequestCb
    :: FileChunkRequestCb -> IO (FunPtr FileChunkRequestCb)

type FileRecvCb =
    ToxPtr
    -> Word32
    -> Word32
    -> Word32
    -> Word64
    -> Ptr Word8
    -> Ptr ()
    -> IO ()
foreign import ccall "wrapper" wrapFileRecvCb
    :: FileRecvCb -> IO (FunPtr FileRecvCb)

type FileRecvChunkCb =
    ToxPtr -> Word32 -> Word32 -> Word64 -> Ptr Word8 -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapFileRecvChunkCb
    :: FileRecvChunkCb -> IO (FunPtr FileRecvChunkCb)

type FileRecvControlCb = ToxPtr -> Word32 -> Word32 -> CInt -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapFileRecvControlCb
    :: FileRecvControlCb -> IO (FunPtr FileRecvControlCb)

type FriendConnectionStatusCb = ToxPtr -> Word32 -> CInt -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapFriendConnectionStatusCb
    :: FriendConnectionStatusCb -> IO (FunPtr FriendConnectionStatusCb)

type FriendLosslessPacketCb = ToxPtr -> Word32 -> Ptr Word8 -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapFriendLosslessPacketCb
    :: FriendLosslessPacketCb -> IO (FunPtr FriendLosslessPacketCb)

type FriendLossyPacketCb = ToxPtr -> Word32 -> Ptr Word8 -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapFriendLossyPacketCb
    :: FriendLossyPacketCb -> IO (FunPtr FriendLossyPacketCb)

type FriendMessageCb = ToxPtr -> Word32 -> CInt -> Ptr Word8 -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapFriendMessageCb
    :: FriendMessageCb -> IO (FunPtr FriendMessageCb)

type FriendNameCb = ToxPtr -> Word32 -> Ptr Word8 -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapFriendNameCb
    :: FriendNameCb -> IO (FunPtr FriendNameCb)

type FriendReadReceiptCb = ToxPtr -> Word32 -> Word32 -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapFriendReadReceiptCb
    :: FriendReadReceiptCb -> IO (FunPtr FriendReadReceiptCb)

type FriendRequestCb = ToxPtr -> Ptr Word8 -> Ptr Word8 -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapFriendRequestCb
    :: FriendRequestCb -> IO (FunPtr FriendRequestCb)

type FriendStatusCb = ToxPtr -> Word32 -> CInt -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapFriendStatusCb
    :: FriendStatusCb -> IO (FunPtr FriendStatusCb)

type FriendStatusMessageCb = ToxPtr -> Word32 -> Ptr Word8 -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapFriendStatusMessageCb
    :: FriendStatusMessageCb -> IO (FunPtr FriendStatusMessageCb)

type FriendTypingCb = ToxPtr -> Word32 -> CBool -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapFriendTypingCb
    :: FriendTypingCb -> IO (FunPtr FriendTypingCb)

type GroupCustomPacketCb =
    ToxPtr -> Word32 -> Word32 -> Ptr Word8 -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapGroupCustomPacketCb
    :: GroupCustomPacketCb -> IO (FunPtr GroupCustomPacketCb)

type GroupCustomPrivatePacketCb =
    ToxPtr -> Word32 -> Word32 -> Ptr Word8 -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapGroupCustomPrivatePacketCb
    :: GroupCustomPrivatePacketCb -> IO (FunPtr GroupCustomPrivatePacketCb)

type GroupInviteCb =
    ToxPtr -> Word32 -> Ptr Word8 -> Ptr Word8 -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapGroupInviteCb
    :: GroupInviteCb -> IO (FunPtr GroupInviteCb)

type GroupJoinFailCb = ToxPtr -> Word32 -> CInt -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapGroupJoinFailCb
    :: GroupJoinFailCb -> IO (FunPtr GroupJoinFailCb)

type GroupMessageCb =
    ToxPtr -> Word32 -> Word32 -> CInt -> Ptr Word8 -> Word32 -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapGroupMessageCb
    :: GroupMessageCb -> IO (FunPtr GroupMessageCb)

type GroupModerationCb =
    ToxPtr -> Word32 -> Word32 -> Word32 -> CInt -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapGroupModerationCb
    :: GroupModerationCb -> IO (FunPtr GroupModerationCb)

type GroupPasswordCb = ToxPtr -> Word32 -> Ptr Word8 -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapGroupPasswordCb
    :: GroupPasswordCb -> IO (FunPtr GroupPasswordCb)

type GroupPeerExitCb =
    ToxPtr
    -> Word32
    -> Word32
    -> CInt
    -> Ptr Word8
    -> Ptr Word8
    -> Ptr ()
    -> IO ()
foreign import ccall "wrapper" wrapGroupPeerExitCb
    :: GroupPeerExitCb -> IO (FunPtr GroupPeerExitCb)

type GroupPeerJoinCb = ToxPtr -> Word32 -> Word32 -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapGroupPeerJoinCb
    :: GroupPeerJoinCb -> IO (FunPtr GroupPeerJoinCb)

type GroupPeerLimitCb = ToxPtr -> Word32 -> Word32 -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapGroupPeerLimitCb
    :: GroupPeerLimitCb -> IO (FunPtr GroupPeerLimitCb)

type GroupPeerNameCb =
    ToxPtr -> Word32 -> Word32 -> Ptr Word8 -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapGroupPeerNameCb
    :: GroupPeerNameCb -> IO (FunPtr GroupPeerNameCb)

type GroupPeerStatusCb = ToxPtr -> Word32 -> Word32 -> CInt -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapGroupPeerStatusCb
    :: GroupPeerStatusCb -> IO (FunPtr GroupPeerStatusCb)

type GroupPrivacyStateCb = ToxPtr -> Word32 -> CInt -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapGroupPrivacyStateCb
    :: GroupPrivacyStateCb -> IO (FunPtr GroupPrivacyStateCb)

type GroupPrivateMessageCb =
    ToxPtr -> Word32 -> Word32 -> CInt -> Ptr Word8 -> Word32 -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapGroupPrivateMessageCb
    :: GroupPrivateMessageCb -> IO (FunPtr GroupPrivateMessageCb)

type GroupSelfJoinCb = ToxPtr -> Word32 -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapGroupSelfJoinCb
    :: GroupSelfJoinCb -> IO (FunPtr GroupSelfJoinCb)

type GroupTopicCb = ToxPtr -> Word32 -> Word32 -> Ptr Word8 -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapGroupTopicCb
    :: GroupTopicCb -> IO (FunPtr GroupTopicCb)

type GroupTopicLockCb = ToxPtr -> Word32 -> CInt -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapGroupTopicLockCb
    :: GroupTopicLockCb -> IO (FunPtr GroupTopicLockCb)

type GroupVoiceStateCb = ToxPtr -> Word32 -> CInt -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapGroupVoiceStateCb
    :: GroupVoiceStateCb -> IO (FunPtr GroupVoiceStateCb)

type LogCb =
    ToxPtr -> CInt -> CString -> Word32 -> CString -> CString -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapLogCb :: LogCb -> IO (FunPtr LogCb)

type SelfConnectionStatusCb = ToxPtr -> CInt -> Ptr () -> IO ()
foreign import ccall "wrapper" wrapSelfConnectionStatusCb
    :: SelfConnectionStatusCb -> IO (FunPtr SelfConnectionStatusCb)
