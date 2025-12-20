-- | The options a Tox instance starts with.
module Network.Tox.C.Options
    ( Options (..)
    , defaultOptions
    , withOptions
    , peekOptions
    ) where

import           Control.Monad         (void)
import           Data.ByteString       (ByteString)
import           Data.Coerce           (coerce)
import qualified FFI.Tox.Options       as Raw
import           FFI.Tox.Types         (OptionsPtr)
import           Foreign.C.Enum        (fromCEnum, toCEnum)
import           Foreign.C.String      (withCString)
import           Foreign.Marshal.Utils (fromBool, toBool)
import           Network.Tox.C.Marshal (peekNullableString, peekSizedBytes,
                                        withBytesLen, withNew)
import           Network.Tox.C.Types   (ErrOptionsNew, Port (..), ProxyType,
                                        SavedataType)

-- | The options for a new Tox instance.
data Options = Options
    { ipv6Enabled                   :: Bool
      -- ^ The type of socket to create.
      --
      -- If this is set to false, an IPv4 socket is created, which
      -- subsequently only allows IPv4 communication. If it is set to true, an
      -- IPv6 socket is created, allowing both IPv4 and IPv6 communication.
    , udpEnabled                    :: Bool
      -- ^ Enable the use of UDP communication when available.
      --
      -- Setting this to false will force Tox to use TCP only. Communications
      -- will need to be relayed through a TCP relay node, potentially slowing
      -- them down.
      --
      -- If a proxy is enabled, UDP will be disabled if either the Tox library
      -- or the proxy don't support proxying UDP messages.
    , localDiscoveryEnabled         :: Bool
      -- ^ Enable local network peer discovery.
      --
      -- Disabling this will cause Tox to not look for peers on the local
      -- network.
    , dhtAnnouncementsEnabled       :: Bool
      -- ^ Enable storing DHT announcements and forwarding corresponding
      -- requests.
      --
      -- Disabling this will cause Tox to ignore the relevant packets.
    , proxyType                     :: ProxyType
      -- ^ Pass communications through a proxy.
    , proxyHost                     :: String
      -- ^ The IP address or DNS name of the proxy to be used.
      --
      -- If used, this must be non-NULL and be a valid DNS name. The name must
      -- not exceed 'Network.Tox.C.Constants.toxMaxHostnameLength' characters,
      -- and be in a NUL-terminated C string format
      -- ('Network.Tox.C.Constants.toxMaxHostnameLength' includes the NUL
      -- byte).
      --
      -- This member is ignored (it can be NULL) if proxy_type is
      -- TOX_PROXY_TYPE_NONE.
      --
      -- The data pointed at by this member is owned by the user, so must
      -- outlive the options object (unless experimental_owned_data is set).
    , proxyPort                     :: Port
      -- ^ The port to use to connect to the proxy server.
      --
      -- Ports must be in the range (1, 65535). The value is ignored if
      -- proxy_type is TOX_PROXY_TYPE_NONE.
    , startPort                     :: Port
      -- ^ The start port of the inclusive port range to attempt to use.
      --
      -- If both start_port and end_port are 0, the default port range will be
      -- used: @[33445, 33545]@.
      --
      -- If either start_port or end_port is 0 while the other is non-zero,
      -- the non-zero port will be the only port in the range.
      --
      -- Having start_port > end_port will yield the same behavior as if
      -- start_port and end_port were swapped.
    , endPort                       :: Port
      -- ^ The end port of the inclusive port range to attempt to use.
    , tcpPort                       :: Port
      -- ^ The port to use for the TCP server (relay). If 0, the TCP server is
      -- disabled.
      --
      -- Enabling it is not required for Tox to function properly.
      --
      -- When enabled, your Tox instance can act as a TCP relay for other Tox
      -- instance. This leads to increased traffic, thus when writing a client
      -- it is recommended to enable TCP server only if the user has an option
      -- to disable it.
    , holePunchingEnabled           :: Bool
      -- ^ Enables or disables UDP hole-punching. (Default: enabled).
    , savedataType                  :: SavedataType
      -- ^ The type of savedata to load from.
    , savedata                      :: ByteString
      -- ^ The savedata (either a Tox save or a secret key) to load from.
      --
      -- The data pointed at by this member is owned by the user, so must
      -- outlive the options object (unless experimental_owned_data is set).
    , experimentalGroupsPersistence :: Bool
      -- ^ Enable saving DHT-based group chats to Tox save data (via
      -- 'Network.Tox.C.Tox.toxGetSavedata'). This format will change in the
      -- future, so don't rely on it.
      --
      -- As an alternative, clients can save the group chat ID in client-owned
      -- savedata. Then, when the client starts, it can use
      -- 'Network.Tox.C.Group.toxGroupJoin' with the saved chat ID to recreate
      -- the group chat.
      --
      -- Default: false.
    , experimentalDisableDns        :: Bool
      -- ^ Disable DNS hostname resolution.
      --
      -- Hostnames or IP addresses are passed to the bootstrap\/add_tcp_relay
      -- function and proxy host options. If disabled (this flag is true),
      -- only IP addresses are allowed.
      --
      -- If this is set to true, the library will not attempt to resolve
      -- hostnames. This is useful for clients that want to resolve hostnames
      -- themselves and pass the resolved IP addresses to the library (e.g. in
      -- case it wants to use Tor). Passing hostnames will result in a
      -- TOX_ERR_BOOTSTRAP_BAD_HOST error if this is set to true.
      --
      -- Default: false. May become true in the future (0.3.0).
    }
    deriving (Eq, Read, Show)

-- | The options C gives a new instance.
defaultOptions :: IO (Either ErrOptionsNew Options)
defaultOptions = withNew Raw.tox_options_new Raw.tox_options_free peekOptions

-- | C options with these values, for the action.
withOptions :: Options -> (OptionsPtr -> IO a) -> IO (Either ErrOptionsNew a)
withOptions options action =
    withNew Raw.tox_options_new Raw.tox_options_free $ \ptr ->
    withCString (proxyHost options) $ \proxyHostPtr ->
    withBytesLen (savedata options) $ \savedataPtr savedataLen -> do
        Raw.tox_options_set_experimental_thread_safety ptr (fromBool True)
        Raw.tox_options_set_ipv6_enabled ptr (fromBool (ipv6Enabled options))
        Raw.tox_options_set_udp_enabled ptr (fromBool (udpEnabled options))
        Raw.tox_options_set_local_discovery_enabled ptr
            (fromBool (localDiscoveryEnabled options))
        Raw.tox_options_set_dht_announcements_enabled ptr
            (fromBool (dhtAnnouncementsEnabled options))
        Raw.tox_options_set_proxy_type ptr (toCEnum (proxyType options))
        void $ Raw.tox_options_set_proxy_host ptr proxyHostPtr
        Raw.tox_options_set_proxy_port ptr (coerce (proxyPort options))
        Raw.tox_options_set_start_port ptr (coerce (startPort options))
        Raw.tox_options_set_end_port ptr (coerce (endPort options))
        Raw.tox_options_set_tcp_port ptr (coerce (tcpPort options))
        Raw.tox_options_set_hole_punching_enabled ptr
            (fromBool (holePunchingEnabled options))
        Raw.tox_options_set_savedata_type ptr (toCEnum (savedataType options))
        void $ Raw.tox_options_set_savedata_data ptr savedataPtr savedataLen
        Raw.tox_options_set_experimental_groups_persistence ptr
            (fromBool (experimentalGroupsPersistence options))
        Raw.tox_options_set_experimental_disable_dns ptr
            (fromBool (experimentalDisableDns options))
        action ptr

-- | The values of C options.
peekOptions :: OptionsPtr -> IO Options
peekOptions ptr =
    Options
        <$> (toBool <$> Raw.tox_options_get_ipv6_enabled ptr)
        <*> (toBool <$> Raw.tox_options_get_udp_enabled ptr)
        <*> (toBool <$> Raw.tox_options_get_local_discovery_enabled ptr)
        <*> (toBool <$> Raw.tox_options_get_dht_announcements_enabled ptr)
        <*> (fromCEnum <$> Raw.tox_options_get_proxy_type ptr)
        <*> (Raw.tox_options_get_proxy_host ptr >>= peekNullableString)
        <*> (Port <$> Raw.tox_options_get_proxy_port ptr)
        <*> (Port <$> Raw.tox_options_get_start_port ptr)
        <*> (Port <$> Raw.tox_options_get_end_port ptr)
        <*> (Port <$> Raw.tox_options_get_tcp_port ptr)
        <*> (toBool <$> Raw.tox_options_get_hole_punching_enabled ptr)
        <*> (fromCEnum <$> Raw.tox_options_get_savedata_type ptr)
        <*> peekSizedBytes
                (Raw.tox_options_get_savedata_data ptr)
                (Raw.tox_options_get_savedata_length ptr)
        <*> (toBool <$> Raw.tox_options_get_experimental_groups_persistence ptr)
        <*> (toBool <$> Raw.tox_options_get_experimental_disable_dns ptr)
