{-# LANGUAGE OverloadedStrings #-}
module Main where

import Web.Scotty   (scotty)
import Memo.App     (app)
import Memo.Model   (emptyStore)
import Data.IORef   (newIORef)

main :: IO ()
main = do
    let port = 3000
    store <- newIORef emptyStore
    scotty port $ app store
