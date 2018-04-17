{-# LANGUAGE ScopedTypeVariables #-}

module Odai_1 where

import           Control.Exception (try)
import           System.IO.Error   (IOError, ioeGetFileName,
                                    isDoesNotExistError)

run :: FilePath -> IO ()
run path = do
    res <- readAll path
    case res of
      Right c -> printNumberdLines c
      Left  e -> printError e

readAll :: FilePath -> IO (Either IOError String)
readAll path = try $ readFile path

printNumberdLines :: String -> IO ()
printNumberdLines = mapM_ putStrLn . numbering . lines

printError :: IOError -> IO ()
printError e =
  if isDoesNotExistError e
    then putStrLn $ "Not Found: " ++ show (ioeGetFileName e)
    else print e

-- | 行番号を付ける
--
-- >>> numbering ["aaa","bbb"]
-- ["1:aaa","2:bbb"]
--
-- >>> numbering []
-- []
--
numbering :: [String] -> [String]
numbering ls = map (prepend width) (pairs ls)
  where
    width = digit $ length ls

-- | 行番号と行文字列のペアを作成する
--
-- >>> pairs ["aaa","bbb"]
-- [(1,"aaa"),(2,"bbb")]
--
-- >>> pairs []
-- []
--
pairs :: [String] -> [(Int, String)]
pairs ls = zip [1..] ls

-- | 最大桁数を考慮して行番号を先頭に追加する
--
-- >>> prepend 2 (1, "test")
-- " 1:test"
--
-- >>> prepend 2 (10, "test")
-- "10:test"
--
prepend :: Int -> (Int, String) -> String
prepend w (n, l) = padding w n ++ show n ++ ":" ++ l

-- | 必要なサイズのパディングを生成する
--
-- >>> padding 3 9
-- "  "
--
-- >>> padding 3 10
-- " "
--
-- >>> padding 3 100
-- ""
--
padding :: Int -> Int -> String
padding m n = replicate needed ' '
  where
    needed = m - digit n

-- | 整数値の桁数を求める (負値に対しては未定義)
--
-- >>> digit 0
-- 1
--
-- >>> digit 1
-- 1
--
-- >>> digit 19
-- 2
--
-- >>> digit 199
-- 3
--
digit :: Int -> Int
digit n
    | n > 0  = floor (log10 n :: Double) + 1
    | n == 0 = 1
    | otherwise = undefined
  where
    log10 x = logBase 10 $ fromIntegral x
