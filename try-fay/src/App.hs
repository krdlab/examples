{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RebindableSyntax  #-}
module App where

import qualified Fay.Text as T
import Fay.Text (fromString)
import FFI
import JQuery
import Prelude

create :: T.Text -> Fay JQuery
create = ffi "$(%1)"

main :: Fay ()
main = ready $ do
    input <- create "<input/>"
    div'  <- create "<div/>"
        >>= setText "Name: "
        >>= append input
    p     <- create "<p/>"
        >>= setCss "color" "red"

    select "body"
        >>= append div'
        >>= append p

    flip keyup input $ \_ -> do
        name <- getVal input
        setText ("Hello, " `T.append` name) p
        return ()

