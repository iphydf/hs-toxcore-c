-- | A Tox instance: its own address, name and status, its connections, and its
-- save data.
module Network.Tox.C.Tox
    ( toxVersionIsCompatible
    , toxGetSavedata
    , toxBootstrap
    , toxAddTcpRelay
    , toxSelfGetConnectionStatus
    , toxIterationInterval
    , toxSelfGetAddress
    , toxSelfSetNospam
    , toxSelfGetNospam
    , toxSelfGetPublicKey
    , toxSelfGetSecretKey
    , toxSelfSetName
    , toxSelfGetName
    , toxSelfSetStatusMessage
    , toxSelfGetStatusMessage
    , toxSelfSetStatus
    , toxSelfGetStatus
    , toxSelfGetFriendList
    , toxSelfSetTyping
    , toxHash
    , toxSelfGetDhtId
    , toxSelfGetUdpPort
    , toxSelfGetTcpPort
    ) where

import           Data.ByteString       (ByteString)
import           Data.Word             (Word32)
import qualified FFI.Tox.Tox           as Raw
import           Foreign.C.Enum        (callErrFun, callErrFun_, fromCEnum,
                                        toCEnum)
import           Foreign.C.String      (withCString)
import           Foreign.Marshal.Utils (fromBool, toBool)
import           Network.Tox.C.Marshal (getFixedBytes, getList, getSized,
                                        withBytesLen, withFixedBytes)
import           Network.Tox.C.Types   (Address, Connection, DhtId,
                                        ErrBootstrap, ErrGetPort, ErrSetInfo,
                                        ErrSetTyping, FriendNumber (..), Hash,
                                        Port (..), PublicKey, SecretKey,
                                        Tox (..), UserStatus)

-- | Return whether the compiled library version is compatible with the passed
-- version numbers.
toxVersionIsCompatible :: Word32 -> Word32 -> Word32 -> IO Bool
toxVersionIsCompatible major minor patch =
    toBool <$> Raw.tox_version_is_compatible major minor patch

-- | Store all information associated with the Tox instance to a byte array.
toxGetSavedata :: Tox -> IO ByteString
toxGetSavedata (Tox tox) =
    getSized (Raw.tox_get_savedata_size tox) (Raw.tox_get_savedata tox)

-- | Sends a "nodes request" to the given bootstrap node with IP, port, and DHT
-- public key to setup connections.
--
-- This function will attempt to connect to the node using UDP. You must use
-- this function even if Tox_Options.udp_enabled was set to false.
--
-- * @host@: The hostname or IP address (IPv4 or IPv6) of the node. Must be at
--   most 'Network.Tox.C.Constants.toxMaxHostnameLength' chars, including the
--   NUL byte.
-- * @port@: The port on the host on which the bootstrap Tox instance is
--   listening.
-- * @publicKey@: The DHT public key of the bootstrap node
--   ('Network.Tox.C.Constants.toxDhtIdSize' bytes).
toxBootstrap :: Tox -> String -> Port -> DhtId -> IO (Either ErrBootstrap ())
toxBootstrap (Tox tox) host (Port port) publicKey =
    withCString host $ \hostPtr ->
    withFixedBytes publicKey $ \publicKeyPtr ->
        callErrFun_ $ Raw.tox_bootstrap tox hostPtr port publicKeyPtr

-- | Adds additional host:port pair as TCP relay.
--
-- This function can be used to initiate TCP connections to different ports on
-- the same bootstrap node, or to add TCP relays without using them as
-- bootstrap nodes.
--
-- * @host@: The hostname or IP address (IPv4 or IPv6) of the TCP relay. Must
--   be at most 'Network.Tox.C.Constants.toxMaxHostnameLength' chars,
--   including the NUL byte.
-- * @port@: The port on the host on which the TCP relay is listening.
-- * @publicKey@: The DHT public key of the TCP relay
--   ('Network.Tox.C.Constants.toxDhtIdSize' bytes).
toxAddTcpRelay :: Tox -> String -> Port -> DhtId -> IO (Either ErrBootstrap ())
toxAddTcpRelay (Tox tox) host (Port port) publicKey =
    withCString host $ \hostPtr ->
    withFixedBytes publicKey $ \publicKeyPtr ->
        callErrFun_ $ Raw.tox_add_tcp_relay tox hostPtr port publicKeyPtr

-- | Return whether we are connected to the DHT.
--
-- The return value is equal to the last value received through the
-- @self_connection_status@ callback.
--
-- Deprecated: This getter is deprecated. Use the event and store the status
-- in the client state.
toxSelfGetConnectionStatus :: Tox -> IO Connection
toxSelfGetConnectionStatus (Tox tox) =
    fromCEnum <$> Raw.tox_self_get_connection_status tox

-- | Return the time in milliseconds before @tox_iterate()@ should be called
-- again for optimal performance.
toxIterationInterval :: Tox -> IO Word32
toxIterationInterval (Tox tox) = Raw.tox_iteration_interval tox

-- | Writes the Tox friend address of the client to a byte array.
--
-- The address is not in human-readable format. If a client wants to display
-- the address, formatting is required.
--
-- See 'Network.Tox.C.Constants.toxAddressSize' for the address format.
toxSelfGetAddress :: Tox -> IO Address
toxSelfGetAddress (Tox tox) = getFixedBytes $ Raw.tox_self_get_address tox

-- | Set the 4-byte nospam part of the address.
--
-- This value is expected in host byte order. I.e. 0x12345678 will form the
-- bytes @[12, 34, 56, 78]@ in the nospam part of the Tox friend address.
--
-- * @nospam@: Any 32 bit unsigned integer.
toxSelfSetNospam :: Tox -> Word32 -> IO ()
toxSelfSetNospam (Tox tox) nospam = Raw.tox_self_set_nospam tox nospam

-- | Get the 4-byte nospam part of the address.
--
-- This value is returned in host byte order.
toxSelfGetNospam :: Tox -> IO Word32
toxSelfGetNospam (Tox tox) = Raw.tox_self_get_nospam tox

-- | Copy the Tox Public Key (long term) from the Tox object.
toxSelfGetPublicKey :: Tox -> IO PublicKey
toxSelfGetPublicKey (Tox tox) = getFixedBytes $ Raw.tox_self_get_public_key tox

-- | Copy the Tox Secret Key from the Tox object.
toxSelfGetSecretKey :: Tox -> IO SecretKey
toxSelfGetSecretKey (Tox tox) = getFixedBytes $ Raw.tox_self_get_secret_key tox

-- | Set the nickname for the Tox client.
--
-- Nickname length cannot exceed 'Network.Tox.C.Constants.toxMaxNameLength'.
-- If length is 0, the name parameter is ignored (it can be NULL), and the
-- nickname is set back to empty.
--
-- * @name@: A byte array containing the new nickname.
toxSelfSetName :: Tox -> ByteString -> IO (Either ErrSetInfo ())
toxSelfSetName (Tox tox) name =
    withBytesLen name $ \namePtr nameLen ->
        callErrFun_ $ Raw.tox_self_set_name tox namePtr nameLen

-- | Write the nickname set by 'toxSelfSetName' to a byte array.
--
-- If no nickname was set before calling this function, the name is empty, and
-- this function has no effect.
toxSelfGetName :: Tox -> IO ByteString
toxSelfGetName (Tox tox) =
    getSized (Raw.tox_self_get_name_size tox) (Raw.tox_self_get_name tox)

-- | Set the client's status message.
--
-- Status message length cannot exceed
-- 'Network.Tox.C.Constants.toxMaxStatusMessageLength'. If length is 0, the
-- status parameter is ignored (it can be NULL), and the user status is set
-- back to empty.
toxSelfSetStatusMessage :: Tox -> ByteString -> IO (Either ErrSetInfo ())
toxSelfSetStatusMessage (Tox tox) statusMessage =
    withBytesLen statusMessage $ \statusMessagePtr statusMessageLen ->
        callErrFun_ $
            Raw.tox_self_set_status_message tox statusMessagePtr
                statusMessageLen

-- | Write the status message set by 'toxSelfSetStatusMessage' to a byte array.
--
-- If no status message was set before calling this function, the status is
-- empty, and this function has no effect.
toxSelfGetStatusMessage :: Tox -> IO ByteString
toxSelfGetStatusMessage (Tox tox) =
    getSized
        (Raw.tox_self_get_status_message_size tox)
        (Raw.tox_self_get_status_message tox)

-- | Set the client's user status.
--
-- * @status@: One of the user statuses listed in the enumeration above.
toxSelfSetStatus :: Tox -> UserStatus -> IO ()
toxSelfSetStatus (Tox tox) status = Raw.tox_self_set_status tox (toCEnum status)

-- | Returns the client's user status.
toxSelfGetStatus :: Tox -> IO UserStatus
toxSelfGetStatus (Tox tox) = fromCEnum <$> Raw.tox_self_get_status tox

-- | Copy a list of valid friend numbers into an array.
toxSelfGetFriendList :: Tox -> IO [FriendNumber]
toxSelfGetFriendList (Tox tox) =
    map FriendNumber
        <$> getList
            (Raw.tox_self_get_friend_list_size tox)
            (Raw.tox_self_get_friend_list tox)

-- | Set the client's typing status for a friend.
--
-- The client is responsible for turning it on or off.
--
-- * @friendNumber@: The friend to which the client is typing a message.
-- * @typing@: The typing status. True means the client is typing.
toxSelfSetTyping :: Tox -> FriendNumber -> Bool -> IO (Either ErrSetTyping ())
toxSelfSetTyping (Tox tox) (FriendNumber friendNumber) typing =
    callErrFun_ $ Raw.tox_self_set_typing tox friendNumber (fromBool typing)

-- | Generates a cryptographic hash of the given data.
--
-- This function may be used by clients for any purpose, but is provided
-- primarily for validating cached avatars. This use is highly recommended to
-- avoid unnecessary avatar updates.
--
-- If hash is NULL or data is NULL while length is not 0 the function returns
-- false, otherwise it returns true.
--
-- This function is a wrapper to internal message-digest functions.
--
-- * @data'@: Data to be hashed or NULL.
toxHash :: ByteString -> IO Hash
toxHash data' =
    withBytesLen data' $ \dataPtr dataLen ->
        getFixedBytes $ \buffer -> Raw.tox_hash buffer dataPtr dataLen

-- | Writes the temporary DHT public key of this instance to a byte array.
--
-- This can be used in combination with an externally accessible IP address
-- and the bound port (from 'toxSelfGetUdpPort') to run a temporary bootstrap
-- node.
--
-- Be aware that every time a new instance is created, the DHT public key
-- changes, meaning this cannot be used to run a permanent bootstrap node.
toxSelfGetDhtId :: Tox -> IO DhtId
toxSelfGetDhtId (Tox tox) = getFixedBytes $ Raw.tox_self_get_dht_id tox

-- | Return the UDP port this Tox instance is bound to.
toxSelfGetUdpPort :: Tox -> IO (Either ErrGetPort Port)
toxSelfGetUdpPort (Tox tox) =
    fmap Port <$> callErrFun (Raw.tox_self_get_udp_port tox)

-- | Return the TCP port this Tox instance is bound to.
--
-- This is only relevant if the instance is acting as a TCP relay.
toxSelfGetTcpPort :: Tox -> IO (Either ErrGetPort Port)
toxSelfGetTcpPort (Tox tox) =
    fmap Port <$> callErrFun (Raw.tox_self_get_tcp_port tox)
