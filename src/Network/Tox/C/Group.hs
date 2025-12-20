-- | Group chats and their peers.
module Network.Tox.C.Group
    ( toxGroupNew
    , toxGroupJoin
    , toxGroupIsConnected
    , toxGroupDisconnect
    , toxGroupLeave
    , toxGroupSelfSetName
    , toxGroupSelfGetName
    , toxGroupSelfSetStatus
    , toxGroupSelfGetStatus
    , toxGroupSelfGetRole
    , toxGroupSelfGetPeerId
    , toxGroupSelfGetPublicKey
    , toxGroupSetTopic
    , toxGroupGetTopic
    , toxGroupGetName
    , toxGroupGetChatId
    , toxGroupById
    , toxGroupGetPrivacyState
    , toxGroupGetVoiceState
    , toxGroupGetTopicLock
    , toxGroupGetPeerLimit
    , toxGroupGetPassword
    , toxGroupSendMessage
    , toxGroupSendPrivateMessage
    , toxGroupSendCustomPacket
    , toxGroupSendCustomPrivatePacket
    , toxGroupInviteFriend
    , toxGroupInviteAccept
    , toxGroupSetPassword
    , toxGroupSetTopicLock
    , toxGroupSetVoiceState
    , toxGroupSetPrivacyState
    , toxGroupSetPeerLimit
    , toxGroupSetIgnore
    , toxGroupSetRole
    , toxGroupKickPeer
    , toxGroupPeerGetName
    , toxGroupPeerGetStatus
    , toxGroupPeerGetRole
    , toxGroupPeerGetConnectionStatus
    , toxGroupPeerGetPublicKey
    , toxGroupGetGroupList
    ) where

import           Data.ByteString       (ByteString)
import           Data.Word             (Word16, Word32)
import qualified FFI.Tox.Tox           as Raw
import           Foreign.C.Enum        (callErrFun, callErrFun_, fromCEnum,
                                        toCEnum)
import           Foreign.Marshal.Utils (fromBool, toBool)
import           Network.Tox.C.Marshal (getFixedBytesErr, getList, getSizedErr,
                                        withBytesLen, withFixedBytes)
import           Network.Tox.C.Types   (Connection, ErrGroupById,
                                        ErrGroupDisconnect,
                                        ErrGroupInviteAccept,
                                        ErrGroupInviteFriend,
                                        ErrGroupIsConnected, ErrGroupJoin,
                                        ErrGroupKickPeer, ErrGroupLeave,
                                        ErrGroupNew, ErrGroupPeerQuery,
                                        ErrGroupSelfNameSet, ErrGroupSelfQuery,
                                        ErrGroupSelfStatusSet,
                                        ErrGroupSendCustomPacket,
                                        ErrGroupSendCustomPrivatePacket,
                                        ErrGroupSendMessage,
                                        ErrGroupSendPrivateMessage,
                                        ErrGroupSetIgnore, ErrGroupSetPassword,
                                        ErrGroupSetPeerLimit,
                                        ErrGroupSetPrivacyState,
                                        ErrGroupSetRole, ErrGroupSetTopicLock,
                                        ErrGroupSetVoiceState,
                                        ErrGroupStateQuery, ErrGroupTopicSet,
                                        FriendNumber (..), GroupChatId,
                                        GroupMessageId (..), GroupNumber (..),
                                        GroupPeerNumber (..), GroupPrivacyState,
                                        GroupRole, GroupTopicLock,
                                        GroupVoiceState, MessageType, PublicKey,
                                        Tox (..), UserStatus)

-- | Creates a new group chat.
--
-- This function creates a new group chat object and adds it to the chats
-- array.
--
-- The caller of this function has Founder role privileges.
--
-- The client should initiate its peer list with self info after calling this
-- function, as the peer_join callback will not be triggered.
--
-- * @privacyState@: The privacy state of the group. If this is set to
--   TOX_GROUP_PRIVACY_STATE_PUBLIC, the group will attempt to announce itself
--   to the DHT and anyone with the Chat ID may join. Otherwise a friend
--   invite will be required to join the group.
-- * @groupName@: The name of the group. The name must be non-NULL.
-- * @name@: The name of the peer creating the group.
toxGroupNew
    :: Tox
    -> GroupPrivacyState
    -> ByteString
    -> ByteString
    -> IO (Either ErrGroupNew GroupNumber)
toxGroupNew (Tox tox) privacyState groupName name =
    withBytesLen groupName $ \groupNamePtr groupNameLen ->
    withBytesLen name $ \namePtr nameLen ->
        fmap GroupNumber
            <$> callErrFun
                (Raw.tox_group_new tox
                    (toCEnum privacyState)
                    groupNamePtr
                    groupNameLen
                    namePtr
                    nameLen)

-- | Joins a group chat with specified Chat ID or reconnects to an existing
-- group.
--
-- This function creates a new group chat object, adds it to the chats array,
-- and sends a DHT announcement to find peers in the group associated with
-- chat_id. Once a peer has been found a join attempt will be initiated.
--
-- If a group with the specified Chat ID already exists, this function will
-- attempt to reconnect to the group.
--
-- * @chatId@: The Chat ID of the group you wish to join. This must be
--   'Network.Tox.C.Constants.toxGroupChatIdSize' bytes.
-- * @password@: The password required to join the group. Set to NULL if no
--   password is required.
-- * @name@: The name of the peer joining the group.
toxGroupJoin
    :: Tox
    -> GroupChatId
    -> ByteString
    -> ByteString
    -> IO (Either ErrGroupJoin GroupNumber)
toxGroupJoin (Tox tox) chatId name password =
    withFixedBytes chatId $ \chatIdPtr ->
    withBytesLen name $ \namePtr nameLen ->
    withBytesLen password $ \passwordPtr passwordLen ->
        fmap GroupNumber
            <$> callErrFun
                (Raw.tox_group_join tox chatIdPtr namePtr nameLen passwordPtr
                    passwordLen)

-- | Returns true if the group chat is currently connected or attempting to
-- connect to other peers in the group.
--
-- * @groupNumber@: The group number of the designated group.
toxGroupIsConnected
    :: Tox -> GroupNumber -> IO (Either ErrGroupIsConnected Bool)
toxGroupIsConnected (Tox tox) (GroupNumber groupNumber) =
    fmap toBool <$> callErrFun (Raw.tox_group_is_connected tox groupNumber)

-- | Disconnects from a group chat while retaining the group state and
-- credentials.
--
-- Returns true if we successfully disconnect from the group.
--
-- * @groupNumber@: The group number of the designated group.
toxGroupDisconnect :: Tox -> GroupNumber -> IO (Either ErrGroupDisconnect ())
toxGroupDisconnect (Tox tox) (GroupNumber groupNumber) =
    callErrFun_ $ Raw.tox_group_disconnect tox groupNumber

-- | Leaves a group.
--
-- This function sends a parting packet containing a custom (non-obligatory)
-- message to all peers in a group, and deletes the group from the chat array.
-- All group state information is permanently lost, including keys and role
-- credentials.
--
-- * @groupNumber@: The group number of the group we wish to leave.
-- * @partMessage@: The parting message to be sent to all the peers. Set to
--   NULL if we do not wish to send a parting message.
toxGroupLeave
    :: Tox -> GroupNumber -> ByteString -> IO (Either ErrGroupLeave ())
toxGroupLeave (Tox tox) (GroupNumber groupNumber) partMessage =
    withBytesLen partMessage $ \partMessagePtr partMessageLen ->
        callErrFun_ $
            Raw.tox_group_leave tox groupNumber partMessagePtr partMessageLen

-- | Set the client's nickname for the group instance designated by the given
-- group number.
--
-- Nickname length cannot exceed 'Network.Tox.C.Constants.toxMaxNameLength'.
-- If length is equal to zero or name is a NULL pointer, the function call
-- will fail.
--
-- * @name@: A byte array containing the new nickname.
toxGroupSelfSetName
    :: Tox -> GroupNumber -> ByteString -> IO (Either ErrGroupSelfNameSet ())
toxGroupSelfSetName (Tox tox) (GroupNumber groupNumber) name =
    withBytesLen name $ \namePtr nameLen ->
        callErrFun_ $
            Raw.tox_group_self_set_name tox groupNumber namePtr nameLen

-- | Write the nickname set by 'toxGroupSelfSetName' to a byte array.
--
-- If no nickname was set before calling this function, the name is empty, and
-- this function has no effect.
toxGroupSelfGetName
    :: Tox -> GroupNumber -> IO (Either ErrGroupSelfQuery ByteString)
toxGroupSelfGetName (Tox tox) (GroupNumber groupNumber) =
    getSizedErr
        (Raw.tox_group_self_get_name_size tox groupNumber)
        (Raw.tox_group_self_get_name tox groupNumber)

-- | Set the client's status for the group instance. Status must be a
-- Tox_User_Status.
toxGroupSelfSetStatus
    :: Tox -> GroupNumber -> UserStatus -> IO (Either ErrGroupSelfStatusSet ())
toxGroupSelfSetStatus (Tox tox) (GroupNumber groupNumber) status =
    callErrFun_ $ Raw.tox_group_self_set_status tox groupNumber (toCEnum status)

-- | returns the client's status for the group instance on success. return value
-- is unspecified on failure.
toxGroupSelfGetStatus
    :: Tox -> GroupNumber -> IO (Either ErrGroupSelfQuery UserStatus)
toxGroupSelfGetStatus (Tox tox) (GroupNumber groupNumber) =
    fmap fromCEnum
        <$> callErrFun (Raw.tox_group_self_get_status tox groupNumber)

-- | returns the client's role for the group instance on success. return value
-- is unspecified on failure.
toxGroupSelfGetRole
    :: Tox -> GroupNumber -> IO (Either ErrGroupSelfQuery GroupRole)
toxGroupSelfGetRole (Tox tox) (GroupNumber groupNumber) =
    fmap fromCEnum <$> callErrFun (Raw.tox_group_self_get_role tox groupNumber)

-- | returns the client's peer id for the group instance on success. return
-- value is unspecified on failure.
toxGroupSelfGetPeerId
    :: Tox -> GroupNumber -> IO (Either ErrGroupSelfQuery GroupPeerNumber)
toxGroupSelfGetPeerId (Tox tox) (GroupNumber groupNumber) =
    fmap GroupPeerNumber
        <$> callErrFun (Raw.tox_group_self_get_peer_id tox groupNumber)

-- | Write the client's group public key designated by the given group number to
-- a byte array.
--
-- This key will be permanently tied to the client's identity for this
-- particular group until the client explicitly leaves the group. This key is
-- the only way for other peers to reliably identify the client across client
-- restarts.
--
-- @public_key@ should have room for at least
-- 'Network.Tox.C.Constants.toxGroupPeerPublicKeySize' bytes.
toxGroupSelfGetPublicKey
    :: Tox -> GroupNumber -> IO (Either ErrGroupSelfQuery PublicKey)
toxGroupSelfGetPublicKey (Tox tox) (GroupNumber groupNumber) =
    getFixedBytesErr $ Raw.tox_group_self_get_public_key tox groupNumber

-- | Set the group topic and broadcast it to the rest of the group.
--
-- Topic length cannot be longer than
-- 'Network.Tox.C.Constants.toxGroupMaxTopicLength'. If the length is equal to
-- zero or topic is set to NULL, the topic will be unset.
toxGroupSetTopic
    :: Tox -> GroupNumber -> ByteString -> IO (Either ErrGroupTopicSet ())
toxGroupSetTopic (Tox tox) (GroupNumber groupNumber) topic =
    withBytesLen topic $ \topicPtr topicLen ->
        callErrFun_ $ Raw.tox_group_set_topic tox groupNumber topicPtr topicLen

-- | Write the topic designated by the given group number to a byte array.
--
-- The data written to @topic@ is equal to the data received by the last
-- @group_topic@ callback.
toxGroupGetTopic
    :: Tox -> GroupNumber -> IO (Either ErrGroupStateQuery ByteString)
toxGroupGetTopic (Tox tox) (GroupNumber groupNumber) =
    getSizedErr
        (Raw.tox_group_get_topic_size tox groupNumber)
        (Raw.tox_group_get_topic tox groupNumber)

-- | Write the name of the group designated by the given group number to a byte
-- array.
toxGroupGetName
    :: Tox -> GroupNumber -> IO (Either ErrGroupStateQuery ByteString)
toxGroupGetName (Tox tox) (GroupNumber groupNumber) =
    getSizedErr
        (Raw.tox_group_get_name_size tox groupNumber)
        (Raw.tox_group_get_name tox groupNumber)

-- | Write the Chat ID designated by the given group number to a byte array.
--
-- @chat_id@ should have room for at least
-- 'Network.Tox.C.Constants.toxGroupChatIdSize' bytes.
toxGroupGetChatId
    :: Tox -> GroupNumber -> IO (Either ErrGroupStateQuery GroupChatId)
toxGroupGetChatId (Tox tox) (GroupNumber groupNumber) =
    getFixedBytesErr $ Raw.tox_group_get_chat_id tox groupNumber

-- | Return the group number associated with the specified Chat ID.
--
-- * @chatId@: A byte array containing the Chat ID
--   ('Network.Tox.C.Constants.toxGroupChatIdSize').
toxGroupById :: Tox -> GroupChatId -> IO (Either ErrGroupById GroupNumber)
toxGroupById (Tox tox) chatId =
    withFixedBytes chatId $ \chatIdPtr ->
        fmap GroupNumber <$> callErrFun (Raw.tox_group_by_id tox chatIdPtr)

-- | Return the privacy state of the group designated by the given group number.
-- If group number is invalid, the return value is unspecified.
--
-- The value returned is equal to the data received by the last
-- @group_privacy_state@ callback.
--
-- See the @Group chat Founder controls@ section for the respective set
-- function.
toxGroupGetPrivacyState
    :: Tox -> GroupNumber -> IO (Either ErrGroupStateQuery GroupPrivacyState)
toxGroupGetPrivacyState (Tox tox) (GroupNumber groupNumber) =
    fmap fromCEnum
        <$> callErrFun (Raw.tox_group_get_privacy_state tox groupNumber)

-- | Return the voice state of the group designated by the given group number.
-- If group number is invalid, the return value is unspecified.
--
-- The value returned is equal to the data received by the last
-- @group_voice_state@ callback.
--
-- See the @Group chat Founder controls@ section for the respective set
-- function.
toxGroupGetVoiceState
    :: Tox -> GroupNumber -> IO (Either ErrGroupStateQuery GroupVoiceState)
toxGroupGetVoiceState (Tox tox) (GroupNumber groupNumber) =
    fmap fromCEnum
        <$> callErrFun (Raw.tox_group_get_voice_state tox groupNumber)

-- | Return the topic lock status of the group designated by the given group
-- number. If group number is invalid, the return value is unspecified.
--
-- The value returned is equal to the data received by the last
-- @group_topic_lock@ callback.
--
-- See the @Group chat Founder controls@ section for the respective set
-- function.
toxGroupGetTopicLock
    :: Tox -> GroupNumber -> IO (Either ErrGroupStateQuery GroupTopicLock)
toxGroupGetTopicLock (Tox tox) (GroupNumber groupNumber) =
    fmap fromCEnum <$> callErrFun (Raw.tox_group_get_topic_lock tox groupNumber)

-- | Return the maximum number of peers allowed for the group designated by the
-- given group number. If the group number is invalid, the return value is
-- unspecified.
--
-- The value returned is equal to the data received by the last
-- @group_peer_limit@ callback.
--
-- See the @Group chat Founder controls@ section for the respective set
-- function.
toxGroupGetPeerLimit
    :: Tox -> GroupNumber -> IO (Either ErrGroupStateQuery Word16)
toxGroupGetPeerLimit (Tox tox) (GroupNumber groupNumber) =
    callErrFun $ Raw.tox_group_get_peer_limit tox groupNumber

-- | Write the password for the group designated by the given group number to a
-- byte array.
--
-- The data received is equal to the data received by the last
-- @group_password@ callback.
--
-- See the @Group chat Founder controls@ section for the respective set
-- function.
toxGroupGetPassword
    :: Tox -> GroupNumber -> IO (Either ErrGroupStateQuery ByteString)
toxGroupGetPassword (Tox tox) (GroupNumber groupNumber) =
    getSizedErr
        (Raw.tox_group_get_password_size tox groupNumber)
        (Raw.tox_group_get_password tox groupNumber)

-- | Send a text chat message to the group.
--
-- This function creates a group message packet and pushes it into the send
-- queue.
--
-- The message length may not exceed
-- 'Network.Tox.C.Constants.toxGroupMaxMessageLength'. Larger messages must be
-- split by the client and sent as separate messages. Other clients can then
-- reassemble the fragments. Messages may not be empty.
--
-- * @groupNumber@: The group number of the group the message is intended for.
-- * @messageType@: Message type (normal, action, ...).
-- * @message@: A non-NULL pointer to the first element of a byte array
--   containing the message text.
toxGroupSendMessage
    :: Tox
    -> GroupNumber
    -> MessageType
    -> ByteString
    -> IO (Either ErrGroupSendMessage GroupMessageId)
toxGroupSendMessage (Tox tox) (GroupNumber groupNumber) messageType message =
    withBytesLen message $ \messagePtr messageLen ->
        fmap GroupMessageId
            <$> callErrFun
                (Raw.tox_group_send_message tox groupNumber
                    (toCEnum messageType)
                    messagePtr
                    messageLen)

-- | Send a text chat message to the specified peer in the specified group.
--
-- This function creates a group private message packet and pushes it into the
-- send queue.
--
-- The message length may not exceed
-- 'Network.Tox.C.Constants.toxGroupMaxMessageLength'. Larger messages must be
-- split by the client and sent as separate messages. Other clients can then
-- reassemble the fragments. Messages may not be empty.
--
-- * @groupNumber@: The group number of the group the message is intended for.
-- * @peerId@: The ID of the peer the message is intended for.
-- * @messageType@: The type of message (normal, action, ...).
-- * @message@: A non-NULL pointer to the first element of a byte array
--   containing the message text.
toxGroupSendPrivateMessage
    :: Tox
    -> GroupNumber
    -> GroupPeerNumber
    -> MessageType
    -> ByteString
    -> IO (Either ErrGroupSendPrivateMessage GroupMessageId)
toxGroupSendPrivateMessage (Tox tox) (GroupNumber groupNumber)
    (GroupPeerNumber peerId) messageType message =
    withBytesLen message $ \messagePtr messageLen ->
        fmap GroupMessageId
            <$> callErrFun
                (Raw.tox_group_send_private_message tox groupNumber peerId
                    (toCEnum messageType)
                    messagePtr
                    messageLen)

-- | Send a custom packet to the group.
--
-- If lossless is true the packet will be lossless. Lossless packet behaviour
-- is comparable to TCP (reliability, arrive in order) but with packets
-- instead of a stream.
--
-- If lossless is false, the packet will be lossy. Lossy packets behave like
-- UDP packets, meaning they might never reach the other side or might arrive
-- more than once (if someone is messing with the connection) or might arrive
-- in the wrong order.
--
-- Unless latency is an issue or message reliability is not important, it is
-- recommended that you use lossless packets.
--
-- The message length may not exceed
-- 'Network.Tox.C.Constants.toxMaxCustomPacketSize'. Larger packets must be
-- split by the client and sent as separate packets. Other clients can then
-- reassemble the fragments. Packets may not be empty.
--
-- * @groupNumber@: The group number of the group the packet is intended for.
-- * @lossless@: True if the packet should be lossless.
-- * @data'@: A byte array containing the packet data.
toxGroupSendCustomPacket
    :: Tox
    -> GroupNumber
    -> Bool
    -> ByteString
    -> IO (Either ErrGroupSendCustomPacket ())
toxGroupSendCustomPacket (Tox tox) (GroupNumber groupNumber) lossless data' =
    withBytesLen data' $ \dataPtr dataLen ->
        callErrFun_ $
            Raw.tox_group_send_custom_packet tox groupNumber
                (fromBool lossless)
                dataPtr
                dataLen

-- | Send a custom private packet to a designated peer in the group.
--
-- If lossless is true the packet will be lossless. Lossless packet behaviour
-- is comparable to TCP (reliability, arrive in order) but with packets
-- instead of a stream.
--
-- If lossless is false, the packet will be lossy. Lossy packets behave like
-- UDP packets, meaning they might never reach the other side or might arrive
-- more than once (if someone is messing with the connection) or might arrive
-- in the wrong order.
--
-- Unless latency is an issue or message reliability is not important, it is
-- recommended that you use lossless packets.
--
-- The packet length may not exceed
-- 'Network.Tox.C.Constants.toxMaxCustomPacketSize'. Larger packets must be
-- split by the client and sent as separate packets. Other clients can then
-- reassemble the fragments. Packets may not be empty.
--
-- * @groupNumber@: The group number of the group the packet is intended for.
-- * @peerId@: The ID of the peer the packet is intended for.
-- * @lossless@: True if the packet should be lossless.
-- * @data'@: A byte array containing the packet data.
toxGroupSendCustomPrivatePacket
    :: Tox
    -> GroupNumber
    -> GroupPeerNumber
    -> Bool
    -> ByteString
    -> IO (Either ErrGroupSendCustomPrivatePacket ())
toxGroupSendCustomPrivatePacket (Tox tox) (GroupNumber groupNumber)
    (GroupPeerNumber peerId) lossless data' =
    withBytesLen data' $ \dataPtr dataLen ->
        callErrFun_ $
            Raw.tox_group_send_custom_private_packet tox groupNumber peerId
                (fromBool lossless)
                dataPtr
                dataLen

-- | Invite a friend to a group.
--
-- This function creates an invite request packet and pushes it to the send
-- queue.
--
-- * @groupNumber@: The group number of the group the message is intended for.
-- * @friendNumber@: The friend number of the friend the invite is intended
--   for.
toxGroupInviteFriend
    :: Tox -> GroupNumber -> FriendNumber -> IO (Either ErrGroupInviteFriend ())
toxGroupInviteFriend (Tox tox) (GroupNumber groupNumber)
    (FriendNumber friendNumber) =
    callErrFun_ $ Raw.tox_group_invite_friend tox groupNumber friendNumber

-- | Accept an invite to a group chat that the client previously received from a
-- friend. The invite is only valid while the inviter is present in the group.
--
-- * @inviteData@: The invite data received from the @group_invite@ event.
-- * @name@: The name of the peer joining the group.
-- * @password@: The password required to join the group. Set to NULL if no
--   password is required.
toxGroupInviteAccept
    :: Tox
    -> FriendNumber
    -> ByteString
    -> ByteString
    -> ByteString
    -> IO (Either ErrGroupInviteAccept GroupNumber)
toxGroupInviteAccept (Tox tox) (FriendNumber friendNumber) inviteData name
    password =
    withBytesLen inviteData $ \inviteDataPtr inviteDataLen ->
    withBytesLen name $ \namePtr nameLen ->
    withBytesLen password $ \passwordPtr passwordLen ->
        fmap GroupNumber
            <$> callErrFun
                (Raw.tox_group_invite_accept tox friendNumber inviteDataPtr
                    inviteDataLen namePtr nameLen passwordPtr passwordLen)

-- | Set or unset the group password.
--
-- This function allows Founders to set or unset a group password. It will
-- create a new group shared state including the change and distribute it to
-- the rest of the group.
--
-- * @groupNumber@: The group number of the group for which we wish to set the
--   password.
-- * @password@: The password we want to set. Set password to NULL to unset
--   the password.
toxGroupSetPassword
    :: Tox -> GroupNumber -> ByteString -> IO (Either ErrGroupSetPassword ())
toxGroupSetPassword (Tox tox) (GroupNumber groupNumber) password =
    withBytesLen password $ \passwordPtr passwordLen ->
        callErrFun_ $
            Raw.tox_group_set_password tox groupNumber passwordPtr passwordLen

-- | Set the group topic lock state.
--
-- This function allows Founders to enable or disable the group's topic lock.
-- It will create a new shared state including the change and distribute it to
-- the rest of the group.
--
-- When the topic lock is enabled, only the group founder and moderators may
-- set the topic. When disabled, all peers except those with the observer role
-- may set the topic.
--
-- * @groupNumber@: The group number of the group for which we wish to change
--   the topic lock state.
-- * @topicLock@: The state we wish to set the topic lock to.
toxGroupSetTopicLock
    :: Tox
    -> GroupNumber
    -> GroupTopicLock
    -> IO (Either ErrGroupSetTopicLock ())
toxGroupSetTopicLock (Tox tox) (GroupNumber groupNumber) topicLock =
    callErrFun_ $
        Raw.tox_group_set_topic_lock tox groupNumber (toCEnum topicLock)

-- | Set the group voice state.
--
-- This function allows Founders to set the group's voice state. It will
-- create a new group shared state including the change and distribute it to
-- the rest of the group.
--
-- If an attempt is made to set the voice state to the same state that the
-- group is already in, the function call will be successful and no action
-- will be taken.
--
-- * @groupNumber@: The group number of the group for which we wish to change
--   the voice state.
-- * @voiceState@: The voice state we wish to set the group to.
toxGroupSetVoiceState
    :: Tox
    -> GroupNumber
    -> GroupVoiceState
    -> IO (Either ErrGroupSetVoiceState ())
toxGroupSetVoiceState (Tox tox) (GroupNumber groupNumber) voiceState =
    callErrFun_ $
        Raw.tox_group_set_voice_state tox groupNumber (toCEnum voiceState)

-- | Set the group privacy state.
--
-- This function allows Founders to set the group's privacy state. It will
-- create a new group shared state including the change and distribute it to
-- the rest of the group.
--
-- If an attempt is made to set the privacy state to the same state that the
-- group is already in, the function call will be successful and no action
-- will be taken.
--
-- * @groupNumber@: The group number of the group for which we wish to change
--   the privacy state.
-- * @privacyState@: The privacy state we wish to set the group to.
toxGroupSetPrivacyState
    :: Tox
    -> GroupNumber
    -> GroupPrivacyState
    -> IO (Either ErrGroupSetPrivacyState ())
toxGroupSetPrivacyState (Tox tox) (GroupNumber groupNumber) privacyState =
    callErrFun_ $
        Raw.tox_group_set_privacy_state tox groupNumber (toCEnum privacyState)

-- | Set the group peer limit.
--
-- This function allows Founders to set a limit for the number of peers who
-- may be in the group. It will create a new group shared state including the
-- change and distribute it to the rest of the group.
--
-- * @groupNumber@: The group number of the group for which we wish to set the
--   peer limit.
-- * @peerLimit@: The maximum number of peers to allow in the group.
toxGroupSetPeerLimit
    :: Tox -> GroupNumber -> Word16 -> IO (Either ErrGroupSetPeerLimit ())
toxGroupSetPeerLimit (Tox tox) (GroupNumber groupNumber) peerLimit =
    callErrFun_ $ Raw.tox_group_set_peer_limit tox groupNumber peerLimit

-- | Ignore or unignore a peer.
--
-- * @groupNumber@: The group number of the group in which you wish to ignore
--   a peer.
-- * @peerId@: The ID of the peer who shall be ignored or unignored.
-- * @ignore@: True to ignore the peer, false to unignore the peer.
toxGroupSetIgnore
    :: Tox
    -> GroupNumber
    -> GroupPeerNumber
    -> Bool
    -> IO (Either ErrGroupSetIgnore ())
toxGroupSetIgnore (Tox tox) (GroupNumber groupNumber) (GroupPeerNumber peerId)
    ignore =
    callErrFun_ $
        Raw.tox_group_set_ignore tox groupNumber peerId (fromBool ignore)

-- | Set a peer's role.
--
-- This function will first remove the peer's previous role and then assign
-- them a new role. It will also send a packet to the rest of the group,
-- requesting that they perform the role reassignment.
--
-- Only Founders may promote peers to the Moderator role, and only Founders
-- and Moderators may set peers to the Observer or User role. Moderators may
-- not set the role of other Moderators or the Founder. Peers may not be
-- promoted to the Founder role.
--
-- * @groupNumber@: The group number of the group the in which you wish set
--   the peer's role.
-- * @peerId@: The ID of the peer whose role you wish to set.
-- * @role@: The role you wish to set the peer to.
toxGroupSetRole
    :: Tox
    -> GroupNumber
    -> GroupPeerNumber
    -> GroupRole
    -> IO (Either ErrGroupSetRole ())
toxGroupSetRole (Tox tox) (GroupNumber groupNumber) (GroupPeerNumber peerId)
    role =
    callErrFun_ $ Raw.tox_group_set_role tox groupNumber peerId (toCEnum role)

-- | Kick a peer.
--
-- This function allows peers with the Founder or Moderator role to silently
-- instruct all other peers in the group to remove a particular peer from
-- their peer list.
--
-- Note: This function will not trigger the @group_peer_exit@ event for the
-- caller.
--
-- * @groupNumber@: The group number of the group the action is intended for.
-- * @peerId@: The ID of the peer who will be kicked.
toxGroupKickPeer
    :: Tox -> GroupNumber -> GroupPeerNumber -> IO (Either ErrGroupKickPeer ())
toxGroupKickPeer (Tox tox) (GroupNumber groupNumber) (GroupPeerNumber peerId) =
    callErrFun_ $ Raw.tox_group_kick_peer tox groupNumber peerId

-- | Write the name of the peer designated by the given ID to a byte array.
--
-- The data written to @name@ is equal to the data received by the last
-- @group_peer_name@ callback.
--
-- * @groupNumber@: The group number of the group we wish to query.
-- * @peerId@: The ID of the peer whose name we wish to retrieve.
toxGroupPeerGetName
    :: Tox
    -> GroupNumber
    -> GroupPeerNumber
    -> IO (Either ErrGroupPeerQuery ByteString)
toxGroupPeerGetName (Tox tox) (GroupNumber groupNumber)
    (GroupPeerNumber peerId) =
    getSizedErr
        (Raw.tox_group_peer_get_name_size tox groupNumber peerId)
        (Raw.tox_group_peer_get_name tox groupNumber peerId)

-- | Return the peer's user status (away\/busy\/...). If the ID or group number
-- is invalid, the return value is unspecified.
--
-- * @groupNumber@: The group number of the group we wish to query.
-- * @peerId@: The ID of the peer whose status we wish to query.
--
-- The status returned is equal to the last status received through the
-- @group_peer_status@ callback.
toxGroupPeerGetStatus
    :: Tox
    -> GroupNumber
    -> GroupPeerNumber
    -> IO (Either ErrGroupPeerQuery UserStatus)
toxGroupPeerGetStatus (Tox tox) (GroupNumber groupNumber)
    (GroupPeerNumber peerId) =
    fmap fromCEnum
        <$> callErrFun (Raw.tox_group_peer_get_status tox groupNumber peerId)

-- | Return the peer's role (user\/moderator\/founder...). If the ID or group
-- number is invalid, the return value is unspecified.
--
-- * @groupNumber@: The group number of the group we wish to query.
-- * @peerId@: The ID of the peer whose role we wish to query.
--
-- The role returned is equal to the last role received through the
-- @group_moderation@ callback.
toxGroupPeerGetRole
    :: Tox
    -> GroupNumber
    -> GroupPeerNumber
    -> IO (Either ErrGroupPeerQuery GroupRole)
toxGroupPeerGetRole (Tox tox) (GroupNumber groupNumber)
    (GroupPeerNumber peerId) =
    fmap fromCEnum
        <$> callErrFun (Raw.tox_group_peer_get_role tox groupNumber peerId)

-- | Return the type of connection we have established with a peer.
--
-- If @peer_id@ designates ourself, the return value indicates whether we're
-- capable of making UDP connections with other peers, or are limited to TCP
-- connections.
--
-- * @groupNumber@: The group number of the group we wish to query.
-- * @peerId@: The ID of the peer whose connection status we wish to query.
toxGroupPeerGetConnectionStatus
    :: Tox
    -> GroupNumber
    -> GroupPeerNumber
    -> IO (Either ErrGroupPeerQuery Connection)
toxGroupPeerGetConnectionStatus (Tox tox) (GroupNumber groupNumber)
    (GroupPeerNumber peerId) =
    fmap fromCEnum
        <$> callErrFun
            (Raw.tox_group_peer_get_connection_status tox groupNumber peerId)

-- | Write the group public key with the designated peer_id for the designated
-- group number to public_key.
--
-- This key will be permanently tied to a particular peer until they
-- explicitly leave the group and is the only way to reliably identify the
-- same peer across client restarts.
--
-- @public_key@ should have room for at least
-- 'Network.Tox.C.Constants.toxGroupPeerPublicKeySize' bytes. If @public_key@
-- is NULL this function has no effect.
--
-- * @groupNumber@: The group number of the group we wish to query.
-- * @peerId@: The ID of the peer whose public key we wish to retrieve.
toxGroupPeerGetPublicKey
    :: Tox
    -> GroupNumber
    -> GroupPeerNumber
    -> IO (Either ErrGroupPeerQuery PublicKey)
toxGroupPeerGetPublicKey (Tox tox) (GroupNumber groupNumber)
    (GroupPeerNumber peerId) =
    getFixedBytesErr $ Raw.tox_group_peer_get_public_key tox groupNumber peerId

toxGroupGetGroupList :: Tox -> IO [GroupNumber]
toxGroupGetGroupList (Tox tox) =
    map GroupNumber
        <$> getList
            (Raw.tox_group_get_group_list_size tox)
            (Raw.tox_group_get_group_list tox)
