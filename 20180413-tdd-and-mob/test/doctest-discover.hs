{-# OPTIONS_GHC -F -pgmF doctest-discover #-}

module Main where

import           Test.DocTest

main :: IO ()
main = doctest
    [ "src/Odai_1.hs"
    , "src/Odai_2.hs"
    , "src/Odai_2_1.hs"
    , "src/Odai_2_2.hs"
    , "src/Odai_2_3.hs"
    ]
