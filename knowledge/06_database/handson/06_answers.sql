-- ============================================================
-- 総合問題1〜4 の答え（先に見ない）
-- 実行: python3 sql.py -f 06_answers.sql   （答え合わせ用。全部通る）
-- 各行の「-- [記号]」が、06_integrated.md の空欄の答え
-- GRANT / REVOKE は SQLite にないため、コメントで示す
-- ============================================================
PRAGMA foreign_keys = ON;

-- ############ 総合1 備品貸出管理 ############
DROP TABLE IF EXISTS 貸出;
DROP TABLE IF EXISTS 備品;
DROP TABLE IF EXISTS 社員;
DROP TABLE IF EXISTS 課;

CREATE TABLE 課 (
    課ID  CHAR(3)     NOT NULL,
    課名  VARCHAR(20) NOT NULL,
    PRIMARY KEY (課ID)
);
CREATE TABLE 社員 (
    社員ID  CHAR(4)     NOT NULL,
    氏名    VARCHAR(20) NOT NULL,
    課ID    CHAR(3)     NOT NULL,
    PRIMARY KEY (社員ID),
    FOREIGN KEY (課ID) REFERENCES 課 (課ID)
);
CREATE TABLE 備品 (
    備品ID  CHAR(5)     NOT NULL,
    備品名  VARCHAR(30) NOT NULL,
    区分    CHAR(2)     NOT NULL CHECK (区分 IN ('PC', '周辺')),   -- [ア]
    状態    CHAR(2)     DEFAULT '在庫' NOT NULL,                   -- [イ]
    PRIMARY KEY (備品ID)
);
CREATE TABLE 貸出 (
    貸出ID  INTEGER  NOT NULL,
    備品ID  CHAR(5)  NOT NULL,
    社員ID  CHAR(4)  NOT NULL,
    貸出日  DATE     NOT NULL,
    返却日  DATE,                                                   -- [ウ] NOT NULL を付けない
    PRIMARY KEY (貸出ID),                                           -- [エ]
    FOREIGN KEY (備品ID) REFERENCES 備品 (備品ID),                  -- [オ]
    FOREIGN KEY (社員ID) REFERENCES 社員 (社員ID)
);
-- [カ] GRANT SELECT (備品ID, 備品名, 状態) ON 備品 TO 総務課;
ALTER TABLE 備品 ADD 備考 VARCHAR(50);                              -- [キ]
CREATE VIEW 貸出中 AS                                               -- [ク]
    SELECT 備品ID, 社員ID, 貸出日 FROM 貸出 WHERE 返却日 IS NULL;

-- データ投入（06_s1_data.sql と同じ内容）
INSERT INTO 課 VALUES ('K01','総務'), ('K02','開発'), ('K03','営業');
INSERT INTO 社員 VALUES ('E001','佐藤','K01'), ('E002','鈴木','K02'), ('E003','高橋','K02'), ('E004','田中','K02');
INSERT INTO 備品 (備品ID, 備品名, 区分, 状態) VALUES
  ('P0001','ノートPC-A','PC','貸出'),
  ('P0002','ノートPC-B','PC','在庫'),
  ('P0003','モニタ','周辺','貸出'),
  ('P0004','キーボード','周辺','在庫'),
  ('P0005','マウス','周辺','在庫');
INSERT INTO 貸出 VALUES
  (1,'P0001','E002','2026-10-01',NULL),
  (2,'P0003','E002','2026-10-05',NULL),
  (3,'P0002','E003','2026-09-20','2026-09-30'),
  (4,'P0004','E004','2026-10-10','2026-10-12'),
  (5,'P0001','E003','2026-08-01','2026-08-31');

-- [ケ] いま2点以上借りている社員（結果: 鈴木 2）
SELECT 社員.氏名, COUNT(*) AS 件数
  FROM 社員 INNER JOIN 貸出 ON 社員.社員ID = 貸出.社員ID
 WHERE 貸出.返却日 IS NULL
 GROUP BY 社員.社員ID, 社員.氏名
HAVING COUNT(*) >= 2;

-- [コ] 一度も貸し出されていない備品（結果: マウス）
SELECT 備品.備品名
  FROM 備品 LEFT OUTER JOIN 貸出 ON 備品.備品ID = 貸出.備品ID
 WHERE 貸出.貸出ID IS NULL;

-- [サ] 課ごとの貸出中の件数（0件の課も出す。結果: 総務0・開発2・営業0）
SELECT 課.課名, COUNT(貸出.貸出ID) AS 貸出中
  FROM 課
  LEFT OUTER JOIN 社員 ON 課.課ID = 社員.課ID
  LEFT OUTER JOIN 貸出 ON 社員.社員ID = 貸出.社員ID AND 貸出.返却日 IS NULL
 GROUP BY 課.課ID, 課.課名;

-- [シ] P0002 を E004 に貸し出す（2つの表を同時に更新 → 1つのトランザクション）
BEGIN;
INSERT INTO 貸出 (貸出ID, 備品ID, 社員ID, 貸出日) VALUES (6, 'P0002', 'E004', '2026-11-15');
UPDATE 備品 SET 状態 = '貸出' WHERE 備品ID = 'P0002';
COMMIT;

-- [ス] P0001 を返却（返却日 IS NULL の行だけ）
BEGIN;
UPDATE 貸出 SET 返却日 = '2026-11-15' WHERE 備品ID = 'P0001' AND 返却日 IS NULL;
UPDATE 備品 SET 状態 = '在庫' WHERE 備品ID = 'P0001';
COMMIT;

SELECT 備品ID, 備品名, 状態 FROM 備品 ORDER BY 備品ID;


-- ############ 総合2 注文管理 ############
DROP TABLE IF EXISTS 注文明細;
DROP TABLE IF EXISTS 注文;
DROP TABLE IF EXISTS 商品;
DROP TABLE IF EXISTS 顧客;

CREATE TABLE 顧客 (
    顧客ID  CHAR(5)     NOT NULL,
    顧客名  VARCHAR(20) NOT NULL,
    地域    VARCHAR(10) NOT NULL,
    PRIMARY KEY (顧客ID)
);
CREATE TABLE 商品 (
    商品ID  CHAR(4)     NOT NULL,
    商品名  VARCHAR(30) NOT NULL,
    単価    INTEGER     NOT NULL CHECK (単価 > 0),                  -- [ア]
    PRIMARY KEY (商品ID)
);
CREATE TABLE 注文 (
    注文番号  INTEGER  NOT NULL,
    顧客ID    CHAR(5)  NOT NULL,
    注文日    DATE     NOT NULL,
    PRIMARY KEY (注文番号),
    FOREIGN KEY (顧客ID) REFERENCES 顧客 (顧客ID)
);
CREATE TABLE 注文明細 (
    注文番号  INTEGER  NOT NULL,
    行番号    INTEGER  NOT NULL,
    商品ID    CHAR(4)  NOT NULL,
    数量      INTEGER  NOT NULL CHECK (数量 > 0),
    PRIMARY KEY (注文番号, 行番号),                                 -- [イ]
    FOREIGN KEY (注文番号) REFERENCES 注文 (注文番号) ON DELETE CASCADE,  -- [ウ]
    FOREIGN KEY (商品ID) REFERENCES 商品 (商品ID)
);
-- [エ] GRANT SELECT ON 注文明細 TO 経理課;
-- [オ] GRANT UPDATE (単価) ON 商品 TO 仕入課;

INSERT INTO 顧客 VALUES ('C0001','山田','東京'), ('C0002','佐々木','大阪'), ('C0003','伊藤','東京');
INSERT INTO 商品 VALUES ('G001','ペン',100), ('G002','ノート',200), ('G003','バッグ',3000);
INSERT INTO 注文 VALUES (1,'C0001','2026-10-03'), (2,'C0001','2026-11-02'), (3,'C0002','2026-11-05');
INSERT INTO 注文明細 VALUES
  (1,1,'G001',10), (1,2,'G002',5),
  (2,1,'G003',1),
  (3,1,'G001',20), (3,2,'G003',2);

-- [カ] 注文ごとの合計金額（結果: 1→2000、2→3000、3→8000）
SELECT 注文明細.注文番号, SUM(商品.単価 * 注文明細.数量) AS 合計
  FROM 注文明細 INNER JOIN 商品 ON 注文明細.商品ID = 商品.商品ID
 GROUP BY 注文明細.注文番号;

-- [キ] 顧客ごとの合計が、全顧客の平均を上回る顧客（結果: 佐々木 8000）
SELECT 顧客.顧客名, SUM(商品.単価 * 注文明細.数量) AS 合計
  FROM 顧客
  INNER JOIN 注文 ON 顧客.顧客ID = 注文.顧客ID
  INNER JOIN 注文明細 ON 注文.注文番号 = 注文明細.注文番号
  INNER JOIN 商品 ON 注文明細.商品ID = 商品.商品ID
 GROUP BY 顧客.顧客ID, 顧客.顧客名
HAVING SUM(商品.単価 * 注文明細.数量) >
       (SELECT AVG(小計) FROM
           (SELECT SUM(商品.単価 * 注文明細.数量) AS 小計
              FROM 注文
              INNER JOIN 注文明細 ON 注文.注文番号 = 注文明細.注文番号
              INNER JOIN 商品 ON 注文明細.商品ID = 商品.商品ID
             GROUP BY 注文.顧客ID));

-- [ク] 一度も注文していない顧客（結果: 伊藤）
SELECT 顧客名 FROM 顧客
 WHERE NOT EXISTS (SELECT 1 FROM 注文 WHERE 注文.顧客ID = 顧客.顧客ID);

-- [ケ] 月ごとの注文件数（結果: 2026-10→1、2026-11→2）
SELECT SUBSTR(注文日, 1, 7) AS 年月, COUNT(*) AS 件数
  FROM 注文 GROUP BY SUBSTR(注文日, 1, 7);

-- [コ] 値上げ: 1000円未満は+10円、1000円以上は+100円（1回のUPDATEで）
UPDATE 商品
   SET 単価 = CASE WHEN 単価 < 1000 THEN 単価 + 10 ELSE 単価 + 100 END;
SELECT * FROM 商品;

-- [サ] 注文1を削除 → 明細も連鎖して消える
DELETE FROM 注文 WHERE 注文番号 = 1;
SELECT COUNT(*) AS 注文1の明細 FROM 注文明細 WHERE 注文番号 = 1;   -- 0


-- ############ 総合3 会議室予約 ############
DROP TABLE IF EXISTS 予約;
DROP TABLE IF EXISTS 利用者;
DROP TABLE IF EXISTS 会議室;

CREATE TABLE 会議室 (
    室ID    CHAR(3)     NOT NULL,
    室名    VARCHAR(20) NOT NULL,
    定員    INTEGER     NOT NULL CHECK (定員 > 0),
    PRIMARY KEY (室ID)
);
CREATE TABLE 利用者 (
    利用者ID  CHAR(3)     NOT NULL,
    氏名      VARCHAR(20) NOT NULL,
    PRIMARY KEY (利用者ID)
);
CREATE TABLE 予約 (
    室ID      CHAR(3)  NOT NULL,
    予約日    DATE     NOT NULL,
    時間帯    CHAR(1)  NOT NULL CHECK (時間帯 IN ('A', 'B')),       -- [ア]
    利用者ID  CHAR(3)  NOT NULL,
    PRIMARY KEY (室ID, 予約日, 時間帯),                             -- [イ]
    FOREIGN KEY (室ID) REFERENCES 会議室 (室ID),                    -- [ウ]
    FOREIGN KEY (利用者ID) REFERENCES 利用者 (利用者ID)
);
-- [エ] GRANT SELECT ON 予約 TO 全社員;  GRANT INSERT, DELETE ON 予約 TO 総務課;

INSERT INTO 会議室 VALUES ('R01','大会議室',20), ('R02','小会議室',6), ('R03','面談室',2);
INSERT INTO 利用者 VALUES ('U01','佐藤'), ('U02','鈴木'), ('U03','高橋');
INSERT INTO 予約 VALUES
  ('R01','2026-11-16','A','U01'),
  ('R01','2026-11-16','B','U02'),
  ('R02','2026-11-16','A','U01'),
  ('R02','2026-11-17','A','U03'),
  ('R01','2026-11-17','B','U01');

-- [オ] 会議室ごとの予約件数（0件の会議室も出す。結果: R01→3、R02→2、R03→0）
SELECT 会議室.室名, COUNT(予約.室ID) AS 件数
  FROM 会議室 LEFT OUTER JOIN 予約 ON 会議室.室ID = 予約.室ID
 GROUP BY 会議室.室ID, 会議室.室名;

-- [カ] 同じ日に2件以上予約した利用者（結果: 佐藤 2026-11-16）
SELECT 利用者.氏名, 予約.予約日, COUNT(*) AS 件数
  FROM 利用者 INNER JOIN 予約 ON 利用者.利用者ID = 予約.利用者ID
 GROUP BY 利用者.利用者ID, 利用者.氏名, 予約.予約日
HAVING COUNT(*) >= 2;

-- [キ] 2026-11-16 の午前（A）に空いている会議室（結果: 面談室）
SELECT 室名 FROM 会議室
 WHERE NOT EXISTS (SELECT 1 FROM 予約
                    WHERE 予約.室ID = 会議室.室ID
                      AND 予約.予約日 = '2026-11-16'
                      AND 予約.時間帯 = 'A');

-- [ク] 定員が最大の会議室（結果: 大会議室）
SELECT 室名 FROM 会議室 WHERE 定員 = (SELECT MAX(定員) FROM 会議室);

-- [ケ] 予約の取消（主キーの3列をすべて指定する）
DELETE FROM 予約 WHERE 室ID = 'R02' AND 予約日 = '2026-11-17' AND 時間帯 = 'A';
SELECT COUNT(*) AS 残り FROM 予約;   -- 4

-- 二重予約は主キー違反で失敗する（試す用。実行するとエラーになる）
-- INSERT INTO 予約 VALUES ('R01','2026-11-16','A','U03');


-- ############ 総合4 ポイント管理 ############
DROP TABLE IF EXISTS ポイント履歴;
DROP TABLE IF EXISTS 会員;

CREATE TABLE 会員 (
    会員ID  CHAR(4)     NOT NULL,
    氏名    VARCHAR(20) NOT NULL,
    ポイント  INTEGER   DEFAULT 0 NOT NULL CHECK (ポイント >= 0),   -- [ア]
    PRIMARY KEY (会員ID)
);
CREATE TABLE ポイント履歴 (
    履歴ID  INTEGER  NOT NULL,
    会員ID  CHAR(4)  NOT NULL,
    増減    INTEGER  NOT NULL,
    日付    DATE     NOT NULL,
    PRIMARY KEY (履歴ID),
    FOREIGN KEY (会員ID) REFERENCES 会員 (会員ID)                   -- [イ]
);
-- [ウ] GRANT SELECT ON ポイント履歴 TO 経理課;
-- [エ] GRANT SELECT, UPDATE (ポイント) ON 会員 TO 会員システム;
-- [オ] REVOKE DELETE ON ポイント履歴 FROM 会員システム;

INSERT INTO 会員 VALUES ('M001','佐藤',300), ('M002','鈴木',160), ('M003','高橋',0);
INSERT INTO ポイント履歴 VALUES
  (1,'M001',500,'2026-09-01'),
  (2,'M001',-200,'2026-09-15'),
  (3,'M002',150,'2026-10-01');

-- [カ] ランク表示（300以上ゴールド、100以上シルバー、それ以外ブロンズ）
SELECT 氏名, ポイント,
       CASE WHEN ポイント >= 300 THEN 'ゴールド'
            WHEN ポイント >= 100 THEN 'シルバー'
            ELSE 'ブロンズ' END AS ランク
  FROM 会員;

-- [キ] 履歴が1件もない会員（結果: 高橋）
SELECT 会員.氏名
  FROM 会員 LEFT OUTER JOIN ポイント履歴 ON 会員.会員ID = ポイント履歴.会員ID
 WHERE ポイント履歴.履歴ID IS NULL;

-- [ク] 会員表のポイントが、履歴の合計と合わない会員（結果: 鈴木 160 と 150）
SELECT 氏名, ポイント,
       COALESCE((SELECT SUM(増減) FROM ポイント履歴 WHERE ポイント履歴.会員ID = 会員.会員ID), 0) AS 履歴合計
  FROM 会員
 WHERE ポイント <> COALESCE((SELECT SUM(増減) FROM ポイント履歴 WHERE ポイント履歴.会員ID = 会員.会員ID), 0);

-- [ケ] 月ごとの付与ポイント合計（増減がプラスのものだけ）
SELECT SUBSTR(日付, 1, 7) AS 年月, SUM(増減) AS 付与
  FROM ポイント履歴 WHERE 増減 > 0 GROUP BY SUBSTR(日付, 1, 7);

-- [コ] M001 が100ポイント使う（会員表の更新と履歴の追加を、1つのトランザクションで）
BEGIN;
UPDATE 会員 SET ポイント = ポイント - 100 WHERE 会員ID = 'M001';
INSERT INTO ポイント履歴 VALUES (4, 'M001', -100, '2026-11-15');
COMMIT;
SELECT 会員ID, ポイント FROM 会員 ORDER BY 会員ID;

-- [サ] 残高を超えて使うと CHECK 違反になる → ROLLBACK で全部戻す（実行するとエラー）
-- BEGIN;
-- UPDATE 会員 SET ポイント = ポイント - 1000 WHERE 会員ID = 'M003';
-- ROLLBACK;
