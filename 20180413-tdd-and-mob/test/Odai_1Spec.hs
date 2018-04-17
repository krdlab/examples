module Odai_1Spec (main, spec) where

import           Data.Either
import           System.IO.Error
import           Test.Hspec
import           Test.QuickCheck

import           Odai_1

main :: IO ()
main = hspec spec

spec :: Spec
spec =
  describe "readAll" $ do
    it "should return content if file exists" $ do
      res <- readAll "test/Spec.hs"
      let c = either (const "") id res
      c `shouldSatisfy` (not . null)

    it "should return 'Not Found' error if file does not exists" $ do
      res <- readAll "not-found"
      let err = either id userError res
      isDoesNotExistError err `shouldBe` True
