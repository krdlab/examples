{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE TypeFamilies     #-}

module Odai_2 where
-- NOTE: お題 2 (1) の時点で「ごちゃってきたからまとめとこう」と思ってできたモジュール

import           Data.Char (toUpper)
import           Data.List (nub)

data Hand = Rock | Paper | Scissers
    deriving (Eq, Show, Read)

data JankenResult = Win | Lose | Draw
    deriving (Eq, Show)

-- | 読み込んだ文字列を Hand に変換する
--
-- >>> parseHand "rock"
-- Rock
--
-- >>> parseHand "paper"
-- Paper
--
-- >>> parseHand "scissers"
-- Scissers
--
parseHand :: String -> Hand
parseHand s = read $ capitalize s -- TODO: 手抜き
  where
    capitalize (x:xs) = toUpper x : xs

-- | 3 すくみの状態か？
--
-- >>> standoff []
-- False
--
-- >>> standoff [Rock, Rock]
-- False
--
-- >>> standoff [Rock, Paper]
-- False
--
-- >>> standoff [Paper, Scissers, Rock]
-- True
--
-- >>> standoff [Paper, Scissers, Rock, Paper]
-- True
--
standoff :: [Hand] -> Bool
standoff xs = length (nub xs) == 3

-- | すべて同じ手か？
--
-- >>> sameAll []
-- False
--
-- >>> sameAll [Rock, Rock]
-- True
--
-- >>> sameAll [Rock, Paper]
-- False
--
-- >>> sameAll [Paper, Scissers, Paper]
-- False
--
sameAll :: [Hand] -> Bool
sameAll xs = length (nub xs) == 1

-- | 自分が相手に「どうなったのか」を判定する
--
judge :: Hand -> Hand -> JankenResult
judge Rock Rock         = Draw
judge Rock Paper        = Lose
judge Rock Scissers     = Win
judge Paper Paper       = Draw
judge Paper Rock        = Win
judge Paper Scissers    = Lose
judge Scissers Scissers = Draw
judge Scissers Rock     = Lose
judge Scissers Paper    = Win

-- | じゃんけん挑戦者を表現するために必要な構造を示す
--
class (Show a, Eq (Name a), Show (Name a)) => JankenChallenger a where
    type Name a :: *
    name :: a -> Name a
    hand :: a -> Hand
