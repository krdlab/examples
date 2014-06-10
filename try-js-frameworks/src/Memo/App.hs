{-# LANGUAGE OverloadedStrings #-}
module Memo.App (app) where

import Web.Scotty (ScottyM, ActionM, middleware, get, file, post, jsonData, json, delete, param)
import Network.Wai.Middleware.Static (staticPolicy, (>->), noDots, addBase)
import Network.Wai.Middleware.RequestLogger (logStdoutDev)
import Data.IORef
import qualified Data.IntMap as Map
import Control.Monad.IO.Class (liftIO)

import Memo.Model

app :: IORef MemoryStore -> ScottyM ()
app store = do
    middleware logStdoutDev
    middleware $ staticPolicy $ noDots >-> addBase "app"

    get "/" $ file "app/index.html"

    get "/memos" $ do
        memos <- listMemos
        json memos

    post "/memos" $ do
        jdat <- jsonData
        m <- saveMemo jdat
        json m

    delete "/memos/:id" $ do
        mid <- param "id"
        deleteMemo mid

  where
    listMemos :: ActionM [StoredMemo]
    listMemos = do
        MemoryStore _ m <- liftIO $ readIORef store
        return $ map snd $ Map.toAscList m

    saveMemo :: Memo -> ActionM StoredMemo
    saveMemo m =
        liftIO $ atomicModifyIORef store $
            \s ->
                let nid = nextId s
                    smemo = StoredMemo nid m
                in
                    (MemoryStore (nid + 1) (Map.insert nid smemo (records s)), smemo)

    deleteMemo :: Int -> ActionM ()
    deleteMemo k = liftIO $
        modifyIORef store $
            \s -> MemoryStore (nextId s) (Map.delete k (records s))

