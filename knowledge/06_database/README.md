# B科目 問6 SQLハンズオンキット

過去問（令4秋・令7秋ほか、IPA講評の頻出型）のSQLを、手を動かして覚えるための練習キット。サンプルデータ入りで、毎日リセットして使える。

## 中身
| ファイル | 役割 |
| --- | --- |
| `handson/sql.py` | SQLを実行して結果を表で見るツール（Python標準のsqlite3だけで動く） |
| `handson/01_setup.sql` | 表とサンプルデータ（過去問の型を再現した自作データ） |
| `handson/02_exercises.md` | 練習問題 Q1〜Q32（ヒントつき）と、毎日のやり方 |
| `handson/03_answers.sql` | 答え（先に見ない） |
| `cheatsheet.md` | SQL構文表（問題文の手がかりつき） |
| `01_condition_to_sql.md` | **条件の文→SQLの対応表**と例（CREATE/ALTER/GRANT/SELECT/更新）、練習P1〜P4。例は実行確認済み |
| `02_design_basics.md` | E-R図の読み方・正規化・ビュー・トランザクションの基本と、問6の解答前チェック |
| `handson/06_integrated.md` | **総合問題4題**（備品貸出・注文・会議室予約・ポイント）。定義・権限・検索・更新・設計を1つの場面で一気に使う。**まずこれを毎日1題** |
| `handson/06_s1_data.sql`〜`06_s4_data.sql` | 総合問題のデータ（表を作ってから流す） |
| `handson/06_answers.sql` | 総合問題の答え（先に見ない。`python3 sql.py -f 06_answers.sql` で全部通る） |
| `03_dwh_and_advanced.md` | 補足（読み物）。スタースキーマ、マルチテナント、インデックス、LIKE、ウィンドウ関数、副問合せ、排他制御、埋込み変数、サブタイプ |
| `handson/test_01.py` | `01_condition_to_sql.md` のSQL例が実行できるかを確かめるテスト |

## 使い方（最初の1回）
```
cd knowledge/06_database/handson
python3 sql.py reset                      # DBを作る
python3 sql.py tables                     # 表と行数を見る
python3 sql.py "SELECT * FROM staff"      # SQLを1つ実行
python3 sql.py repl                       # 対話モード（空行で実行）
```
Python 3 の標準ライブラリだけで動くので、インストールは不要。

## 毎日
- **総合問題（`06_integrated.md`）を1日1題**。4題をローテーションする（1題15〜20分）
- 苦手な構文は、`02_exercises.md` のQ1〜Q32を辞書のように使って補う（1回の目安は3問）

## 全体の整理

### 2つの層
| 層 | ファイル | 役割 | データ |
| --- | --- | --- | --- |
| 辞書 | `02_exercises.md`（Q1〜Q32）、`cheatsheet.md`、`01_condition_to_sql.md` | 型ごとの短い練習。構文の引き直し | `01_setup.sql`（部署・従業員・講座） |
| 本番形式 | `06_integrated.md`（総合1〜4） | 1つの場面で、定義・検索・更新・設計を通して書く | `06_s1〜s4_data.sql` |

答えは、辞書が `03_answers.sql`、総合が `06_answers.sql`。書き終えて実行したあとで見る。

### 手元のファイルではなく、db-fiddle で回す場合
1. エンジンは **SQLite** にする（`sql.py` と同じエンジンで確認済み。GRANT/REVOKE 以外は、答えがそのまま通る）
2. スキーマ側に `CREATE TABLE` を書き、そのあとにデータの `INSERT`（`06_s*_data.sql` の中身）を貼る。作る順は、参照される表が先
3. クエリ側に `SELECT` や `UPDATE` を書いて実行し、問題の「期待」と比べる
4. 答えは、書き終えたあとだけ見る
5. `GRANT` / `REVOKE` は動かないことが多いので、書いて答えと見比べる
6. `UPDATE` やトランザクションは、実行のたびにスキーマが初期状態に戻る。連続した操作は、クエリを1つにまとめる

### 型の重なり
総合4題は、次の型が重なっている。繰り返して打つことで、定着させるための重なり。

| 型 | 出てくる場所 |
| --- | --- |
| 定義（PRIMARY KEY・FOREIGN KEY・NOT NULL・CHECK） | 総合1〜4のA |
| 0件も出す外部結合 | 総合1サ、総合3オ |
| 「一度もない」を探す（LEFT JOIN … IS NULL / NOT EXISTS） | 総合1コ、総合2ク、総合4キ |
| 集計してから絞る（HAVING） | 総合1ケ、総合3カ |
| 複数の表を1つのトランザクションで更新 | 総合1シ、総合4コ |

その題にしかない型: 総合2＝CASE式の1回のUPDATE・ON DELETE CASCADE・平均を比べる副問合せ、総合3＝3列の複合主キー・IN の定義域制約、総合4＝DEFAULT・NOT NULL・CHECK を重ねる順番・COALESCE・REVOKE・ROLLBACK。

辞書のQだけにある型: Q9（複合キーの結合条件を2つ）、Q17（DEFAULTで入る値）、Q18（外部キー違反のエラー）、Q21（ALTER … ADD FOREIGN KEY）、Q23（DROP と DELETE の違い）。

Level 8（Q29〜Q32）は、練習問題がなかった型の補強: `ALTER TABLE … ADD CONSTRAINT … UNIQUE`、`INSERT … SELECT`、`WITH` ＋ `MAX` ＋ `COALESCE`、CRUD図の読み取り。

### 時間が足りないとき
- 型ごとに1問を選ぶ（例: 0件の外部結合＝総合1サ、「一度もない」＝総合1コ、HAVING＝総合1ケ、平均との比較＝総合2キ、CASEのUPDATE＝総合2コ、2表の更新＝総合1シ）
- 4題のAとCだけを打ち、Bは型ごとの1問に絞る

### 英語表記について
- SQLの表名・列名・値は英語（snake_case）。日本語との対応は、各ファイルの「名前の対応表」にある。条件表・場面・`--` コメントは日本語のまま
- 値を英語にして長くなった列（総合1の区分・状態）は、「10桁以内の可変長文字」にしてある
- `to_english.py` は、対応表に語を足して再実行すると、日本語の残りを置き換え、対応表に追記する。`<code>` タグの中も対象

## 注意
- 過去問の本文そのものは入れていない。表と値は、型を再現した自作のもの
- GRANT/REVOKE は SQLite にないので、書いて答えと見比べる

## 名前の対応表（日本語→英語）

SQLの例の表名・列名・値は、英語で書いてある。日本語との対応は次のとおり。

| 日本語 | 英語 |
| --- | --- |
| 従業員 | `staff` |
