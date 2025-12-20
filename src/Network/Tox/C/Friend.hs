-- | Friends: adding and removing them, what they say about themselves, and
-- messages and packets to them.
module Network.Tox.C.Friend
    ( toxFriendAdd
    , toxFriendAddNorequest
    , toxFriendDelete
    , toxFriendByPublicKey
    , toxFriendExists
    , toxFriendGetPublicKey
    , toxFriendGetLastOnline
    , toxFriendGetName
    , toxFriendGetStatusMessage
    , toxFriendGetStatus
    , toxFriendGetConnectionStatus
    , toxFriendGetTyping
    , toxFriendSendMessage
    , toxFriendSendLossyPacket
    , toxFriendSendLosslessPacket
    ) where

import           Data.ByteString       (ByteString)
import           Data.Word             (Word64)
import qualified FFI.Tox.Tox           as Raw
import           Foreign.C.Enum        (callErrFun, callErrFun_, fromCEnum,
                                        toCEnum)
import           Foreign.Marshal.Utils (toBool)
import           Network.Tox.C.Marshal (getFixedBytesErr, getSizedErr,
                                        withBytesLen, withFixedBytes)
import           Network.Tox.C.Types   (Address, Connection, ErrFriendAdd,
                                        ErrFriendByPublicKey,
                                        ErrFriendCustomPacket, ErrFriendDelete,
                                        ErrFriendGetLastOnline,
                                        ErrFriendGetPublicKey, ErrFriendQuery,
                                        ErrFriendSendMessage,
                                        FriendMessageId (..), FriendNumber (..),
                                        MessageType, PublicKey, Tox (..),
                                        UserStatus)

-- | Add a friend to the friend list and send a friend request.
--
-- A friend request message must be at least 1 byte long and at most
-- 'Network.Tox.C.Constants.toxMaxFriendRequestLength'.
--
-- Friend numbers are unique identifiers used in all functions that operate on
-- friends. Once added, a friend number is stable for the lifetime of the Tox
-- object. After saving the state and reloading it, the friend numbers may not
-- be the same as before. Deleting a friend creates a gap in the friend number
-- set, which is filled by the next adding of a friend. Any pattern in friend
-- numbers should not be relied on.
--
-- If more than INT32_MAX friends are added, this function causes undefined
-- behaviour.
--
-- * @address@: The address of the friend (returned by
--   'Network.Tox.C.Tox.toxSelfGetAddress' of the friend you wish to add) it
--   must be 'Network.Tox.C.Constants.toxAddressSize' bytes.
-- * @message@: The message that will be sent along with the friend request.
toxFriendAdd
    :: Tox -> Address -> ByteString -> IO (Either ErrFriendAdd FriendNumber)
toxFriendAdd (Tox tox) address message =
    withFixedBytes address $ \addressPtr ->
    withBytesLen message $ \messagePtr messageLen ->
        fmap FriendNumber
            <$> callErrFun
                (Raw.tox_friend_add tox addressPtr messagePtr messageLen)

-- | Add a friend without sending a friend request.
--
-- This function is used to add a friend in response to a friend request. If
-- the client receives a friend request, it can be reasonably sure that the
-- other client added this client as a friend, eliminating the need for a
-- friend request.
--
-- This function is also useful in a situation where both instances are
-- controlled by the same entity, so that this entity can perform the mutual
-- friend adding. In this case, there is no need for a friend request, either.
--
-- * @publicKey@: A byte array of length
--   'Network.Tox.C.Constants.toxPublicKeySize' containing the Public Key (not
--   the Address) of the friend to add.
--
-- See 'toxFriendAdd' for a more detailed description of friend numbers.
toxFriendAddNorequest
    :: Tox -> PublicKey -> IO (Either ErrFriendAdd FriendNumber)
toxFriendAddNorequest (Tox tox) publicKey =
    withFixedBytes publicKey $ \publicKeyPtr ->
        fmap FriendNumber
            <$> callErrFun (Raw.tox_friend_add_norequest tox publicKeyPtr)

-- | Remove a friend from the friend list.
--
-- This does not notify the friend of their deletion. After calling this
-- function, this client will appear offline to the friend and no
-- communication can occur between the two.
--
-- * @friendNumber@: Friend number for the friend to be deleted.
toxFriendDelete :: Tox -> FriendNumber -> IO (Either ErrFriendDelete ())
toxFriendDelete (Tox tox) (FriendNumber friendNumber) =
    callErrFun_ $ Raw.tox_friend_delete tox friendNumber

-- | Return the friend number associated with that Public Key.
--
-- * @publicKey@: A byte array containing the Public Key.
toxFriendByPublicKey
    :: Tox -> PublicKey -> IO (Either ErrFriendByPublicKey FriendNumber)
toxFriendByPublicKey (Tox tox) publicKey =
    withFixedBytes publicKey $ \publicKeyPtr ->
        fmap FriendNumber
            <$> callErrFun (Raw.tox_friend_by_public_key tox publicKeyPtr)

-- | Checks if a friend with the given friend number exists and returns true if
-- it does.
toxFriendExists :: Tox -> FriendNumber -> IO Bool
toxFriendExists (Tox tox) (FriendNumber friendNumber) =
    toBool <$> Raw.tox_friend_exists tox friendNumber

-- | Copies the Public Key associated with a given friend number to a byte
-- array.
--
-- * @friendNumber@: The friend number you want the Public Key of.
toxFriendGetPublicKey
    :: Tox -> FriendNumber -> IO (Either ErrFriendGetPublicKey PublicKey)
toxFriendGetPublicKey (Tox tox) (FriendNumber friendNumber) =
    getFixedBytesErr $ Raw.tox_friend_get_public_key tox friendNumber

-- | Return a unix-time timestamp of the last time the friend associated with a
-- given friend number was seen online.
--
-- * @friendNumber@: The friend number you want to query.
toxFriendGetLastOnline
    :: Tox -> FriendNumber -> IO (Either ErrFriendGetLastOnline Word64)
toxFriendGetLastOnline (Tox tox) (FriendNumber friendNumber) =
    callErrFun $ Raw.tox_friend_get_last_online tox friendNumber

-- | Write the name of the friend designated by the given friend number to a
-- byte array.
--
-- The data written to @name@ is equal to the data received by the last
-- @friend_name@ callback.
toxFriendGetName :: Tox -> FriendNumber -> IO (Either ErrFriendQuery ByteString)
toxFriendGetName (Tox tox) (FriendNumber friendNumber) =
    getSizedErr
        (Raw.tox_friend_get_name_size tox friendNumber)
        (Raw.tox_friend_get_name tox friendNumber)

-- | Write the status message of the friend designated by the given friend
-- number to a byte array.
--
-- The data written to @status_message@ is equal to the data received by the
-- last @friend_status_message@ callback.
toxFriendGetStatusMessage
    :: Tox -> FriendNumber -> IO (Either ErrFriendQuery ByteString)
toxFriendGetStatusMessage (Tox tox) (FriendNumber friendNumber) =
    getSizedErr
        (Raw.tox_friend_get_status_message_size tox friendNumber)
        (Raw.tox_friend_get_status_message tox friendNumber)

-- | Return the friend's user status (away\/busy\/...).
--
-- If the friend number is invalid, the return value is unspecified.
--
-- The status returned is equal to the last status received through the
-- @friend_status@ callback.
--
-- Deprecated: This getter is deprecated. Use the event and store the status
-- in the client state.
toxFriendGetStatus
    :: Tox -> FriendNumber -> IO (Either ErrFriendQuery UserStatus)
toxFriendGetStatus (Tox tox) (FriendNumber friendNumber) =
    fmap fromCEnum <$> callErrFun (Raw.tox_friend_get_status tox friendNumber)

-- | Check whether a friend is currently connected to this client.
--
-- The result of this function is equal to the last value received by the
-- @friend_connection_status@ callback.
--
-- * @friendNumber@: The friend number for which to query the connection
--   status.
--
-- Deprecated: This getter is deprecated. Use the event and store the status
-- in the client state.
toxFriendGetConnectionStatus
    :: Tox -> FriendNumber -> IO (Either ErrFriendQuery Connection)
toxFriendGetConnectionStatus (Tox tox) (FriendNumber friendNumber) =
    fmap fromCEnum
        <$> callErrFun (Raw.tox_friend_get_connection_status tox friendNumber)

-- | Check whether a friend is currently typing a message.
--
-- * @friendNumber@: The friend number for which to query the typing status.
--
-- Deprecated: This getter is deprecated. Use the event and store the status
-- in the client state.
toxFriendGetTyping :: Tox -> FriendNumber -> IO (Either ErrFriendQuery Bool)
toxFriendGetTyping (Tox tox) (FriendNumber friendNumber) =
    fmap toBool <$> callErrFun (Raw.tox_friend_get_typing tox friendNumber)

-- | Send a text chat message to an online friend.
--
-- This function creates a chat message packet and pushes it into the send
-- queue.
--
-- The message length may not exceed
-- 'Network.Tox.C.Constants.toxMaxMessageLength'. Larger messages must be
-- split by the client and sent as separate messages. Other clients can then
-- reassemble the fragments. Messages may not be empty.
--
-- The return value of this function is the message ID. If a read receipt is
-- received, the triggered @friend_read_receipt@ event will be passed this
-- message ID.
--
-- Message IDs are unique per friend. The first message ID is 0. Message IDs
-- are incremented by 1 each time a message is sent. If UINT32_MAX messages
-- were sent, the next message ID is 0.
--
-- * @type'@: Message type (normal, action, ...).
-- * @friendNumber@: The friend number of the friend to send the message to.
-- * @message@: A non-NULL pointer to the first element of a byte array
--   containing the message text.
toxFriendSendMessage
    :: Tox
    -> FriendNumber
    -> MessageType
    -> ByteString
    -> IO (Either ErrFriendSendMessage FriendMessageId)
toxFriendSendMessage (Tox tox) (FriendNumber friendNumber) type' message =
    withBytesLen message $ \messagePtr messageLen ->
        fmap FriendMessageId
            <$> callErrFun
                (Raw.tox_friend_send_message tox friendNumber
                    (toCEnum type')
                    messagePtr
                    messageLen)

-- | Send a custom lossy packet to a friend.
--
-- The first byte of data must be in the range 192-254. Maximum length of a
-- custom packet is 'Network.Tox.C.Constants.toxMaxCustomPacketSize'.
--
-- Lossy packets behave like UDP packets, meaning they might never reach the
-- other side or might arrive more than once (if someone is messing with the
-- connection) or might arrive in the wrong order.
--
-- Unless latency is an issue, it is recommended that you use lossless custom
-- packets instead.
--
-- * @friendNumber@: The friend number of the friend this lossy packet should
--   be sent to.
-- * @data'@: A byte array containing the packet data.
toxFriendSendLossyPacket
    :: Tox -> FriendNumber -> ByteString -> IO (Either ErrFriendCustomPacket ())
toxFriendSendLossyPacket (Tox tox) (FriendNumber friendNumber) data' =
    withBytesLen data' $ \dataPtr dataLen ->
        callErrFun_ $
            Raw.tox_friend_send_lossy_packet tox friendNumber dataPtr dataLen

-- | Send a custom lossless packet to a friend.
--
-- The first byte of data must be either 69 or in the range 160-191. Maximum
-- length of a custom packet is
-- 'Network.Tox.C.Constants.toxMaxCustomPacketSize'.
--
-- Lossless packet behaviour is comparable to TCP (reliability, arrive in
-- order) but with packets instead of a stream.
--
-- * @friendNumber@: The friend number of the friend this lossless packet
--   should be sent to.
-- * @data'@: A byte array containing the packet data.
toxFriendSendLosslessPacket
    :: Tox -> FriendNumber -> ByteString -> IO (Either ErrFriendCustomPacket ())
toxFriendSendLosslessPacket (Tox tox) (FriendNumber friendNumber) data' =
    withBytesLen data' $ \dataPtr dataLen ->
        callErrFun_ $
            Raw.tox_friend_send_lossless_packet tox friendNumber dataPtr dataLen
