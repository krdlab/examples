{-# LANGUAGE FlexibleContexts  #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GADTs             #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeFamilies      #-}
{-# LANGUAGE DeriveGeneric     #-}
module Memo.Model where

import Data.Text (Text)
import Data.Aeson (FromJSON, ToJSON)
import GHC.Generics
import Data.IntMap
import Prelude hiding (id)

data Memo = Memo { content :: Text } deriving (Show, Generic)
data StoredMemo = StoredMemo { id :: Int, memo :: Memo } deriving (Show, Generic)

instance FromJSON Memo
instance ToJSON   Memo

instance ToJSON   StoredMemo

data MemoryStore = MemoryStore { nextId :: Int, records :: IntMap StoredMemo }

emptyStore :: MemoryStore
emptyStore = MemoryStore 1 empty

