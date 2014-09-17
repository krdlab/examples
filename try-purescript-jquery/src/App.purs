module App where

import Prelude
import Data.Either
import Data.Foreign
import qualified Control.Monad.JQuery as J

run = do
    b <- J.body

    i <- J.create "<input />"

    d <- J.create "<div />"
        >>= J.appendText "Your Name: "
        >>= J.append i
    J.append d b

    p <- J.create "<p />"
        >>= J.css { color: "red" }
    J.append p b

    flip (J.on "keyup") i $ do
        name <- getString i
        J.setText ("Hello, " ++ name) p

getString jq = do
    res <- parseForeign read <$> J.getValue jq
    case res of
        Left _  -> return ""
        Right s -> return s
