{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE PatternSynonyms            #-}
-- | The types the safe API shares: enums, ids, fixed-size byte strings, and
-- handles.
module Network.Tox.C.Types
    ( -- * Enumerations
      ConferenceType (..)
    , Connection (..)
    , ErrBootstrap (..)
    , ErrConferenceById (..)
    , ErrConferenceByUid (..)
    , ErrConferenceDelete (..)
    , ErrConferenceGetType (..)
    , ErrConferenceInvite (..)
    , ErrConferenceJoin (..)
    , ErrConferenceNew (..)
    , ErrConferencePeerQuery (..)
    , ErrConferenceSendMessage (..)
    , ErrConferenceSetMaxOffline (..)
    , ErrConferenceTitle (..)
    , ErrDecryption (..)
    , ErrEncryption (..)
    , ErrEventsIterate (..)
    , ErrFileById (..)
    , ErrFileControl (..)
    , ErrFileGet (..)
    , ErrFileSeek (..)
    , ErrFileSend (..)
    , ErrFileSendChunk (..)
    , ErrFriendAdd (..)
    , ErrFriendByPublicKey (..)
    , ErrFriendCustomPacket (..)
    , ErrFriendDelete (..)
    , ErrFriendGetLastOnline (..)
    , ErrFriendGetPublicKey (..)
    , ErrFriendQuery (..)
    , ErrFriendSendMessage (..)
    , ErrGetPort (..)
    , ErrGetSalt (..)
    , ErrGroupById (..)
    , ErrGroupDisconnect (..)
    , ErrGroupInviteAccept (..)
    , ErrGroupInviteFriend (..)
    , ErrGroupIsConnected (..)
    , ErrGroupJoin (..)
    , ErrGroupKickPeer (..)
    , ErrGroupLeave (..)
    , ErrGroupNew (..)
    , ErrGroupPeerQuery (..)
    , ErrGroupReconnect (..)
    , ErrGroupSelfNameSet (..)
    , ErrGroupSelfQuery (..)
    , ErrGroupSelfStatusSet (..)
    , ErrGroupSendCustomPacket (..)
    , ErrGroupSendCustomPrivatePacket (..)
    , ErrGroupSendMessage (..)
    , ErrGroupSendPrivateMessage (..)
    , ErrGroupSetIgnore (..)
    , ErrGroupSetPassword (..)
    , ErrGroupSetPeerLimit (..)
    , ErrGroupSetPrivacyState (..)
    , ErrGroupSetRole (..)
    , ErrGroupSetTopicLock (..)
    , ErrGroupSetVoiceState (..)
    , ErrGroupStateQuery (..)
    , ErrGroupTopicSet (..)
    , ErrKeyDerivation (..)
    , ErrNew (..)
    , ErrOptionsNew (..)
    , ErrSetInfo (..)
    , ErrSetTyping (..)
    , EventType (..)
    , FileControl (..)
    , GroupExitType (..)
    , GroupJoinFail (..)
    , GroupModEvent (..)
    , GroupPrivacyState (..)
    , GroupRole (..)
    , GroupTopicLock (..)
    , GroupVoiceState (..)
    , LogLevel (..)
    , MessageType (..)
    , ProxyType (..)
    , SavedataType (..)
    , UserStatus (..)
    , AvCallControl (..)
    , AvErrAnswer (..)
    , AvErrBitRateSet (..)
    , AvErrCall (..)
    , AvErrCallControl (..)
    , AvErrNew (..)
    , AvErrSendFrame (..)
      -- * Open enumerations
    , FileKind (..)
    , pattern FileKindData
    , pattern FileKindAvatar
    , pattern FileKindSticker
    , pattern FileKindSha1
    , pattern FileKindSha256
    , AvFriendCallState (..)
    , pattern AvFriendCallStateNone
    , pattern AvFriendCallStateError
    , pattern AvFriendCallStateFinished
    , pattern AvFriendCallStateSendingA
    , pattern AvFriendCallStateSendingV
    , pattern AvFriendCallStateAcceptingA
    , pattern AvFriendCallStateAcceptingV
      -- * Numbers
    , ConferenceNumber (..)
    , ConferenceOfflinePeerNumber (..)
    , ConferencePeerNumber (..)
    , FileNumber (..)
    , FriendMessageId (..)
    , FriendNumber (..)
    , GroupMessageId (..)
    , GroupNumber (..)
    , GroupPeerNumber (..)
      -- * Units
    , AvBitRate (..)
    , AvChannels (..)
    , AvHeight (..)
    , AvSamplingRate (..)
    , AvWidth (..)
    , Port (..)
      -- * Fixed-size byte strings
    , Address
    , ConferenceId
    , DhtId
    , FileId
    , GroupChatId
    , GroupPeerPublicKey
    , Hash
    , PassSalt
    , PublicKey
    , SecretKey
      -- * Handles
    , PassKey (..)
    , Tox (..)
    , ToxAv (..)
    ) where

import           Data.Bits               (Bits)
import           Data.ByteString         (ByteString)
import           Data.Word               (Word16, Word32, Word8)
import           FFI.Tox.Types           (PassKeyStruct, ToxAvPtr, ToxPtr)
import           Foreign.C.Enum          (CEnum (..), unknownCEnum)
import           Foreign.ForeignPtr      (ForeignPtr)
import           Network.Tox.C.Constants (toxAddressSize, toxConferenceIdSize,
                                          toxDhtIdSize, toxFileIdLength,
                                          toxGroupChatIdSize,
                                          toxGroupPeerPublicKeySize,
                                          toxHashLength, toxPassSaltLength,
                                          toxPublicKeySize, toxSecretKeySize)
import           Network.Tox.C.Marshal   (CallbackRegistry, FixedBytes (..))

data ConferenceType
    = ConferenceTypeText
      -- ^ Text-only conferences that must be accepted with the
      -- 'Network.Tox.C.Conference.toxConferenceJoin' function.
    | ConferenceTypeAv
      -- ^ Video conference. The function to accept these is in toxav.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ConferenceType where
    toCEnum ConferenceTypeText = 0
    toCEnum ConferenceTypeAv   = 1

    fromCEnum 0 = ConferenceTypeText
    fromCEnum 1 = ConferenceTypeAv
    fromCEnum n = unknownCEnum "Tox_Conference_Type" n

data Connection
    = ConnectionNone
      -- ^ There is no connection.
      --
      -- This instance, or the friend the state change is about, is now
      -- offline.
    | ConnectionTcp
      -- ^ A TCP connection has been established.
      --
      -- For the own instance, this means it is connected through a TCP relay,
      -- only. For a friend, this means that the connection to that particular
      -- friend goes through a TCP relay.
    | ConnectionUdp
      -- ^ A UDP connection has been established.
      --
      -- For the own instance, this means it is able to send UDP packets to
      -- DHT nodes, but may still be connected to a TCP relay. For a friend,
      -- this means that the connection to that particular friend was built
      -- using direct UDP packets.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum Connection where
    toCEnum ConnectionNone = 0
    toCEnum ConnectionTcp  = 1
    toCEnum ConnectionUdp  = 2

    fromCEnum 0 = ConnectionNone
    fromCEnum 1 = ConnectionTcp
    fromCEnum 2 = ConnectionUdp
    fromCEnum n = unknownCEnum "Tox_Connection" n

data ErrBootstrap
    = ErrBootstrapNull
      -- ^ One of the arguments to the function was NULL when it was not
      -- expected.
    | ErrBootstrapBadHost
      -- ^ The hostname could not be resolved to an IP address, the IP address
      -- passed was invalid, or the function failed to send the initial
      -- request packet to the bootstrap node or TCP relay.
    | ErrBootstrapBadPort
      -- ^ The port passed was invalid. The valid port range is (1, 65535).
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrBootstrap where
    toCEnum ErrBootstrapNull    = 1
    toCEnum ErrBootstrapBadHost = 2
    toCEnum ErrBootstrapBadPort = 3

    fromCEnum 1 = ErrBootstrapNull
    fromCEnum 2 = ErrBootstrapBadHost
    fromCEnum 3 = ErrBootstrapBadPort
    fromCEnum n = unknownCEnum "Tox_Err_Bootstrap" n

data ErrConferenceById
    = ErrConferenceByIdNull
      -- ^ One of the arguments to the function was NULL when it was not
      -- expected.
    | ErrConferenceByIdNotFound
      -- ^ No conference with the given id exists on the conference list.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrConferenceById where
    toCEnum ErrConferenceByIdNull     = 1
    toCEnum ErrConferenceByIdNotFound = 2

    fromCEnum 1 = ErrConferenceByIdNull
    fromCEnum 2 = ErrConferenceByIdNotFound
    fromCEnum n = unknownCEnum "Tox_Err_Conference_By_Id" n

data ErrConferenceByUid
    = ErrConferenceByUidNull
      -- ^ One of the arguments to the function was NULL when it was not
      -- expected.
    | ErrConferenceByUidNotFound
      -- ^ No conference with the given uid exists on the conference list.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrConferenceByUid where
    toCEnum ErrConferenceByUidNull     = 1
    toCEnum ErrConferenceByUidNotFound = 2

    fromCEnum 1 = ErrConferenceByUidNull
    fromCEnum 2 = ErrConferenceByUidNotFound
    fromCEnum n = unknownCEnum "Tox_Err_Conference_By_Uid" n

data ErrConferenceDelete
    = ErrConferenceDeleteConferenceNotFound
      -- ^ The conference number passed did not designate a valid conference.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrConferenceDelete where
    toCEnum ErrConferenceDeleteConferenceNotFound = 1

    fromCEnum 1 = ErrConferenceDeleteConferenceNotFound
    fromCEnum n = unknownCEnum "Tox_Err_Conference_Delete" n

data ErrConferenceGetType
    = ErrConferenceGetTypeConferenceNotFound
      -- ^ The conference number passed did not designate a valid conference.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrConferenceGetType where
    toCEnum ErrConferenceGetTypeConferenceNotFound = 1

    fromCEnum 1 = ErrConferenceGetTypeConferenceNotFound
    fromCEnum n = unknownCEnum "Tox_Err_Conference_Get_Type" n

data ErrConferenceInvite
    = ErrConferenceInviteConferenceNotFound
      -- ^ The conference number passed did not designate a valid conference.
    | ErrConferenceInviteFailSend
      -- ^ The invite packet failed to send.
    | ErrConferenceInviteNoConnection
      -- ^ The client is not connected to the conference.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrConferenceInvite where
    toCEnum ErrConferenceInviteConferenceNotFound = 1
    toCEnum ErrConferenceInviteFailSend           = 2
    toCEnum ErrConferenceInviteNoConnection       = 3

    fromCEnum 1 = ErrConferenceInviteConferenceNotFound
    fromCEnum 2 = ErrConferenceInviteFailSend
    fromCEnum 3 = ErrConferenceInviteNoConnection
    fromCEnum n = unknownCEnum "Tox_Err_Conference_Invite" n

data ErrConferenceJoin
    = ErrConferenceJoinInvalidLength
      -- ^ The cookie passed has an invalid length.
    | ErrConferenceJoinWrongType
      -- ^ The conference is not the expected type. This indicates an invalid
      -- cookie.
    | ErrConferenceJoinFriendNotFound
      -- ^ The friend number passed does not designate a valid friend.
    | ErrConferenceJoinDuplicate
      -- ^ Client is already in this conference.
    | ErrConferenceJoinInitFail
      -- ^ Conference instance failed to initialize.
    | ErrConferenceJoinFailSend
      -- ^ The join packet failed to send.
    | ErrConferenceJoinNull
      -- ^ The cookie passed was NULL.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrConferenceJoin where
    toCEnum ErrConferenceJoinInvalidLength  = 1
    toCEnum ErrConferenceJoinWrongType      = 2
    toCEnum ErrConferenceJoinFriendNotFound = 3
    toCEnum ErrConferenceJoinDuplicate      = 4
    toCEnum ErrConferenceJoinInitFail       = 5
    toCEnum ErrConferenceJoinFailSend       = 6
    toCEnum ErrConferenceJoinNull           = 7

    fromCEnum 1 = ErrConferenceJoinInvalidLength
    fromCEnum 2 = ErrConferenceJoinWrongType
    fromCEnum 3 = ErrConferenceJoinFriendNotFound
    fromCEnum 4 = ErrConferenceJoinDuplicate
    fromCEnum 5 = ErrConferenceJoinInitFail
    fromCEnum 6 = ErrConferenceJoinFailSend
    fromCEnum 7 = ErrConferenceJoinNull
    fromCEnum n = unknownCEnum "Tox_Err_Conference_Join" n

data ErrConferenceNew
    = ErrConferenceNewInit
      -- ^ The conference instance failed to initialize.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrConferenceNew where
    toCEnum ErrConferenceNewInit = 1

    fromCEnum 1 = ErrConferenceNewInit
    fromCEnum n = unknownCEnum "Tox_Err_Conference_New" n

data ErrConferencePeerQuery
    = ErrConferencePeerQueryConferenceNotFound
      -- ^ The conference number passed did not designate a valid conference.
    | ErrConferencePeerQueryPeerNotFound
      -- ^ The peer number passed did not designate a valid peer.
    | ErrConferencePeerQueryNoConnection
      -- ^ The client is not connected to the conference.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrConferencePeerQuery where
    toCEnum ErrConferencePeerQueryConferenceNotFound = 1
    toCEnum ErrConferencePeerQueryPeerNotFound       = 2
    toCEnum ErrConferencePeerQueryNoConnection       = 3

    fromCEnum 1 = ErrConferencePeerQueryConferenceNotFound
    fromCEnum 2 = ErrConferencePeerQueryPeerNotFound
    fromCEnum 3 = ErrConferencePeerQueryNoConnection
    fromCEnum n = unknownCEnum "Tox_Err_Conference_Peer_Query" n

data ErrConferenceSendMessage
    = ErrConferenceSendMessageConferenceNotFound
      -- ^ The conference number passed did not designate a valid conference.
    | ErrConferenceSendMessageTooLong
      -- ^ The message is too long.
    | ErrConferenceSendMessageNoConnection
      -- ^ The client is not connected to the conference.
    | ErrConferenceSendMessageFailSend
      -- ^ The message packet failed to send.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrConferenceSendMessage where
    toCEnum ErrConferenceSendMessageConferenceNotFound = 1
    toCEnum ErrConferenceSendMessageTooLong            = 2
    toCEnum ErrConferenceSendMessageNoConnection       = 3
    toCEnum ErrConferenceSendMessageFailSend           = 4

    fromCEnum 1 = ErrConferenceSendMessageConferenceNotFound
    fromCEnum 2 = ErrConferenceSendMessageTooLong
    fromCEnum 3 = ErrConferenceSendMessageNoConnection
    fromCEnum 4 = ErrConferenceSendMessageFailSend
    fromCEnum n = unknownCEnum "Tox_Err_Conference_Send_Message" n

data ErrConferenceSetMaxOffline
    = ErrConferenceSetMaxOfflineConferenceNotFound
      -- ^ The conference number passed did not designate a valid conference.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrConferenceSetMaxOffline where
    toCEnum ErrConferenceSetMaxOfflineConferenceNotFound = 1

    fromCEnum 1 = ErrConferenceSetMaxOfflineConferenceNotFound
    fromCEnum n = unknownCEnum "Tox_Err_Conference_Set_Max_Offline" n

data ErrConferenceTitle
    = ErrConferenceTitleConferenceNotFound
      -- ^ The conference number passed did not designate a valid conference.
    | ErrConferenceTitleInvalidLength
      -- ^ The title is too long or empty.
    | ErrConferenceTitleFailSend
      -- ^ The title packet failed to send.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrConferenceTitle where
    toCEnum ErrConferenceTitleConferenceNotFound = 1
    toCEnum ErrConferenceTitleInvalidLength      = 2
    toCEnum ErrConferenceTitleFailSend           = 3

    fromCEnum 1 = ErrConferenceTitleConferenceNotFound
    fromCEnum 2 = ErrConferenceTitleInvalidLength
    fromCEnum 3 = ErrConferenceTitleFailSend
    fromCEnum n = unknownCEnum "Tox_Err_Conference_Title" n

data ErrDecryption
    = ErrDecryptionNull
      -- ^ One of the arguments to the function was NULL when it was not
      -- expected.
    | ErrDecryptionInvalidLength
      -- ^ The input data was shorter than
      -- 'Network.Tox.C.Constants.toxPassEncryptionExtraLength' bytes
    | ErrDecryptionBadFormat
      -- ^ The input data is missing the magic number (i.e. wasn't created by
      -- this module, or is corrupted).
    | ErrDecryptionKeyDerivationFailed
      -- ^ The crypto lib was unable to derive a key from the given passphrase,
      -- which is usually a lack of memory issue. The functions accepting keys
      -- do not produce this error.
    | ErrDecryptionFailed
      -- ^ The encrypted byte array could not be decrypted. Either the data was
      -- corrupted or the password\/key was incorrect.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrDecryption where
    toCEnum ErrDecryptionNull                = 1
    toCEnum ErrDecryptionInvalidLength       = 2
    toCEnum ErrDecryptionBadFormat           = 3
    toCEnum ErrDecryptionKeyDerivationFailed = 4
    toCEnum ErrDecryptionFailed              = 5

    fromCEnum 1 = ErrDecryptionNull
    fromCEnum 2 = ErrDecryptionInvalidLength
    fromCEnum 3 = ErrDecryptionBadFormat
    fromCEnum 4 = ErrDecryptionKeyDerivationFailed
    fromCEnum 5 = ErrDecryptionFailed
    fromCEnum n = unknownCEnum "Tox_Err_Decryption" n

data ErrEncryption
    = ErrEncryptionNull
      -- ^ One of the arguments to the function was NULL when it was not
      -- expected.
    | ErrEncryptionKeyDerivationFailed
      -- ^ The crypto lib was unable to derive a key from the given passphrase,
      -- which is usually a lack of memory issue. The functions accepting keys
      -- do not produce this error.
    | ErrEncryptionFailed
      -- ^ The encryption itself failed.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrEncryption where
    toCEnum ErrEncryptionNull                = 1
    toCEnum ErrEncryptionKeyDerivationFailed = 2
    toCEnum ErrEncryptionFailed              = 3

    fromCEnum 1 = ErrEncryptionNull
    fromCEnum 2 = ErrEncryptionKeyDerivationFailed
    fromCEnum 3 = ErrEncryptionFailed
    fromCEnum n = unknownCEnum "Tox_Err_Encryption" n

data ErrEventsIterate
    = ErrEventsIterateMalloc
      -- ^ The function failed to allocate enough memory to store the events.
      --
      -- Some events may still be stored if the return value is NULL. The
      -- events object will always be valid (or NULL) but if this error code
      -- is set, the function may have missed some events.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrEventsIterate where
    toCEnum ErrEventsIterateMalloc = 1

    fromCEnum 1 = ErrEventsIterateMalloc
    fromCEnum n = unknownCEnum "Tox_Err_Events_Iterate" n

data ErrFileById
    = ErrFileByIdNull
      -- ^ One of the arguments to the function was NULL when it was not
      -- expected.
    | ErrFileByIdFriendNotFound
      -- ^ The friend_number passed did not designate a valid friend.
    | ErrFileByIdNotFound
      -- ^ No file transfer with the given ID exists.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrFileById where
    toCEnum ErrFileByIdNull           = 1
    toCEnum ErrFileByIdFriendNotFound = 2
    toCEnum ErrFileByIdNotFound       = 3

    fromCEnum 1 = ErrFileByIdNull
    fromCEnum 2 = ErrFileByIdFriendNotFound
    fromCEnum 3 = ErrFileByIdNotFound
    fromCEnum n = unknownCEnum "Tox_Err_File_By_Id" n

data ErrFileControl
    = ErrFileControlFriendNotFound
      -- ^ The friend_number passed did not designate a valid friend.
    | ErrFileControlFriendNotConnected
      -- ^ This client is currently not connected to the friend.
    | ErrFileControlNotFound
      -- ^ No file transfer with the given file number was found for the given
      -- friend.
    | ErrFileControlNotPaused
      -- ^ A RESUME control was sent, but the file transfer is running normally.
    | ErrFileControlDenied
      -- ^ A RESUME control was sent, but the file transfer was paused by the
      -- other party. Only the party that paused the transfer can resume it.
    | ErrFileControlAlreadyPaused
      -- ^ A PAUSE control was sent, but the file transfer was already paused.
    | ErrFileControlSendq
      -- ^ Packet queue is full.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrFileControl where
    toCEnum ErrFileControlFriendNotFound     = 1
    toCEnum ErrFileControlFriendNotConnected = 2
    toCEnum ErrFileControlNotFound           = 3
    toCEnum ErrFileControlNotPaused          = 4
    toCEnum ErrFileControlDenied             = 5
    toCEnum ErrFileControlAlreadyPaused      = 6
    toCEnum ErrFileControlSendq              = 7

    fromCEnum 1 = ErrFileControlFriendNotFound
    fromCEnum 2 = ErrFileControlFriendNotConnected
    fromCEnum 3 = ErrFileControlNotFound
    fromCEnum 4 = ErrFileControlNotPaused
    fromCEnum 5 = ErrFileControlDenied
    fromCEnum 6 = ErrFileControlAlreadyPaused
    fromCEnum 7 = ErrFileControlSendq
    fromCEnum n = unknownCEnum "Tox_Err_File_Control" n

data ErrFileGet
    = ErrFileGetNull
      -- ^ One of the arguments to the function was NULL when it was not
      -- expected.
    | ErrFileGetFriendNotFound
      -- ^ The friend_number passed did not designate a valid friend.
    | ErrFileGetNotFound
      -- ^ No file transfer with the given file number was found for the given
      -- friend.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrFileGet where
    toCEnum ErrFileGetNull           = 1
    toCEnum ErrFileGetFriendNotFound = 2
    toCEnum ErrFileGetNotFound       = 3

    fromCEnum 1 = ErrFileGetNull
    fromCEnum 2 = ErrFileGetFriendNotFound
    fromCEnum 3 = ErrFileGetNotFound
    fromCEnum n = unknownCEnum "Tox_Err_File_Get" n

data ErrFileSeek
    = ErrFileSeekFriendNotFound
      -- ^ The friend_number passed did not designate a valid friend.
    | ErrFileSeekFriendNotConnected
      -- ^ This client is currently not connected to the friend.
    | ErrFileSeekNotFound
      -- ^ No file transfer with the given file number was found for the given
      -- friend.
    | ErrFileSeekDenied
      -- ^ File was not in a state where it could be seeked.
    | ErrFileSeekInvalidPosition
      -- ^ Seek position was invalid
    | ErrFileSeekSendq
      -- ^ Packet queue is full.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrFileSeek where
    toCEnum ErrFileSeekFriendNotFound     = 1
    toCEnum ErrFileSeekFriendNotConnected = 2
    toCEnum ErrFileSeekNotFound           = 3
    toCEnum ErrFileSeekDenied             = 4
    toCEnum ErrFileSeekInvalidPosition    = 5
    toCEnum ErrFileSeekSendq              = 6

    fromCEnum 1 = ErrFileSeekFriendNotFound
    fromCEnum 2 = ErrFileSeekFriendNotConnected
    fromCEnum 3 = ErrFileSeekNotFound
    fromCEnum 4 = ErrFileSeekDenied
    fromCEnum 5 = ErrFileSeekInvalidPosition
    fromCEnum 6 = ErrFileSeekSendq
    fromCEnum n = unknownCEnum "Tox_Err_File_Seek" n

data ErrFileSend
    = ErrFileSendNull
      -- ^ One of the arguments to the function was NULL when it was not
      -- expected.
    | ErrFileSendFriendNotFound
      -- ^ The friend_number passed did not designate a valid friend.
    | ErrFileSendFriendNotConnected
      -- ^ This client is currently not connected to the friend.
    | ErrFileSendNameTooLong
      -- ^ Filename length exceeded
      -- 'Network.Tox.C.Constants.toxMaxFilenameLength' bytes.
    | ErrFileSendTooMany
      -- ^ Too many ongoing transfers. The maximum number of concurrent file
      -- transfers is 256 per friend per direction (sending and receiving).
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrFileSend where
    toCEnum ErrFileSendNull               = 1
    toCEnum ErrFileSendFriendNotFound     = 2
    toCEnum ErrFileSendFriendNotConnected = 3
    toCEnum ErrFileSendNameTooLong        = 4
    toCEnum ErrFileSendTooMany            = 5

    fromCEnum 1 = ErrFileSendNull
    fromCEnum 2 = ErrFileSendFriendNotFound
    fromCEnum 3 = ErrFileSendFriendNotConnected
    fromCEnum 4 = ErrFileSendNameTooLong
    fromCEnum 5 = ErrFileSendTooMany
    fromCEnum n = unknownCEnum "Tox_Err_File_Send" n

data ErrFileSendChunk
    = ErrFileSendChunkNull
      -- ^ The length parameter was non-zero, but data was NULL.
    | ErrFileSendChunkFriendNotFound
      -- ^ The friend_number passed did not designate a valid friend.
    | ErrFileSendChunkFriendNotConnected
      -- ^ This client is currently not connected to the friend.
    | ErrFileSendChunkNotFound
      -- ^ No file transfer with the given file number was found for the given
      -- friend.
    | ErrFileSendChunkNotTransferring
      -- ^ File transfer was found but isn't in a transferring state: (paused,
      -- done, broken, etc...) (happens only when not called from the request
      -- chunk callback).
    | ErrFileSendChunkInvalidLength
      -- ^ Attempted to send more or less data than requested. The requested
      -- data size is adjusted according to maximum transmission unit and the
      -- expected end of the file. Trying to send less or more than requested
      -- will return this error.
    | ErrFileSendChunkSendq
      -- ^ Packet queue is full.
    | ErrFileSendChunkWrongPosition
      -- ^ Position parameter was wrong.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrFileSendChunk where
    toCEnum ErrFileSendChunkNull               = 1
    toCEnum ErrFileSendChunkFriendNotFound     = 2
    toCEnum ErrFileSendChunkFriendNotConnected = 3
    toCEnum ErrFileSendChunkNotFound           = 4
    toCEnum ErrFileSendChunkNotTransferring    = 5
    toCEnum ErrFileSendChunkInvalidLength      = 6
    toCEnum ErrFileSendChunkSendq              = 7
    toCEnum ErrFileSendChunkWrongPosition      = 8

    fromCEnum 1 = ErrFileSendChunkNull
    fromCEnum 2 = ErrFileSendChunkFriendNotFound
    fromCEnum 3 = ErrFileSendChunkFriendNotConnected
    fromCEnum 4 = ErrFileSendChunkNotFound
    fromCEnum 5 = ErrFileSendChunkNotTransferring
    fromCEnum 6 = ErrFileSendChunkInvalidLength
    fromCEnum 7 = ErrFileSendChunkSendq
    fromCEnum 8 = ErrFileSendChunkWrongPosition
    fromCEnum n = unknownCEnum "Tox_Err_File_Send_Chunk" n

data ErrFriendAdd
    = ErrFriendAddNull
      -- ^ One of the arguments to the function was NULL when it was not
      -- expected.
    | ErrFriendAddTooLong
      -- ^ The length of the friend request message exceeded
      -- 'Network.Tox.C.Constants.toxMaxFriendRequestLength'.
    | ErrFriendAddNoMessage
      -- ^ The friend request message was empty. This, and the TOO_LONG code
      -- will never be returned from
      -- 'Network.Tox.C.Friend.toxFriendAddNorequest'.
    | ErrFriendAddOwnKey
      -- ^ The friend address belongs to the sending client.
    | ErrFriendAddAlreadySent
      -- ^ A friend request has already been sent, or the address belongs to a
      -- friend that is already on the friend list.
    | ErrFriendAddBadChecksum
      -- ^ The friend address checksum failed.
    | ErrFriendAddSetNewNospam
      -- ^ The friend was already there, but the nospam value was different.
    | ErrFriendAddMalloc
      -- ^ A memory allocation failed when trying to increase the friend list
      -- size.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrFriendAdd where
    toCEnum ErrFriendAddNull         = 1
    toCEnum ErrFriendAddTooLong      = 2
    toCEnum ErrFriendAddNoMessage    = 3
    toCEnum ErrFriendAddOwnKey       = 4
    toCEnum ErrFriendAddAlreadySent  = 5
    toCEnum ErrFriendAddBadChecksum  = 6
    toCEnum ErrFriendAddSetNewNospam = 7
    toCEnum ErrFriendAddMalloc       = 8

    fromCEnum 1 = ErrFriendAddNull
    fromCEnum 2 = ErrFriendAddTooLong
    fromCEnum 3 = ErrFriendAddNoMessage
    fromCEnum 4 = ErrFriendAddOwnKey
    fromCEnum 5 = ErrFriendAddAlreadySent
    fromCEnum 6 = ErrFriendAddBadChecksum
    fromCEnum 7 = ErrFriendAddSetNewNospam
    fromCEnum 8 = ErrFriendAddMalloc
    fromCEnum n = unknownCEnum "Tox_Err_Friend_Add" n

data ErrFriendByPublicKey
    = ErrFriendByPublicKeyNull
      -- ^ One of the arguments to the function was NULL when it was not
      -- expected.
    | ErrFriendByPublicKeyNotFound
      -- ^ No friend with the given Public Key exists on the friend list.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrFriendByPublicKey where
    toCEnum ErrFriendByPublicKeyNull     = 1
    toCEnum ErrFriendByPublicKeyNotFound = 2

    fromCEnum 1 = ErrFriendByPublicKeyNull
    fromCEnum 2 = ErrFriendByPublicKeyNotFound
    fromCEnum n = unknownCEnum "Tox_Err_Friend_By_Public_Key" n

data ErrFriendCustomPacket
    = ErrFriendCustomPacketNull
      -- ^ One of the arguments to the function was NULL when it was not
      -- expected.
    | ErrFriendCustomPacketFriendNotFound
      -- ^ The friend number did not designate a valid friend.
    | ErrFriendCustomPacketFriendNotConnected
      -- ^ This client is currently not connected to the friend.
    | ErrFriendCustomPacketInvalid
      -- ^ The first byte of data was not one of the permitted values; for lossy
      -- packets the first byte must be in the range 192-254, and for lossless
      -- packets it must be either 69 or in the range 160-191.
    | ErrFriendCustomPacketEmpty
      -- ^ Attempted to send an empty packet.
    | ErrFriendCustomPacketTooLong
      -- ^ Packet data length exceeded
      -- 'Network.Tox.C.Constants.toxMaxCustomPacketSize'.
    | ErrFriendCustomPacketSendq
      -- ^ Packet queue is full.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrFriendCustomPacket where
    toCEnum ErrFriendCustomPacketNull               = 1
    toCEnum ErrFriendCustomPacketFriendNotFound     = 2
    toCEnum ErrFriendCustomPacketFriendNotConnected = 3
    toCEnum ErrFriendCustomPacketInvalid            = 4
    toCEnum ErrFriendCustomPacketEmpty              = 5
    toCEnum ErrFriendCustomPacketTooLong            = 6
    toCEnum ErrFriendCustomPacketSendq              = 7

    fromCEnum 1 = ErrFriendCustomPacketNull
    fromCEnum 2 = ErrFriendCustomPacketFriendNotFound
    fromCEnum 3 = ErrFriendCustomPacketFriendNotConnected
    fromCEnum 4 = ErrFriendCustomPacketInvalid
    fromCEnum 5 = ErrFriendCustomPacketEmpty
    fromCEnum 6 = ErrFriendCustomPacketTooLong
    fromCEnum 7 = ErrFriendCustomPacketSendq
    fromCEnum n = unknownCEnum "Tox_Err_Friend_Custom_Packet" n

data ErrFriendDelete
    = ErrFriendDeleteFriendNotFound
      -- ^ There was no friend with the given friend number. No friends were
      -- deleted.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrFriendDelete where
    toCEnum ErrFriendDeleteFriendNotFound = 1

    fromCEnum 1 = ErrFriendDeleteFriendNotFound
    fromCEnum n = unknownCEnum "Tox_Err_Friend_Delete" n

data ErrFriendGetLastOnline
    = ErrFriendGetLastOnlineFriendNotFound
      -- ^ No friend with the given number exists on the friend list.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrFriendGetLastOnline where
    toCEnum ErrFriendGetLastOnlineFriendNotFound = 1

    fromCEnum 1 = ErrFriendGetLastOnlineFriendNotFound
    fromCEnum n = unknownCEnum "Tox_Err_Friend_Get_Last_Online" n

data ErrFriendGetPublicKey
    = ErrFriendGetPublicKeyFriendNotFound
      -- ^ No friend with the given number exists on the friend list.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrFriendGetPublicKey where
    toCEnum ErrFriendGetPublicKeyFriendNotFound = 1

    fromCEnum 1 = ErrFriendGetPublicKeyFriendNotFound
    fromCEnum n = unknownCEnum "Tox_Err_Friend_Get_Public_Key" n

data ErrFriendQuery
    = ErrFriendQueryNull
      -- ^ The pointer parameter for storing the query result (name, message)
      -- was NULL. Unlike the @_self_@ variants of these functions, which have
      -- no effect when a parameter is NULL, these functions return an error
      -- in that case.
    | ErrFriendQueryFriendNotFound
      -- ^ The friend_number did not designate a valid friend.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrFriendQuery where
    toCEnum ErrFriendQueryNull           = 1
    toCEnum ErrFriendQueryFriendNotFound = 2

    fromCEnum 1 = ErrFriendQueryNull
    fromCEnum 2 = ErrFriendQueryFriendNotFound
    fromCEnum n = unknownCEnum "Tox_Err_Friend_Query" n

data ErrFriendSendMessage
    = ErrFriendSendMessageNull
      -- ^ One of the arguments to the function was NULL when it was not
      -- expected.
    | ErrFriendSendMessageFriendNotFound
      -- ^ The friend number did not designate a valid friend.
    | ErrFriendSendMessageFriendNotConnected
      -- ^ This client is currently not connected to the friend.
    | ErrFriendSendMessageSendq
      -- ^ An allocation error occurred while increasing the send queue size.
    | ErrFriendSendMessageTooLong
      -- ^ Message length exceeded
      -- 'Network.Tox.C.Constants.toxMaxMessageLength'.
    | ErrFriendSendMessageEmpty
      -- ^ Attempted to send a zero-length message.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrFriendSendMessage where
    toCEnum ErrFriendSendMessageNull               = 1
    toCEnum ErrFriendSendMessageFriendNotFound     = 2
    toCEnum ErrFriendSendMessageFriendNotConnected = 3
    toCEnum ErrFriendSendMessageSendq              = 4
    toCEnum ErrFriendSendMessageTooLong            = 5
    toCEnum ErrFriendSendMessageEmpty              = 6

    fromCEnum 1 = ErrFriendSendMessageNull
    fromCEnum 2 = ErrFriendSendMessageFriendNotFound
    fromCEnum 3 = ErrFriendSendMessageFriendNotConnected
    fromCEnum 4 = ErrFriendSendMessageSendq
    fromCEnum 5 = ErrFriendSendMessageTooLong
    fromCEnum 6 = ErrFriendSendMessageEmpty
    fromCEnum n = unknownCEnum "Tox_Err_Friend_Send_Message" n

data ErrGetPort
    = ErrGetPortNotBound
      -- ^ The instance was not bound to any port.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrGetPort where
    toCEnum ErrGetPortNotBound = 1

    fromCEnum 1 = ErrGetPortNotBound
    fromCEnum n = unknownCEnum "Tox_Err_Get_Port" n

data ErrGetSalt
    = ErrGetSaltNull
      -- ^ One of the arguments to the function was NULL when it was not
      -- expected.
    | ErrGetSaltBadFormat
      -- ^ The input data is missing the magic number (i.e. wasn't created by
      -- this module, or is corrupted).
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrGetSalt where
    toCEnum ErrGetSaltNull      = 1
    toCEnum ErrGetSaltBadFormat = 2

    fromCEnum 1 = ErrGetSaltNull
    fromCEnum 2 = ErrGetSaltBadFormat
    fromCEnum n = unknownCEnum "Tox_Err_Get_Salt" n

data ErrGroupById
    = ErrGroupByIdNull
      -- ^ One of the arguments to the function was NULL when it was not
      -- expected.
    | ErrGroupByIdNotFound
      -- ^ No group with the given ID exists on the group list.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrGroupById where
    toCEnum ErrGroupByIdNull     = 1
    toCEnum ErrGroupByIdNotFound = 2

    fromCEnum 1 = ErrGroupByIdNull
    fromCEnum 2 = ErrGroupByIdNotFound
    fromCEnum n = unknownCEnum "Tox_Err_Group_By_Id" n

data ErrGroupDisconnect
    = ErrGroupDisconnectGroupNotFound
      -- ^ The group number passed did not designate a valid group.
    | ErrGroupDisconnectAlreadyDisconnected
      -- ^ The group is already disconnected.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrGroupDisconnect where
    toCEnum ErrGroupDisconnectGroupNotFound       = 1
    toCEnum ErrGroupDisconnectAlreadyDisconnected = 2

    fromCEnum 1 = ErrGroupDisconnectGroupNotFound
    fromCEnum 2 = ErrGroupDisconnectAlreadyDisconnected
    fromCEnum n = unknownCEnum "Tox_Err_Group_Disconnect" n

data ErrGroupInviteAccept
    = ErrGroupInviteAcceptBadInvite
      -- ^ The invite data is not in the expected format.
    | ErrGroupInviteAcceptInitFailed
      -- ^ The group instance failed to initialize.
    | ErrGroupInviteAcceptTooLong
      -- ^ name exceeds 'Network.Tox.C.Constants.toxMaxNameLength'
    | ErrGroupInviteAcceptEmpty
      -- ^ name is NULL or name_length is zero.
    | ErrGroupInviteAcceptPassword
      -- ^ Failed to set password. This usually occurs if the password exceeds
      -- 'Network.Tox.C.Constants.toxGroupMaxPasswordSize'.
    | ErrGroupInviteAcceptFriendNotFound
      -- ^ The friend number passed did not designate a valid friend.
    | ErrGroupInviteAcceptFailSend
      -- ^ Packet failed to send.
    | ErrGroupInviteAcceptNull
      -- ^ Invite data or name is NULL.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrGroupInviteAccept where
    toCEnum ErrGroupInviteAcceptBadInvite      = 1
    toCEnum ErrGroupInviteAcceptInitFailed     = 2
    toCEnum ErrGroupInviteAcceptTooLong        = 3
    toCEnum ErrGroupInviteAcceptEmpty          = 4
    toCEnum ErrGroupInviteAcceptPassword       = 5
    toCEnum ErrGroupInviteAcceptFriendNotFound = 6
    toCEnum ErrGroupInviteAcceptFailSend       = 7
    toCEnum ErrGroupInviteAcceptNull           = 8

    fromCEnum 1 = ErrGroupInviteAcceptBadInvite
    fromCEnum 2 = ErrGroupInviteAcceptInitFailed
    fromCEnum 3 = ErrGroupInviteAcceptTooLong
    fromCEnum 4 = ErrGroupInviteAcceptEmpty
    fromCEnum 5 = ErrGroupInviteAcceptPassword
    fromCEnum 6 = ErrGroupInviteAcceptFriendNotFound
    fromCEnum 7 = ErrGroupInviteAcceptFailSend
    fromCEnum 8 = ErrGroupInviteAcceptNull
    fromCEnum n = unknownCEnum "Tox_Err_Group_Invite_Accept" n

data ErrGroupInviteFriend
    = ErrGroupInviteFriendGroupNotFound
      -- ^ The group number passed did not designate a valid group.
    | ErrGroupInviteFriendFriendNotFound
      -- ^ The friend number passed did not designate a valid friend.
    | ErrGroupInviteFriendInviteFail
      -- ^ Creation of the invite packet failed. This indicates a network
      -- related error.
    | ErrGroupInviteFriendFailSend
      -- ^ Packet failed to send.
    | ErrGroupInviteFriendDisconnected
      -- ^ The group is disconnected.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrGroupInviteFriend where
    toCEnum ErrGroupInviteFriendGroupNotFound  = 1
    toCEnum ErrGroupInviteFriendFriendNotFound = 2
    toCEnum ErrGroupInviteFriendInviteFail     = 3
    toCEnum ErrGroupInviteFriendFailSend       = 4
    toCEnum ErrGroupInviteFriendDisconnected   = 5

    fromCEnum 1 = ErrGroupInviteFriendGroupNotFound
    fromCEnum 2 = ErrGroupInviteFriendFriendNotFound
    fromCEnum 3 = ErrGroupInviteFriendInviteFail
    fromCEnum 4 = ErrGroupInviteFriendFailSend
    fromCEnum 5 = ErrGroupInviteFriendDisconnected
    fromCEnum n = unknownCEnum "Tox_Err_Group_Invite_Friend" n

data ErrGroupIsConnected
    = ErrGroupIsConnectedGroupNotFound
      -- ^ The group number passed did not designate a valid group.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrGroupIsConnected where
    toCEnum ErrGroupIsConnectedGroupNotFound = 1

    fromCEnum 1 = ErrGroupIsConnectedGroupNotFound
    fromCEnum n = unknownCEnum "Tox_Err_Group_Is_Connected" n

data ErrGroupJoin
    = ErrGroupJoinInit
      -- ^ The group instance failed to initialize.
    | ErrGroupJoinBadChatId
      -- ^ The chat_id pointer is set to NULL.
    | ErrGroupJoinEmpty
      -- ^ name is NULL or name_length is zero.
    | ErrGroupJoinTooLong
      -- ^ name exceeds 'Network.Tox.C.Constants.toxMaxNameLength'.
    | ErrGroupJoinPassword
      -- ^ Failed to set password. This usually occurs if the password exceeds
      -- 'Network.Tox.C.Constants.toxGroupMaxPasswordSize'.
    | ErrGroupJoinCore
      -- ^ There was a core error when initiating the group.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrGroupJoin where
    toCEnum ErrGroupJoinInit      = 1
    toCEnum ErrGroupJoinBadChatId = 2
    toCEnum ErrGroupJoinEmpty     = 3
    toCEnum ErrGroupJoinTooLong   = 4
    toCEnum ErrGroupJoinPassword  = 5
    toCEnum ErrGroupJoinCore      = 6

    fromCEnum 1 = ErrGroupJoinInit
    fromCEnum 2 = ErrGroupJoinBadChatId
    fromCEnum 3 = ErrGroupJoinEmpty
    fromCEnum 4 = ErrGroupJoinTooLong
    fromCEnum 5 = ErrGroupJoinPassword
    fromCEnum 6 = ErrGroupJoinCore
    fromCEnum n = unknownCEnum "Tox_Err_Group_Join" n

data ErrGroupKickPeer
    = ErrGroupKickPeerGroupNotFound
      -- ^ The group number passed did not designate a valid group.
    | ErrGroupKickPeerPeerNotFound
      -- ^ The ID passed did not designate a valid peer.
    | ErrGroupKickPeerPermissions
      -- ^ The caller does not have the required permissions for this action.
    | ErrGroupKickPeerFailAction
      -- ^ The peer could not be kicked from the group.
    | ErrGroupKickPeerFailSend
      -- ^ The packet failed to send.
    | ErrGroupKickPeerSelf
      -- ^ The caller attempted to set their own role.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrGroupKickPeer where
    toCEnum ErrGroupKickPeerGroupNotFound = 1
    toCEnum ErrGroupKickPeerPeerNotFound  = 2
    toCEnum ErrGroupKickPeerPermissions   = 3
    toCEnum ErrGroupKickPeerFailAction    = 4
    toCEnum ErrGroupKickPeerFailSend      = 5
    toCEnum ErrGroupKickPeerSelf          = 6

    fromCEnum 1 = ErrGroupKickPeerGroupNotFound
    fromCEnum 2 = ErrGroupKickPeerPeerNotFound
    fromCEnum 3 = ErrGroupKickPeerPermissions
    fromCEnum 4 = ErrGroupKickPeerFailAction
    fromCEnum 5 = ErrGroupKickPeerFailSend
    fromCEnum 6 = ErrGroupKickPeerSelf
    fromCEnum n = unknownCEnum "Tox_Err_Group_Kick_Peer" n

data ErrGroupLeave
    = ErrGroupLeaveGroupNotFound
      -- ^ The group number passed did not designate a valid group.
    | ErrGroupLeaveTooLong
      -- ^ Message length exceeded
      -- 'Network.Tox.C.Constants.toxGroupMaxPartLength'.
    | ErrGroupLeaveFailSend
      -- ^ The parting packet failed to send.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrGroupLeave where
    toCEnum ErrGroupLeaveGroupNotFound = 1
    toCEnum ErrGroupLeaveTooLong       = 2
    toCEnum ErrGroupLeaveFailSend      = 3

    fromCEnum 1 = ErrGroupLeaveGroupNotFound
    fromCEnum 2 = ErrGroupLeaveTooLong
    fromCEnum 3 = ErrGroupLeaveFailSend
    fromCEnum n = unknownCEnum "Tox_Err_Group_Leave" n

data ErrGroupNew
    = ErrGroupNewTooLong
      -- ^ name exceeds 'Network.Tox.C.Constants.toxMaxNameLength' or group_name
      -- exceeded 'Network.Tox.C.Constants.toxGroupMaxGroupNameLength'.
    | ErrGroupNewEmpty
      -- ^ name or group_name is NULL or length is zero.
    | ErrGroupNewInit
      -- ^ The group instance failed to initialize.
    | ErrGroupNewState
      -- ^ The group state failed to initialize. This usually indicates that
      -- something went wrong related to cryptographic signing.
    | ErrGroupNewAnnounce
      -- ^ The group failed to announce to the DHT. This indicates a network
      -- related error.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrGroupNew where
    toCEnum ErrGroupNewTooLong  = 1
    toCEnum ErrGroupNewEmpty    = 2
    toCEnum ErrGroupNewInit     = 3
    toCEnum ErrGroupNewState    = 4
    toCEnum ErrGroupNewAnnounce = 5

    fromCEnum 1 = ErrGroupNewTooLong
    fromCEnum 2 = ErrGroupNewEmpty
    fromCEnum 3 = ErrGroupNewInit
    fromCEnum 4 = ErrGroupNewState
    fromCEnum 5 = ErrGroupNewAnnounce
    fromCEnum n = unknownCEnum "Tox_Err_Group_New" n

data ErrGroupPeerQuery
    = ErrGroupPeerQueryGroupNotFound
      -- ^ The group number passed did not designate a valid group.
    | ErrGroupPeerQueryPeerNotFound
      -- ^ The ID passed did not designate a valid peer.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrGroupPeerQuery where
    toCEnum ErrGroupPeerQueryGroupNotFound = 1
    toCEnum ErrGroupPeerQueryPeerNotFound  = 2

    fromCEnum 1 = ErrGroupPeerQueryGroupNotFound
    fromCEnum 2 = ErrGroupPeerQueryPeerNotFound
    fromCEnum n = unknownCEnum "Tox_Err_Group_Peer_Query" n

data ErrGroupReconnect
    = ErrGroupReconnectGroupNotFound
      -- ^ The group number passed did not designate a valid group.
    | ErrGroupReconnectCore
      -- ^ There was a core error when initiating the group.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrGroupReconnect where
    toCEnum ErrGroupReconnectGroupNotFound = 1
    toCEnum ErrGroupReconnectCore          = 2

    fromCEnum 1 = ErrGroupReconnectGroupNotFound
    fromCEnum 2 = ErrGroupReconnectCore
    fromCEnum n = unknownCEnum "Tox_Err_Group_Reconnect" n

data ErrGroupSelfNameSet
    = ErrGroupSelfNameSetGroupNotFound
      -- ^ The group number passed did not designate a valid group.
    | ErrGroupSelfNameSetTooLong
      -- ^ Name length exceeded 'Network.Tox.C.Constants.toxMaxNameLength'.
    | ErrGroupSelfNameSetInvalid
      -- ^ The length given to the set function is zero or name is a NULL
      -- pointer.
    | ErrGroupSelfNameSetFailSend
      -- ^ The packet failed to send.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrGroupSelfNameSet where
    toCEnum ErrGroupSelfNameSetGroupNotFound = 1
    toCEnum ErrGroupSelfNameSetTooLong       = 2
    toCEnum ErrGroupSelfNameSetInvalid       = 3
    toCEnum ErrGroupSelfNameSetFailSend      = 4

    fromCEnum 1 = ErrGroupSelfNameSetGroupNotFound
    fromCEnum 2 = ErrGroupSelfNameSetTooLong
    fromCEnum 3 = ErrGroupSelfNameSetInvalid
    fromCEnum 4 = ErrGroupSelfNameSetFailSend
    fromCEnum n = unknownCEnum "Tox_Err_Group_Self_Name_Set" n

data ErrGroupSelfQuery
    = ErrGroupSelfQueryGroupNotFound
      -- ^ The group number passed did not designate a valid group.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrGroupSelfQuery where
    toCEnum ErrGroupSelfQueryGroupNotFound = 1

    fromCEnum 1 = ErrGroupSelfQueryGroupNotFound
    fromCEnum n = unknownCEnum "Tox_Err_Group_Self_Query" n

data ErrGroupSelfStatusSet
    = ErrGroupSelfStatusSetGroupNotFound
      -- ^ The group number passed did not designate a valid group.
    | ErrGroupSelfStatusSetFailSend
      -- ^ The packet failed to send.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrGroupSelfStatusSet where
    toCEnum ErrGroupSelfStatusSetGroupNotFound = 1
    toCEnum ErrGroupSelfStatusSetFailSend      = 2

    fromCEnum 1 = ErrGroupSelfStatusSetGroupNotFound
    fromCEnum 2 = ErrGroupSelfStatusSetFailSend
    fromCEnum n = unknownCEnum "Tox_Err_Group_Self_Status_Set" n

data ErrGroupSendCustomPacket
    = ErrGroupSendCustomPacketGroupNotFound
      -- ^ The group number passed did not designate a valid group.
    | ErrGroupSendCustomPacketTooLong
      -- ^ Message length exceeded
      -- 'Network.Tox.C.Constants.toxGroupMaxCustomLossyPacketLength' if the
      -- packet was lossy, or
      -- 'Network.Tox.C.Constants.toxGroupMaxCustomLosslessPacketLength' if
      -- the packet was lossless.
    | ErrGroupSendCustomPacketEmpty
      -- ^ The message pointer is NULL or length is zero.
    | ErrGroupSendCustomPacketDisconnected
      -- ^ The group is disconnected.
    | ErrGroupSendCustomPacketFailSend
      -- ^ The packet did not successfully send to any peer. This often
      -- indicates a connection issue on the sender's side.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrGroupSendCustomPacket where
    toCEnum ErrGroupSendCustomPacketGroupNotFound = 1
    toCEnum ErrGroupSendCustomPacketTooLong       = 2
    toCEnum ErrGroupSendCustomPacketEmpty         = 3
    toCEnum ErrGroupSendCustomPacketDisconnected  = 4
    toCEnum ErrGroupSendCustomPacketFailSend      = 5

    fromCEnum 1 = ErrGroupSendCustomPacketGroupNotFound
    fromCEnum 2 = ErrGroupSendCustomPacketTooLong
    fromCEnum 3 = ErrGroupSendCustomPacketEmpty
    fromCEnum 4 = ErrGroupSendCustomPacketDisconnected
    fromCEnum 5 = ErrGroupSendCustomPacketFailSend
    fromCEnum n = unknownCEnum "Tox_Err_Group_Send_Custom_Packet" n

data ErrGroupSendCustomPrivatePacket
    = ErrGroupSendCustomPrivatePacketGroupNotFound
      -- ^ The group number passed did not designate a valid group.
    | ErrGroupSendCustomPrivatePacketTooLong
      -- ^ Message length exceeded
      -- 'Network.Tox.C.Constants.toxGroupMaxCustomLossyPacketLength' if the
      -- packet was lossy, or
      -- 'Network.Tox.C.Constants.toxGroupMaxCustomLosslessPacketLength' if
      -- the packet was lossless.
    | ErrGroupSendCustomPrivatePacketEmpty
      -- ^ The message pointer is NULL or length is zero.
    | ErrGroupSendCustomPrivatePacketPeerNotFound
      -- ^ The peer ID passed did no designate a valid peer.
    | ErrGroupSendCustomPrivatePacketFailSend
      -- ^ The packet failed to send.
    | ErrGroupSendCustomPrivatePacketDisconnected
      -- ^ The group is disconnected.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrGroupSendCustomPrivatePacket where
    toCEnum ErrGroupSendCustomPrivatePacketGroupNotFound = 1
    toCEnum ErrGroupSendCustomPrivatePacketTooLong       = 2
    toCEnum ErrGroupSendCustomPrivatePacketEmpty         = 3
    toCEnum ErrGroupSendCustomPrivatePacketPeerNotFound  = 4
    toCEnum ErrGroupSendCustomPrivatePacketFailSend      = 5
    toCEnum ErrGroupSendCustomPrivatePacketDisconnected  = 6

    fromCEnum 1 = ErrGroupSendCustomPrivatePacketGroupNotFound
    fromCEnum 2 = ErrGroupSendCustomPrivatePacketTooLong
    fromCEnum 3 = ErrGroupSendCustomPrivatePacketEmpty
    fromCEnum 4 = ErrGroupSendCustomPrivatePacketPeerNotFound
    fromCEnum 5 = ErrGroupSendCustomPrivatePacketFailSend
    fromCEnum 6 = ErrGroupSendCustomPrivatePacketDisconnected
    fromCEnum n = unknownCEnum "Tox_Err_Group_Send_Custom_Private_Packet" n

data ErrGroupSendMessage
    = ErrGroupSendMessageGroupNotFound
      -- ^ The group number passed did not designate a valid group.
    | ErrGroupSendMessageTooLong
      -- ^ Message length exceeded
      -- 'Network.Tox.C.Constants.toxGroupMaxMessageLength'.
    | ErrGroupSendMessageEmpty
      -- ^ The message pointer is NULL or length is zero.
    | ErrGroupSendMessageBadType
      -- ^ The message type is invalid.
    | ErrGroupSendMessagePermissions
      -- ^ The caller does not have the required permissions to send group
      -- messages.
    | ErrGroupSendMessageFailSend
      -- ^ Packet failed to send.
    | ErrGroupSendMessageDisconnected
      -- ^ The group is disconnected.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrGroupSendMessage where
    toCEnum ErrGroupSendMessageGroupNotFound = 1
    toCEnum ErrGroupSendMessageTooLong       = 2
    toCEnum ErrGroupSendMessageEmpty         = 3
    toCEnum ErrGroupSendMessageBadType       = 4
    toCEnum ErrGroupSendMessagePermissions   = 5
    toCEnum ErrGroupSendMessageFailSend      = 6
    toCEnum ErrGroupSendMessageDisconnected  = 7

    fromCEnum 1 = ErrGroupSendMessageGroupNotFound
    fromCEnum 2 = ErrGroupSendMessageTooLong
    fromCEnum 3 = ErrGroupSendMessageEmpty
    fromCEnum 4 = ErrGroupSendMessageBadType
    fromCEnum 5 = ErrGroupSendMessagePermissions
    fromCEnum 6 = ErrGroupSendMessageFailSend
    fromCEnum 7 = ErrGroupSendMessageDisconnected
    fromCEnum n = unknownCEnum "Tox_Err_Group_Send_Message" n

data ErrGroupSendPrivateMessage
    = ErrGroupSendPrivateMessageGroupNotFound
      -- ^ The group number passed did not designate a valid group.
    | ErrGroupSendPrivateMessagePeerNotFound
      -- ^ The peer ID passed did not designate a valid peer.
    | ErrGroupSendPrivateMessageTooLong
      -- ^ Message length exceeded
      -- 'Network.Tox.C.Constants.toxGroupMaxMessageLength'.
    | ErrGroupSendPrivateMessageEmpty
      -- ^ The message pointer is NULL or length is zero.
    | ErrGroupSendPrivateMessageBadType
      -- ^ The message type is invalid.
    | ErrGroupSendPrivateMessagePermissions
      -- ^ The caller does not have the required permissions to send group
      -- messages.
    | ErrGroupSendPrivateMessageFailSend
      -- ^ Packet failed to send.
    | ErrGroupSendPrivateMessageDisconnected
      -- ^ The group is disconnected.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrGroupSendPrivateMessage where
    toCEnum ErrGroupSendPrivateMessageGroupNotFound = 1
    toCEnum ErrGroupSendPrivateMessagePeerNotFound  = 2
    toCEnum ErrGroupSendPrivateMessageTooLong       = 3
    toCEnum ErrGroupSendPrivateMessageEmpty         = 4
    toCEnum ErrGroupSendPrivateMessageBadType       = 5
    toCEnum ErrGroupSendPrivateMessagePermissions   = 6
    toCEnum ErrGroupSendPrivateMessageFailSend      = 7
    toCEnum ErrGroupSendPrivateMessageDisconnected  = 8

    fromCEnum 1 = ErrGroupSendPrivateMessageGroupNotFound
    fromCEnum 2 = ErrGroupSendPrivateMessagePeerNotFound
    fromCEnum 3 = ErrGroupSendPrivateMessageTooLong
    fromCEnum 4 = ErrGroupSendPrivateMessageEmpty
    fromCEnum 5 = ErrGroupSendPrivateMessageBadType
    fromCEnum 6 = ErrGroupSendPrivateMessagePermissions
    fromCEnum 7 = ErrGroupSendPrivateMessageFailSend
    fromCEnum 8 = ErrGroupSendPrivateMessageDisconnected
    fromCEnum n = unknownCEnum "Tox_Err_Group_Send_Private_Message" n

data ErrGroupSetIgnore
    = ErrGroupSetIgnoreGroupNotFound
      -- ^ The group number passed did not designate a valid group.
    | ErrGroupSetIgnorePeerNotFound
      -- ^ The ID passed did not designate a valid peer.
    | ErrGroupSetIgnoreSelf
      -- ^ The caller attempted to ignore himself.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrGroupSetIgnore where
    toCEnum ErrGroupSetIgnoreGroupNotFound = 1
    toCEnum ErrGroupSetIgnorePeerNotFound  = 2
    toCEnum ErrGroupSetIgnoreSelf          = 3

    fromCEnum 1 = ErrGroupSetIgnoreGroupNotFound
    fromCEnum 2 = ErrGroupSetIgnorePeerNotFound
    fromCEnum 3 = ErrGroupSetIgnoreSelf
    fromCEnum n = unknownCEnum "Tox_Err_Group_Set_Ignore" n

data ErrGroupSetPassword
    = ErrGroupSetPasswordGroupNotFound
      -- ^ The group number passed did not designate a valid group.
    | ErrGroupSetPasswordPermissions
      -- ^ The caller does not have the required permissions to set the
      -- password.
    | ErrGroupSetPasswordTooLong
      -- ^ Password length exceeded
      -- 'Network.Tox.C.Constants.toxGroupMaxPasswordSize'.
    | ErrGroupSetPasswordFailSend
      -- ^ The packet failed to send.
    | ErrGroupSetPasswordMalloc
      -- ^ The function failed to allocate enough memory for the operation.
    | ErrGroupSetPasswordDisconnected
      -- ^ The group is disconnected.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrGroupSetPassword where
    toCEnum ErrGroupSetPasswordGroupNotFound = 1
    toCEnum ErrGroupSetPasswordPermissions   = 2
    toCEnum ErrGroupSetPasswordTooLong       = 3
    toCEnum ErrGroupSetPasswordFailSend      = 4
    toCEnum ErrGroupSetPasswordMalloc        = 5
    toCEnum ErrGroupSetPasswordDisconnected  = 6

    fromCEnum 1 = ErrGroupSetPasswordGroupNotFound
    fromCEnum 2 = ErrGroupSetPasswordPermissions
    fromCEnum 3 = ErrGroupSetPasswordTooLong
    fromCEnum 4 = ErrGroupSetPasswordFailSend
    fromCEnum 5 = ErrGroupSetPasswordMalloc
    fromCEnum 6 = ErrGroupSetPasswordDisconnected
    fromCEnum n = unknownCEnum "Tox_Err_Group_Set_Password" n

data ErrGroupSetPeerLimit
    = ErrGroupSetPeerLimitGroupNotFound
      -- ^ The group number passed did not designate a valid group.
    | ErrGroupSetPeerLimitPermissions
      -- ^ The caller does not have the required permissions to set the peer
      -- limit.
    | ErrGroupSetPeerLimitFailSet
      -- ^ The peer limit could not be set. This may occur due to an error
      -- related to cryptographic signing of the new shared state.
    | ErrGroupSetPeerLimitFailSend
      -- ^ The packet failed to send.
    | ErrGroupSetPeerLimitDisconnected
      -- ^ The group is disconnected.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrGroupSetPeerLimit where
    toCEnum ErrGroupSetPeerLimitGroupNotFound = 1
    toCEnum ErrGroupSetPeerLimitPermissions   = 2
    toCEnum ErrGroupSetPeerLimitFailSet       = 3
    toCEnum ErrGroupSetPeerLimitFailSend      = 4
    toCEnum ErrGroupSetPeerLimitDisconnected  = 5

    fromCEnum 1 = ErrGroupSetPeerLimitGroupNotFound
    fromCEnum 2 = ErrGroupSetPeerLimitPermissions
    fromCEnum 3 = ErrGroupSetPeerLimitFailSet
    fromCEnum 4 = ErrGroupSetPeerLimitFailSend
    fromCEnum 5 = ErrGroupSetPeerLimitDisconnected
    fromCEnum n = unknownCEnum "Tox_Err_Group_Set_Peer_Limit" n

data ErrGroupSetPrivacyState
    = ErrGroupSetPrivacyStateGroupNotFound
      -- ^ The group number passed did not designate a valid group.
    | ErrGroupSetPrivacyStatePermissions
      -- ^ The caller does not have the required permissions to set the privacy
      -- state.
    | ErrGroupSetPrivacyStateFailSet
      -- ^ The privacy state could not be set. This may occur due to an error
      -- related to cryptographic signing of the new shared state.
    | ErrGroupSetPrivacyStateFailSend
      -- ^ The packet failed to send.
    | ErrGroupSetPrivacyStateDisconnected
      -- ^ The group is disconnected.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrGroupSetPrivacyState where
    toCEnum ErrGroupSetPrivacyStateGroupNotFound = 1
    toCEnum ErrGroupSetPrivacyStatePermissions   = 2
    toCEnum ErrGroupSetPrivacyStateFailSet       = 3
    toCEnum ErrGroupSetPrivacyStateFailSend      = 4
    toCEnum ErrGroupSetPrivacyStateDisconnected  = 5

    fromCEnum 1 = ErrGroupSetPrivacyStateGroupNotFound
    fromCEnum 2 = ErrGroupSetPrivacyStatePermissions
    fromCEnum 3 = ErrGroupSetPrivacyStateFailSet
    fromCEnum 4 = ErrGroupSetPrivacyStateFailSend
    fromCEnum 5 = ErrGroupSetPrivacyStateDisconnected
    fromCEnum n = unknownCEnum "Tox_Err_Group_Set_Privacy_State" n

data ErrGroupSetRole
    = ErrGroupSetRoleGroupNotFound
      -- ^ The group number passed did not designate a valid group.
    | ErrGroupSetRolePeerNotFound
      -- ^ The ID passed did not designate a valid peer. Note: you cannot set
      -- your own role.
    | ErrGroupSetRolePermissions
      -- ^ The caller does not have the required permissions for this action.
    | ErrGroupSetRoleAssignment
      -- ^ The role assignment is invalid. This will occur if you try to set a
      -- peer's role to the role they already have.
    | ErrGroupSetRoleFailAction
      -- ^ The role was not successfully set. This may occur if the packet
      -- failed to send, or if the role limit has been reached.
    | ErrGroupSetRoleSelf
      -- ^ The caller attempted to set their own role.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrGroupSetRole where
    toCEnum ErrGroupSetRoleGroupNotFound = 1
    toCEnum ErrGroupSetRolePeerNotFound  = 2
    toCEnum ErrGroupSetRolePermissions   = 3
    toCEnum ErrGroupSetRoleAssignment    = 4
    toCEnum ErrGroupSetRoleFailAction    = 5
    toCEnum ErrGroupSetRoleSelf          = 6

    fromCEnum 1 = ErrGroupSetRoleGroupNotFound
    fromCEnum 2 = ErrGroupSetRolePeerNotFound
    fromCEnum 3 = ErrGroupSetRolePermissions
    fromCEnum 4 = ErrGroupSetRoleAssignment
    fromCEnum 5 = ErrGroupSetRoleFailAction
    fromCEnum 6 = ErrGroupSetRoleSelf
    fromCEnum n = unknownCEnum "Tox_Err_Group_Set_Role" n

data ErrGroupSetTopicLock
    = ErrGroupSetTopicLockGroupNotFound
      -- ^ The group number passed did not designate a valid group.
    | ErrGroupSetTopicLockInvalid
      -- ^ Tox_Group_Topic_Lock is an invalid type.
    | ErrGroupSetTopicLockPermissions
      -- ^ The caller does not have the required permissions to set the topic
      -- lock.
    | ErrGroupSetTopicLockFailSet
      -- ^ The topic lock could not be set. This may occur due to an error
      -- related to cryptographic signing of the new shared state.
    | ErrGroupSetTopicLockFailSend
      -- ^ The packet failed to send.
    | ErrGroupSetTopicLockDisconnected
      -- ^ The group is disconnected.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrGroupSetTopicLock where
    toCEnum ErrGroupSetTopicLockGroupNotFound = 1
    toCEnum ErrGroupSetTopicLockInvalid       = 2
    toCEnum ErrGroupSetTopicLockPermissions   = 3
    toCEnum ErrGroupSetTopicLockFailSet       = 4
    toCEnum ErrGroupSetTopicLockFailSend      = 5
    toCEnum ErrGroupSetTopicLockDisconnected  = 6

    fromCEnum 1 = ErrGroupSetTopicLockGroupNotFound
    fromCEnum 2 = ErrGroupSetTopicLockInvalid
    fromCEnum 3 = ErrGroupSetTopicLockPermissions
    fromCEnum 4 = ErrGroupSetTopicLockFailSet
    fromCEnum 5 = ErrGroupSetTopicLockFailSend
    fromCEnum 6 = ErrGroupSetTopicLockDisconnected
    fromCEnum n = unknownCEnum "Tox_Err_Group_Set_Topic_Lock" n

data ErrGroupSetVoiceState
    = ErrGroupSetVoiceStateGroupNotFound
      -- ^ The group number passed did not designate a valid group.
    | ErrGroupSetVoiceStatePermissions
      -- ^ The caller does not have the required permissions to set the privacy
      -- state.
    | ErrGroupSetVoiceStateFailSet
      -- ^ The voice state could not be set. This may occur due to an error
      -- related to cryptographic signing of the new shared state.
    | ErrGroupSetVoiceStateFailSend
      -- ^ The packet failed to send.
    | ErrGroupSetVoiceStateDisconnected
      -- ^ The group is disconnected.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrGroupSetVoiceState where
    toCEnum ErrGroupSetVoiceStateGroupNotFound = 1
    toCEnum ErrGroupSetVoiceStatePermissions   = 2
    toCEnum ErrGroupSetVoiceStateFailSet       = 3
    toCEnum ErrGroupSetVoiceStateFailSend      = 4
    toCEnum ErrGroupSetVoiceStateDisconnected  = 5

    fromCEnum 1 = ErrGroupSetVoiceStateGroupNotFound
    fromCEnum 2 = ErrGroupSetVoiceStatePermissions
    fromCEnum 3 = ErrGroupSetVoiceStateFailSet
    fromCEnum 4 = ErrGroupSetVoiceStateFailSend
    fromCEnum 5 = ErrGroupSetVoiceStateDisconnected
    fromCEnum n = unknownCEnum "Tox_Err_Group_Set_Voice_State" n

data ErrGroupStateQuery
    = ErrGroupStateQueryGroupNotFound
      -- ^ The group number passed did not designate a valid group.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrGroupStateQuery where
    toCEnum ErrGroupStateQueryGroupNotFound = 1

    fromCEnum 1 = ErrGroupStateQueryGroupNotFound
    fromCEnum n = unknownCEnum "Tox_Err_Group_State_Query" n

data ErrGroupTopicSet
    = ErrGroupTopicSetGroupNotFound
      -- ^ The group number passed did not designate a valid group.
    | ErrGroupTopicSetTooLong
      -- ^ Topic length exceeded
      -- 'Network.Tox.C.Constants.toxGroupMaxTopicLength'.
    | ErrGroupTopicSetPermissions
      -- ^ The caller does not have the required permissions to set the topic.
    | ErrGroupTopicSetFailCreate
      -- ^ The packet could not be created. This error is usually related to
      -- cryptographic signing.
    | ErrGroupTopicSetFailSend
      -- ^ The packet failed to send.
    | ErrGroupTopicSetDisconnected
      -- ^ The group is disconnected.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrGroupTopicSet where
    toCEnum ErrGroupTopicSetGroupNotFound = 1
    toCEnum ErrGroupTopicSetTooLong       = 2
    toCEnum ErrGroupTopicSetPermissions   = 3
    toCEnum ErrGroupTopicSetFailCreate    = 4
    toCEnum ErrGroupTopicSetFailSend      = 5
    toCEnum ErrGroupTopicSetDisconnected  = 6

    fromCEnum 1 = ErrGroupTopicSetGroupNotFound
    fromCEnum 2 = ErrGroupTopicSetTooLong
    fromCEnum 3 = ErrGroupTopicSetPermissions
    fromCEnum 4 = ErrGroupTopicSetFailCreate
    fromCEnum 5 = ErrGroupTopicSetFailSend
    fromCEnum 6 = ErrGroupTopicSetDisconnected
    fromCEnum n = unknownCEnum "Tox_Err_Group_Topic_Set" n

data ErrKeyDerivation
    = ErrKeyDerivationNull
      -- ^ One of the arguments to the function was NULL when it was not
      -- expected.
    | ErrKeyDerivationFailed
      -- ^ The crypto lib was unable to derive a key from the given passphrase,
      -- which is usually a lack of memory issue.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrKeyDerivation where
    toCEnum ErrKeyDerivationNull   = 1
    toCEnum ErrKeyDerivationFailed = 2

    fromCEnum 1 = ErrKeyDerivationNull
    fromCEnum 2 = ErrKeyDerivationFailed
    fromCEnum n = unknownCEnum "Tox_Err_Key_Derivation" n

data ErrNew
    = ErrNewNull
      -- ^ One of the arguments to the function was NULL when it was not
      -- expected.
    | ErrNewMalloc
      -- ^ The function was unable to allocate enough memory to store the
      -- internal structures for the Tox object.
    | ErrNewPortAlloc
      -- ^ The function was unable to bind to a port. This may mean that all
      -- ports have already been bound, e.g. by other Tox instances, or it may
      -- mean a permission error. You may be able to gather more information
      -- from errno.
    | ErrNewProxyBadType
      -- ^ proxy_type was invalid.
    | ErrNewProxyBadHost
      -- ^ proxy_type was valid but the proxy_host passed had an invalid format
      -- or was NULL.
    | ErrNewProxyBadPort
      -- ^ proxy_type was valid, but the proxy_port was invalid.
    | ErrNewProxyNotFound
      -- ^ The proxy address passed could not be resolved.
    | ErrNewLoadEncrypted
      -- ^ The byte array to be loaded contained an encrypted save.
    | ErrNewLoadBadFormat
      -- ^ The data format was invalid. This can happen when loading data that
      -- was saved by an older version of Tox, or when the data has been
      -- corrupted. When loading from badly formatted data, some data may have
      -- been loaded, and the rest is discarded. Passing an invalid length
      -- parameter also causes this error.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrNew where
    toCEnum ErrNewNull          = 1
    toCEnum ErrNewMalloc        = 2
    toCEnum ErrNewPortAlloc     = 3
    toCEnum ErrNewProxyBadType  = 4
    toCEnum ErrNewProxyBadHost  = 5
    toCEnum ErrNewProxyBadPort  = 6
    toCEnum ErrNewProxyNotFound = 7
    toCEnum ErrNewLoadEncrypted = 8
    toCEnum ErrNewLoadBadFormat = 9

    fromCEnum 1 = ErrNewNull
    fromCEnum 2 = ErrNewMalloc
    fromCEnum 3 = ErrNewPortAlloc
    fromCEnum 4 = ErrNewProxyBadType
    fromCEnum 5 = ErrNewProxyBadHost
    fromCEnum 6 = ErrNewProxyBadPort
    fromCEnum 7 = ErrNewProxyNotFound
    fromCEnum 8 = ErrNewLoadEncrypted
    fromCEnum 9 = ErrNewLoadBadFormat
    fromCEnum n = unknownCEnum "Tox_Err_New" n

data ErrOptionsNew
    = ErrOptionsNewMalloc
      -- ^ The function failed to allocate enough memory for the options struct.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrOptionsNew where
    toCEnum ErrOptionsNewMalloc = 1

    fromCEnum 1 = ErrOptionsNewMalloc
    fromCEnum n = unknownCEnum "Tox_Err_Options_New" n

data ErrSetInfo
    = ErrSetInfoNull
      -- ^ One of the arguments to the function was NULL when it was not
      -- expected.
    | ErrSetInfoTooLong
      -- ^ Information length exceeded maximum permissible size.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrSetInfo where
    toCEnum ErrSetInfoNull    = 1
    toCEnum ErrSetInfoTooLong = 2

    fromCEnum 1 = ErrSetInfoNull
    fromCEnum 2 = ErrSetInfoTooLong
    fromCEnum n = unknownCEnum "Tox_Err_Set_Info" n

data ErrSetTyping
    = ErrSetTypingFriendNotFound
      -- ^ The friend number did not designate a valid friend.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ErrSetTyping where
    toCEnum ErrSetTypingFriendNotFound = 1

    fromCEnum 1 = ErrSetTypingFriendNotFound
    fromCEnum n = unknownCEnum "Tox_Err_Set_Typing" n

data EventType
    = EventTypeSelfConnectionStatus
    | EventTypeFriendRequest
    | EventTypeFriendConnectionStatus
    | EventTypeFriendLossyPacket
    | EventTypeFriendLosslessPacket
    | EventTypeFriendName
    | EventTypeFriendStatus
    | EventTypeFriendStatusMessage
    | EventTypeFriendMessage
    | EventTypeFriendReadReceipt
    | EventTypeFriendTyping
    | EventTypeFileChunkRequest
    | EventTypeFileRecv
    | EventTypeFileRecvChunk
    | EventTypeFileRecvControl
    | EventTypeConferenceInvite
    | EventTypeConferenceConnected
    | EventTypeConferencePeerListChanged
    | EventTypeConferencePeerName
    | EventTypeConferenceTitle
    | EventTypeConferenceMessage
    | EventTypeGroupPeerName
    | EventTypeGroupPeerStatus
    | EventTypeGroupTopic
    | EventTypeGroupPrivacyState
    | EventTypeGroupVoiceState
    | EventTypeGroupTopicLock
    | EventTypeGroupPeerLimit
    | EventTypeGroupPassword
    | EventTypeGroupMessage
    | EventTypeGroupPrivateMessage
    | EventTypeGroupCustomPacket
    | EventTypeGroupCustomPrivatePacket
    | EventTypeGroupInvite
    | EventTypeGroupPeerJoin
    | EventTypeGroupPeerExit
    | EventTypeGroupSelfJoin
    | EventTypeGroupJoinFail
    | EventTypeGroupModeration
    | EventTypeDhtNodesResponse
    | EventTypeInvalid
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum EventType where
    toCEnum EventTypeSelfConnectionStatus      = 0
    toCEnum EventTypeFriendRequest             = 1
    toCEnum EventTypeFriendConnectionStatus    = 2
    toCEnum EventTypeFriendLossyPacket         = 3
    toCEnum EventTypeFriendLosslessPacket      = 4
    toCEnum EventTypeFriendName                = 5
    toCEnum EventTypeFriendStatus              = 6
    toCEnum EventTypeFriendStatusMessage       = 7
    toCEnum EventTypeFriendMessage             = 8
    toCEnum EventTypeFriendReadReceipt         = 9
    toCEnum EventTypeFriendTyping              = 10
    toCEnum EventTypeFileChunkRequest          = 11
    toCEnum EventTypeFileRecv                  = 12
    toCEnum EventTypeFileRecvChunk             = 13
    toCEnum EventTypeFileRecvControl           = 14
    toCEnum EventTypeConferenceInvite          = 15
    toCEnum EventTypeConferenceConnected       = 16
    toCEnum EventTypeConferencePeerListChanged = 17
    toCEnum EventTypeConferencePeerName        = 18
    toCEnum EventTypeConferenceTitle           = 19
    toCEnum EventTypeConferenceMessage         = 20
    toCEnum EventTypeGroupPeerName             = 21
    toCEnum EventTypeGroupPeerStatus           = 22
    toCEnum EventTypeGroupTopic                = 23
    toCEnum EventTypeGroupPrivacyState         = 24
    toCEnum EventTypeGroupVoiceState           = 25
    toCEnum EventTypeGroupTopicLock            = 26
    toCEnum EventTypeGroupPeerLimit            = 27
    toCEnum EventTypeGroupPassword             = 28
    toCEnum EventTypeGroupMessage              = 29
    toCEnum EventTypeGroupPrivateMessage       = 30
    toCEnum EventTypeGroupCustomPacket         = 31
    toCEnum EventTypeGroupCustomPrivatePacket  = 32
    toCEnum EventTypeGroupInvite               = 33
    toCEnum EventTypeGroupPeerJoin             = 34
    toCEnum EventTypeGroupPeerExit             = 35
    toCEnum EventTypeGroupSelfJoin             = 36
    toCEnum EventTypeGroupJoinFail             = 37
    toCEnum EventTypeGroupModeration           = 38
    toCEnum EventTypeDhtNodesResponse          = 39
    toCEnum EventTypeInvalid                   = 255

    fromCEnum 0   = EventTypeSelfConnectionStatus
    fromCEnum 1   = EventTypeFriendRequest
    fromCEnum 2   = EventTypeFriendConnectionStatus
    fromCEnum 3   = EventTypeFriendLossyPacket
    fromCEnum 4   = EventTypeFriendLosslessPacket
    fromCEnum 5   = EventTypeFriendName
    fromCEnum 6   = EventTypeFriendStatus
    fromCEnum 7   = EventTypeFriendStatusMessage
    fromCEnum 8   = EventTypeFriendMessage
    fromCEnum 9   = EventTypeFriendReadReceipt
    fromCEnum 10  = EventTypeFriendTyping
    fromCEnum 11  = EventTypeFileChunkRequest
    fromCEnum 12  = EventTypeFileRecv
    fromCEnum 13  = EventTypeFileRecvChunk
    fromCEnum 14  = EventTypeFileRecvControl
    fromCEnum 15  = EventTypeConferenceInvite
    fromCEnum 16  = EventTypeConferenceConnected
    fromCEnum 17  = EventTypeConferencePeerListChanged
    fromCEnum 18  = EventTypeConferencePeerName
    fromCEnum 19  = EventTypeConferenceTitle
    fromCEnum 20  = EventTypeConferenceMessage
    fromCEnum 21  = EventTypeGroupPeerName
    fromCEnum 22  = EventTypeGroupPeerStatus
    fromCEnum 23  = EventTypeGroupTopic
    fromCEnum 24  = EventTypeGroupPrivacyState
    fromCEnum 25  = EventTypeGroupVoiceState
    fromCEnum 26  = EventTypeGroupTopicLock
    fromCEnum 27  = EventTypeGroupPeerLimit
    fromCEnum 28  = EventTypeGroupPassword
    fromCEnum 29  = EventTypeGroupMessage
    fromCEnum 30  = EventTypeGroupPrivateMessage
    fromCEnum 31  = EventTypeGroupCustomPacket
    fromCEnum 32  = EventTypeGroupCustomPrivatePacket
    fromCEnum 33  = EventTypeGroupInvite
    fromCEnum 34  = EventTypeGroupPeerJoin
    fromCEnum 35  = EventTypeGroupPeerExit
    fromCEnum 36  = EventTypeGroupSelfJoin
    fromCEnum 37  = EventTypeGroupJoinFail
    fromCEnum 38  = EventTypeGroupModeration
    fromCEnum 39  = EventTypeDhtNodesResponse
    fromCEnum 255 = EventTypeInvalid
    fromCEnum n   = unknownCEnum "Tox_Event_Type" n

data FileControl
    = FileControlResume
      -- ^ Sent by the receiving side to accept a file send request. Also sent
      -- after a TOX_FILE_CONTROL_PAUSE command to continue sending or
      -- receiving.
    | FileControlPause
      -- ^ Sent by clients to pause the file transfer. The initial state of a
      -- file transfer is always paused on the receiving side and running on
      -- the sending side. If both the sending and receiving side pause the
      -- transfer, then both need to send TOX_FILE_CONTROL_RESUME for the
      -- transfer to resume.
    | FileControlCancel
      -- ^ Sent by the receiving side to reject a file send request before any
      -- other commands are sent. Also sent by either side to terminate a file
      -- transfer.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum FileControl where
    toCEnum FileControlResume = 0
    toCEnum FileControlPause  = 1
    toCEnum FileControlCancel = 2

    fromCEnum 0 = FileControlResume
    fromCEnum 1 = FileControlPause
    fromCEnum 2 = FileControlCancel
    fromCEnum n = unknownCEnum "Tox_File_Control" n

newtype FileKind = FileKind Word32
    deriving (Eq, Ord, Read, Show)

-- | Arbitrary file data. Clients can choose to handle it based on the file name
-- or magic or any other way they choose.
pattern FileKindData :: FileKind
pattern FileKindData = FileKind 0

-- | Avatar file_id. This consists of 'Network.Tox.C.Tox.toxHash'(image). Avatar
-- data. This consists of the image data.
--
-- Avatars can be sent at any time the client wishes. Generally, a client will
-- send the avatar to a friend when that friend comes online, and to all
-- friends when the avatar changed. A client can save some traffic by
-- remembering which friend received the updated avatar already and only send
-- it if the friend has an out of date avatar.
--
-- Clients who receive avatar send requests can reject it (by sending
-- TOX_FILE_CONTROL_CANCEL before any other controls), or accept it (by
-- sending TOX_FILE_CONTROL_RESUME). The file_id of length
-- 'Network.Tox.C.Constants.toxHashLength' bytes (same length as
-- 'Network.Tox.C.Constants.toxFileIdLength') will contain the hash. A client
-- can compare this hash with a saved hash and send TOX_FILE_CONTROL_CANCEL to
-- terminate the avatar transfer if it matches.
--
-- When file_size is set to 0 in the transfer request it means that the client
-- has no avatar.
pattern FileKindAvatar :: FileKind
pattern FileKindAvatar = FileKind 1

-- | To be specified.
pattern FileKindSticker :: FileKind
pattern FileKindSticker = FileKind 2

-- | Here the file_id is the specified hash of the data.
pattern FileKindSha1 :: FileKind
pattern FileKindSha1 = FileKind 3

pattern FileKindSha256 :: FileKind
pattern FileKindSha256 = FileKind 4

data GroupExitType
    = GroupExitTypeQuit
      -- ^ The peer has quit the group.
    | GroupExitTypeTimeout
      -- ^ Your connection with this peer has timed out.
    | GroupExitTypeDisconnected
      -- ^ Your connection with this peer has been severed.
    | GroupExitTypeSelfDisconnected
      -- ^ Your connection with all peers has been severed. This will occur when
      -- you are kicked from a group, rejoin a group, or manually disconnect
      -- from a group.
    | GroupExitTypeKick
      -- ^ The peer has been kicked.
    | GroupExitTypeSyncError
      -- ^ The peer provided invalid group sync information.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum GroupExitType where
    toCEnum GroupExitTypeQuit             = 0
    toCEnum GroupExitTypeTimeout          = 1
    toCEnum GroupExitTypeDisconnected     = 2
    toCEnum GroupExitTypeSelfDisconnected = 3
    toCEnum GroupExitTypeKick             = 4
    toCEnum GroupExitTypeSyncError        = 5

    fromCEnum 0 = GroupExitTypeQuit
    fromCEnum 1 = GroupExitTypeTimeout
    fromCEnum 2 = GroupExitTypeDisconnected
    fromCEnum 3 = GroupExitTypeSelfDisconnected
    fromCEnum 4 = GroupExitTypeKick
    fromCEnum 5 = GroupExitTypeSyncError
    fromCEnum n = unknownCEnum "Tox_Group_Exit_Type" n

data GroupJoinFail
    = GroupJoinFailPeerLimit
      -- ^ The group peer limit has been reached.
    | GroupJoinFailInvalidPassword
      -- ^ You have supplied an invalid password.
    | GroupJoinFailUnknown
      -- ^ The join attempt failed due to an unspecified error. This often
      -- occurs when the group is not found in the DHT.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum GroupJoinFail where
    toCEnum GroupJoinFailPeerLimit       = 0
    toCEnum GroupJoinFailInvalidPassword = 1
    toCEnum GroupJoinFailUnknown         = 2

    fromCEnum 0 = GroupJoinFailPeerLimit
    fromCEnum 1 = GroupJoinFailInvalidPassword
    fromCEnum 2 = GroupJoinFailUnknown
    fromCEnum n = unknownCEnum "Tox_Group_Join_Fail" n

data GroupModEvent
    = GroupModEventKick
      -- ^ A peer has been kicked from the group.
    | GroupModEventObserver
      -- ^ A peer as been given the observer role.
    | GroupModEventUser
      -- ^ A peer has been given the user role.
    | GroupModEventModerator
      -- ^ A peer has been given the moderator role.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum GroupModEvent where
    toCEnum GroupModEventKick      = 0
    toCEnum GroupModEventObserver  = 1
    toCEnum GroupModEventUser      = 2
    toCEnum GroupModEventModerator = 3

    fromCEnum 0 = GroupModEventKick
    fromCEnum 1 = GroupModEventObserver
    fromCEnum 2 = GroupModEventUser
    fromCEnum 3 = GroupModEventModerator
    fromCEnum n = unknownCEnum "Tox_Group_Mod_Event" n

data GroupPrivacyState
    = GroupPrivacyStatePublic
      -- ^ The group is considered to be public. Anyone may join the group using
      -- the Chat ID.
      --
      -- If the group is in this state, even if the Chat ID is never
      -- explicitly shared with someone outside of the group, information
      -- including the Chat ID, IP addresses, and peer ID's (but not Tox ID's)
      -- is visible to anyone with access to a node storing a DHT entry for
      -- the given group.
    | GroupPrivacyStatePrivate
      -- ^ The group is considered to be private. The only way to join the group
      -- is by having someone in your contact list send you an invite.
      --
      -- If the group is in this state, no group information (mentioned above)
      -- is present in the DHT; the DHT is not used for any purpose at all. If
      -- a public group is set to private, all DHT information related to the
      -- group will expire shortly.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum GroupPrivacyState where
    toCEnum GroupPrivacyStatePublic  = 0
    toCEnum GroupPrivacyStatePrivate = 1

    fromCEnum 0 = GroupPrivacyStatePublic
    fromCEnum 1 = GroupPrivacyStatePrivate
    fromCEnum n = unknownCEnum "Tox_Group_Privacy_State" n

data GroupRole
    = GroupRoleFounder
      -- ^ May kick all other peers as well as set their role to anything
      -- (except founder). Founders may also set the group password, toggle
      -- the privacy state, and set the peer limit.
    | GroupRoleModerator
      -- ^ May kick and set the user and observer roles for peers below this
      -- role. May also set the group topic.
    | GroupRoleUser
      -- ^ May communicate with other peers normally.
    | GroupRoleObserver
      -- ^ May observe the group and ignore peers; may not communicate with
      -- other peers or with the group.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum GroupRole where
    toCEnum GroupRoleFounder   = 0
    toCEnum GroupRoleModerator = 1
    toCEnum GroupRoleUser      = 2
    toCEnum GroupRoleObserver  = 3

    fromCEnum 0 = GroupRoleFounder
    fromCEnum 1 = GroupRoleModerator
    fromCEnum 2 = GroupRoleUser
    fromCEnum 3 = GroupRoleObserver
    fromCEnum n = unknownCEnum "Tox_Group_Role" n

data GroupTopicLock
    = GroupTopicLockEnabled
      -- ^ The topic lock is enabled. Only peers with the founder and moderator
      -- roles may set the topic.
    | GroupTopicLockDisabled
      -- ^ The topic lock is disabled. All peers except those with the observer
      -- role may set the topic.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum GroupTopicLock where
    toCEnum GroupTopicLockEnabled  = 0
    toCEnum GroupTopicLockDisabled = 1

    fromCEnum 0 = GroupTopicLockEnabled
    fromCEnum 1 = GroupTopicLockDisabled
    fromCEnum n = unknownCEnum "Tox_Group_Topic_Lock" n

data GroupVoiceState
    = GroupVoiceStateAll
      -- ^ All group roles above Observer have permission to speak.
    | GroupVoiceStateModerator
      -- ^ Moderators and Founders have permission to speak.
    | GroupVoiceStateFounder
      -- ^ Only the founder may speak.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum GroupVoiceState where
    toCEnum GroupVoiceStateAll       = 0
    toCEnum GroupVoiceStateModerator = 1
    toCEnum GroupVoiceStateFounder   = 2

    fromCEnum 0 = GroupVoiceStateAll
    fromCEnum 1 = GroupVoiceStateModerator
    fromCEnum 2 = GroupVoiceStateFounder
    fromCEnum n = unknownCEnum "Tox_Group_Voice_State" n

data LogLevel
    = LogLevelTrace
      -- ^ Very detailed traces including all network activity.
    | LogLevelDebug
      -- ^ Debug messages such as which port we bind to.
    | LogLevelInfo
      -- ^ Informational log messages such as video call status changes.
    | LogLevelWarning
      -- ^ Warnings about internal inconsistency or logic errors.
    | LogLevelError
      -- ^ Severe unexpected errors caused by external or internal
      -- inconsistency.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum LogLevel where
    toCEnum LogLevelTrace   = 0
    toCEnum LogLevelDebug   = 1
    toCEnum LogLevelInfo    = 2
    toCEnum LogLevelWarning = 3
    toCEnum LogLevelError   = 4

    fromCEnum 0 = LogLevelTrace
    fromCEnum 1 = LogLevelDebug
    fromCEnum 2 = LogLevelInfo
    fromCEnum 3 = LogLevelWarning
    fromCEnum 4 = LogLevelError
    fromCEnum n = unknownCEnum "Tox_Log_Level" n

data MessageType
    = MessageTypeNormal
      -- ^ Normal text message. Similar to PRIVMSG on IRC.
    | MessageTypeAction
      -- ^ A message describing an user action. This is similar to \/me (CTCP
      -- ACTION) on IRC.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum MessageType where
    toCEnum MessageTypeNormal = 0
    toCEnum MessageTypeAction = 1

    fromCEnum 0 = MessageTypeNormal
    fromCEnum 1 = MessageTypeAction
    fromCEnum n = unknownCEnum "Tox_Message_Type" n

data ProxyType
    = ProxyTypeNone
      -- ^ Don't use a proxy.
    | ProxyTypeHttp
      -- ^ HTTP proxy using CONNECT.
    | ProxyTypeSocks5
      -- ^ SOCKS proxy for simple socket pipes.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum ProxyType where
    toCEnum ProxyTypeNone   = 0
    toCEnum ProxyTypeHttp   = 1
    toCEnum ProxyTypeSocks5 = 2

    fromCEnum 0 = ProxyTypeNone
    fromCEnum 1 = ProxyTypeHttp
    fromCEnum 2 = ProxyTypeSocks5
    fromCEnum n = unknownCEnum "Tox_Proxy_Type" n

data SavedataType
    = SavedataTypeNone
      -- ^ No savedata.
    | SavedataTypeToxSave
      -- ^ Savedata is one that was obtained from
      -- 'Network.Tox.C.Tox.toxGetSavedata'.
    | SavedataTypeSecretKey
      -- ^ Savedata is a secret key of length
      -- 'Network.Tox.C.Constants.toxSecretKeySize'.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum SavedataType where
    toCEnum SavedataTypeNone      = 0
    toCEnum SavedataTypeToxSave   = 1
    toCEnum SavedataTypeSecretKey = 2

    fromCEnum 0 = SavedataTypeNone
    fromCEnum 1 = SavedataTypeToxSave
    fromCEnum 2 = SavedataTypeSecretKey
    fromCEnum n = unknownCEnum "Tox_Savedata_Type" n

data UserStatus
    = UserStatusNone
      -- ^ User is online and available.
    | UserStatusAway
      -- ^ User is away. Clients can set this e.g. after a user defined
      -- inactivity time.
    | UserStatusBusy
      -- ^ User is busy. Signals to other clients that this client does not
      -- currently wish to communicate.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum UserStatus where
    toCEnum UserStatusNone = 0
    toCEnum UserStatusAway = 1
    toCEnum UserStatusBusy = 2

    fromCEnum 0 = UserStatusNone
    fromCEnum 1 = UserStatusAway
    fromCEnum 2 = UserStatusBusy
    fromCEnum n = unknownCEnum "Tox_User_Status" n

data AvCallControl
    = AvCallControlResume
      -- ^ Resume a previously paused call. Only valid if the pause was caused
      -- by this client, if not, this control is ignored. Not valid before the
      -- call is accepted.
    | AvCallControlPause
      -- ^ Put a call on hold. Not valid before the call is accepted.
    | AvCallControlCancel
      -- ^ Reject a call if it was not answered, yet. Cancel a call after it was
      -- answered.
    | AvCallControlMuteAudio
      -- ^ Request that the friend stops sending audio. Regardless of the
      -- friend's compliance, this will cause the audio_receive_frame event to
      -- stop being triggered on receiving an audio frame from the friend.
    | AvCallControlUnmuteAudio
      -- ^ Calling this control will notify client to start sending audio again.
    | AvCallControlHideVideo
      -- ^ Request that the friend stops sending video. Regardless of the
      -- friend's compliance, this will cause the video_receive_frame event to
      -- stop being triggered on receiving a video frame from the friend.
    | AvCallControlShowVideo
      -- ^ Calling this control will notify client to start sending video again.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum AvCallControl where
    toCEnum AvCallControlResume      = 0
    toCEnum AvCallControlPause       = 1
    toCEnum AvCallControlCancel      = 2
    toCEnum AvCallControlMuteAudio   = 3
    toCEnum AvCallControlUnmuteAudio = 4
    toCEnum AvCallControlHideVideo   = 5
    toCEnum AvCallControlShowVideo   = 6

    fromCEnum 0 = AvCallControlResume
    fromCEnum 1 = AvCallControlPause
    fromCEnum 2 = AvCallControlCancel
    fromCEnum 3 = AvCallControlMuteAudio
    fromCEnum 4 = AvCallControlUnmuteAudio
    fromCEnum 5 = AvCallControlHideVideo
    fromCEnum 6 = AvCallControlShowVideo
    fromCEnum n = unknownCEnum "Toxav_Call_Control" n

data AvErrAnswer
    = AvErrAnswerSync
      -- ^ Synchronization error occurred.
    | AvErrAnswerCodecInitialization
      -- ^ Failed to initialize codecs for call session. Note that codec
      -- initiation will fail if there is no receive callback registered for
      -- either audio or video.
    | AvErrAnswerFriendNotFound
      -- ^ The friend number did not designate a valid friend.
    | AvErrAnswerFriendNotCalling
      -- ^ The friend was valid, but they are not currently trying to initiate a
      -- call. This is also returned if this client is already in a call with
      -- the friend.
    | AvErrAnswerInvalidBitRate
      -- ^ Audio or video bit rate is invalid.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum AvErrAnswer where
    toCEnum AvErrAnswerSync                = 1
    toCEnum AvErrAnswerCodecInitialization = 2
    toCEnum AvErrAnswerFriendNotFound      = 3
    toCEnum AvErrAnswerFriendNotCalling    = 4
    toCEnum AvErrAnswerInvalidBitRate      = 5

    fromCEnum 1 = AvErrAnswerSync
    fromCEnum 2 = AvErrAnswerCodecInitialization
    fromCEnum 3 = AvErrAnswerFriendNotFound
    fromCEnum 4 = AvErrAnswerFriendNotCalling
    fromCEnum 5 = AvErrAnswerInvalidBitRate
    fromCEnum n = unknownCEnum "Toxav_Err_Answer" n

data AvErrBitRateSet
    = AvErrBitRateSetSync
      -- ^ Synchronization error occurred.
    | AvErrBitRateSetInvalidBitRate
      -- ^ The bit rate passed was not one of the supported values.
    | AvErrBitRateSetFriendNotFound
      -- ^ The friend_number passed did not designate a valid friend.
    | AvErrBitRateSetFriendNotInCall
      -- ^ This client is currently not in a call with the friend.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum AvErrBitRateSet where
    toCEnum AvErrBitRateSetSync            = 1
    toCEnum AvErrBitRateSetInvalidBitRate  = 2
    toCEnum AvErrBitRateSetFriendNotFound  = 3
    toCEnum AvErrBitRateSetFriendNotInCall = 4

    fromCEnum 1 = AvErrBitRateSetSync
    fromCEnum 2 = AvErrBitRateSetInvalidBitRate
    fromCEnum 3 = AvErrBitRateSetFriendNotFound
    fromCEnum 4 = AvErrBitRateSetFriendNotInCall
    fromCEnum n = unknownCEnum "Toxav_Err_Bit_Rate_Set" n

data AvErrCall
    = AvErrCallMalloc
      -- ^ A resource allocation error occurred while trying to create the
      -- structures required for the call.
    | AvErrCallSync
      -- ^ Synchronization error occurred.
    | AvErrCallFriendNotFound
      -- ^ The friend number did not designate a valid friend.
    | AvErrCallFriendNotConnected
      -- ^ The friend was valid, but not currently connected.
    | AvErrCallFriendAlreadyInCall
      -- ^ Attempted to call a friend while already in an audio or video call
      -- with them.
    | AvErrCallInvalidBitRate
      -- ^ Audio or video bit rate is invalid.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum AvErrCall where
    toCEnum AvErrCallMalloc              = 1
    toCEnum AvErrCallSync                = 2
    toCEnum AvErrCallFriendNotFound      = 3
    toCEnum AvErrCallFriendNotConnected  = 4
    toCEnum AvErrCallFriendAlreadyInCall = 5
    toCEnum AvErrCallInvalidBitRate      = 6

    fromCEnum 1 = AvErrCallMalloc
    fromCEnum 2 = AvErrCallSync
    fromCEnum 3 = AvErrCallFriendNotFound
    fromCEnum 4 = AvErrCallFriendNotConnected
    fromCEnum 5 = AvErrCallFriendAlreadyInCall
    fromCEnum 6 = AvErrCallInvalidBitRate
    fromCEnum n = unknownCEnum "Toxav_Err_Call" n

data AvErrCallControl
    = AvErrCallControlSync
      -- ^ Synchronization error occurred.
    | AvErrCallControlFriendNotFound
      -- ^ The friend_number passed did not designate a valid friend.
    | AvErrCallControlFriendNotInCall
      -- ^ This client is currently not in a call with the friend. Before the
      -- call is answered, only CANCEL is a valid control.
    | AvErrCallControlInvalidTransition
      -- ^ Happens if user tried to pause an already paused call or if trying to
      -- resume a call that is not paused.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum AvErrCallControl where
    toCEnum AvErrCallControlSync              = 1
    toCEnum AvErrCallControlFriendNotFound    = 2
    toCEnum AvErrCallControlFriendNotInCall   = 3
    toCEnum AvErrCallControlInvalidTransition = 4

    fromCEnum 1 = AvErrCallControlSync
    fromCEnum 2 = AvErrCallControlFriendNotFound
    fromCEnum 3 = AvErrCallControlFriendNotInCall
    fromCEnum 4 = AvErrCallControlInvalidTransition
    fromCEnum n = unknownCEnum "Toxav_Err_Call_Control" n

data AvErrNew
    = AvErrNewNull
      -- ^ One of the arguments to the function was NULL when it was not
      -- expected.
    | AvErrNewMalloc
      -- ^ Memory allocation failure while trying to allocate structures
      -- required for the A\/V session.
    | AvErrNewMultiple
      -- ^ Attempted to create a second session for the same Tox instance.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum AvErrNew where
    toCEnum AvErrNewNull     = 1
    toCEnum AvErrNewMalloc   = 2
    toCEnum AvErrNewMultiple = 3

    fromCEnum 1 = AvErrNewNull
    fromCEnum 2 = AvErrNewMalloc
    fromCEnum 3 = AvErrNewMultiple
    fromCEnum n = unknownCEnum "Toxav_Err_New" n

data AvErrSendFrame
    = AvErrSendFrameNull
      -- ^ In case of video, one of Y, U, or V was NULL. In case of audio, the
      -- samples data pointer was NULL.
    | AvErrSendFrameFriendNotFound
      -- ^ The friend_number passed did not designate a valid friend.
    | AvErrSendFrameFriendNotInCall
      -- ^ This client is currently not in a call with the friend.
    | AvErrSendFrameSync
      -- ^ Synchronization error occurred.
    | AvErrSendFrameInvalid
      -- ^ One of the frame parameters was invalid. E.g. the resolution may be
      -- too small or too large, or the audio sampling rate may be
      -- unsupported.
    | AvErrSendFramePayloadTypeDisabled
      -- ^ Either friend turned off audio or video receiving or we turned off
      -- sending for the said payload.
    | AvErrSendFrameRtpFailed
      -- ^ Failed to push frame through RTP interface.
    deriving (Eq, Ord, Enum, Bounded, Read, Show)

instance CEnum AvErrSendFrame where
    toCEnum AvErrSendFrameNull                = 1
    toCEnum AvErrSendFrameFriendNotFound      = 2
    toCEnum AvErrSendFrameFriendNotInCall     = 3
    toCEnum AvErrSendFrameSync                = 4
    toCEnum AvErrSendFrameInvalid             = 5
    toCEnum AvErrSendFramePayloadTypeDisabled = 6
    toCEnum AvErrSendFrameRtpFailed           = 7

    fromCEnum 1 = AvErrSendFrameNull
    fromCEnum 2 = AvErrSendFrameFriendNotFound
    fromCEnum 3 = AvErrSendFrameFriendNotInCall
    fromCEnum 4 = AvErrSendFrameSync
    fromCEnum 5 = AvErrSendFrameInvalid
    fromCEnum 6 = AvErrSendFramePayloadTypeDisabled
    fromCEnum 7 = AvErrSendFrameRtpFailed
    fromCEnum n = unknownCEnum "Toxav_Err_Send_Frame" n

newtype AvFriendCallState = AvFriendCallState Word32
    deriving (Eq, Ord, Read, Show, Bits)

-- | The empty bit mask. None of the bits specified below are set.
pattern AvFriendCallStateNone :: AvFriendCallState
pattern AvFriendCallStateNone = AvFriendCallState 0

-- | Set by the AV core if an error occurred on the remote end or if friend
-- timed out. This is the final state after which no more state transitions
-- can occur for the call. This call state will never be triggered in
-- combination with other call states.
pattern AvFriendCallStateError :: AvFriendCallState
pattern AvFriendCallStateError = AvFriendCallState 1

-- | The call has finished. This is the final state after which no more state
-- transitions can occur for the call. This call state will never be triggered
-- in combination with other call states.
pattern AvFriendCallStateFinished :: AvFriendCallState
pattern AvFriendCallStateFinished = AvFriendCallState 2

-- | The flag that marks that friend is sending audio.
pattern AvFriendCallStateSendingA :: AvFriendCallState
pattern AvFriendCallStateSendingA = AvFriendCallState 4

-- | The flag that marks that friend is sending video.
pattern AvFriendCallStateSendingV :: AvFriendCallState
pattern AvFriendCallStateSendingV = AvFriendCallState 8

-- | The flag that marks that friend is receiving audio.
pattern AvFriendCallStateAcceptingA :: AvFriendCallState
pattern AvFriendCallStateAcceptingA = AvFriendCallState 16

-- | The flag that marks that friend is receiving video.
pattern AvFriendCallStateAcceptingV :: AvFriendCallState
pattern AvFriendCallStateAcceptingV = AvFriendCallState 32

newtype ConferenceNumber = ConferenceNumber Word32
    deriving (Eq, Ord, Read, Show)

newtype ConferenceOfflinePeerNumber = ConferenceOfflinePeerNumber Word32
    deriving (Eq, Ord, Read, Show)

newtype ConferencePeerNumber = ConferencePeerNumber Word32
    deriving (Eq, Ord, Read, Show)

newtype FileNumber = FileNumber Word32
    deriving (Eq, Ord, Read, Show)

newtype FriendMessageId = FriendMessageId Word32
    deriving (Eq, Ord, Read, Show)

newtype FriendNumber = FriendNumber Word32
    deriving (Eq, Ord, Read, Show)

newtype GroupMessageId = GroupMessageId Word32
    deriving (Eq, Ord, Read, Show)

newtype GroupNumber = GroupNumber Word32
    deriving (Eq, Ord, Read, Show)

newtype GroupPeerNumber = GroupPeerNumber Word32
    deriving (Eq, Ord, Read, Show)

-- | A bit rate in kbit\/sec.
newtype AvBitRate = AvBitRate Word32
    deriving (Eq, Ord, Read, Show)

-- | The number of audio channels.
newtype AvChannels = AvChannels Word8
    deriving (Eq, Ord, Read, Show)

-- | A video frame's height in pixels.
newtype AvHeight = AvHeight Word16
    deriving (Eq, Ord, Read, Show)

-- | An audio sampling rate in Hz.
newtype AvSamplingRate = AvSamplingRate Word32
    deriving (Eq, Ord, Read, Show)

-- | A video frame's width in pixels.
newtype AvWidth = AvWidth Word16
    deriving (Eq, Ord, Read, Show)

-- | A TCP or UDP port number.
newtype Port = Port Word16
    deriving (Eq, Ord, Read, Show)

-- | 'toxAddressSize' bytes; 'Network.Tox.C.Marshal.fromBytes' makes one.
newtype Address = Address ByteString
    deriving (Eq, Ord, Read, Show)

instance FixedBytes Address where
    fixedSize _ = toxAddressSize

    toBytes (Address bytes) = bytes

    unsafeFromBytes = Address

-- | 'toxConferenceIdSize' bytes; 'Network.Tox.C.Marshal.fromBytes' makes one.
newtype ConferenceId = ConferenceId ByteString
    deriving (Eq, Ord, Read, Show)

instance FixedBytes ConferenceId where
    fixedSize _ = toxConferenceIdSize

    toBytes (ConferenceId bytes) = bytes

    unsafeFromBytes = ConferenceId

-- | 'toxDhtIdSize' bytes; 'Network.Tox.C.Marshal.fromBytes' makes one.
newtype DhtId = DhtId ByteString
    deriving (Eq, Ord, Read, Show)

instance FixedBytes DhtId where
    fixedSize _ = toxDhtIdSize

    toBytes (DhtId bytes) = bytes

    unsafeFromBytes = DhtId

-- | 'toxFileIdLength' bytes; 'Network.Tox.C.Marshal.fromBytes' makes one.
newtype FileId = FileId ByteString
    deriving (Eq, Ord, Read, Show)

instance FixedBytes FileId where
    fixedSize _ = toxFileIdLength

    toBytes (FileId bytes) = bytes

    unsafeFromBytes = FileId

-- | 'toxGroupChatIdSize' bytes; 'Network.Tox.C.Marshal.fromBytes' makes one.
newtype GroupChatId = GroupChatId ByteString
    deriving (Eq, Ord, Read, Show)

instance FixedBytes GroupChatId where
    fixedSize _ = toxGroupChatIdSize

    toBytes (GroupChatId bytes) = bytes

    unsafeFromBytes = GroupChatId

-- | 'toxGroupPeerPublicKeySize' bytes; 'Network.Tox.C.Marshal.fromBytes' makes
-- one.
newtype GroupPeerPublicKey = GroupPeerPublicKey ByteString
    deriving (Eq, Ord, Read, Show)

instance FixedBytes GroupPeerPublicKey where
    fixedSize _ = toxGroupPeerPublicKeySize

    toBytes (GroupPeerPublicKey bytes) = bytes

    unsafeFromBytes = GroupPeerPublicKey

-- | 'toxHashLength' bytes; 'Network.Tox.C.Marshal.fromBytes' makes one.
newtype Hash = Hash ByteString
    deriving (Eq, Ord, Read, Show)

instance FixedBytes Hash where
    fixedSize _ = toxHashLength

    toBytes (Hash bytes) = bytes

    unsafeFromBytes = Hash

-- | 'toxPassSaltLength' bytes; 'Network.Tox.C.Marshal.fromBytes' makes one.
newtype PassSalt = PassSalt ByteString
    deriving (Eq, Ord, Read, Show)

instance FixedBytes PassSalt where
    fixedSize _ = toxPassSaltLength

    toBytes (PassSalt bytes) = bytes

    unsafeFromBytes = PassSalt

-- | 'toxPublicKeySize' bytes; 'Network.Tox.C.Marshal.fromBytes' makes one.
newtype PublicKey = PublicKey ByteString
    deriving (Eq, Ord, Read, Show)

instance FixedBytes PublicKey where
    fixedSize _ = toxPublicKeySize

    toBytes (PublicKey bytes) = bytes

    unsafeFromBytes = PublicKey

-- | 'toxSecretKeySize' bytes; 'Network.Tox.C.Marshal.fromBytes' makes one.
newtype SecretKey = SecretKey ByteString
    deriving (Eq, Ord, Read, Show)

instance FixedBytes SecretKey where
    fixedSize _ = toxSecretKeySize

    toBytes (SecretKey bytes) = bytes

    unsafeFromBytes = SecretKey

newtype PassKey = PassKey (ForeignPtr PassKeyStruct)

newtype Tox = Tox ToxPtr

-- | Start new A\/V session. There can only be only one session per Tox
-- instance.
data ToxAv
    = ToxAv ToxAvPtr CallbackRegistry
