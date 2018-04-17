{-# LANGUAGE FlexibleContexts     #-}
{-# LANGUAGE FlexibleInstances    #-}
{-# LANGUAGE ScopedTypeVariables  #-}
{-# LANGUAGE TypeFamilies         #-}
{-# LANGUAGE TypeSynonymInstances #-}

module Odai_2_3 where

import           Control.Monad (replicateM)
import           Data.Char     (toLower)
import           Odai_2
import           Odai_2_1      hiding (Challenger, format, readAll)

data Challenger = Challenger
    { _name :: String
    , _hand :: Hand
    }
    deriving (Eq, Show)

instance JankenChallenger Challenger where
    type Name Challenger = String
    name = _name
    hand = _hand

run :: IO ()
run = do
    cs <- readAll parser
    let rs = judges cs
    if isAllDraws rs
        then putStrLn "draw"
        else putStrLn . format $ winners rs

readAll :: (String -> Challenger) -> IO [Challenger]
readAll p = do
    n :: Int <- read <$> getLine
    replicateM n (p <$> getLine)

-- |
-- >>> parser "paper krdlab"
-- Challenger {_name = "krdlab", _hand = Paper}
--
parser :: String -> Challenger
parser s = -- TODO: 手抜き
    let ps = words s in
        Challenger { _name = ps !! 1
                   , _hand = parseHand $ ps !! 0
                   }

format :: [Challenger] -> String
format ws =
    str (hand $ head ws)
    ++ "\n" ++
    unlines (map name ws)
  where
    str = map toLower . show
