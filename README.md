# ap-b-exam-notes

応用情報技術者試験（科目B）の学習ノート。手を動かして覚える教材、分野別の知識メモ、過去の出題テーマをまとめている。

日々の学習ログ・スケジュールは別の場所（work-diary）で管理し、ここは「具体的な知識を調べるときの参照先」として使う。

## フォルダ構成
| フォルダ | 内容 |
| --- | --- |
| `method/` | 科目Bの解き方（空欄の埋め方） |
| `past-topics/` | IPA採点講評から整理した、問ごとの出題テーマと、講評で正答率が低かった設問（令元秋〜令7秋） |
| `knowledge/01_security/` | 問1（情報セキュリティ）の知識メモ（認証、暗号、ログ検知、メール、不正対策など） |
| `knowledge/06_database/` | 問6（データベース）のSQL・E-R図の練習キット。`sql.py` で実行して確認できる。DWH・インデックスなどの補足あり |
| `knowledge/07_embedded/` | 問7（組込みシステム）の知識メモ（RTOS、状態遷移、時間・電池の計算、バッファ・フィルタ） |
| `knowledge/08_development/` | 問8（情報システム開発）の知識メモ（オブジェクト指向、デザインパターン、スレッド、Git、設計判断） |
| `knowledge/09_pm/` | 問9（プロジェクトマネジメント）の知識メモ（リスク、EVM、スケジュール、見積り、調達、アジャイルなど） |
| `knowledge/10_service/` | 問10（サービスマネジメント）の知識メモ（インシデント・問題・変更管理、SLA、KPI、費用） |

## はじめに見るもの
1. 空欄に何を書くか分からない → `method/blank-filling-method.md`
2. どの分野が何度も出ているか知りたい → `past-topics/README.md`、`past-topics/00_overall_ratings.md`
3. SQLの構文や、本文の言葉との対応を調べたい → `knowledge/06_database/cheatsheet.md`、`knowledge/06_database/01_condition_to_sql.md`
4. 毎日10分のSQL練習 → `knowledge/06_database/handson/02_exercises.md`
5. E-R図・正規化・トランザクション → `knowledge/06_database/02_design_basics.md`
6. PMの知識（RBS、EVM、クリティカルパスなど） → `knowledge/09_pm/01_risk.md` から順に
7. 問1・7・8・10の知識 → `knowledge/` の各フォルダのファイル（「繰り返し出る、正答率が低かった知識」の対応表は `past-topics/` の各ファイル）。各フォルダ末尾の `*_low_accuracy_themes.md` は、正答率が低かったテーマの詳しい解説と確認問題

## 方針
- 過去問の問題文・図表は載せない（著作権のため）。「どの空欄で何を見るか」という考え方と、一般知識だけを書く
- 例題とサンプルデータは、型を再現した自作のもの
- `past-topics/` の評価と設問番号は、IPA講評と突き合わせて修正済み（要約ツール経由のため、PDFでの目視確認は未実施）。`knowledge/` の知識メモは一般知識が中心で、講評に基づく記述にだけ「IPA講評」と明記した。`06_database/` の練習キットは例を実行確認済み
- SQL教材は Python 3 の標準ライブラリだけで動く（インストール不要）
