# メッセージ → コマンド列

## Caveat

As codes are experimentally written, it is maybe hard to read.

実験的なコードなので，おそらく読みづらいです．

## 概要

アテンション付き Encoder-Decoder モデル．

とりあえず，例えば以下のような基本的なタスクから試してみる．

```txt
> おはようございます
 => nothing

> 来週月曜日の14時から鈴木さんと会う
 => dic = { name0: 鈴木, time0: 14時 }
 => schedule ( 来週 月曜日 ) ( time0 ) ( name0 会う )

> 明日の9時までに資料を作る
 => dic = { time0: 9時 }
 => todo ( 明日 ) ( time0 ) ( 資料 作る )
```
