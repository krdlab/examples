{-# LANGUAGE FlexibleContexts     #-}
{-# LANGUAGE FlexibleInstances    #-}
{-# LANGUAGE ScopedTypeVariables  #-}
{-# LANGUAGE TypeFamilies         #-}
{-# LANGUAGE TypeSynonymInstances #-}

module Odai_2_1 where

import           Control.Monad (replicateM)
import           Data.Char     (toLower)
import           Odai_2

type Challenger = (Int, Hand)

instance JankenChallenger Challenger where
    type Name Challenger = Int
    name = fst
    hand = snd

run :: IO ()
run = do
    cs <- readAll parseHand
    let res = judges cs
    if isAllDraws res
        then putStrLn "draw"
        else putStrLn . format $ winners res

readAll :: (String -> Hand) -> IO [Challenger]    -- NOTE: ファイル読み込みにしたければ，ここを変える
readAll p = do
    n  :: Int <- read <$> getLine
    js <- replicateM n (p <$> getLine)
    return $ zip [1..] js

format :: [Challenger] -> String
format = map toLower . show . snd . head

-- $
-- >>> :set -XFlexibleContexts
-- >>> :set -XScopedTypeVariables

-- | じゃんけんの判定結果を返す
--
-- >>> judges [(1,Paper),(2,Paper)] :: [(Challenger, JankenResult)]
-- [((1,Paper),Draw),((2,Paper),Draw)]
--
-- >>> judges [(1,Scissers),(2,Paper)] :: [(Challenger, JankenResult)]
-- [((1,Scissers),Win),((2,Paper),Lose)]
--
-- >>> judges [(1,Scissers),(2,Paper),(3,Rock),(4,Paper)] :: [(Challenger, JankenResult)]
-- [((1,Scissers),Draw),((2,Paper),Draw),((3,Rock),Draw),((4,Paper),Draw)]
--
judges :: JankenChallenger a => [a] -> [(a, JankenResult)]
judges cs =
    if isStandoff cs || isSameAll cs
        then draws cs
        else judges' cs
  where
    draws = map (\c -> (c, Draw))

judges' :: JankenChallenger a => [a] -> [(a, JankenResult)]
judges' cs = do
    self <- cs
    let results = map (judge (hand self) . hand) (without self)
    return (self, notDraw results)
  where
    without s  = filter ((/=) (name s) . name) cs
    notDraw rs = head $ filter ((/=) Draw) rs

isStandoff :: JankenChallenger a => [a] -> Bool
isStandoff cs = standoff $ map hand cs

isSameAll :: JankenChallenger a => [a] -> Bool
isSameAll cs = sameAll $ map hand cs

-- | すべて Draw か？
--
-- >>> isAllDraws ([((1,Paper),Draw),((2,Paper),Draw)] :: [(Challenger, JankenResult)])
-- True
--
-- >>> isAllDraws ([((1,Paper),Win),((2,Rock),Draw)] :: [(Challenger, JankenResult)])
-- False
--
isAllDraws :: JankenChallenger a => [(a, JankenResult)] -> Bool
isAllDraws = all (\r -> snd r == Draw)

-- | 勝者を返す
--
-- >>> winners ([((1,Scissers),Win),((2,Paper),Lose)] :: [(Challenger, JankenResult)])
-- [(1,Scissers)]
--
winners :: JankenChallenger a => [(a, JankenResult)] -> [a]
winners xs = map fst $ filter (\x -> snd x == Win) xs
