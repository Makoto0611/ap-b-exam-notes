# B科目 問6 SQLハンズオンキット

過去問（令4秋・令7秋ほか、IPA講評の頻出型）のSQLを、手を動かして覚えるための練習キット。サンプルデータ入りで、毎日リセットして使える。

## 中身
| ファイル | 役割 |
| --- | --- |
| `sql.py` | SQLを実行して結果を表で見るツール（Python標準のsqlite3だけで動く） |
| `01_setup.sql` | 表とサンプルデータ（過去問の型を再現した自作データ） |
| `02_exercises.md` | 練習問題 Q1〜Q28（ヒントつき）と、毎日のやり方 |
| `03_answers.sql` | 答え（先に見ない） |
| `cheatsheet.md` | SQL構文表（問題文の手がかりつき） |
| `04_condition_to_sql.md` | **条件の文→SQLの対応表**と例（CREATE/ALTER/GRANT/SELECT/更新）、練習P1〜P4。例は実行確認済み |
| `05_design_basics.md` | E-R図の読み方・正規化・ビュー・トランザクションの基本と、問6の解答前チェック |
| `test_04.py` | `04` のSQL例が実行できるかを確かめるテスト |

## 使い方（最初の1回）
```
cd sql-handson
python3 sql.py reset                      # DBを作る
python3 sql.py tables                     # 表と行数を見る
python3 sql.py "SELECT * FROM 従業員"      # SQLを1つ実行
python3 sql.py repl                       # 対話モード（空行で実行）
```
Python 3 の標準ライブラリだけで動くので、インストールは不要。

## 毎日
`02_exercises.md` の「毎日のやり方（10分）」に従う。1回の目安は3問。

## 注意
- 過去問の本文そのものは入れていない。表と値は、型を再現した自作のもの
- GRANT/REVOKE は SQLite にないので、書いて答えと見比べる
