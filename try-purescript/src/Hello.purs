module Main where

import Control.Monad.Eff
import Debug.Trace

main :: Eff (trace :: Trace) Unit
main = trace "Hello, world!"
