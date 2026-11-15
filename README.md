# ap-b-exam-notes

応用情報技術者試験（科目B）の学習ノート。手を動かして覚える教材、分野別の知識メモ、過去の出題テーマをまとめている。

日々の学習ログ・スケジュールは別の場所（work-diary）で管理し、ここは「具体的な知識を調べるときの参照先」として使う。

## フォルダ構成
| フォルダ | 内容 |
| --- | --- |
| `method/` | 科目Bの解き方（空欄の埋め方） |
| `past-topics/` | IPA採点講評から整理した、問ごとの出題テーマと「低い」設問（令元秋〜令7秋） |
| `knowledge/06_database/` | 問6（データベース）のSQL・E-R図の練習キット。`sql.py` で実行して確認できる |
| `knowledge/09_pm/` | 問9（プロジェクトマネジメント）の知識メモ（リスク、EVM、スケジュール、見積り、調達、アジャイルなど） |

## はじめに見るもの
1. 空欄に何を書くか分からない → `method/blank-filling-method.md`
2. どの分野が何度も出ているか知りたい → `past-topics/README.md`、`past-topics/00_overall_ratings.md`
3. SQLの構文や、本文の言葉との対応を調べたい → `knowledge/06_database/cheatsheet.md`、`knowledge/06_database/04_condition_to_sql.md`
4. 毎日10分のSQL練習 → `knowledge/06_database/02_exercises.md`
5. E-R図・正規化・トランザクション → `knowledge/06_database/05_design_basics.md`
6. PMの知識（RBS、EVM、クリティカルパスなど） → `knowledge/09_pm/01_risk.md` から順に

## 方針
- 過去問の問題文・図表は載せない（著作権のため）。「どの空欄で何を見るか」という考え方と、一般知識だけを書く
- 例題とサンプルデータは、型を再現した自作のもの
- `past-topics/` と `knowledge/09_pm/` の内容は、IPA原文との照合を済ませていない（各ファイルに明記）
- SQL教材は Python 3 の標準ライブラリだけで動く（インストール不要）
