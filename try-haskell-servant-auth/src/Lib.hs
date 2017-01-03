{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE OverloadedStrings #-}
module Lib
    ( startApp
    ) where

import Control.Monad.IO.Class (liftIO)
import Data.Aeson
import Data.Aeson.TH
import Data.ByteString (ByteString)
import Data.Map (Map)
import qualified Data.Map as Map
import Data.Text
import Network.Wai
import Network.Wai.Handler.Warp
import Servant
import Servant.Server.Experimental.Auth


newtype Account = Account { name :: Text } deriving Show
$(deriveJSON defaultOptions ''Account)

database :: Map ByteString Account
database = Map.fromList accounts
  where
    accounts = [ ("key1", Account "Account1")
               , ("key2", Account "Account2")
               , ("key3", Account "Account3")
               ]

-- pseudo IO access
select :: ByteString -> IO (Maybe Account)
select key = return $ Map.lookup key database

lookupAccount :: ByteString -> Handler Account
lookupAccount key = do
    res <- liftIO $ select key
    case res of
        Just a  -> return a
        Nothing -> throwError $ err403 { errBody = "Invalid token" }

authHandler :: AuthHandler Request Account
authHandler = mkAuthHandler handler
  where
    handler req =
        case lookup "X-Servant-Auth-Token" (requestHeaders req) of
            Just sid -> lookupAccount sid
            Nothing  -> throwError $ err401 { errBody = "Missing token header" }

type API =
         "account" :> AuthProtect "header-auth" :> Get '[JSON] Account
    :<|> Get '[JSON] Text

type instance AuthServerData (AuthProtect "header-auth") = Account

api :: Proxy API
api = Proxy

authServerContext :: Context (AuthHandler Request Account ': '[])
authServerContext = authHandler :. EmptyContext

server :: Server API
server = protected :<|> unprotected
  where
    protected   = return
    unprotected = return "unprotected url"

startApp :: IO ()
startApp = run 3000 app

app :: Application
app = serveWithContext api authServerContext server
