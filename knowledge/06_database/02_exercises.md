# B科目 問6 SQLハンズオン（毎日10分）

答えは `03_answers.sql` にあります。**先に見ない**。まず自分で書いて、結果の表を見て、合っているか確かめる。

## 毎日のやり方（10分）
1. `python3 sql.py reset`（DBをまっさらに戻す）
2. 今日の3問を選ぶ（下の「日替わり」参照）
3. **書く前に**、結果の行数と中身を予想する（紙に1行）
4. 実行して、予想と比べる。ずれたら、そこが穴
5. 穴を1行メモ（例:「LEFT JOINは右が無いとNULL」）
6. 3問のうち1つは、答えを見ずに「なぜそう書くか」を口で説明する

## 表の構成（`python3 sql.py tables` / `schema 表名`）
```
部署(部署ID, 部署名, 上位部署ID→部署)            … 自己参照
従業員(従業員ID, 氏名, 部署ID→部署, 給与)
通信事業者(事業者ID, 事業者名)
契約(契約ID, 従業員ID→従業員, 事業者ID→通信事業者, 暗証番号 DEFAULT '1234')
講座(講座コード, 講座名)
開催(講座コード→講座, 開催番号, 開催日)           … 複合主キー
受講(従業員ID→従業員, 講座コード, 開催番号, 結果)  … 複合外部キー＋ON DELETE CASCADE
```
意図的に入れてある「穴」: 従業員がいない部署（本社・総務部）、開催がない講座（SQL入門）、結果が NULL の受講、暗証番号が初期値の契約。

## 日替わり
| 曜日 | Level | 目安 |
| --- | --- | --- |
| 月 | 1（参照） | Q1〜Q4 |
| 火 | 2（結合・外部結合） | Q5〜Q9 |
| 水 | 3（集計・副問合せ） | Q10〜Q14 |
| 木 | 4（更新） | Q15〜Q18 |
| 金 | 5（定義） | Q19〜Q23 |
| 土日 | 6（制御）＋7（過去問型） | Q24〜Q28 |

---

## Level 1 参照の基本

**Q1** 従業員の氏名と給与を、給与の高い順に表示する。
<details><summary>ヒント</summary>並べ替えは <code>ORDER BY 列 DESC</code>。昇順がデフォルト。</details>

**Q2** 開発部（部署ID = 'D02'）の従業員の氏名だけを表示する。
<details><summary>ヒント</summary><code>WHERE 部署ID = 'D02'</code>。文字列は引用符で囲む。</details>

**Q3** 受講の結果が **まだ入っていない**（NULL の）行を表示する。
<details><summary>ヒント</summary><code>= NULL</code> では取れない。<code>IS NULL</code> を使う。なぜ <code>=</code> では駄目か、一言で説明できるように。</details>

**Q4** 給与が 350000 以上 400000 以下の従業員を表示する。
<details><summary>ヒント</summary><code>BETWEEN</code> でも <code>AND</code> でも書ける。両端を含むか確認。</details>

## Level 2 結合・外部結合

**Q5** 従業員の氏名と部署名を並べて表示する（内部結合）。
<details><summary>ヒント</summary><code>FROM 従業員 INNER JOIN 部署 ON 従業員.部署ID = 部署.部署ID</code>。<b>ON は「どの列で結びつけるか」</b>。</details>

**Q6** 全部署の部署名と、その部署の従業員の氏名を表示する。**従業員がいない部署（本社・総務部）も残す**。
<details><summary>ヒント</summary>残したい側が左なら <code>LEFT OUTER JOIN</code>。右に相手がいない行は、右の列が NULL になる。Q5と行数を比べる。</details>

**Q7** 従業員が **1人もいない** 部署だけを表示する。
<details><summary>ヒント</summary>Q6の結果の「右側の列が NULL」の行だけを取る。<code>WHERE 従業員.従業員ID IS NULL</code>。</details>

**Q8** 講座名と、その開催日を表示する。**開催が1つもない講座も残す**。
<details><summary>ヒント</summary>Q6と同じ型。左に残したい表を置く。</details>

**Q9** 受講の行から、従業員の氏名・講座名・開催日・結果を表示する（3〜4表の結合）。
<details><summary>ヒント</summary>開催は <b>複合主キー（講座コード＋開催番号）</b>。ON の条件を2つ <code>AND</code> でつなぐ。1つだと行が増える（なぜ増えるか確認）。</details>

## Level 3 集計・副問合せ

**Q10** 部署ごとの人数を表示する。
<details><summary>ヒント</summary><code>GROUP BY 部署ID</code>と<code>COUNT(*)</code>。</details>

**Q11** 人数が3人以上の部署だけを表示する。
<details><summary>ヒント</summary>グループに対する条件は <code>WHERE</code> ではなく <code>HAVING</code>。WHEREとの違いを一言で（「集計の前に絞る」か「集計の後に絞る」か）。</details>

**Q12** 部署ごとの平均給与を、高い順に表示する。

**Q13** 全従業員の平均給与より給与が高い従業員を表示する。
<details><summary>ヒント</summary>副問合せ：<code>WHERE 給与 &gt; (SELECT AVG(給与) FROM 従業員)</code>。</details>

**Q14** 受講の行が1件でもある従業員だけを表示する（<code>EXISTS</code> で）。
<details><summary>ヒント</summary><code>WHERE EXISTS (SELECT 1 FROM 受講 WHERE 受講.従業員ID = 従業員.従業員ID)</code>。外側の表を、内側から参照している点を確認。</details>

## Level 4 更新（INSERT / UPDATE / DELETE）
各問の **前後で SELECT して確認**する。

**Q15** 従業員 E0007（氏名「中村」、部署 D04、給与 300000）を追加する。
<details><summary>ヒント</summary><code>INSERT INTO 表 (列, ...) VALUES (値, ...)</code>。列を書くと順番を間違えない。</details>

**Q16** 開発部（D02）の全員の給与を 10000 増やす。
<details><summary>ヒント</summary><code>UPDATE 表 SET 列 = 式 WHERE 条件</code>。<b>WHEREを忘れると全員が更新される</b>。先に同じWHEREでSELECTして対象を確認する癖を。</details>

**Q17** 契約を、暗証番号を指定せずに1件追加し、暗証番号が何になるか確認する。
<details><summary>ヒント</summary>列を省略すると DEFAULT が使われる。<code>契約</code>表の定義（<code>schema 契約</code>）を見る。</details>

**Q18** 存在しない部署ID 'D99' の従業員を追加してみる。**エラーになる理由**を説明する。
<details><summary>ヒント</summary>外部キー制約。参照先の部署に D99 が無い。<code>PRAGMA foreign_keys = ON</code> が効いている点も確認。</details>

## Level 5 定義（CREATE / ALTER / DROP）

**Q19** 「端末」表を作る。端末ID（CHAR(5)・主キー）、機種名（VARCHAR(20)・空にできない）、状態（CHAR(1)・初期値 'A'・空にできない）。
<details><summary>ヒント</summary>列の定義は <code>列名 型 DEFAULT 初期値 NOT NULL</code> の順。主キーは表の最後に <code>PRIMARY KEY (列)</code>。</details>

**Q20** 従業員表に「入社日」（DATE）の列を追加する。
<details><summary>ヒント</summary><code>ALTER TABLE 表 ADD 列 型</code>。CREATEは「新しく作る」、ALTERは「すでにある表を変える」。</details>

**Q21** 端末表に「従業員ID」列を追加し、従業員表を参照する外部キーにする。
<details><summary>ヒント</summary>SQLiteでは、後から外部キーを足すには表を作り直す必要がある。<b>試験の文では <code>ALTER TABLE ... ADD FOREIGN KEY</code> の形で出る</b>ので、書き方だけ答え側で確認し、実行は表を作り直して試す。</details>

**Q22** 開催を1件削除し、受講の行がどうなるか確認する。（<code>受講</code> の定義の <code>ON DELETE CASCADE</code> を確認）
<details><summary>ヒント</summary>削除前に <code>SELECT * FROM 受講</code>、削除後にもう一度。親（開催）を消すと、子（受講）が <b>連鎖して</b> 消える。CASCADE の意味をここで体で覚える。</details>

**Q23** 端末表を削除する。
<details><summary>ヒント</summary><code>DROP TABLE 表</code>。DELETE（行を消す）との違いを一言で。</details>

## Level 6 制御（GRANT / REVOKE / COMMIT / ROLLBACK）

**Q24**（書くだけ）一般ユーザに、従業員表の「従業員ID」「氏名」だけの参照権限を与える文を書く。
<details><summary>ヒント</summary><code>GRANT SELECT (列, 列) ON 表 TO ユーザ</code>。SQLiteには GRANT が無いので、書いて答えと見比べる。</details>

**Q25**（書くだけ）Q24で与えた権限のうち、人事課から更新権限だけを取り消す文を書く。
<details><summary>ヒント</summary><code>REVOKE UPDATE ON 表 FROM ユーザ</code>。GRANT の ON と TO に対して、REVOKE は ON と <b>FROM</b>。</details>

**Q26** トランザクション: 次の3文を順に実行する。`BEGIN` → 給与を全員 0 に UPDATE → `SELECT` で確認 → `ROLLBACK` → もう一度 `SELECT`。給与が元に戻ることを確認する。
<details><summary>ヒント</summary>ROLLBACK は取消、COMMIT は確定。<code>python3 sql.py repl</code> で空行区切りで1つずつ実行すると、途中の状態が見える。</details>

## Level 7 過去問の型（空欄埋め）

**Q27** 次の空欄 ア〜エ を埋める。（令4秋・問6設問3の型）
```
CREATE TABLE 契約 (
    契約ID    CHAR(6)  NOT NULL,
    暗証番号  ア       イ  NOT NULL,
    PRIMARY KEY (契約ID),
    ウ (事業者ID) REFERENCES 通信事業者 (事業者ID)
);
GRANT エ (契約ID, 暗証番号) ON 契約 TO ADMIN;
```
条件: 暗証番号は4桁の固定長文字、初期値は 1234。
<details><summary>ヒント</summary>表4（条件の表）の文言と、空欄の位置を1つずつ対応させる。<b>ア＝型、イ＝初期値の指定</b>。</details>

**Q28** 令7秋・問6の型。受講表に、開催（講座コード＋開催番号）を参照する外部キーがある。開催の行を削除したら、受講も自動で削除されるようにしたい。次の空欄を埋める。
```
FOREIGN KEY (講座コード, 開催番号) REFERENCES 開催 (講座コード, 開催番号)
    ON DELETE  オ
```
```
SELECT ... FROM 受講 AS t0 INNER JOIN 開催 AS t1
    カ  t0.講座コード = t1.講座コード  AND  t0.開催番号 = t1.開催番号
```
<details><summary>ヒント</summary>オ＝「連鎖して削除」を表す語。カ＝結合条件を書き始める語。Q9と Q22 をもう一度見る。</details>

---

## 試験への戻し方（週1回）
1. 今週間違えた Q を1つ選び、**自分の言葉で「何をするSQLか」** を1行で書く
2. `cheatsheet.md` の「問題文の手がかり」の列に、自分の手がかりを1つ足す
3. 令和4秋 問6 の設問3 を、答えを見ずにもう一度書いてみる
