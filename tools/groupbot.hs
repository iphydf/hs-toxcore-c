{-# LANGUAGE LambdaCase     #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE StrictData     #-}
module Main (main) where

import           Control.Concurrent       (threadDelay)
import           Control.Exception        (AsyncException (UserInterrupt),
                                           catch, throwIO)
import           Control.Monad            (foldM)
import qualified Data.ByteString.Base16   as Base16
import qualified Data.ByteString.Char8    as BS
import           Data.String              (fromString)
import qualified Data.Text.Encoding       as Text
import qualified Data.Text.IO             as Text
import           Data.Word                (Word32)
import           System.Directory         (doesFileExist)
import           System.Exit              (exitSuccess)

import qualified Network.Tox.C            as C
import           Network.Tox.Types.Events


bootstrapKey, masterKey :: BS.ByteString
Right bootstrapKey =
    Base16.decode . fromString $
        "3F0A45A268367C1BEA652F258C85F4A66DA76BCAA667A49E770BCC4917AB6A25"
Right masterKey =
    Base16.decode . fromString $
        "040F75B5C8995F9525F9A8692A6C355286BBD3CF248C984560733421274F0365"

isMasterKey :: BS.ByteString -> Bool
isMasterKey = (masterKey ==)

botName :: BS.ByteString
botName = fromString "groupbot"

bootstrapHost :: String
bootstrapHost = "tox.initramfs.io"

savedataFilename :: String
savedataFilename = "groupbot.tox"

options :: BS.ByteString -> C.Options
options savedata = C.Options
    { C.ipv6Enabled  = True
    , C.udpEnabled   = True
    , C.proxyType    = C.ProxyTypeNone
    , C.proxyHost    = ""
    , C.proxyPort    = 0
    , C.startPort    = 33445
    , C.endPort      = 33545
    , C.tcpPort      = 3128
    , C.savedataType = if savedata == BS.empty then C.SavedataTypeNone else C.SavedataTypeToxSave
    , C.savedataData = savedata
    }


getRight :: (MonadFail m, Show a) => Either a b -> m b
getRight (Left  l) = fail $ show l
getRight (Right r) = return r


must :: Show a => IO (Either a b) -> IO b
must = (getRight =<<)


newtype UserData = UserData { groupNumber :: Word32 }
    deriving (Read, Show)

handleEvent :: C.Tox -> UserData -> Event -> IO UserData
handleEvent tox ud@(UserData gn) = \case
    SelfConnectionStatus{ connectionStatus } -> do
        putStrLn "SelfConnectionStatusCb"
        print connectionStatus
        return ud

    FriendRequest{ publicKey = C.FixedByteString pk, message } -> do
        putStrLn "FriendRequestCb"
        Right fn <- C.toxFriendAddNorequest tox pk
        putStrLn $ (BS.unpack . Base16.encode) pk
        Text.putStrLn $ Text.decodeUtf8 message
        print fn
        return ud

    FriendConnectionStatus friendNumber status -> do
        putStrLn "FriendConnectionStatusCb"
        print friendNumber
        print status
        if status /= C.ConnectionNone
            then do
                putStrLn "Inviting!"
                _ <- C.toxConferenceInvite tox friendNumber gn
                return ()
            else
                putStrLn "Friend offline"
        return ud

    FriendMessage{ friendNumber, messageType, message } -> do
        putStrLn "FriendMessage"
        print friendNumber
        print messageType
        Text.putStrLn $ Text.decodeUtf8 message
        _ <- C.toxFriendSendMessage tox friendNumber messageType message
        return ud

    ConferenceInvite{ friendNumber, cookie } -> do
        putStrLn "ConferenceInvite"
        print friendNumber
        pk <- getRight =<< C.toxFriendGetPublicKey tox friendNumber
        if isMasterKey pk
            then do
                putStrLn "Joining!"
                newGn <- getRight =<< C.toxConferenceJoin tox friendNumber cookie
                return $ UserData newGn
            else do
                putStrLn "Not master!"
                return ud

    _ -> return ud


loop :: C.Tox -> UserData -> IO ()
loop tox ud = do
    interval <- C.toxIterationInterval tox
    threadDelay $ fromIntegral $ interval * 10000
    events <- C.toxEventsIterate tox
    case events of
        Left err -> fail $ show err
        Right ok -> foldM (handleEvent tox) ud ok >>= loop tox


main :: IO ()
main = do
    exists <- doesFileExist savedataFilename
    loadedSavedata <- if exists then BS.readFile savedataFilename else return BS.empty
    must $ C.withTox (options loadedSavedata) $ \tox -> do
        must $ C.toxBootstrap tox bootstrapHost 33445 bootstrapKey

        adr <- C.toxSelfGetAddress tox
        putStrLn $ (BS.unpack . Base16.encode) adr
        _ <- C.toxSelfSetName tox botName
        gn <- getRight =<< C.toxConferenceNew tox
        catch (loop tox (UserData gn)) $ \case
            e@UserInterrupt -> throwIO e
            _ -> do
                savedSavedata <- C.toxGetSavedata tox
                BS.writeFile savedataFilename savedSavedata
                exitSuccess
