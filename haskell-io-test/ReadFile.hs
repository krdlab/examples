{-
    Reference information: http://stackoverflow.com/a/7374754
-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE FlexibleInstances #-}
module ReadFile where

import Control.Applicative (Applicative, (<$>))
import Control.Monad.State (State, get, evalState)
import Prelude hiding (readFile)
import qualified System.IO as IO

class (Functor m, Applicative m, Monad m) => MonadFS m where
    readFile :: FilePath -> m String

countChars :: MonadFS m => FilePath -> m Int
countChars path = length <$> readFile path

instance MonadFS IO where
    readFile = IO.readFile

data MockFS = SingleFile FilePath String

instance MonadFS (State MockFS) where
    readFile path = do
        (SingleFile mockPath mockContents) <- get
        if path == mockPath
            then return mockContents
            else fail "file not found"

test :: Bool
test =
    let mock   = SingleFile "test.txt" "hello world"
        expect = 11
        in
            evalState (countChars "test.txt") mock == expect

run :: FilePath -> IO Int
run = countChars
