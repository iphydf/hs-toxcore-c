-- | What happened since the last iteration, as Tox records it.
module Network.Tox.C.Events
    ( Event (..)
    , EventSelfConnectionStatus (..)
    , EventFriendRequest (..)
    , EventFriendConnectionStatus (..)
    , EventFriendLossyPacket (..)
    , EventFriendLosslessPacket (..)
    , EventFriendName (..)
    , EventFriendStatus (..)
    , EventFriendStatusMessage (..)
    , EventFriendMessage (..)
    , EventFriendReadReceipt (..)
    , EventFriendTyping (..)
    , EventFileChunkRequest (..)
    , EventFileRecv (..)
    , EventFileRecvChunk (..)
    , EventFileRecvControl (..)
    , EventConferenceInvite (..)
    , EventConferenceConnected (..)
    , EventConferencePeerListChanged (..)
    , EventConferencePeerName (..)
    , EventConferenceTitle (..)
    , EventConferenceMessage (..)
    , EventGroupPeerName (..)
    , EventGroupPeerStatus (..)
    , EventGroupTopic (..)
    , EventGroupPrivacyState (..)
    , EventGroupVoiceState (..)
    , EventGroupTopicLock (..)
    , EventGroupPeerLimit (..)
    , EventGroupPassword (..)
    , EventGroupMessage (..)
    , EventGroupPrivateMessage (..)
    , EventGroupCustomPacket (..)
    , EventGroupCustomPrivatePacket (..)
    , EventGroupInvite (..)
    , EventGroupPeerJoin (..)
    , EventGroupPeerExit (..)
    , EventGroupSelfJoin (..)
    , EventGroupJoinFail (..)
    , EventGroupModeration (..)
    , EventDhtNodesResponse (..)
    , toxEventsIterate
    ) where

import           Control.Exception     (finally)
import           Data.ByteString       (ByteString)
import           Data.Word             (Word32, Word64)
import qualified FFI.Tox.Events        as Raw
import           FFI.Tox.Types         (EventPtr, EventsPtr)
import           Foreign.C.Enum        (callErrFun, fromCEnum)
import           Foreign.Marshal.Utils (toBool)
import           Foreign.Ptr           (nullPtr)
import           Network.Tox.C.Marshal (iterateList, peekFixedBytes,
                                        peekSizedBytes, peekSizedString)
import           Network.Tox.C.Types   (ConferenceNumber (..),
                                        ConferencePeerNumber (..),
                                        ConferenceType, Connection,
                                        ErrEventsIterate, EventType (..),
                                        FileControl, FileKind (..),
                                        FileNumber (..), FriendMessageId (..),
                                        FriendNumber (..), GroupExitType,
                                        GroupJoinFail (..), GroupMessageId (..),
                                        GroupModEvent, GroupNumber (..),
                                        GroupPeerNumber (..),
                                        GroupPrivacyState (..),
                                        GroupTopicLock (..),
                                        GroupVoiceState (..), MessageType,
                                        Port (..), PublicKey, Tox (..),
                                        UserStatus)

-- | An event, by the callback that would have told of it.
data Event
    = SelfConnectionStatus EventSelfConnectionStatus
    | FriendRequest EventFriendRequest
    | FriendConnectionStatus EventFriendConnectionStatus
    | FriendLossyPacket EventFriendLossyPacket
    | FriendLosslessPacket EventFriendLosslessPacket
    | FriendName EventFriendName
    | FriendStatus EventFriendStatus
    | FriendStatusMessage EventFriendStatusMessage
    | FriendMessage EventFriendMessage
    | FriendReadReceipt EventFriendReadReceipt
    | FriendTyping EventFriendTyping
    | FileChunkRequest EventFileChunkRequest
    | FileRecv EventFileRecv
    | FileRecvChunk EventFileRecvChunk
    | FileRecvControl EventFileRecvControl
    | ConferenceInvite EventConferenceInvite
    | ConferenceConnected EventConferenceConnected
    | ConferencePeerListChanged EventConferencePeerListChanged
    | ConferencePeerName EventConferencePeerName
    | ConferenceTitle EventConferenceTitle
    | ConferenceMessage EventConferenceMessage
    | GroupPeerName EventGroupPeerName
    | GroupPeerStatus EventGroupPeerStatus
    | GroupTopic EventGroupTopic
    | GroupPrivacyState EventGroupPrivacyState
    | GroupVoiceState EventGroupVoiceState
    | GroupTopicLock EventGroupTopicLock
    | GroupPeerLimit EventGroupPeerLimit
    | GroupPassword EventGroupPassword
    | GroupMessage EventGroupMessage
    | GroupPrivateMessage EventGroupPrivateMessage
    | GroupCustomPacket EventGroupCustomPacket
    | GroupCustomPrivatePacket EventGroupCustomPrivatePacket
    | GroupInvite EventGroupInvite
    | GroupPeerJoin EventGroupPeerJoin
    | GroupPeerExit EventGroupPeerExit
    | GroupSelfJoin EventGroupSelfJoin
    | GroupJoinFail EventGroupJoinFail
    | GroupModeration EventGroupModeration
    | DhtNodesResponse EventDhtNodesResponse
    deriving (Eq, Show)

-- | Pass NULL to unset.
--
-- This event is triggered whenever there is a change in the DHT connection
-- state. When disconnected, a client may choose to call
-- 'Network.Tox.C.Tox.toxBootstrap' again, to reconnect to the DHT. Note that
-- this state may frequently change for short amounts of time. Clients should
-- therefore not immediately bootstrap on receiving a disconnect.
--
-- TODO(iphydf): how long should a client wait before bootstrapping again?
--
-- * @selfConnectionStatus@: Whether we are connected to the DHT.
data EventSelfConnectionStatus = EventSelfConnectionStatus
    { selfConnectionStatus :: Connection
    }
    deriving (Eq, Show)

-- | Pass NULL to unset.
--
-- This event is triggered when a friend request is received.
--
-- * @friendRequestPublicKey@: The Public Key of the user who sent the friend
--   request.
-- * @friendRequestMessage@: The message they sent along with the request.
data EventFriendRequest = EventFriendRequest
    { friendRequestPublicKey :: PublicKey
    , friendRequestMessage   :: ByteString
    }
    deriving (Eq, Show)

-- | Pass NULL to unset.
--
-- This event is triggered when a friend goes offline after having been
-- online, or when a friend goes online.
--
-- This callback is not called when adding friends. It is assumed that when
-- adding friends, their connection status is initially offline.
--
-- * @friendConnectionStatusFriendNumber@: The friend number of the friend
--   whose connection status changed.
-- * @friendConnectionStatus@: The result of calling
--   'Network.Tox.C.Friend.toxFriendGetConnectionStatus' on the passed
--   friend_number.
data EventFriendConnectionStatus = EventFriendConnectionStatus
    { friendConnectionStatusFriendNumber :: FriendNumber
    , friendConnectionStatus             :: Connection
    }
    deriving (Eq, Show)

-- | Pass NULL to unset.
--
-- tox_callback_friend_lossy_packet is the compatibility function to set the
-- callback for all packet IDs except those reserved for ToxAV.
--
-- * @friendLossyPacketFriendNumber@: The friend number of the friend who sent
--   a lossy packet.
-- * @friendLossyPacketData@: A byte array containing the received packet
--   data.
data EventFriendLossyPacket = EventFriendLossyPacket
    { friendLossyPacketFriendNumber :: FriendNumber
    , friendLossyPacketData         :: ByteString
    }
    deriving (Eq, Show)

-- | Pass NULL to unset.
--
-- * @friendLosslessPacketFriendNumber@: The friend number of the friend who
--   sent the packet.
-- * @friendLosslessPacketData@: A byte array containing the received packet
--   data.
data EventFriendLosslessPacket = EventFriendLosslessPacket
    { friendLosslessPacketFriendNumber :: FriendNumber
    , friendLosslessPacketData         :: ByteString
    }
    deriving (Eq, Show)

-- | Pass NULL to unset.
--
-- This event is triggered when a friend changes their name.
--
-- * @friendNameFriendNumber@: The friend number of the friend whose name
--   changed.
-- * @friendName@: A byte array containing the same data as
--   'Network.Tox.C.Friend.toxFriendGetName' would write to its @name@
--   parameter.
data EventFriendName = EventFriendName
    { friendNameFriendNumber :: FriendNumber
    , friendName             :: ByteString
    }
    deriving (Eq, Show)

-- | Pass NULL to unset.
--
-- This event is triggered when a friend changes their user status.
--
-- * @friendStatusFriendNumber@: The friend number of the friend whose user
--   status changed.
-- * @friendStatus@: The new user status.
data EventFriendStatus = EventFriendStatus
    { friendStatusFriendNumber :: FriendNumber
    , friendStatus             :: UserStatus
    }
    deriving (Eq, Show)

-- | Pass NULL to unset.
--
-- This event is triggered when a friend changes their status message.
--
-- * @friendStatusMessageFriendNumber@: The friend number of the friend whose
--   status message changed.
-- * @friendStatusMessage@: A byte array containing the same data as
--   'Network.Tox.C.Friend.toxFriendGetStatusMessage' would write to its
--   @status_message@ parameter.
data EventFriendStatusMessage = EventFriendStatusMessage
    { friendStatusMessageFriendNumber :: FriendNumber
    , friendStatusMessage             :: ByteString
    }
    deriving (Eq, Show)

-- | Pass NULL to unset.
--
-- This event is triggered when a message from a friend is received.
--
-- * @friendMessageFriendNumber@: The friend number of the friend who sent the
--   message.
-- * @friendMessageType@: The type of the message (normal, action, ...).
-- * @friendMessage@: The message data they sent.
data EventFriendMessage = EventFriendMessage
    { friendMessageFriendNumber :: FriendNumber
    , friendMessageType         :: MessageType
    , friendMessage             :: ByteString
    }
    deriving (Eq, Show)

-- | Pass NULL to unset.
--
-- This event is triggered when the friend receives the message sent with
-- 'Network.Tox.C.Friend.toxFriendSendMessage' with the corresponding message
-- ID.
--
-- * @friendReadReceiptFriendNumber@: The friend number of the friend who
--   received the message.
-- * @friendReadReceiptMessageId@: The message ID as returned from
--   'Network.Tox.C.Friend.toxFriendSendMessage' corresponding to the message
--   sent.
data EventFriendReadReceipt = EventFriendReadReceipt
    { friendReadReceiptFriendNumber :: FriendNumber
    , friendReadReceiptMessageId    :: FriendMessageId
    }
    deriving (Eq, Show)

-- | Pass NULL to unset.
--
-- This event is triggered when a friend starts or stops typing.
--
-- * @friendTypingFriendNumber@: The friend number of the friend who started
--   or stopped typing.
-- * @friendTyping@: The result of calling
--   'Network.Tox.C.Friend.toxFriendGetTyping' on the passed friend_number.
data EventFriendTyping = EventFriendTyping
    { friendTypingFriendNumber :: FriendNumber
    , friendTyping             :: Bool
    }
    deriving (Eq, Show)

-- | Pass NULL to unset.
--
-- This event is triggered when Tox is ready to send more file data.
--
-- If the length parameter is 0, the file transfer is finished, and the
-- client's resources associated with the file number should be released.
-- After a call with zero length, the file number can be reused for future
-- file transfers.
--
-- If the requested position is not equal to the client's idea of the current
-- file or stream position, it will need to seek. In case of read-once
-- streams, the client should keep the last read chunk so that a seek back can
-- be supported. A seek-back only ever needs to read from the last requested
-- chunk. This happens when a chunk was requested, but the send failed. A
-- seek-back request can occur an arbitrary number of times for any given
-- chunk.
--
-- In response to receiving this callback, the client should call the function
-- 'Network.Tox.C.File.toxFileSendChunk' with the requested chunk. If the
-- number of bytes sent through that function is zero, the file transfer is
-- assumed complete. A client must send the full length of data requested with
-- this callback.
--
-- * @fileChunkRequestFriendNumber@: The friend number of the receiving friend
--   for this file.
-- * @fileChunkRequestFileNumber@: The file transfer identifier returned by
--   'Network.Tox.C.File.toxFileSend'.
-- * @fileChunkRequestPosition@: The file or stream position from which to
--   continue reading.
-- * @fileChunkRequestLength@: The number of bytes requested for the current
--   chunk.
data EventFileChunkRequest = EventFileChunkRequest
    { fileChunkRequestFriendNumber :: FriendNumber
    , fileChunkRequestFileNumber   :: FileNumber
    , fileChunkRequestPosition     :: Word64
    , fileChunkRequestLength       :: Int
    }
    deriving (Eq, Show)

-- | Pass NULL to unset.
--
-- This event is triggered when a file transfer request is received.
--
-- The client should acquire resources to be associated with the file
-- transfer. Incoming file transfers start in the PAUSED state. After this
-- callback returns, a transfer can be rejected by sending a
-- TOX_FILE_CONTROL_CANCEL control command before any other control commands.
-- It can be accepted by sending TOX_FILE_CONTROL_RESUME.
--
-- * @fileRecvFriendNumber@: The friend number of the friend who is sending
--   the file transfer request.
-- * @fileRecvFileNumber@: The friend-specific file number the data received
--   is associated with.
-- * @fileRecvKind@: The meaning of the file that was sent.
-- * @fileRecvFileSize@: Size in bytes of the file the client wants to send,
--   UINT64_MAX if unknown or streaming.
-- * @fileRecvFilename@: Name of the file. Does not need to be the actual
--   name. This name will be sent along with the file send request.
data EventFileRecv = EventFileRecv
    { fileRecvFriendNumber :: FriendNumber
    , fileRecvFileNumber   :: FileNumber
    , fileRecvKind         :: FileKind
    , fileRecvFileSize     :: Word64
    , fileRecvFilename     :: ByteString
    }
    deriving (Eq, Show)

-- | Pass NULL to unset.
--
-- This event is first triggered when a file transfer request is received, and
-- subsequently when a chunk of file data for an accepted request was
-- received.
--
-- When length is 0, the transfer is finished and the client should release
-- the resources it acquired for the transfer. After a call with length = 0,
-- the file number can be reused for new file transfers.
--
-- If position is equal to file_size (received in the file_receive callback)
-- when the transfer finishes, the file was received completely. Otherwise, if
-- file_size was UINT64_MAX, streaming ended successfully when length is 0.
--
-- * @fileRecvChunkFriendNumber@: The friend number of the friend who is
--   sending the file.
-- * @fileRecvChunkFileNumber@: The friend-specific file number the data
--   received is associated with.
-- * @fileRecvChunkPosition@: The file position of the first byte in data.
-- * @fileRecvChunkData@: A byte array containing the received chunk.
data EventFileRecvChunk = EventFileRecvChunk
    { fileRecvChunkFriendNumber :: FriendNumber
    , fileRecvChunkFileNumber   :: FileNumber
    , fileRecvChunkPosition     :: Word64
    , fileRecvChunkData         :: ByteString
    }
    deriving (Eq, Show)

-- | Pass NULL to unset.
--
-- This event is triggered when a file control command is received from a
-- friend.
--
-- When receiving TOX_FILE_CONTROL_CANCEL, the client should release the
-- resources associated with the file number and consider the transfer failed.
--
-- * @fileRecvControlFriendNumber@: The friend number of the friend who is
--   sending the file.
-- * @fileRecvControlFileNumber@: The friend-specific file number the data
--   received is associated with.
-- * @fileRecvControl@: The file control command received.
data EventFileRecvControl = EventFileRecvControl
    { fileRecvControlFriendNumber :: FriendNumber
    , fileRecvControlFileNumber   :: FileNumber
    , fileRecvControl             :: FileControl
    }
    deriving (Eq, Show)

-- | Pass NULL to unset.
--
-- This event is triggered when the client is invited to join a conference.
--
-- The invitation will remain valid until the inviting friend goes offline or
-- exits the conference.
--
-- * @conferenceInviteFriendNumber@: The friend who invited us.
-- * @conferenceInviteType@: The conference type (text only or audio\/video).
-- * @conferenceInviteCookie@: A piece of data of variable length required to
--   join the conference.
data EventConferenceInvite = EventConferenceInvite
    { conferenceInviteFriendNumber :: FriendNumber
    , conferenceInviteType         :: ConferenceType
    , conferenceInviteCookie       :: ByteString
    }
    deriving (Eq, Show)

-- | Pass NULL to unset.
--
-- This event is triggered when the client successfully connects to a
-- conference after joining it with the
-- 'Network.Tox.C.Conference.toxConferenceJoin' function.
--
-- * @conferenceConnectedConferenceNumber@: The conference number of the
--   conference to which we have connected.
data EventConferenceConnected = EventConferenceConnected
    { conferenceConnectedConferenceNumber :: ConferenceNumber
    }
    deriving (Eq, Show)

-- | Pass NULL to unset.
--
-- This event is triggered when a peer joins or leaves the conference.
--
-- * @conferencePeerListChangedConferenceNumber@: The conference number of the
--   conference the peer is in.
data EventConferencePeerListChanged = EventConferencePeerListChanged
    { conferencePeerListChangedConferenceNumber :: ConferenceNumber
    }
    deriving (Eq, Show)

-- | Pass NULL to unset.
--
-- This event is triggered when a peer changes their name.
--
-- * @conferencePeerNameConferenceNumber@: The conference number of the
--   conference the peer is in.
-- * @conferencePeerNamePeerNumber@: The ID of the peer who changed their
--   nickname.
-- * @conferencePeerName@: A byte array containing the new nickname.
data EventConferencePeerName = EventConferencePeerName
    { conferencePeerNameConferenceNumber :: ConferenceNumber
    , conferencePeerNamePeerNumber       :: ConferencePeerNumber
    , conferencePeerName                 :: ByteString
    }
    deriving (Eq, Show)

-- | Pass NULL to unset.
--
-- This event is triggered when a peer changes the conference title.
--
-- If peer_number == UINT32_MAX, then author is unknown (e.g. initial joining
-- the conference).
--
-- * @conferenceTitleConferenceNumber@: The conference number of the
--   conference the title change is intended for.
-- * @conferenceTitlePeerNumber@: The ID of the peer who changed the title.
-- * @conferenceTitle@: The title data.
data EventConferenceTitle = EventConferenceTitle
    { conferenceTitleConferenceNumber :: ConferenceNumber
    , conferenceTitlePeerNumber       :: ConferencePeerNumber
    , conferenceTitle                 :: ByteString
    }
    deriving (Eq, Show)

-- | Pass NULL to unset.
--
-- This event is triggered when the client receives a conference message.
--
-- * @conferenceMessageConferenceNumber@: The conference number of the
--   conference the message is intended for.
-- * @conferenceMessagePeerNumber@: The ID of the peer who sent the message.
-- * @conferenceMessageType@: The type of message (normal, action, ...).
-- * @conferenceMessage@: The message data.
data EventConferenceMessage = EventConferenceMessage
    { conferenceMessageConferenceNumber :: ConferenceNumber
    , conferenceMessagePeerNumber       :: ConferencePeerNumber
    , conferenceMessageType             :: MessageType
    , conferenceMessage                 :: ByteString
    }
    deriving (Eq, Show)

-- | This event is triggered when a peer changes their nickname.
--
-- * @groupPeerNameGroupNumber@: The group number of the group the name change
--   is intended for.
-- * @groupPeerNamePeerId@: The ID of the peer who has changed their name.
-- * @groupPeerName@: The name data.
data EventGroupPeerName = EventGroupPeerName
    { groupPeerNameGroupNumber :: GroupNumber
    , groupPeerNamePeerId      :: GroupPeerNumber
    , groupPeerName            :: ByteString
    }
    deriving (Eq, Show)

-- | This event is triggered when a peer changes their status.
--
-- * @groupPeerStatusGroupNumber@: The group number of the group the status
--   change is intended for.
-- * @groupPeerStatusPeerId@: The ID of the peer who has changed their status.
-- * @groupPeerStatus@: The new status of the peer.
data EventGroupPeerStatus = EventGroupPeerStatus
    { groupPeerStatusGroupNumber :: GroupNumber
    , groupPeerStatusPeerId      :: GroupPeerNumber
    , groupPeerStatus            :: UserStatus
    }
    deriving (Eq, Show)

-- | This event is triggered when a peer changes the group topic.
--
-- * @groupTopicGroupNumber@: The group number of the group the topic change
--   is intended for.
-- * @groupTopicPeerId@: The ID of the peer who changed the topic. If the peer
--   who set the topic is not present in our peer list this value will be set
--   to 0.
-- * @groupTopic@: The topic data.
data EventGroupTopic = EventGroupTopic
    { groupTopicGroupNumber :: GroupNumber
    , groupTopicPeerId      :: GroupPeerNumber
    , groupTopic            :: ByteString
    }
    deriving (Eq, Show)

-- | This event is triggered when the group founder changes the privacy state.
--
-- * @groupPrivacyStateGroupNumber@: The group number of the group the privacy
--   state is intended for.
-- * @groupPrivacyState@: The new privacy state.
data EventGroupPrivacyState = EventGroupPrivacyState
    { groupPrivacyStateGroupNumber :: GroupNumber
    , groupPrivacyState            :: GroupPrivacyState
    }
    deriving (Eq, Show)

-- | This event is triggered when the group founder changes the voice state.
--
-- * @groupVoiceStateGroupNumber@: The group number of the group the voice
--   state change is intended for.
-- * @groupVoiceState@: The new voice state.
data EventGroupVoiceState = EventGroupVoiceState
    { groupVoiceStateGroupNumber :: GroupNumber
    , groupVoiceState            :: GroupVoiceState
    }
    deriving (Eq, Show)

-- | This event is triggered when the group founder changes the topic lock
-- status.
--
-- * @groupTopicLockGroupNumber@: The group number of the group for which the
--   topic lock has changed.
-- * @groupTopicLock@: The new topic lock state.
data EventGroupTopicLock = EventGroupTopicLock
    { groupTopicLockGroupNumber :: GroupNumber
    , groupTopicLock            :: GroupTopicLock
    }
    deriving (Eq, Show)

-- | This event is triggered when the group founder changes the maximum peer
-- limit.
--
-- * @groupPeerLimitGroupNumber@: The group number of the group for which the
--   peer limit has changed.
-- * @groupPeerLimit@: The new peer limit for the group.
data EventGroupPeerLimit = EventGroupPeerLimit
    { groupPeerLimitGroupNumber :: GroupNumber
    , groupPeerLimit            :: Word32
    }
    deriving (Eq, Show)

-- | This event is triggered when the group founder changes the group password.
--
-- * @groupPasswordGroupNumber@: The group number of the group for which the
--   password has changed.
-- * @groupPassword@: The new group password.
data EventGroupPassword = EventGroupPassword
    { groupPasswordGroupNumber :: GroupNumber
    , groupPassword            :: ByteString
    }
    deriving (Eq, Show)

-- | This event is triggered when the client receives a group message.
--
-- * @groupMessageGroupNumber@: The group number of the group the message is
--   intended for.
-- * @groupMessagePeerId@: The ID of the peer who sent the message.
-- * @groupMessageMessageType@: The type of message (normal, action, ...).
-- * @groupMessage@: The message data.
-- * @groupMessageMessageId@: A pseudo message id that clients can use to
--   uniquely identify this group message.
data EventGroupMessage = EventGroupMessage
    { groupMessageGroupNumber :: GroupNumber
    , groupMessagePeerId      :: GroupPeerNumber
    , groupMessageMessageType :: MessageType
    , groupMessage            :: ByteString
    , groupMessageMessageId   :: GroupMessageId
    }
    deriving (Eq, Show)

-- | This event is triggered when the client receives a private message.
--
-- * @groupPrivateMessageGroupNumber@: The group number of the group the
--   private message is intended for.
-- * @groupPrivateMessagePeerId@: The ID of the peer who sent the private
--   message.
-- * @groupPrivateMessageMessageType@: The type of message (normal, action,
--   ...).
-- * @groupPrivateMessage@: The message data.
-- * @groupPrivateMessageMessageId@: A pseudo message id that clients can use
--   to uniquely identify this group message.
data EventGroupPrivateMessage = EventGroupPrivateMessage
    { groupPrivateMessageGroupNumber :: GroupNumber
    , groupPrivateMessagePeerId      :: GroupPeerNumber
    , groupPrivateMessageMessageType :: MessageType
    , groupPrivateMessage            :: ByteString
    , groupPrivateMessageMessageId   :: GroupMessageId
    }
    deriving (Eq, Show)

-- | This event is triggered when the client receives a custom packet.
--
-- * @groupCustomPacketGroupNumber@: The group number of the group the packet
--   is intended for.
-- * @groupCustomPacketPeerId@: The ID of the peer who sent the packet.
-- * @groupCustomPacketData@: The packet data.
data EventGroupCustomPacket = EventGroupCustomPacket
    { groupCustomPacketGroupNumber :: GroupNumber
    , groupCustomPacketPeerId      :: GroupPeerNumber
    , groupCustomPacketData        :: ByteString
    }
    deriving (Eq, Show)

-- | This event is triggered when the client receives a custom private packet.
--
-- * @groupCustomPrivatePacketGroupNumber@: The group number of the group the
--   packet is intended for.
-- * @groupCustomPrivatePacketPeerId@: The ID of the peer who sent the packet.
-- * @groupCustomPrivatePacketData@: The packet data.
data EventGroupCustomPrivatePacket = EventGroupCustomPrivatePacket
    { groupCustomPrivatePacketGroupNumber :: GroupNumber
    , groupCustomPrivatePacketPeerId      :: GroupPeerNumber
    , groupCustomPrivatePacketData        :: ByteString
    }
    deriving (Eq, Show)

-- | This event is triggered when the client receives a group invite from a
-- friend. The client must store invite_data which is used to join the group
-- via 'Network.Tox.C.Group.toxGroupInviteAccept'.
--
-- * @groupInviteFriendNumber@: The friend number of the contact who sent the
--   invite.
-- * @groupInviteInviteData@: The invite data.
-- * @groupInviteGroupName@: The name of the group. In conferences, this is
--   "title".
data EventGroupInvite = EventGroupInvite
    { groupInviteFriendNumber :: FriendNumber
    , groupInviteInviteData   :: ByteString
    , groupInviteGroupName    :: ByteString
    }
    deriving (Eq, Show)

-- | This event is triggered when a peer other than self joins the group.
--
-- * @groupPeerJoinGroupNumber@: The group number of the group in which a new
--   peer has joined.
-- * @groupPeerJoinPeerId@: The permanent ID of the new peer. This id should
--   not be relied on for client behaviour and should be treated as a random
--   value.
data EventGroupPeerJoin = EventGroupPeerJoin
    { groupPeerJoinGroupNumber :: GroupNumber
    , groupPeerJoinPeerId      :: GroupPeerNumber
    }
    deriving (Eq, Show)

-- | This event is triggered when a peer other than self exits the group.
--
-- * @groupPeerExitGroupNumber@: The group number of the group in which a peer
--   has left.
-- * @groupPeerExitPeerId@: The ID of the peer who left the group. This ID no
--   longer designates a valid peer and cannot be used for API calls.
-- * @groupPeerExitExitType@: The type of exit event. One of
--   Tox_Group_Exit_Type.
-- * @groupPeerExitName@: The nickname of the peer who left the group.
-- * @groupPeerExitPartMessage@: The parting message data.
data EventGroupPeerExit = EventGroupPeerExit
    { groupPeerExitGroupNumber :: GroupNumber
    , groupPeerExitPeerId      :: GroupPeerNumber
    , groupPeerExitExitType    :: GroupExitType
    , groupPeerExitName        :: ByteString
    , groupPeerExitPartMessage :: ByteString
    }
    deriving (Eq, Show)

-- | This event is triggered when the client has successfully joined a group.
-- Use this to initialize any group information the client may need.
--
-- * @groupSelfJoinGroupNumber@: The group number of the group that the client
--   has joined.
data EventGroupSelfJoin = EventGroupSelfJoin
    { groupSelfJoinGroupNumber :: GroupNumber
    }
    deriving (Eq, Show)

-- | This event is triggered when the client fails to join a group.
--
-- * @groupJoinFailGroupNumber@: The group number of the group for which the
--   join has failed.
-- * @groupJoinFailFailType@: The type of group rejection.
data EventGroupJoinFail = EventGroupJoinFail
    { groupJoinFailGroupNumber :: GroupNumber
    , groupJoinFailFailType    :: GroupJoinFail
    }
    deriving (Eq, Show)

-- | This event is triggered when a moderator or founder executes a moderation
-- event, with the exception of the peer who initiates the event. It is also
-- triggered when the observer and moderator lists are silently modified (this
-- may occur during group syncing).
--
-- If either peer id does not designate a valid peer in the group chat, the
-- client should manually update all peer roles.
--
-- * @groupModerationGroupNumber@: The group number of the group the event is
--   intended for.
-- * @groupModerationSourcePeerId@: The ID of the peer who initiated the
--   event.
-- * @groupModerationTargetPeerId@: The ID of the peer who is the target of
--   the event.
-- * @groupModerationModType@: The type of event.
data EventGroupModeration = EventGroupModeration
    { groupModerationGroupNumber  :: GroupNumber
    , groupModerationSourcePeerId :: GroupPeerNumber
    , groupModerationTargetPeerId :: GroupPeerNumber
    , groupModerationModType      :: GroupModEvent
    }
    deriving (Eq, Show)

data EventDhtNodesResponse = EventDhtNodesResponse
    { dhtNodesResponsePublicKey :: PublicKey
    , dhtNodesResponseIp        :: String
    , dhtNodesResponsePort      :: Port
    }
    deriving (Eq, Show)

-- | Run a single @tox_iterate@ iteration and record all the events.
--
-- If allocation of the top level events object fails, this returns NULL.
-- Otherwise it returns an object with the recorded events in it. If an
-- allocation fails while recording events, some events may be dropped.
--
-- If @fail_hard@ in @options@ is @true@, any failure will result in NULL, so
-- all recorded events will be dropped.
--
-- The result must be freed using @tox_events_free@.
toxEventsIterate :: Tox -> IO (Either ErrEventsIterate [Event])
toxEventsIterate (Tox tox) =
    callErrFun (Raw.tox_events_iterate tox nullPtr) >>= traverse peekEvents

-- | The events in a batch, which this frees.
peekEvents :: EventsPtr -> IO [Event]
peekEvents events =
    finally
        (iterateList Raw.tox_events_get_size Raw.tox_events_get events
            >>= mapM peekEvent)
        (Raw.tox_events_free events)

peekEvent :: EventPtr -> IO Event
peekEvent event = do
    eventType <- fromCEnum <$> Raw.tox_event_get_type event
    case eventType of
        EventTypeSelfConnectionStatus ->
            SelfConnectionStatus <$> peekSelfConnectionStatus event
        EventTypeFriendRequest -> FriendRequest <$> peekFriendRequest event
        EventTypeFriendConnectionStatus ->
            FriendConnectionStatus <$> peekFriendConnectionStatus event
        EventTypeFriendLossyPacket ->
            FriendLossyPacket <$> peekFriendLossyPacket event
        EventTypeFriendLosslessPacket ->
            FriendLosslessPacket <$> peekFriendLosslessPacket event
        EventTypeFriendName -> FriendName <$> peekFriendName event
        EventTypeFriendStatus -> FriendStatus <$> peekFriendStatus event
        EventTypeFriendStatusMessage ->
            FriendStatusMessage <$> peekFriendStatusMessage event
        EventTypeFriendMessage -> FriendMessage <$> peekFriendMessage event
        EventTypeFriendReadReceipt ->
            FriendReadReceipt <$> peekFriendReadReceipt event
        EventTypeFriendTyping -> FriendTyping <$> peekFriendTyping event
        EventTypeFileChunkRequest ->
            FileChunkRequest <$> peekFileChunkRequest event
        EventTypeFileRecv -> FileRecv <$> peekFileRecv event
        EventTypeFileRecvChunk -> FileRecvChunk <$> peekFileRecvChunk event
        EventTypeFileRecvControl ->
            FileRecvControl <$> peekFileRecvControl event
        EventTypeConferenceInvite ->
            ConferenceInvite <$> peekConferenceInvite event
        EventTypeConferenceConnected ->
            ConferenceConnected <$> peekConferenceConnected event
        EventTypeConferencePeerListChanged ->
            ConferencePeerListChanged <$> peekConferencePeerListChanged event
        EventTypeConferencePeerName ->
            ConferencePeerName <$> peekConferencePeerName event
        EventTypeConferenceTitle ->
            ConferenceTitle <$> peekConferenceTitle event
        EventTypeConferenceMessage ->
            ConferenceMessage <$> peekConferenceMessage event
        EventTypeGroupPeerName -> GroupPeerName <$> peekGroupPeerName event
        EventTypeGroupPeerStatus ->
            GroupPeerStatus <$> peekGroupPeerStatus event
        EventTypeGroupTopic -> GroupTopic <$> peekGroupTopic event
        EventTypeGroupPrivacyState ->
            GroupPrivacyState <$> peekGroupPrivacyState event
        EventTypeGroupVoiceState ->
            GroupVoiceState <$> peekGroupVoiceState event
        EventTypeGroupTopicLock -> GroupTopicLock <$> peekGroupTopicLock event
        EventTypeGroupPeerLimit -> GroupPeerLimit <$> peekGroupPeerLimit event
        EventTypeGroupPassword -> GroupPassword <$> peekGroupPassword event
        EventTypeGroupMessage -> GroupMessage <$> peekGroupMessage event
        EventTypeGroupPrivateMessage ->
            GroupPrivateMessage <$> peekGroupPrivateMessage event
        EventTypeGroupCustomPacket ->
            GroupCustomPacket <$> peekGroupCustomPacket event
        EventTypeGroupCustomPrivatePacket ->
            GroupCustomPrivatePacket <$> peekGroupCustomPrivatePacket event
        EventTypeGroupInvite -> GroupInvite <$> peekGroupInvite event
        EventTypeGroupPeerJoin -> GroupPeerJoin <$> peekGroupPeerJoin event
        EventTypeGroupPeerExit -> GroupPeerExit <$> peekGroupPeerExit event
        EventTypeGroupSelfJoin -> GroupSelfJoin <$> peekGroupSelfJoin event
        EventTypeGroupJoinFail -> GroupJoinFail <$> peekGroupJoinFail event
        EventTypeGroupModeration ->
            GroupModeration <$> peekGroupModeration event
        EventTypeDhtNodesResponse ->
            DhtNodesResponse <$> peekDhtNodesResponse event
        _ -> ioError $ userError "an event of a type the bindings don't know"

peekSelfConnectionStatus :: EventPtr -> IO EventSelfConnectionStatus
peekSelfConnectionStatus event = do
    ptr <- Raw.tox_event_get_self_connection_status event
    EventSelfConnectionStatus
        <$> (fromCEnum
            <$> Raw.tox_event_self_connection_status_get_connection_status ptr)

peekFriendRequest :: EventPtr -> IO EventFriendRequest
peekFriendRequest event = do
    ptr <- Raw.tox_event_get_friend_request event
    EventFriendRequest
        <$> (Raw.tox_event_friend_request_get_public_key ptr >>= peekFixedBytes)
        <*> peekSizedBytes
                (Raw.tox_event_friend_request_get_message ptr)
                (Raw.tox_event_friend_request_get_message_length ptr)

peekFriendConnectionStatus :: EventPtr -> IO EventFriendConnectionStatus
peekFriendConnectionStatus event = do
    ptr <- Raw.tox_event_get_friend_connection_status event
    EventFriendConnectionStatus
        <$> (FriendNumber
                <$> Raw.tox_event_friend_connection_status_get_friend_number
                    ptr)
        <*> (fromCEnum
                <$> Raw.tox_event_friend_connection_status_get_connection_status
                    ptr)

peekFriendLossyPacket :: EventPtr -> IO EventFriendLossyPacket
peekFriendLossyPacket event = do
    ptr <- Raw.tox_event_get_friend_lossy_packet event
    EventFriendLossyPacket
        <$> (FriendNumber
                <$> Raw.tox_event_friend_lossy_packet_get_friend_number ptr)
        <*> peekSizedBytes
                (Raw.tox_event_friend_lossy_packet_get_data ptr)
                (Raw.tox_event_friend_lossy_packet_get_data_length ptr)

peekFriendLosslessPacket :: EventPtr -> IO EventFriendLosslessPacket
peekFriendLosslessPacket event = do
    ptr <- Raw.tox_event_get_friend_lossless_packet event
    EventFriendLosslessPacket
        <$> (FriendNumber
                <$> Raw.tox_event_friend_lossless_packet_get_friend_number ptr)
        <*> peekSizedBytes
                (Raw.tox_event_friend_lossless_packet_get_data ptr)
                (Raw.tox_event_friend_lossless_packet_get_data_length ptr)

peekFriendName :: EventPtr -> IO EventFriendName
peekFriendName event = do
    ptr <- Raw.tox_event_get_friend_name event
    EventFriendName
        <$> (FriendNumber <$> Raw.tox_event_friend_name_get_friend_number ptr)
        <*> peekSizedBytes
                (Raw.tox_event_friend_name_get_name ptr)
                (Raw.tox_event_friend_name_get_name_length ptr)

peekFriendStatus :: EventPtr -> IO EventFriendStatus
peekFriendStatus event = do
    ptr <- Raw.tox_event_get_friend_status event
    EventFriendStatus
        <$> (FriendNumber <$> Raw.tox_event_friend_status_get_friend_number ptr)
        <*> (fromCEnum <$> Raw.tox_event_friend_status_get_status ptr)

peekFriendStatusMessage :: EventPtr -> IO EventFriendStatusMessage
peekFriendStatusMessage event = do
    ptr <- Raw.tox_event_get_friend_status_message event
    EventFriendStatusMessage
        <$> (FriendNumber
                <$> Raw.tox_event_friend_status_message_get_friend_number ptr)
        <*> peekSizedBytes
                (Raw.tox_event_friend_status_message_get_message ptr)
                (Raw.tox_event_friend_status_message_get_message_length ptr)

peekFriendMessage :: EventPtr -> IO EventFriendMessage
peekFriendMessage event = do
    ptr <- Raw.tox_event_get_friend_message event
    EventFriendMessage
        <$> (FriendNumber
                <$> Raw.tox_event_friend_message_get_friend_number ptr)
        <*> (fromCEnum <$> Raw.tox_event_friend_message_get_type ptr)
        <*> peekSizedBytes
                (Raw.tox_event_friend_message_get_message ptr)
                (Raw.tox_event_friend_message_get_message_length ptr)

peekFriendReadReceipt :: EventPtr -> IO EventFriendReadReceipt
peekFriendReadReceipt event = do
    ptr <- Raw.tox_event_get_friend_read_receipt event
    EventFriendReadReceipt
        <$> (FriendNumber
                <$> Raw.tox_event_friend_read_receipt_get_friend_number ptr)
        <*> (FriendMessageId
                <$> Raw.tox_event_friend_read_receipt_get_message_id ptr)

peekFriendTyping :: EventPtr -> IO EventFriendTyping
peekFriendTyping event = do
    ptr <- Raw.tox_event_get_friend_typing event
    EventFriendTyping
        <$> (FriendNumber <$> Raw.tox_event_friend_typing_get_friend_number ptr)
        <*> (toBool <$> Raw.tox_event_friend_typing_get_typing ptr)

peekFileChunkRequest :: EventPtr -> IO EventFileChunkRequest
peekFileChunkRequest event = do
    ptr <- Raw.tox_event_get_file_chunk_request event
    EventFileChunkRequest
        <$> (FriendNumber
                <$> Raw.tox_event_file_chunk_request_get_friend_number ptr)
        <*> (FileNumber
                <$> Raw.tox_event_file_chunk_request_get_file_number ptr)
        <*> Raw.tox_event_file_chunk_request_get_position ptr
        <*> (fromIntegral <$> Raw.tox_event_file_chunk_request_get_length ptr)

peekFileRecv :: EventPtr -> IO EventFileRecv
peekFileRecv event = do
    ptr <- Raw.tox_event_get_file_recv event
    EventFileRecv
        <$> (FriendNumber <$> Raw.tox_event_file_recv_get_friend_number ptr)
        <*> (FileNumber <$> Raw.tox_event_file_recv_get_file_number ptr)
        <*> (FileKind <$> Raw.tox_event_file_recv_get_kind ptr)
        <*> Raw.tox_event_file_recv_get_file_size ptr
        <*> peekSizedBytes
                (Raw.tox_event_file_recv_get_filename ptr)
                (Raw.tox_event_file_recv_get_filename_length ptr)

peekFileRecvChunk :: EventPtr -> IO EventFileRecvChunk
peekFileRecvChunk event = do
    ptr <- Raw.tox_event_get_file_recv_chunk event
    EventFileRecvChunk
        <$> (FriendNumber
                <$> Raw.tox_event_file_recv_chunk_get_friend_number ptr)
        <*> (FileNumber <$> Raw.tox_event_file_recv_chunk_get_file_number ptr)
        <*> Raw.tox_event_file_recv_chunk_get_position ptr
        <*> peekSizedBytes
                (Raw.tox_event_file_recv_chunk_get_data ptr)
                (Raw.tox_event_file_recv_chunk_get_data_length ptr)

peekFileRecvControl :: EventPtr -> IO EventFileRecvControl
peekFileRecvControl event = do
    ptr <- Raw.tox_event_get_file_recv_control event
    EventFileRecvControl
        <$> (FriendNumber
                <$> Raw.tox_event_file_recv_control_get_friend_number ptr)
        <*> (FileNumber <$> Raw.tox_event_file_recv_control_get_file_number ptr)
        <*> (fromCEnum <$> Raw.tox_event_file_recv_control_get_control ptr)

peekConferenceInvite :: EventPtr -> IO EventConferenceInvite
peekConferenceInvite event = do
    ptr <- Raw.tox_event_get_conference_invite event
    EventConferenceInvite
        <$> (FriendNumber
                <$> Raw.tox_event_conference_invite_get_friend_number ptr)
        <*> (fromCEnum <$> Raw.tox_event_conference_invite_get_type ptr)
        <*> peekSizedBytes
                (Raw.tox_event_conference_invite_get_cookie ptr)
                (Raw.tox_event_conference_invite_get_cookie_length ptr)

peekConferenceConnected :: EventPtr -> IO EventConferenceConnected
peekConferenceConnected event = do
    ptr <- Raw.tox_event_get_conference_connected event
    EventConferenceConnected
        <$> (ConferenceNumber
            <$> Raw.tox_event_conference_connected_get_conference_number ptr)

peekConferencePeerListChanged :: EventPtr -> IO EventConferencePeerListChanged
peekConferencePeerListChanged event = do
    ptr <- Raw.tox_event_get_conference_peer_list_changed event
    EventConferencePeerListChanged
        <$> (ConferenceNumber
            <$> Raw.tox_event_conference_peer_list_changed_get_conference_number
                ptr)

peekConferencePeerName :: EventPtr -> IO EventConferencePeerName
peekConferencePeerName event = do
    ptr <- Raw.tox_event_get_conference_peer_name event
    EventConferencePeerName
        <$> (ConferenceNumber
                <$> Raw.tox_event_conference_peer_name_get_conference_number
                    ptr)
        <*> (ConferencePeerNumber
                <$> Raw.tox_event_conference_peer_name_get_peer_number ptr)
        <*> peekSizedBytes
                (Raw.tox_event_conference_peer_name_get_name ptr)
                (Raw.tox_event_conference_peer_name_get_name_length ptr)

peekConferenceTitle :: EventPtr -> IO EventConferenceTitle
peekConferenceTitle event = do
    ptr <- Raw.tox_event_get_conference_title event
    EventConferenceTitle
        <$> (ConferenceNumber
                <$> Raw.tox_event_conference_title_get_conference_number ptr)
        <*> (ConferencePeerNumber
                <$> Raw.tox_event_conference_title_get_peer_number ptr)
        <*> peekSizedBytes
                (Raw.tox_event_conference_title_get_title ptr)
                (Raw.tox_event_conference_title_get_title_length ptr)

peekConferenceMessage :: EventPtr -> IO EventConferenceMessage
peekConferenceMessage event = do
    ptr <- Raw.tox_event_get_conference_message event
    EventConferenceMessage
        <$> (ConferenceNumber
                <$> Raw.tox_event_conference_message_get_conference_number ptr)
        <*> (ConferencePeerNumber
                <$> Raw.tox_event_conference_message_get_peer_number ptr)
        <*> (fromCEnum <$> Raw.tox_event_conference_message_get_type ptr)
        <*> peekSizedBytes
                (Raw.tox_event_conference_message_get_message ptr)
                (Raw.tox_event_conference_message_get_message_length ptr)

peekGroupPeerName :: EventPtr -> IO EventGroupPeerName
peekGroupPeerName event = do
    ptr <- Raw.tox_event_get_group_peer_name event
    EventGroupPeerName
        <$> (GroupNumber <$> Raw.tox_event_group_peer_name_get_group_number ptr)
        <*> (GroupPeerNumber <$> Raw.tox_event_group_peer_name_get_peer_id ptr)
        <*> peekSizedBytes
                (Raw.tox_event_group_peer_name_get_name ptr)
                (Raw.tox_event_group_peer_name_get_name_length ptr)

peekGroupPeerStatus :: EventPtr -> IO EventGroupPeerStatus
peekGroupPeerStatus event = do
    ptr <- Raw.tox_event_get_group_peer_status event
    EventGroupPeerStatus
        <$> (GroupNumber
                <$> Raw.tox_event_group_peer_status_get_group_number ptr)
        <*> (GroupPeerNumber
                <$> Raw.tox_event_group_peer_status_get_peer_id ptr)
        <*> (fromCEnum <$> Raw.tox_event_group_peer_status_get_status ptr)

peekGroupTopic :: EventPtr -> IO EventGroupTopic
peekGroupTopic event = do
    ptr <- Raw.tox_event_get_group_topic event
    EventGroupTopic
        <$> (GroupNumber <$> Raw.tox_event_group_topic_get_group_number ptr)
        <*> (GroupPeerNumber <$> Raw.tox_event_group_topic_get_peer_id ptr)
        <*> peekSizedBytes
                (Raw.tox_event_group_topic_get_topic ptr)
                (Raw.tox_event_group_topic_get_topic_length ptr)

peekGroupPrivacyState :: EventPtr -> IO EventGroupPrivacyState
peekGroupPrivacyState event = do
    ptr <- Raw.tox_event_get_group_privacy_state event
    EventGroupPrivacyState
        <$> (GroupNumber
                <$> Raw.tox_event_group_privacy_state_get_group_number ptr)
        <*> (fromCEnum
                <$> Raw.tox_event_group_privacy_state_get_privacy_state ptr)

peekGroupVoiceState :: EventPtr -> IO EventGroupVoiceState
peekGroupVoiceState event = do
    ptr <- Raw.tox_event_get_group_voice_state event
    EventGroupVoiceState
        <$> (GroupNumber
                <$> Raw.tox_event_group_voice_state_get_group_number ptr)
        <*> (fromCEnum <$> Raw.tox_event_group_voice_state_get_voice_state ptr)

peekGroupTopicLock :: EventPtr -> IO EventGroupTopicLock
peekGroupTopicLock event = do
    ptr <- Raw.tox_event_get_group_topic_lock event
    EventGroupTopicLock
        <$> (GroupNumber
                <$> Raw.tox_event_group_topic_lock_get_group_number ptr)
        <*> (fromCEnum <$> Raw.tox_event_group_topic_lock_get_topic_lock ptr)

peekGroupPeerLimit :: EventPtr -> IO EventGroupPeerLimit
peekGroupPeerLimit event = do
    ptr <- Raw.tox_event_get_group_peer_limit event
    EventGroupPeerLimit
        <$> (GroupNumber
                <$> Raw.tox_event_group_peer_limit_get_group_number ptr)
        <*> Raw.tox_event_group_peer_limit_get_peer_limit ptr

peekGroupPassword :: EventPtr -> IO EventGroupPassword
peekGroupPassword event = do
    ptr <- Raw.tox_event_get_group_password event
    EventGroupPassword
        <$> (GroupNumber <$> Raw.tox_event_group_password_get_group_number ptr)
        <*> peekSizedBytes
                (Raw.tox_event_group_password_get_password ptr)
                (Raw.tox_event_group_password_get_password_length ptr)

peekGroupMessage :: EventPtr -> IO EventGroupMessage
peekGroupMessage event = do
    ptr <- Raw.tox_event_get_group_message event
    EventGroupMessage
        <$> (GroupNumber <$> Raw.tox_event_group_message_get_group_number ptr)
        <*> (GroupPeerNumber <$> Raw.tox_event_group_message_get_peer_id ptr)
        <*> (fromCEnum <$> Raw.tox_event_group_message_get_message_type ptr)
        <*> peekSizedBytes
                (Raw.tox_event_group_message_get_message ptr)
                (Raw.tox_event_group_message_get_message_length ptr)
        <*> (GroupMessageId <$> Raw.tox_event_group_message_get_message_id ptr)

peekGroupPrivateMessage :: EventPtr -> IO EventGroupPrivateMessage
peekGroupPrivateMessage event = do
    ptr <- Raw.tox_event_get_group_private_message event
    EventGroupPrivateMessage
        <$> (GroupNumber
                <$> Raw.tox_event_group_private_message_get_group_number ptr)
        <*> (GroupPeerNumber
                <$> Raw.tox_event_group_private_message_get_peer_id ptr)
        <*> (fromCEnum
                <$> Raw.tox_event_group_private_message_get_message_type ptr)
        <*> peekSizedBytes
                (Raw.tox_event_group_private_message_get_message ptr)
                (Raw.tox_event_group_private_message_get_message_length ptr)
        <*> (GroupMessageId
                <$> Raw.tox_event_group_private_message_get_message_id ptr)

peekGroupCustomPacket :: EventPtr -> IO EventGroupCustomPacket
peekGroupCustomPacket event = do
    ptr <- Raw.tox_event_get_group_custom_packet event
    EventGroupCustomPacket
        <$> (GroupNumber
                <$> Raw.tox_event_group_custom_packet_get_group_number ptr)
        <*> (GroupPeerNumber
                <$> Raw.tox_event_group_custom_packet_get_peer_id ptr)
        <*> peekSizedBytes
                (Raw.tox_event_group_custom_packet_get_data ptr)
                (Raw.tox_event_group_custom_packet_get_data_length ptr)

peekGroupCustomPrivatePacket :: EventPtr -> IO EventGroupCustomPrivatePacket
peekGroupCustomPrivatePacket event = do
    ptr <- Raw.tox_event_get_group_custom_private_packet event
    EventGroupCustomPrivatePacket
        <$> (GroupNumber
                <$> Raw.tox_event_group_custom_private_packet_get_group_number
                    ptr)
        <*> (GroupPeerNumber
                <$> Raw.tox_event_group_custom_private_packet_get_peer_id ptr)
        <*> peekSizedBytes
                (Raw.tox_event_group_custom_private_packet_get_data ptr)
                (Raw.tox_event_group_custom_private_packet_get_data_length ptr)

peekGroupInvite :: EventPtr -> IO EventGroupInvite
peekGroupInvite event = do
    ptr <- Raw.tox_event_get_group_invite event
    EventGroupInvite
        <$> (FriendNumber <$> Raw.tox_event_group_invite_get_friend_number ptr)
        <*> peekSizedBytes
                (Raw.tox_event_group_invite_get_invite_data ptr)
                (Raw.tox_event_group_invite_get_invite_data_length ptr)
        <*> peekSizedBytes
                (Raw.tox_event_group_invite_get_group_name ptr)
                (Raw.tox_event_group_invite_get_group_name_length ptr)

peekGroupPeerJoin :: EventPtr -> IO EventGroupPeerJoin
peekGroupPeerJoin event = do
    ptr <- Raw.tox_event_get_group_peer_join event
    EventGroupPeerJoin
        <$> (GroupNumber <$> Raw.tox_event_group_peer_join_get_group_number ptr)
        <*> (GroupPeerNumber <$> Raw.tox_event_group_peer_join_get_peer_id ptr)

peekGroupPeerExit :: EventPtr -> IO EventGroupPeerExit
peekGroupPeerExit event = do
    ptr <- Raw.tox_event_get_group_peer_exit event
    EventGroupPeerExit
        <$> (GroupNumber <$> Raw.tox_event_group_peer_exit_get_group_number ptr)
        <*> (GroupPeerNumber <$> Raw.tox_event_group_peer_exit_get_peer_id ptr)
        <*> (fromCEnum <$> Raw.tox_event_group_peer_exit_get_exit_type ptr)
        <*> peekSizedBytes
                (Raw.tox_event_group_peer_exit_get_name ptr)
                (Raw.tox_event_group_peer_exit_get_name_length ptr)
        <*> peekSizedBytes
                (Raw.tox_event_group_peer_exit_get_part_message ptr)
                (Raw.tox_event_group_peer_exit_get_part_message_length ptr)

peekGroupSelfJoin :: EventPtr -> IO EventGroupSelfJoin
peekGroupSelfJoin event = do
    ptr <- Raw.tox_event_get_group_self_join event
    EventGroupSelfJoin
        <$> (GroupNumber <$> Raw.tox_event_group_self_join_get_group_number ptr)

peekGroupJoinFail :: EventPtr -> IO EventGroupJoinFail
peekGroupJoinFail event = do
    ptr <- Raw.tox_event_get_group_join_fail event
    EventGroupJoinFail
        <$> (GroupNumber <$> Raw.tox_event_group_join_fail_get_group_number ptr)
        <*> (fromCEnum <$> Raw.tox_event_group_join_fail_get_fail_type ptr)

peekGroupModeration :: EventPtr -> IO EventGroupModeration
peekGroupModeration event = do
    ptr <- Raw.tox_event_get_group_moderation event
    EventGroupModeration
        <$> (GroupNumber
                <$> Raw.tox_event_group_moderation_get_group_number ptr)
        <*> (GroupPeerNumber
                <$> Raw.tox_event_group_moderation_get_source_peer_id ptr)
        <*> (GroupPeerNumber
                <$> Raw.tox_event_group_moderation_get_target_peer_id ptr)
        <*> (fromCEnum <$> Raw.tox_event_group_moderation_get_mod_type ptr)

peekDhtNodesResponse :: EventPtr -> IO EventDhtNodesResponse
peekDhtNodesResponse event = do
    ptr <- Raw.tox_event_get_dht_nodes_response event
    EventDhtNodesResponse
        <$> (Raw.tox_event_dht_nodes_response_get_public_key ptr
                >>= peekFixedBytes)
        <*> peekSizedString
                (Raw.tox_event_dht_nodes_response_get_ip ptr)
                (Raw.tox_event_dht_nodes_response_get_ip_length ptr)
        <*> (Port <$> Raw.tox_event_dht_nodes_response_get_port ptr)
