# 2018/04/13 TDD + モブプログラミング

```sh
$ stack test

$ stack repl
*Odai_2_4 Odai_1 Odai_2 Odai_2_1 Odai_2_2 Odai_2_3 Odai_2_4> Odai_1.run "src/Odai_1.hs"
...(結果が表示される)

*Odai_2_4 Odai_1 Odai_2 Odai_2_1 Odai_2_2 Odai_2_3 Odai_2_4> Odai_2_1.run
2
paper
scissers
scissers -- 結果

*Odai_2_4 Odai_1 Odai_2 Odai_2_1 Odai_2_2 Odai_2_3 Odai_2_4> Odai_2_2.run
3
paper
paper
rock
paper 2 -- 結果

*Odai_2_4 Odai_1 Odai_2 Odai_2_1 Odai_2_2 Odai_2_3 Odai_2_4> Odai_2_3.run
3
paper krdlab
paper foo
rock bar
paper -- 結果
krdlab
foo
```
