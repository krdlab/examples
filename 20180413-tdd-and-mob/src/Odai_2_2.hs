
module Odai_2_2 where

import           Data.Char (toLower)
import           Odai_2
import           Odai_2_1  hiding (format)

run :: IO ()
run = do
    cs <- readAll parseHand
    let rs = judges cs
    if isAllDraws rs
        then putStrLn "draw"
        else putStrLn . format $ winners rs

format :: [Challenger] -> String
format ws = str (snd $ head ws) ++ " " ++ winnerCount ws
  where
    str = map toLower . show
    winnerCount = show . length
