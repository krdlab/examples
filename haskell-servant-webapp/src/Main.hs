{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE DeriveGeneric #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}
module Main where

import Control.Concurrent.STM (atomically, TVar, newTVarIO, readTVar, readTVarIO, writeTVar, modifyTVar)
import Control.Monad.IO.Class (liftIO)
import Data.Aeson (FromJSON(..), ToJSON(..))
import qualified Data.Map as M
import Data.Text (Text)
import Data.Time (LocalTime(..), TimeZone(..), ZonedTime(..), hoursToTimeZone, midday, fromGregorian, utcToZonedTime, getCurrentTime, getCurrentTimeZone)
import GHC.Generics (Generic)
import Network.Wai (Application)
import Network.Wai.Handler.Warp (run)
import Prelude hiding (id)
import Servant ((:>), (:<|>)(..), ReqBody, Capture, Get, Post, Delete, Proxy(..), Server, serve)
import Servant.Docs (docs, ToCapture(..), DocCapture(..), ToSample(..), markdown)
import System.Environment (getArgs)

data Memo = Memo
    { id :: Int
    , text :: Text
    , createdAt :: ZonedTime
    }
    deriving (Show, Generic)

instance ToJSON Memo

data ReqMemo = ReqMemo { memo :: Text } deriving (Show, Generic)

instance FromJSON ReqMemo
instance ToJSON ReqMemo

type MemoAPI =
         "memos"                     :> Get [Memo]
    :<|> "memos" :> ReqBody ReqMemo  :> Post Memo
    :<|> "memos" :> Capture "id" Int :> Delete

memoAPI :: Proxy MemoAPI
memoAPI = Proxy

type MemoStore = TVar (Int, M.Map Int Memo)

main :: IO ()
main = do
    args <- getArgs
    case args of
        ["d"] -> putStrLn doc
        ["s"] -> runApp
        _     -> putStrLn "unknown option"

runApp :: IO ()
runApp = do
    store <- newTVarIO (0, M.empty)
    run 8000 $ app store

app :: MemoStore -> Application
app s = serve memoAPI $ server s

doc :: String
doc = markdown $ docs memoAPI

server :: MemoStore -> Server MemoAPI
server s = getMemosH :<|> postMemoH :<|> deleteMemoH
  where
    getMemosH     = liftIO $ getMemos s
    postMemoH t   = liftIO $ postMemo s t
    deleteMemoH i = liftIO $ deleteMemo s i

getMemos :: MemoStore -> IO [Memo]
getMemos store = do
    (_, m) <- readTVarIO store
    return $ M.elems m

postMemo :: MemoStore -> ReqMemo -> IO Memo
postMemo store req = do
    zone <- getCurrentTimeZone
    zt <- getCurrentZonedTime zone
    atomically $ do
        curr <- readTVar store
        let m = Memo (fst curr + 1) (memo req) zt
        writeTVar store (id m, M.insert (id m) m (snd curr))
        return m

deleteMemo :: MemoStore -> Int -> IO ()
deleteMemo store i = atomically $
    modifyTVar store $ \s -> let nm = M.delete i (snd s) in (fst s, nm)

getCurrentZonedTime :: TimeZone -> IO ZonedTime
getCurrentZonedTime tz = do
    ct <- getCurrentTime
    return $ utcToZonedTime tz ct

-- NOTE: ↓ for documentation

instance ToCapture (Capture "id" Int) where
    toCapture _ = DocCapture "id" "memo id"

instance ToSample Memo where
    toSample = Just sampleMemo

instance ToSample [Memo] where
    toSample = Just [sampleMemo]

sampleMemo :: Memo
sampleMemo = Memo
    { id = 5
    , text = "Try haskell-servant."
    , createdAt = ZonedTime (LocalTime (fromGregorian 2014 12 31) midday) (hoursToTimeZone 9)
    }

instance ToSample ReqMemo where
    toSample = Just $ ReqMemo "Try haskell-servant."

