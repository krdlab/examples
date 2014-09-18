module Main (main) where

import Control.Monad.Eff
import Debug.Trace (Trace(..), trace, print)
import Math (sqrt)

main :: Eff (trace :: Trace) Unit
main = print $ diagonal 3 4

diagonal :: Number -> Number -> Number
diagonal x y = sqrt $ x * x + y * y

