{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE OverloadedStrings #-}
module Lib
    ( startApp
    ) where

import Control.Monad.IO.Class (liftIO)
import Data.Aeson (ToJSON)
import Data.Aeson.TH (deriveJSON, defaultOptions)
import Data.ByteString (ByteString)
import Data.Map (Map)
import qualified Data.Map as Map
import Data.Text (Text)
import Network.Wai (Application, Request, requestHeaders)
import Network.Wai.Handler.Warp (run)
import Servant ((:<|>)((:<|>)), (:>), Get, JSON, Proxy(Proxy), Context((:.), EmptyContext), AuthProtect, throwError, err401, err403, errBody)
import Servant.Server (Server, serveWithContext, Handler)
import Servant.Server.Experimental.Auth (AuthServerData, AuthHandler, mkAuthHandler)


newtype Account = Account { name :: Text } deriving Show
$(deriveJSON defaultOptions ''Account)

type API =
         "account" :> AuthProtect "header-auth" :> Get '[JSON] Account
    :<|> "public"  :> Get '[JSON] Text

type instance AuthServerData (AuthProtect "header-auth") = Account

database :: Map ByteString Account
database = Map.fromList accounts
  where
    accounts = [ ("token1", Account "account1")
               , ("token2", Account "account2")
               , ("token3", Account "account3")
               ]

startApp :: IO ()
startApp = run 3000 app

app :: Application
app = serveWithContext api authServerContext server

api :: Proxy API
api = Proxy

authServerContext :: Context (AuthHandler Request Account ': '[])
authServerContext = authHandler :. EmptyContext

authHandler :: AuthHandler Request Account
authHandler = mkAuthHandler handler
  where
    handler req =
        case lookup "X-Servant-Auth-Token" (requestHeaders req) of
            Just sid -> lookupAccount sid
            Nothing  -> throwError $ err401 { errBody = "Missing token header" }

lookupAccount :: ByteString -> Handler Account
lookupAccount token = do
    res <- liftIO $ select token
    case res of
        Just a  -> return a
        Nothing -> throwError $ err403 { errBody = "Invalid token" }

-- pseudo IO access
select :: ByteString -> IO (Maybe Account)
select token = return $ Map.lookup token database

server :: Server API
server = account :<|> public
  where
    account = return
    public  = return "public resource"
