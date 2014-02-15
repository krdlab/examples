{-# LANGUAGE OverloadedStrings #-}
module Main where

import Web.Scotty               (scotty)
import Memo.App                 (app)
import Memo.Model               (migrateDB)
import Database.Persist.Sqlite  (withSqlitePool)

main :: IO ()
main = do
    let port     = 3000
        database = "memo.db"
        connNum  = 3

    migrateDB database
    withSqlitePool database connNum $ \pool -> scotty port $ app pool
