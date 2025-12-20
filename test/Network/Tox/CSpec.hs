{-# LANGUAGE OverloadedStrings #-}
module Network.Tox.CSpec (spec) where

import           Control.Concurrent (threadDelay)
import           Data.ByteString    (ByteString)
import qualified Data.ByteString    as BS
import           Test.Hspec

import           Network.Tox.C

must :: Show e => IO (Either e a) -> IO a
must action = action >>= either (fail . show) return

withDefaultTox :: (Tox -> IO a) -> IO a
withDefaultTox action = do
    options <- must defaultOptions
    must (withTox options { localDiscoveryEnabled = False } action)

hex :: ByteString -> String
hex = concatMap byte . BS.unpack
  where
    byte b = [digits !! fromIntegral (b `div` 16), digits !! fromIntegral (b `mod` 16)]
    digits = "0123456789abcdef"

spec :: Spec
spec = do
    describe "Options" $
        it "keeps every field through C" $ do
            options <- must defaultOptions
            let changed = options
                    { udpEnabled = not (udpEnabled options)
                    , proxyType = ProxyTypeSocks5
                    , proxyHost = "proxy.example"
                    , proxyPort = Port 9050
                    , savedata = "not really a save"
                    , savedataType = SavedataTypeToxSave
                    , experimentalDisableDns = True
                    }
            withOptions changed peekOptions `shouldReturn` Right changed

    describe "a Tox instance" $ do
        it "remembers its name, status message and nospam" $
            withDefaultTox $ \tox -> do
                must (toxSelfSetName tox "Alice")
                must (toxSelfSetStatusMessage tox "Here")
                toxSelfSetNospam tox 0x01020304
                toxSelfGetName tox `shouldReturn` "Alice"
                toxSelfGetStatusMessage tox `shouldReturn` "Here"
                toxSelfGetNospam tox `shouldReturn` 0x01020304

        it "starts its address with its public key" $
            withDefaultTox $ \tox -> do
                publicKey <- toxSelfGetPublicKey tox
                address <- toxSelfGetAddress tox
                toBytes address `shouldSatisfy` BS.isPrefixOf (toBytes publicKey)

        it "reports C's errors as the error enum's values" $
            withDefaultTox $ \tox -> do
                toxSelfSetName tox (BS.replicate (toxMaxNameLength + 1) 0)
                    `shouldReturn` Left ErrSetInfoTooLong
                toxFriendSendMessage tox (FriendNumber 0) MessageTypeNormal "hi"
                    `shouldReturn` Left ErrFriendSendMessageFriendNotFound
                address <- toxSelfGetAddress tox
                toxFriendAdd tox address "hi" `shouldReturn` Left ErrFriendAddOwnKey

        it "comes back from its save data" $ do
            options <- must defaultOptions
            (save, publicKey) <- must $ withTox options $ \tox -> do
                must (toxSelfSetName tox "Alice")
                (,) <$> toxGetSavedata tox <*> toxSelfGetPublicKey tox
            let restored = options { savedataType = SavedataTypeToxSave, savedata = save }
            must $ withTox restored $ \tox -> do
                toxSelfGetPublicKey tox `shouldReturn` publicKey
                toxSelfGetName tox `shouldReturn` "Alice"

        it "tells of connecting to another instance as an event" $
            withDefaultTox $ \alice -> withDefaultTox $ \bob -> do
                port <- must (toxSelfGetUdpPort alice)
                dhtId <- toxSelfGetDhtId alice
                must (toxBootstrap bob "127.0.0.1" port dhtId)
                let connected = any $ \event -> case event of
                        SelfConnectionStatus e -> selfConnectionStatus e /= ConnectionNone
                        _                      -> False
                    loop :: Int -> IO Bool
                    loop 0 = return False
                    loop n = do
                        _ <- must (toxEventsIterate alice)
                        events <- must (toxEventsIterate bob)
                        if connected events
                            then return True
                            else threadDelay 50000 >> loop (n - 1)
                loop 600 `shouldReturn` True

    describe "fixed-size byte strings" $
        it "only come from bytes of their size" $ do
            (fromBytes (BS.replicate 31 0) :: Maybe PublicKey) `shouldBe` Nothing
            toBytes <$> (fromBytes (BS.replicate 32 7) :: Maybe PublicKey)
                `shouldBe` Just (BS.replicate 32 7)

    describe "toxHash" $
        it "is SHA-256" $ do
            hash <- toxHash ""
            hex (toBytes hash)
                `shouldBe` "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

    describe "encryption" $ do
        it "decrypts what it encrypted, with the same passphrase only" $ do
            ciphertext <- must (toxPassEncrypt "save data" "secret")
            toxIsDataEncrypted ciphertext `shouldReturn` True
            toxPassDecrypt ciphertext "secret" `shouldReturn` Right "save data"
            toxPassDecrypt ciphertext "guess" `shouldReturn` Left ErrDecryptionFailed

        it "derives the same key from the salt of the data" $ do
            ciphertext <- must (toxPassEncrypt "save data" "secret")
            salt <- must (toxGetSalt ciphertext)
            key <- must (toxPassKeyDeriveWithSalt "secret" salt)
            toxPassKeyDecrypt key ciphertext `shouldReturn` Right "save data"

        it "refuses data too short for C to read" $
            toxIsDataEncrypted "short" `shouldThrow` anyIOException

    describe "a ToxAv instance" $
        it "takes callbacks for the life of the instance" $
            withDefaultTox $ \tox -> must $ withToxAv tox $ \av -> do
                toxavCallbackCall av $ \_ _ _ -> return ()
                toxavCallbackCall av $ \_ _ _ -> return ()
                toxavIterationInterval av >>= (`shouldSatisfy` (> 0))
