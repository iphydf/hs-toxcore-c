-- | Conferences, the older group chats, and their peers.
module Network.Tox.C.Conference
    ( toxConferenceNew
    , toxConferenceDelete
    , toxConferencePeerCount
    , toxConferenceOfflinePeerCount
    , toxConferenceSetMaxOffline
    , toxConferenceJoin
    , toxConferenceSendMessage
    , toxConferenceGetTitle
    , toxConferenceSetTitle
    , toxConferenceGetType
    , toxConferenceGetId
    , toxConferenceById
    , toxConferenceOfflinePeerGetName
    , toxConferenceOfflinePeerGetPublicKey
    , toxConferenceOfflinePeerGetLastActive
    , toxConferencePeerGetName
    , toxConferencePeerGetPublicKey
    , toxConferencePeerNumberIsOurs
    , toxConferenceInvite
    , toxConferenceGetChatlist
    ) where

import           Data.ByteString       (ByteString)
import           Data.Word             (Word32, Word64)
import qualified FFI.Tox.Tox           as Raw
import           Foreign.C.Enum        (callErrFun, callErrFun_, fromCEnum,
                                        toCEnum)
import           Foreign.Marshal.Utils (toBool)
import           Network.Tox.C.Marshal (getFixedBytesErr, getFixedBytesMaybe,
                                        getList, getSizedErr, withBytesLen,
                                        withFixedBytes)
import           Network.Tox.C.Types   (ConferenceId, ConferenceNumber (..),
                                        ConferenceOfflinePeerNumber (..),
                                        ConferencePeerNumber (..),
                                        ConferenceType, ErrConferenceById,
                                        ErrConferenceDelete,
                                        ErrConferenceGetType,
                                        ErrConferenceInvite, ErrConferenceJoin,
                                        ErrConferenceNew,
                                        ErrConferencePeerQuery,
                                        ErrConferenceSendMessage,
                                        ErrConferenceSetMaxOffline,
                                        ErrConferenceTitle, FriendNumber (..),
                                        MessageType, PublicKey, Tox (..))

-- | Creates a new conference.
--
-- This function creates and connects to a new text conference.
toxConferenceNew :: Tox -> IO (Either ErrConferenceNew ConferenceNumber)
toxConferenceNew (Tox tox) =
    fmap ConferenceNumber <$> callErrFun (Raw.tox_conference_new tox)

-- | This function deletes a conference.
--
-- * @conferenceNumber@: The conference number of the conference to be
--   deleted.
toxConferenceDelete
    :: Tox -> ConferenceNumber -> IO (Either ErrConferenceDelete ())
toxConferenceDelete (Tox tox) (ConferenceNumber conferenceNumber) =
    callErrFun_ $ Raw.tox_conference_delete tox conferenceNumber

-- | Return the number of online peers in the conference.
--
-- The unsigned integers less than this number are the valid values of
-- peer_number for the functions querying these peers. Return value is
-- unspecified on failure.
toxConferencePeerCount
    :: Tox -> ConferenceNumber -> IO (Either ErrConferencePeerQuery Word32)
toxConferencePeerCount (Tox tox) (ConferenceNumber conferenceNumber) =
    callErrFun $ Raw.tox_conference_peer_count tox conferenceNumber

-- | Return the number of offline peers in the conference.
--
-- The unsigned integers less than this number are the valid values of
-- offline_peer_number for the functions querying these peers.
--
-- Return value is unspecified on failure.
toxConferenceOfflinePeerCount
    :: Tox -> ConferenceNumber -> IO (Either ErrConferencePeerQuery Word32)
toxConferenceOfflinePeerCount (Tox tox) (ConferenceNumber conferenceNumber) =
    callErrFun $ Raw.tox_conference_offline_peer_count tox conferenceNumber

-- | Set maximum number of offline peers to store, overriding the default.
toxConferenceSetMaxOffline
    :: Tox
    -> ConferenceNumber
    -> Word32
    -> IO (Either ErrConferenceSetMaxOffline ())
toxConferenceSetMaxOffline (Tox tox) (ConferenceNumber conferenceNumber)
    maxOffline =
    callErrFun_ $
        Raw.tox_conference_set_max_offline tox conferenceNumber maxOffline

-- | Joins a conference that the client has been invited to.
--
-- After successfully joining the conference, the client will not be
-- "connected" to it until a handshaking procedure has been completed. A
-- @conference_connected@ event will then occur for the conference. The client
-- will then remain connected to the conference until the conference is
-- deleted, even across Tox restarts. Many operations on a conference will
-- fail with a corresponding error if attempted on a conference to which the
-- client is not yet connected.
--
-- * @friendNumber@: The friend number of the friend who sent the invite.
-- * @cookie@: Received via the @conference_invite@ event.
toxConferenceJoin
    :: Tox
    -> FriendNumber
    -> ByteString
    -> IO (Either ErrConferenceJoin ConferenceNumber)
toxConferenceJoin (Tox tox) (FriendNumber friendNumber) cookie =
    withBytesLen cookie $ \cookiePtr cookieLen ->
        fmap ConferenceNumber
            <$> callErrFun
                (Raw.tox_conference_join tox friendNumber cookiePtr cookieLen)

-- | Send a text chat message to the conference.
--
-- This function creates a conference message packet and pushes it into the
-- send queue.
--
-- The message length may not exceed
-- 'Network.Tox.C.Constants.toxMaxMessageLength'. Larger messages must be
-- split by the client and sent as separate messages. Other clients can then
-- reassemble the fragments.
--
-- * @conferenceNumber@: The conference number of the conference the message
--   is intended for.
-- * @type'@: Message type (normal, action, ...).
-- * @message@: A non-NULL pointer to the first element of a byte array
--   containing the message text.
toxConferenceSendMessage
    :: Tox
    -> ConferenceNumber
    -> MessageType
    -> ByteString
    -> IO (Either ErrConferenceSendMessage ())
toxConferenceSendMessage (Tox tox) (ConferenceNumber conferenceNumber) type'
    message =
    withBytesLen message $ \messagePtr messageLen ->
        callErrFun_ $
            Raw.tox_conference_send_message tox conferenceNumber
                (toCEnum type')
                messagePtr
                messageLen

-- | Write the title designated by the given conference number to a byte array.
--
-- The data written to @title@ is equal to the data received by the last
-- @conference_title@ callback.
toxConferenceGetTitle
    :: Tox -> ConferenceNumber -> IO (Either ErrConferenceTitle ByteString)
toxConferenceGetTitle (Tox tox) (ConferenceNumber conferenceNumber) =
    getSizedErr
        (Raw.tox_conference_get_title_size tox conferenceNumber)
        (Raw.tox_conference_get_title tox conferenceNumber)

-- | Set the conference title and broadcast it to the rest of the conference.
--
-- Title length cannot be longer than
-- 'Network.Tox.C.Constants.toxMaxNameLength'.
toxConferenceSetTitle
    :: Tox
    -> ConferenceNumber
    -> ByteString
    -> IO (Either ErrConferenceTitle ())
toxConferenceSetTitle (Tox tox) (ConferenceNumber conferenceNumber) title =
    withBytesLen title $ \titlePtr titleLen ->
        callErrFun_ $
            Raw.tox_conference_set_title tox conferenceNumber titlePtr titleLen

-- | Get the type (text or A\/V) for the conference.
toxConferenceGetType
    :: Tox
    -> ConferenceNumber
    -> IO (Either ErrConferenceGetType ConferenceType)
toxConferenceGetType (Tox tox) (ConferenceNumber conferenceNumber) =
    fmap fromCEnum
        <$> callErrFun (Raw.tox_conference_get_type tox conferenceNumber)

-- | Get the conference unique ID.
--
-- If id is NULL, this function has no effect.
toxConferenceGetId :: Tox -> ConferenceNumber -> IO (Maybe ConferenceId)
toxConferenceGetId (Tox tox) (ConferenceNumber conferenceNumber) =
    getFixedBytesMaybe $ Raw.tox_conference_get_id tox conferenceNumber

-- | Return the conference number associated with the specified id.
--
-- * @id'@: A byte array containing the conference id
--   ('Network.Tox.C.Constants.toxConferenceIdSize').
toxConferenceById
    :: Tox -> ConferenceId -> IO (Either ErrConferenceById ConferenceNumber)
toxConferenceById (Tox tox) id' =
    withFixedBytes id' $ \idPtr ->
        fmap ConferenceNumber
            <$> callErrFun (Raw.tox_conference_by_id tox idPtr)

-- | Copy the name of offline_peer_number who is in conference_number to name.
toxConferenceOfflinePeerGetName
    :: Tox
    -> ConferenceNumber
    -> ConferenceOfflinePeerNumber
    -> IO (Either ErrConferencePeerQuery ByteString)
toxConferenceOfflinePeerGetName (Tox tox) (ConferenceNumber conferenceNumber)
    (ConferenceOfflinePeerNumber offlinePeerNumber) =
    getSizedErr
        (Raw.tox_conference_offline_peer_get_name_size tox conferenceNumber
            offlinePeerNumber)
        (Raw.tox_conference_offline_peer_get_name tox conferenceNumber
            offlinePeerNumber)

-- | Copy the public key of offline_peer_number who is in conference_number to
-- public_key.
--
-- public_key must be 'Network.Tox.C.Constants.toxPublicKeySize' long.
toxConferenceOfflinePeerGetPublicKey
    :: Tox
    -> ConferenceNumber
    -> ConferenceOfflinePeerNumber
    -> IO (Either ErrConferencePeerQuery PublicKey)
toxConferenceOfflinePeerGetPublicKey (Tox tox)
    (ConferenceNumber conferenceNumber)
    (ConferenceOfflinePeerNumber offlinePeerNumber) =
    getFixedBytesErr $
        Raw.tox_conference_offline_peer_get_public_key tox conferenceNumber
            offlinePeerNumber

-- | Return a unix-time timestamp of the last time offline_peer_number was seen
-- to be active.
toxConferenceOfflinePeerGetLastActive
    :: Tox
    -> ConferenceNumber
    -> ConferenceOfflinePeerNumber
    -> IO (Either ErrConferencePeerQuery Word64)
toxConferenceOfflinePeerGetLastActive (Tox tox)
    (ConferenceNumber conferenceNumber)
    (ConferenceOfflinePeerNumber offlinePeerNumber) =
    callErrFun $
        Raw.tox_conference_offline_peer_get_last_active tox conferenceNumber
            offlinePeerNumber

-- | Copy the name of peer_number who is in conference_number to name.
toxConferencePeerGetName
    :: Tox
    -> ConferenceNumber
    -> ConferencePeerNumber
    -> IO (Either ErrConferencePeerQuery ByteString)
toxConferencePeerGetName (Tox tox) (ConferenceNumber conferenceNumber)
    (ConferencePeerNumber peerNumber) =
    getSizedErr
        (Raw.tox_conference_peer_get_name_size tox conferenceNumber peerNumber)
        (Raw.tox_conference_peer_get_name tox conferenceNumber peerNumber)

-- | Copy the public key of peer_number who is in conference_number to
-- public_key.
--
-- public_key must be 'Network.Tox.C.Constants.toxPublicKeySize' long.
toxConferencePeerGetPublicKey
    :: Tox
    -> ConferenceNumber
    -> ConferencePeerNumber
    -> IO (Either ErrConferencePeerQuery PublicKey)
toxConferencePeerGetPublicKey (Tox tox) (ConferenceNumber conferenceNumber)
    (ConferencePeerNumber peerNumber) =
    getFixedBytesErr $
        Raw.tox_conference_peer_get_public_key tox conferenceNumber peerNumber

-- | Return true if passed peer_number corresponds to our own.
toxConferencePeerNumberIsOurs
    :: Tox
    -> ConferenceNumber
    -> ConferencePeerNumber
    -> IO (Either ErrConferencePeerQuery Bool)
toxConferencePeerNumberIsOurs (Tox tox) (ConferenceNumber conferenceNumber)
    (ConferencePeerNumber peerNumber) =
    fmap toBool
        <$> callErrFun
            (Raw.tox_conference_peer_number_is_ours tox conferenceNumber
                peerNumber)

-- | Invites a friend to a conference.
--
-- * @friendNumber@: The friend number of the friend we want to invite.
-- * @conferenceNumber@: The conference number of the conference we want to
--   invite the friend to.
toxConferenceInvite
    :: Tox
    -> FriendNumber
    -> ConferenceNumber
    -> IO (Either ErrConferenceInvite ())
toxConferenceInvite (Tox tox) (FriendNumber friendNumber)
    (ConferenceNumber conferenceNumber) =
    callErrFun_ $ Raw.tox_conference_invite tox friendNumber conferenceNumber

-- | Copy a list of valid conference numbers into the array chatlist.
--
-- Determine how much space to allocate for the array with the
-- @tox_conference_get_chatlist_size@ function.
--
-- Note that 'Network.Tox.C.Tox.toxGetSavedata' saves all connected
-- conferences; when a Tox instance is created from savedata in which
-- conferences were saved, those conferences will be connected at startup, and
-- will be listed by 'toxConferenceGetChatlist'.
--
-- The conference number of a loaded conference may differ from the conference
-- number it had when it was saved.
toxConferenceGetChatlist :: Tox -> IO [ConferenceNumber]
toxConferenceGetChatlist (Tox tox) =
    map ConferenceNumber
        <$> getList
            (Raw.tox_conference_get_chatlist_size tox)
            (Raw.tox_conference_get_chatlist tox)
