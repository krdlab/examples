module Main where

import Control.Monad.Eff
import Debug.Trace

import qualified Data.List as L
import Data.Maybe
import qualified Control.Plus as P

type Entry =
    { firstName :: String
    , lastName  :: String
    , phone     :: String
    }

showEntry :: Entry -> String
showEntry e = e.lastName ++ ", " ++ e.firstName ++ ": " ++ e.phone
-- instance showEntry :: Show Entry where
--     show e = e.lastName ++ ", " ++ e.firstName ++ ": " ++ e.phone

type PhoneBook = L.List Entry

empty :: PhoneBook
empty = P.empty

insert :: Entry -> PhoneBook -> PhoneBook
insert = L.Cons

find :: String -> String -> PhoneBook -> Maybe Entry
find fn ln = L.filter pred >>> L.head
  where
    pred e = e.firstName == fn && e.lastName == ln

main :: Eff (trace :: Trace) Unit
main = do
    let examples = insert sample1 >>> insert sample2
        book = examples empty
    print $ showEntry <$> find "f2" "l2" book
  where
    sample1 = { firstName: "f1", lastName: "l1", phone: "11-1111-1111" }
    sample2 = { firstName: "f2", lastName: "l2", phone: "22-2222-2222" }

