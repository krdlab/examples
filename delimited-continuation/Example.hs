module Example where

import Control.Monad.CC
import Control.Applicative ((<$>))
import Control.Monad.IO.Class (liftIO)
import Prelude hiding (product)

example1 :: CC r Int
example1 = reset $ \p -> (3 +) <$> shift p (\_ -> return 1)

example2 :: CC r Int
example2 = reset $ \p -> (3 +) <$> shift p (\k -> k $ return 1)

product :: [Int] -> Int
product l =
    case l of
        []     -> 1
        (0:_ ) -> 0
        (x:xs) -> x * product xs

product' :: [Int] -> CC r Int
product' l = reset $ \p -> go p l
    where
        go p' l' =
            case l' of
                []     -> return 1
                (0:_ ) -> shift p' $ \_ -> return 0
                (x:xs) -> (x *) <$> go p' xs

data Tree =
      Node Tree Int Tree
    | Empty

data Iter r =
      Iter Int (CC r (Iter r))
    | End

walk :: Tree -> CC r (Iter r)
walk t = reset $ \p -> go p t
    where
        go p' t' =
            case t' of
                Empty      -> return End
                Node l v r -> do
                    go p' l
                    shift p' $ \k -> return $ Iter v (k $ return ())
                    go p' r

tree :: Tree
tree = Node (Node (Node (Node Empty 1 Empty) 2 Empty) 3 Empty) 4 (Node Empty 5 (Node Empty 6 Empty))

exampleTree :: CC r [Int]
exampleTree = do
    n <- walk tree
    go [] n
    where
        go :: [Int] -> Iter r -> CC r [Int]
        go l End = return l
        go l (Iter val cont) = do
            let l' = l ++ [val]
            n' <- cont
            go l' n'

example3 :: CCT r IO ()
example3 = reset $ \p -> do
    e1 <- either' p True False
    e2 <- either' p True False
    liftIO $ putStrLn $ show e1 ++ ", " ++ show e2
    where
        either' p a b = shift p $ \k -> k (return a) >> k (return b)

