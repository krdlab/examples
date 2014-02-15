{-# LANGUAGE OverloadedStrings #-}
module Memo.App (app) where

import Web.Scotty (ScottyM, ActionM, middleware, get, file, post, jsonData, json, delete, param)
import Network.Wai.Middleware.Static (staticPolicy, (>->), noDots, addBase)
import Network.Wai.Middleware.RequestLogger (logStdoutDev)

import Control.Applicative          ((<$>))
import Control.Monad.IO.Class       (MonadIO, liftIO)
import Control.Monad.Trans.Resource (runResourceT)
import Control.Monad.Logger         (runStderrLoggingT)

import Memo.Model
import qualified Database.Persist           as P
import qualified Database.Persist.Sqlite    as P
import Database.Persist.Sqlite (runSqlPool)

app :: P.ConnectionPool -> ScottyM ()
app pool = do
    middleware logStdoutDev
    middleware $ staticPolicy $ noDots >-> addBase "public"

    get "/" $ file "public/index.html"

    get "/memos" $ do
        memos <- listMemos
        json memos

    post "/memos" $ do
        jdat <- jsonData
        memo <- saveMemo jdat
        json memo

    delete "/memos/:id" $ do
        mid <- param "id"
        deleteMemo mid

    where
        listMemos :: ActionM [Memo]
        listMemos = runDB $ map P.entityVal <$> P.selectList ([] :: [P.Filter Memo]) [P.Asc MemoId]

        saveMemo :: Memo -> ActionM Memo
        saveMemo m = runDB $ do
            mid <- P.insert m
            P.getJust mid

        deleteMemo :: Int -> ActionM ()
        deleteMemo = undefined  -- TODO

        runDB query = liftIO $ runResourceT $ runStderrLoggingT $ runSqlPool query pool
