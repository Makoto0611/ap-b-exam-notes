# 条件の文 → SQL 変換ガイド（問6を得点源にする）

問6の空欄は、**本文の「条件の文」をSQLの部品に置き換える**ことで埋まる。ここでは、置き換えの手順と、条件の文＋SQLの対を並べる。

実行確認: 下の ```sql の例は、`sql.py` と同じSQLite（GRANT/REVOKE、`ALTER ... ADD FOREIGN KEY`、`:変数`、`DROP COLUMN ... CASCADE` を除く）で実行して確かめてある。

## 0. 置き換えの手順
1. 条件表の **1行ずつ** 読む（まとめて書こうとしない）
2. その行を「列名／型／制約」に分ける
3. 下の対応表で、SQLの部品に置き換える
4. 表の最後に、主キー・外部キーの行を書く
5. 本文の **ただし書き**（例:「主キーにはUNIQUEを指定しない」）を最後に確認する

## 1. 対応表（条件の言葉 → SQLの部品）
### 型
| 条件の言葉 | SQL |
| --- | --- |
| 〜桁の固定長文字 | `CHAR(n)` |
| 最大〜文字の可変長文字 | `VARCHAR(n)` |
| 整数 | `INTEGER`（`INT`） |
| 小数（全体〜桁、小数〜桁） | `DECIMAL(全体, 小数)` |
| 日付 | `DATE` |
| 日付と時刻 | `TIMESTAMP` |
| 時刻 | `TIME` |

### 制約
| 条件の言葉 | SQL | 注意 |
| --- | --- | --- |
| 空にできない／非NULL／必須 | `NOT NULL` | 列の定義に書く |
| 初期値は〜 | `DEFAULT 値` | **DEFAULT → NOT NULL の順** |
| 主キー | `PRIMARY KEY (列)` | 非NULL・重複なしが自動で付く |
| 〜と〜の組で主キー（複合主キー） | `PRIMARY KEY (列1, 列2)` | 括弧の中に全部並べる |
| 重複を許さない | `UNIQUE (列)` | 主キーには付けない、という指定がある |
| 〜の範囲に限る（定義域制約） | `CHECK (条件)` | 例: `CHECK (数量 > 0)` |
| 〜表の〜を参照する | `FOREIGN KEY (列) REFERENCES 表 (列)` | 参照する側に書く。E-R図では「多」の側 |
| 参照先が消えたら一緒に消える | `ON DELETE CASCADE` | FOREIGN KEYの後ろ |
| 参照先が消えたらNULLにする | `ON DELETE SET NULL` | その列はNULLを許す |
| 参照されている間は消せない | `ON DELETE RESTRICT` | 削除を拒否する |

### 操作（検索・更新・権限）
| 条件の言葉 | SQL |
| --- | --- |
| 〜だけ参照できる（列を絞る） | `GRANT SELECT (列, 列) ON 表 TO ユーザ` |
| 表全体を参照できる | `GRANT SELECT ON 表 TO ユーザ` |
| 〜を更新できる | `GRANT UPDATE ON 表 TO ユーザ` |
| 権限を取り消す | `REVOKE 権限 ON 表 FROM ユーザ` |
| すでにある表に列を追加 | `ALTER TABLE 表 ADD 列 型` |
| 列を削除 | `ALTER TABLE 表 DROP COLUMN 列` |
| 表を削除 | `DROP TABLE 表` |

## 2. CREATE TABLE の例（条件の文 → SQL）

### 例1 列の定義
**条件:** 商品名は最大30文字の可変長文字で、空にできない。
```sql
CREATE TABLE 例1 (
    商品名  VARCHAR(30)  NOT NULL
);
```
**条件:** 状態は1桁の固定長文字で、初期値は'0'、空にできない。
```sql
CREATE TABLE 例1b (
    状態  CHAR(1)  DEFAULT '0'  NOT NULL
);
```

### 例2 主キー（単一・複合）
**条件:** 商品IDは5桁の固定長文字で、主キー。
```sql
CREATE TABLE 例2 (
    商品ID  CHAR(5)  NOT NULL,
    PRIMARY KEY (商品ID)
);
```
**条件:** 受注明細は、受注IDと明細番号の組で主キー。
```sql
CREATE TABLE 例2b (
    受注ID    CHAR(6)  NOT NULL,
    明細番号  INTEGER  NOT NULL,
    PRIMARY KEY (受注ID, 明細番号)
);
```

### 例3 外部キー
**条件:** 注文の顧客IDは、顧客表の顧客IDを参照する。
```sql
CREATE TABLE 例3 (
    注文ID  CHAR(6)  NOT NULL,
    顧客ID  CHAR(5)  NOT NULL,
    PRIMARY KEY (注文ID),
    FOREIGN KEY (顧客ID) REFERENCES 顧客 (顧客ID)
);
```

### 例4 条件表から表をまるごと作る
| 列名 | 条件 |
| --- | --- |
| 注文ID | 6桁の固定長文字、主キー |
| 顧客ID | 5桁の固定長文字、顧客表の顧客IDを参照 |
| 注文日 | 日付、空にできない |
| 状態 | 1桁の固定長文字、初期値は'N'、空にできない |

```sql
CREATE TABLE 注文 (
    注文ID  CHAR(6)  NOT NULL,
    顧客ID  CHAR(5)  NOT NULL,
    注文日  DATE     NOT NULL,
    状態    CHAR(1)  DEFAULT 'N' NOT NULL,
    PRIMARY KEY (注文ID),
    FOREIGN KEY (顧客ID) REFERENCES 顧客 (顧客ID)
);
```

### 例5 複合外部キー＋CASCADE
**条件:** 出荷表の（注文ID, 明細番号）は、明細表の（注文ID, 明細番号）を参照する。明細の行が削除されたら、出荷の行も自動的に削除される。
```sql
CREATE TABLE 出荷 (
    注文ID    CHAR(6)  NOT NULL,
    明細番号  INTEGER  NOT NULL,
    出荷日    DATE     NOT NULL,
    PRIMARY KEY (注文ID, 明細番号),
    FOREIGN KEY (注文ID, 明細番号) REFERENCES 明細 (注文ID, 明細番号)
        ON DELETE CASCADE
);
```

### 例6 自己参照・CHECK・UNIQUE
**条件:** 部署表の上位部署IDは、同じ表の部署IDを参照する（最上位はNULL）。
```sql
CREATE TABLE 組織 (
    部署ID      CHAR(3)  NOT NULL,
    上位部署ID  CHAR(3),
    PRIMARY KEY (部署ID),
    FOREIGN KEY (上位部署ID) REFERENCES 組織 (部署ID)
);
```
**条件:** 数量は1以上に限る。メールアドレスは重複させない。
```sql
CREATE TABLE 例6 (
    数量          INTEGER      NOT NULL CHECK (数量 >= 1),
    メールアドレス  VARCHAR(50)  NOT NULL UNIQUE
);
```

### 例7 暗証番号の型（令4秋の形）
**条件:** 暗証番号は4桁の固定長文字で、空にできず、初期値は'1234'。契約IDは主キー。
```sql
CREATE TABLE 例7 (
    契約ID    CHAR(6)  NOT NULL,
    暗証番号  CHAR(4)  DEFAULT '1234' NOT NULL,
    PRIMARY KEY (契約ID)
);
```

## 3. ALTER / DROP / VIEW / INDEX の例
**条件:** すでにある顧客表に、電話番号2（最大15文字の可変長文字）の列を追加する。
```sql
ALTER TABLE 顧客 ADD 電話番号2 VARCHAR(15);
```
**条件:** 顧客表から、電話番号2の列を削除する。
```sql
ALTER TABLE 顧客 DROP COLUMN 電話番号2;
```
**条件:** 注文表に、顧客表を参照する外部キーを後から追加する。（SQLiteでは実行不可。試験ではこの形で出る）
```sql
-- SQLiteでは実行不可
ALTER TABLE 注文 ADD FOREIGN KEY (顧客ID) REFERENCES 顧客 (顧客ID);
```
**条件:** 列を削除し、その列に依存するものも一緒に消す。（SQLiteでは実行不可）
```sql
-- SQLiteでは実行不可
ALTER TABLE 顧客 DROP COLUMN 電話番号 CASCADE;
```
**条件:** 顧客の顧客IDと氏名だけを見せる仮想の表（ビュー）を作る。（暗証番号のような列を隠したいときに使う）
```sql
CREATE VIEW 顧客名簿 AS
    SELECT 顧客ID, 氏名 FROM 顧客;
```
**条件:** 注文表の顧客IDでの検索を速くする。
```sql
CREATE INDEX 注文_顧客 ON 注文 (顧客ID);
```
**条件:** 営業課に、ビュー「顧客名簿」の参照を許可する。（GRANTはSQLiteでは実行不可）
```sql
-- SQLiteでは実行不可
GRANT SELECT ON 顧客名簿 TO 営業課;
```

## 4. 権限の例（GRANT / REVOKE）
```sql
-- SQLiteでは実行不可
GRANT SELECT (顧客ID, 氏名) ON 顧客 TO 営業課;   -- 列を絞って参照
GRANT SELECT ON 注文 TO 経理課;                   -- 表全体を参照
GRANT SELECT, UPDATE ON 注文 TO 経理課;           -- 複数の権限
REVOKE UPDATE ON 注文 FROM 経理課;                -- 取り消し（FROM）
```

## 5. 検索（SELECT）の例
使う表: 顧客(顧客ID, 氏名, 電話番号, 地域)、商品(商品ID, 商品名, 単価)、注文(注文ID, 顧客ID, 注文日, 状態)、明細(注文ID, 明細番号, 商品ID, 数量)、出荷(注文ID, 明細番号, 出荷日)

**条件:** 顧客の地域を、重複なしで表示する。
```sql
SELECT DISTINCT 地域 FROM 顧客;
```
**条件:** 氏名が「山」で始まる顧客を表示する。
```sql
SELECT * FROM 顧客 WHERE 氏名 LIKE '山%';
```
**条件:** 地域が東京か大阪の顧客を表示する。
```sql
SELECT * FROM 顧客 WHERE 地域 IN ('東京', '大阪');
```
**条件:** 電話番号が未登録（NULL）の顧客を表示する。
```sql
SELECT * FROM 顧客 WHERE 電話番号 IS NULL;
```
**条件:** 電話番号が未登録の顧客は「未登録」と表示する。
```sql
SELECT 氏名, COALESCE(電話番号, '未登録') AS 電話 FROM 顧客;
```
**条件:** 状態がNなら「新規」、それ以外は「処理済」と表示する。
```sql
SELECT 注文ID,
       CASE WHEN 状態 = 'N' THEN '新規' ELSE '処理済' END AS 状況
FROM 注文;
```
**条件:** 注文表と顧客表を、顧客IDで結びつけて、注文IDと氏名を表示する。
```sql
SELECT 注文.注文ID, 顧客.氏名
FROM 注文 INNER JOIN 顧客
    ON 注文.顧客ID = 顧客.顧客ID;
```
**条件:** 結びつける列が2つあるときは、ANDでつなぐ。
```sql
SELECT 明細.注文ID, 明細.明細番号, 出荷.出荷日
FROM 明細 INNER JOIN 出荷
    ON 明細.注文ID = 出荷.注文ID
   AND 明細.明細番号 = 出荷.明細番号;
```
**条件:** 注文が1件もない顧客も含めて、全顧客の氏名と注文IDを表示する。（外部結合）
```sql
SELECT 顧客.氏名, 注文.注文ID
FROM 顧客 LEFT OUTER JOIN 注文
    ON 顧客.顧客ID = 注文.顧客ID;
```
**条件:** 注文が1件もない顧客だけを表示する。（外部結合＋IS NULL）
```sql
SELECT 顧客.氏名
FROM 顧客 LEFT OUTER JOIN 注文
    ON 顧客.顧客ID = 注文.顧客ID
WHERE 注文.注文ID IS NULL;
```
**条件:** 同じことを、NOT EXISTSで書く。
```sql
SELECT 氏名 FROM 顧客
WHERE NOT EXISTS (SELECT 1 FROM 注文 WHERE 注文.顧客ID = 顧客.顧客ID);
```
**条件:** 注文が2件以上ある顧客のIDと件数を表示する。
```sql
SELECT 顧客ID, COUNT(*) AS 件数
FROM 注文
GROUP BY 顧客ID
HAVING COUNT(*) >= 2;
```
**条件:** 注文のある顧客の人数を、重複なしで数える。
```sql
SELECT COUNT(DISTINCT 顧客ID) AS 人数 FROM 注文;
```
**条件:** 単価が、全商品の平均単価より高い商品を表示する。
```sql
SELECT 商品名, 単価 FROM 商品
WHERE 単価 > (SELECT AVG(単価) FROM 商品);
```
**条件:** 注文ごとの合計金額（単価×数量の合計）を表示する。
```sql
SELECT 明細.注文ID, SUM(商品.単価 * 明細.数量) AS 合計
FROM 明細 INNER JOIN 商品
    ON 明細.商品ID = 商品.商品ID
GROUP BY 明細.注文ID;
```
**条件:** 東京の顧客と大阪の顧客の氏名を、1つの結果にまとめる。
```sql
SELECT 氏名 FROM 顧客 WHERE 地域 = '東京'
UNION
SELECT 氏名 FROM 顧客 WHERE 地域 = '大阪';
```

## 6. 更新（INSERT / UPDATE / DELETE）の例
**条件:** 顧客表に、顧客ID 'C0099'、氏名「新規」を追加する。
```sql
INSERT INTO 顧客 (顧客ID, 氏名) VALUES ('C0099', '新規');
```
**条件:** プログラムの変数（:id、:name）の値を、顧客表に追加する。（埋込み変数。SQLiteでは実行不可）
```sql
-- SQLiteでは実行不可（埋込み変数）
INSERT INTO 顧客 (顧客ID, 氏名) VALUES (:id, :name);
```
**条件:** 商品P0001の単価を100円上げる。
```sql
UPDATE 商品 SET 単価 = 単価 + 100 WHERE 商品ID = 'P0001';
```
**条件:** 状態がCの注文を削除する。（明細にON DELETE CASCADEがあれば、明細も消える）
```sql
DELETE FROM 注文 WHERE 状態 = 'C';
```

## 7. トランザクションの例
```sql
BEGIN;
UPDATE 商品 SET 単価 = 単価 + 100 WHERE 商品ID = 'P0001';
UPDATE 商品 SET 単価 = 単価 - 100 WHERE 商品ID = 'P0002';
COMMIT;      -- 確定（取り消すなら ROLLBACK）
```

## 8. 練習（条件表 → CREATE TABLE）
答えは `<details>` の中。先に開かない。

**P1** 条件表から「商品在庫」表を作る。
| 列名 | 条件 |
| --- | --- |
| 商品ID | 5桁の固定長文字、商品表の商品IDを参照 |
| 倉庫コード | 3桁の固定長文字 |
| 在庫数 | 整数、初期値は0、空にできない |
| （主キー） | 商品IDと倉庫コードの組 |

<details><summary>答え</summary>

```sql
CREATE TABLE 商品在庫 (
    商品ID      CHAR(5)  NOT NULL,
    倉庫コード  CHAR(3)  NOT NULL,
    在庫数      INTEGER  DEFAULT 0 NOT NULL,
    PRIMARY KEY (商品ID, 倉庫コード),
    FOREIGN KEY (商品ID) REFERENCES 商品 (商品ID)
);
```
</details>

**P2** 条件表から「受付」表を作る。ただし、主キーにはUNIQUE制約を指定しない。
| 列名 | 条件 |
| --- | --- |
| 受付ID | 8桁の固定長文字、主キー |
| 顧客ID | 5桁の固定長文字、顧客表の顧客IDを参照 |
| 受付日時 | 日付と時刻、空にできない |
| 区分 | 1桁の固定長文字、初期値は'1'、空にできない |

<details><summary>答え</summary>

```sql
CREATE TABLE 受付 (
    受付ID    CHAR(8)    NOT NULL,
    顧客ID    CHAR(5)    NOT NULL,
    受付日時  TIMESTAMP  NOT NULL,
    区分      CHAR(1)    DEFAULT '1' NOT NULL,
    PRIMARY KEY (受付ID),
    FOREIGN KEY (顧客ID) REFERENCES 顧客 (顧客ID)
);
```
</details>

**P3** 営業課に、顧客表の顧客IDと氏名だけの参照を許可する文を書く。

<details><summary>答え</summary>

```sql
-- SQLiteでは実行不可
GRANT SELECT (顧客ID, 氏名) ON 顧客 TO 営業課;
```
</details>

**P4** 「返品」表（返品ID：6桁の固定長文字・主キー、注文ID：6桁の固定長文字・注文表を参照、注文表の行が削除されたら返品の行も自動的に削除）を作る。

<details><summary>答え</summary>

```sql
CREATE TABLE 返品 (
    返品ID  CHAR(6)  NOT NULL,
    注文ID  CHAR(6)  NOT NULL,
    PRIMARY KEY (返品ID),
    FOREIGN KEY (注文ID) REFERENCES 注文 (注文ID)
        ON DELETE CASCADE
);
```
</details>
