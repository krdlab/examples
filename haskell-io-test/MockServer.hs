{-
    Reference information: https://blog.pusher.com/unit-testing-io-in-haskell/
-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
module MockServer where

import Control.Applicative (Applicative)
import Control.Monad.Catch (MonadThrow)
import Control.Monad.Reader (ReaderT, runReaderT, MonadReader, ask)
import Control.Monad.Trans.Class (MonadTrans)
import Data.ByteString.Lazy (ByteString)
import Network.HTTP.Client (newManager, defaultManagerSettings, Manager, createCookieJar, parseUrl, Request, Response(..))
import qualified Network.HTTP.Client as HTTP
import Network.HTTP.Client.Internal (Response(..), ResponseClose(..))
import Network.HTTP.Types.Status (mkStatus)
import Network.HTTP.Types.Version (http11)

newtype MockServer m a = MockServer
    { server :: ReaderT (Response ByteString) m a }
    deriving (Functor, Applicative, Monad, MonadTrans, MonadThrow)

run :: MonadThrow m => MockServer m a -> Response ByteString -> m a
run (MockServer s) = runReaderT s

deriving instance MonadThrow m => MonadReader (Response ByteString) (MockServer m)

class MonadThrow m => MonadHTTP m where
    httpLbs :: Request -> Manager -> m (Response ByteString)

instance MonadHTTP IO where
    httpLbs = HTTP.httpLbs

instance MonadThrow m => MonadHTTP (MockServer m) where
    httpLbs _ _ = ask

succeededResponse :: Response ByteString
succeededResponse = Response
    { responseStatus = mkStatus 200 "success"
    , responseVersion = http11
    , responseHeaders = []
    , responseBody = "{\"data\":\"some body\"}"
    , responseCookieJar = createCookieJar []
    , responseClose' = ResponseClose (return () :: IO ())
    }

get :: MonadHTTP m => Manager -> String -> m ByteString
get manager url = do
    req <- parseUrl url
    res <- httpLbs req manager
    return $ responseBody res

test :: IO ByteString
test = do
    manager <- newManager defaultManagerSettings
    run (get manager "http://localhost/dummy") succeededResponse
