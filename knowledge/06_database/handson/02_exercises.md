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
department(dept_id, department_name, parent_dept_id→department)            … 自己参照
staff(staff_id, name, dept_id→department, salary)
carrier(carrier_id, carrier_name)
contract(contract_id, staff_id→staff, carrier_id→carrier, pin DEFAULT '1234')
course(course_code, course_name)
session(course_code→course, session_no, session_date)           … 複合主キー
enrollment(staff_id→staff, course_code, session_no, result)  … 複合外部キー＋ON DELETE CASCADE
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
| 土日 | 6（制御）＋7（過去問型）＋8（型の補強） | Q24〜Q32 |

---

## Level 1 参照の基本

**Q1** 従業員(staff)の氏名(name)と給与(salary)を、給与の高い順に表示する。
<details><summary>ヒント</summary>並べ替えは <code>ORDER BY 列 DESC</code>。昇順がデフォルト。</details>

**Q2** 開発部（部署ID(dept_id) = 'D02'）の従業員(staff)の氏名(name)だけを表示する。
<details><summary>ヒント</summary><code>WHERE dept_id = 'D02'</code>。文字列は引用符で囲む。</details>

**Q3** 受講(enrollment)の結果(result)が **まだ入っていない**（NULL の）行を表示する。
<details><summary>ヒント</summary><code>= NULL</code> では取れない。<code>IS NULL</code> を使う。なぜ <code>=</code> では駄目か、一言で説明できるように。</details>

**Q4** 給与(salary)が 350000 以上 400000 以下の従業員(staff)を表示する。
<details><summary>ヒント</summary><code>BETWEEN</code> でも <code>AND</code> でも書ける。両端を含むか確認。</details>

## Level 2 結合・外部結合

**Q5** 従業員(staff)の氏名(name)と部署名(department_name)を並べて表示する（内部結合）。部署は department。
<details><summary>ヒント</summary><code>FROM staff INNER JOIN department ON staff.dept_id = department.dept_id</code>。<b>ON は「どの列で結びつけるか」</b>。</details>

**Q6** 全部署(department)の部署名(department_name)と、その部署の従業員(staff)の氏名(name)を表示する。**従業員がいない部署（本社・総務部）も残す**。
<details><summary>ヒント</summary>残したい側が左なら <code>LEFT OUTER JOIN</code>。右に相手がいない行は、右の列が NULL になる。Q5と行数を比べる。</details>

**Q7** 従業員(staff)が **1人もいない** 部署(department)だけを表示する。
<details><summary>ヒント</summary>Q6の結果の「右側の列が NULL」の行だけを取る。<code>WHERE staff.staff_id IS NULL</code>。</details>

**Q8** 講座名(course_name)と、その開催日(session_date)を表示する。**開催(session)が1つもない講座(course)も残す**。
<details><summary>ヒント</summary>Q6と同じ型。左に残したい表を置く。</details>

**Q9** 受講(enrollment)の行から、従業員(staff)の氏名(name)・講座名(course_name)・開催日(session_date)・結果(result)を表示する（3〜4表の結合）。
<details><summary>ヒント</summary>開催は <b>複合主キー（講座コード＋開催番号）</b>。ON の条件を2つ <code>AND</code> でつなぐ。1つだと行が増える（なぜ増えるか確認）。</details>

## Level 3 集計・副問合せ

**Q10** 部署(department)ごとの人数を表示する。
<details><summary>ヒント</summary><code>GROUP BY dept_id</code>と<code>COUNT(*)</code>。</details>

**Q11** 人数が3人以上の部署(department)だけを表示する。
<details><summary>ヒント</summary>グループに対する条件は <code>WHERE</code> ではなく <code>HAVING</code>。WHEREとの違いを一言で（「集計の前に絞る」か「集計の後に絞る」か）。</details>

**Q12** 部署(department)ごとの平均給与(salary)を、高い順に表示する。

**Q13** 全従業員(staff)の平均給与(salary)より給与が高い従業員を表示する。
<details><summary>ヒント</summary>副問合せ：<code>WHERE salary &gt; (SELECT AVG(salary) FROM staff)</code>。</details>

**Q14** 受講(enrollment)の行が1件でもある従業員(staff)だけを表示する（<code>EXISTS</code> で）。
<details><summary>ヒント</summary><code>WHERE EXISTS (SELECT 1 FROM enrollment WHERE enrollment.staff_id = staff.staff_id)</code>。外側の表を、内側から参照している点を確認。</details>

## Level 4 更新（INSERT / UPDATE / DELETE）
各問の **前後で SELECT して確認**する。

**Q15** 従業員(staff) E0007（氏名(name) nakamura、部署(dept_id) D04、給与(salary) 300000）を追加する。
<details><summary>ヒント</summary><code>INSERT INTO 表 (列, ...) VALUES (値, ...)</code>。列を書くと順番を間違えない。</details>

**Q16** 開発部（D02）の全員の給与(salary)を 10000 増やす。表は従業員(staff)、部署は dept_id。
<details><summary>ヒント</summary><code>UPDATE 表 SET 列 = 式 WHERE 条件</code>。<b>WHEREを忘れると全員が更新される</b>。先に同じWHEREでSELECTして対象を確認する癖を。</details>

**Q17** 契約(contract)を、暗証番号(pin)を指定せずに1件追加し、暗証番号が何になるか確認する。
<details><summary>ヒント</summary>列を省略すると DEFAULT が使われる。<code>contract</code>表の定義（<code>schema contract</code>）を見る。</details>

**Q18** 存在しない部署ID(dept_id) 'D99' の従業員(staff)を追加してみる。**エラーになる理由**を説明する。
<details><summary>ヒント</summary>外部キー制約。参照先の部署に D99 が無い。<code>PRAGMA foreign_keys = ON</code> が効いている点も確認。</details>

## Level 5 定義（CREATE / ALTER / DROP）

**Q19** 「端末(device)」表を作る。端末ID(device_id)（CHAR(5)・主キー）、機種名(model_name)（VARCHAR(20)・空にできない）、状態(status)（CHAR(1)・初期値 'A'・空にできない）。
<details><summary>ヒント</summary>列の定義は <code>列名 型 DEFAULT 初期値 NOT NULL</code> の順。主キーは表の最後に <code>PRIMARY KEY (列)</code>。</details>

**Q20** 従業員表(staff)に「入社日(hire_date)」（DATE）の列を追加する。
<details><summary>ヒント</summary><code>ALTER TABLE 表 ADD 列 型</code>。CREATEは「新しく作る」、ALTERは「すでにある表を変える」。</details>

**Q21** 端末表(device)に「従業員ID(staff_id)」列を追加し、従業員表(staff)を参照する外部キーにする。
<details><summary>ヒント</summary>SQLiteでは、後から外部キーを足すには表を作り直す必要がある。<b>試験の文では <code>ALTER TABLE ... ADD FOREIGN KEY</code> の形で出る</b>ので、書き方だけ答え側で確認し、実行は表を作り直して試す。</details>

**Q22** 開催(session)を1件削除し、受講(enrollment)の行がどうなるか確認する。（<code>enrollment</code> の定義の <code>ON DELETE CASCADE</code> を確認）
<details><summary>ヒント</summary>削除前に <code>SELECT * FROM enrollment</code>、削除後にもう一度。親（開催）を消すと、子（受講）が <b>連鎖して</b> 消える。CASCADE の意味をここで体で覚える。</details>

**Q23** 端末表(device)を削除する。
<details><summary>ヒント</summary><code>DROP TABLE 表</code>。DELETE（行を消す）との違いを一言で。</details>

## Level 6 制御（GRANT / REVOKE / COMMIT / ROLLBACK）

**Q24**（書くだけ）一般ユーザ(general_user)に、従業員表(staff)の「従業員ID(staff_id)」「氏名(name)」だけの参照権限を与える文を書く。
<details><summary>ヒント</summary><code>GRANT SELECT (列, 列) ON 表 TO ユーザ</code>。SQLiteには GRANT が無いので、書いて答えと見比べる。</details>

**Q25**（書くだけ）Q24で与えた権限のうち、人事課(hr_dept)から更新権限だけを取り消す文を書く。
<details><summary>ヒント</summary><code>REVOKE UPDATE ON 表 FROM ユーザ</code>。GRANT の ON と TO に対して、REVOKE は ON と <b>FROM</b>。</details>

**Q26** トランザクション: 次の3文を順に実行する。`BEGIN` → 給与(salary)を全員(staff) 0 に UPDATE → `SELECT` で確認 → `ROLLBACK` → もう一度 `SELECT`。給与が元に戻ることを確認する。
<details><summary>ヒント</summary>ROLLBACK は取消、COMMIT は確定。<code>python3 sql.py repl</code> で空行区切りで1つずつ実行すると、途中の状態が見える。</details>

## Level 7 過去問の型（空欄埋め）

**Q27** 次の空欄 ア〜エ を埋める。（令4秋・問6設問3の型）
```
CREATE TABLE contract (
    contract_id    CHAR(6)  NOT NULL,
    pin  ア       イ  NOT NULL,
    PRIMARY KEY (contract_id),
    ウ (carrier_id) REFERENCES carrier (carrier_id)
);
GRANT エ (contract_id, pin) ON contract TO ADMIN;
```
条件: 暗証番号(pin)は4桁の固定長文字、初期値は 1234。
<details><summary>ヒント</summary>表4（条件の表）の文言と、空欄の位置を1つずつ対応させる。<b>ア＝型、イ＝初期値の指定</b>。</details>

**Q28** 令7秋・問6の型。受講表(enrollment)に、開催(session)（講座コード(course_code)＋開催番号(session_no)）を参照する外部キーがある。開催の行を削除したら、受講も自動で削除されるようにしたい。次の空欄を埋める。
```
FOREIGN KEY (course_code, session_no) REFERENCES session (course_code, session_no)
    ON DELETE  オ
```
```
SELECT ... FROM enrollment AS t0 INNER JOIN session AS t1
    カ  t0.course_code = t1.course_code  AND  t0.session_no = t1.session_no
```
<details><summary>ヒント</summary>オ＝「連鎖して削除」を表す語。カ＝結合条件を書き始める語。Q9と Q22 をもう一度見る。</details>

## Level 8 過去問によく出る型の補強
ここまでの Level に、練習問題がなかった型。`python3 sql.py reset` のあとでやる。

**Q29**（書くだけ）契約表(contract)に、同じ従業員(staff_id)が、同じ通信事業者(carrier_id)と、2回契約できないようにする。制約名を uq_staff_carrier として、ALTER TABLE で、2列の組の一意制約を追加する文を書く。
<details><summary>ヒント</summary><code>ALTER TABLE 表 ADD CONSTRAINT 制約名 UNIQUE (列, 列)</code>。<b>括弧の中に2列を並べると、「2列の組」で重複を禁止する</b>（列ごとに別々の UNIQUE を付けるのとは違う）。主キーとの違いは、1つの表に複数付けられることと、NULL を許すこと。SQLiteは後から制約を足せないので、書いて答えと見比べる（db-fiddle で PostgreSQL を選べば、試せる）。</details>

**Q30** 開発部の従業員だけを入れる表 dev_staff を作る。従業員ID(staff_id)（CHAR(5)・主キー）、氏名(name)（VARCHAR(30)・空にできない）。次に、従業員(staff)のうち部署(dept_id)が 'D02' の行の staff_id と name を、**1つの INSERT 文**で、dev_staff にまとめて追加する。追加したあとに SELECT して、3行入っていることを確認する。
<details><summary>ヒント</summary><code>VALUES</code> の代わりに SELECT を書く: <code>INSERT INTO 表 (列, 列) SELECT 列, 列 FROM 表 WHERE 条件</code>。追加先の列の数と順番を、SELECT の列にそろえる。</details>

**Q31** 部署(department)ごとの最高給与(salary)を、WITH で dept_max という名前を付けた検索にまとめ、部署名(department_name)と最高給与を表示する。従業員がいない部署も出し、その最高給与は 0 にする。（期待: reset 直後なら5行。head_office と ga_division は 0）
<details><summary>ヒント</summary><code>WITH 名前 AS (SELECT …) SELECT … FROM …</code>。WITH の中は <code>GROUP BY</code> と <code>MAX</code>。全部署を残すので、外部結合の左は department。結合の右が空の行は NULL になるので、<code>COALESCE(列, 0)</code> で 0 にそろえる。</details>

**Q32**（書くだけ）次の4つの処理を、表ごとに C・R・U・D で分ける。表は dev_staff、staff、contract、enrollment。
```
処理1 INSERT INTO dev_staff (staff_id, name) SELECT staff_id, name FROM staff WHERE dept_id = 'D02';
処理2 UPDATE contract SET pin = '0000' WHERE staff_id IN (SELECT staff_id FROM staff WHERE salary > 400000);
処理3 DELETE FROM enrollment WHERE staff_id = 'E0003';
処理4 UPDATE staff SET salary = salary + 10000 WHERE dept_id = 'D02';
```
<details><summary>ヒント</summary>処理を1文ずつ、書込み先（C・U・D）と読み元（R）に分け、表ごとに記号を集める。同じ表が複数の処理に出てくる。まとめるときは、C→R→U→D の順。自分の値を読んで更新する（<code>SET 列 = 列 + 1</code>）と、RU になる。読み方の手順は <code>../02_design_basics.md</code> の 4-2。</details>

---

## 試験への戻し方（週1回）
1. 今週間違えた Q を1つ選び、**自分の言葉で「何をするSQLか」** を1行で書く
2. `cheatsheet.md` の「問題文の手がかり」の列に、自分の手がかりを1つ足す
3. 令和4秋 問6 の設問3 を、答えを見ずにもう一度書いてみる

## 名前の対応表（日本語→英語）

SQLの例の表名・列名・値は、英語で書いてある。日本語との対応は次のとおり。

| 日本語 | 英語 |
| --- | --- |
| 部署ID | `dept_id` |
| 上位部署ID | `parent_dept_id` |
| 従業員 | `staff` |
| 氏名 | `name` |
| 契約 | `contract` |
| 部署 | `department` |
| 部署名 | `department_name` |
| 従業員ID | `staff_id` |
| 給与 | `salary` |
| 通信事業者 | `carrier` |
| 事業者ID | `carrier_id` |
| 事業者名 | `carrier_name` |
| 契約ID | `contract_id` |
| 暗証番号 | `pin` |
| 講座 | `course` |
| 講座コード | `course_code` |
| 講座名 | `course_name` |
| 開催 | `session` |
| 開催番号 | `session_no` |
| 開催日 | `session_date` |
| 受講 | `enrollment` |
| 結果 | `result` |
