-- | Creating and destroying Tox and ToxAv instances.
module Network.Tox.C.Lifecycle
    ( withTox
    , withToxLogging
    , LogCallback
    , withToxAv
    ) where

import           Control.Exception     (bracket, finally)
import           Data.Word             (Word32)
import qualified FFI.Tox.Av            as Raw
import qualified FFI.Tox.Events        as Raw
import qualified FFI.Tox.Options       as Raw
import qualified FFI.Tox.Tox           as Raw
import qualified FFI.Tox.Types         as Raw
import           Foreign.C.Enum        (fromCEnum)
import           Foreign.Ptr           (FunPtr, freeHaskellFunPtr)
import           Network.Tox.C.Marshal (freeCallbacks, newCallbackRegistry,
                                        peekNullableString, withNew)
import           Network.Tox.C.Options (Options, withOptions)
import           Network.Tox.C.Types   (AvErrNew, ErrNew (..),
                                        ErrOptionsNew (..), LogLevel, Tox (..),
                                        ToxAv (..))

-- | Creates a Tox instance with these options for the action, and kills it
-- after. What happens to it comes from
-- 'Network.Tox.C.Events.toxEventsIterate'.
withTox :: Options -> (Tox -> IO a) -> IO (Either ErrNew a)
withTox options = withToxLogger options Nothing

-- | What Tox logs: the level, the source file, line and function, and the
-- message. It runs in the thread iterating Tox, and must not throw.
type LogCallback = LogLevel -> String -> Word32 -> String -> String -> IO ()

-- | 'withTox', with Tox's log messages going to the callback.
withToxLogging :: Options -> LogCallback -> (Tox -> IO a) -> IO (Either ErrNew a)
withToxLogging options callback action =
    bracket (Raw.wrapLogCb (logCb callback)) freeHaskellFunPtr $ \logger ->
        withToxLogger options (Just logger) action

withToxLogger :: Options -> Maybe (FunPtr Raw.LogCb) -> (Tox -> IO a) -> IO (Either ErrNew a)
withToxLogger options logger action =
    fmap flatten $ withOptions options $ \optionsPtr -> do
        mapM_ (Raw.tox_options_set_log_callback optionsPtr) logger
        withNew (Raw.tox_new optionsPtr) Raw.tox_kill $ \tox -> do
            Raw.tox_events_init tox
            action (Tox tox)
  where
    flatten (Left ErrOptionsNewMalloc) = Left ErrNewMalloc
    flatten (Right result)             = result

logCb :: LogCallback -> Raw.LogCb
logCb callback _ level file line function message _ = do
    file' <- peekNullableString file
    function' <- peekNullableString function
    message' <- peekNullableString message
    callback (fromCEnum level) file' line function' message'

-- | Creates a ToxAv instance on the Tox instance for the action, and kills it
-- after, with the callbacks registered on it.
withToxAv :: Tox -> (ToxAv -> IO a) -> IO (Either AvErrNew a)
withToxAv (Tox tox) action = do
    callbacks <- newCallbackRegistry
    withNew (Raw.toxav_new tox) Raw.toxav_kill (\av -> action (ToxAv av callbacks))
        `finally` freeCallbacks callbacks
