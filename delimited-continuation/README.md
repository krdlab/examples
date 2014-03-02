# Haskell による shift/reset プログラミング入門

## はじめに

[shift/reset プログラミング入門](http://pllab.is.ocha.ac.jp/~asai/cw2011tutorial/main-j.pdf) という
非常に丁寧な解説があります (トップページは[これ](http://pllab.is.ocha.ac.jp/~asai/cw2011tutorial/)かな)．

この内容を Haskell でやってみよう，というものです．[CC-delcont](http://hackage.haskell.org/package/CC-delcont) を利用します．

### 動作確認

```sh
$ cabal sandbox init
$ cabal install --only-dependencies
$ cabal build
$ cabal repl
...
*Main> runCC example1
*Main> runCCT example3
```

## 限定継続

ざっくりいうと「範囲が限定された継続」です．

通常の継続ではプログラム全体が対象ですが，限定継続では指定した範囲のみを継続として扱います．

例えば，今プログラム全体を `3 + 5 * 2 - 1` とします．
範囲指定を `<...>` で，今見ている場所を `[・]` で示すと，以下のようになります．

    <3 + [5 * 2]> - 1
    ~~~~~~~~~~~~~
     限定継続の範囲


    <3 + [5 * 2]> - 1
         ~~~~~~~
         今見ている場所

`[・]` から見た継続は `<3 + [・]> - 1`，限定継続は `<3 + [・]>` になります．

なお，`[・]` のことを hole と呼ぶそうです．

## reset と shift

### reset

前述の `<...>` にあたり，限定継続の範囲を指定します．こんな感じ．

```haskell
reset (3 + [5 * 2]) - 1
```

「`[・]` の結果に 3 を加える」までが限定継続になります．

### shift

限定継続を取ってきます．こんな感じ．

```haskell
shift (\cont -> M)
```

現在の限定継続 (reset の範囲) が `cont` に束縛されます．計算 M を実行して reset の外側まで飛びます．
M の中で `cont` を使うと，束縛された継続が呼び出されます．

### 擬似コードによるイメージ

以下のようなプログラムがあるとします．

```js
A;
B;
```

これを CPS 変換すると以下のようになります．

```js
function _A(next) { A; next(); }
function _B(next) { B; next(); }

_A(function() { _B(function() {}); });
```

この時「`A` と `B` が `reset` で囲まれていて」「`shift` (`_A` や `_B` がこれに相当) によって `next` に継続が束縛されている」ような感じでイメージするとわかりやすいでしょうか？
(少し無理があったかな？)

## CC-delcont を用いたコード

説明だけだとややこしいので実例を示します．
コード中の `p` は限定継続を識別する値だと思ってください (私もまだ詳細を把握できていません)．

### 継続の破棄

`shift` で取ってきた継続 `3 + [・]` を捨てて，1 を返します．

```haskell
example1 :: CC r Int
example1 = reset $ \p -> (3 +) <$> shift p (\_ -> return 1)
```

もちろん捨てずに使えば 4 になります．

```haskell
example2 :: CC r Int
example2 = reset $ \p -> (3 +) <$> shift p (\k -> k $ return 1)
```

次の例では 0 に出会ったら即計算結果として 0 を返します．

```haskell
product' :: [Int] -> CC r Int
product' l = reset $ \p -> go p l
    where
        go p' l' =
            case l' of
                []     -> return 1
                (0:_ ) -> shift p' $ \_ -> return 0
                (x:xs) -> (x *) <$> go p' xs
```

### 継続の取り出し

TODO: 型が分からん...orz

### 継続の保存

実行を中断して返すことができます．`yield` 見たいな感じの動作です．

```haskell
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

-- > runCC exampleTree
-- [1,2,3,4,5,6]
```

### 継続の複製

継続を複数回使用すると，バックトラックみたいになります．

```haskell
example3 :: CCT r IO ()
example3 = reset $ \p -> do
    e1 <- either' p True False
    e2 <- either' p True False
    liftIO $ putStrLn $ show e1 ++ ", " ++ show e2
    where
        either' p a b = shift p $ \k -> k (return a) >> k (return b)
```

これは 4 回出力されます．

```
> runCCT example3
True, True
True, False
False, True
False, False
```

## おわりに

Haskell を用いて限定継続のコードを記述しました．

[shift/reset プログラミング入門](http://pllab.is.ocha.ac.jp/~asai/cw2011tutorial/main-j.pdf) では他にも以下のような例を紹介しています．

* printf
* answer type の変化
* 状態モナドの実現
* 実行順序の変更
* 継続の複製によるバックトラック

興味をもたれた方には一読をおすすめします．


/以上
