-- ============================================================
-- 答え（先に見ない）。 python3 sql.py reset のあと、1問ずつ試す。
-- 全体を流すとき: python3 sql.py reset && python3 sql.py -f 03_answers.sql
-- ============================================================

-- Q1
SELECT 氏名, 給与 FROM 従業員 ORDER BY 給与 DESC;

-- Q2
SELECT 氏名 FROM 従業員 WHERE 部署ID = 'D02';

-- Q3  （NULLは「値がない」ので、= で比べても真にならない。IS NULL を使う）
SELECT * FROM 受講 WHERE 結果 IS NULL;

-- Q4
SELECT * FROM 従業員 WHERE 給与 BETWEEN 350000 AND 400000;

-- Q5
SELECT 従業員.氏名, 部署.部署名
FROM 従業員 INNER JOIN 部署 ON 従業員.部署ID = 部署.部署ID;

-- Q6  （総務部は従業員が無いので、氏名がNULLで残る）
SELECT 部署.部署名, 従業員.氏名
FROM 部署 LEFT OUTER JOIN 従業員 ON 部署.部署ID = 従業員.部署ID;

-- Q7
SELECT 部署.部署名
FROM 部署 LEFT OUTER JOIN 従業員 ON 部署.部署ID = 従業員.部署ID
WHERE 従業員.従業員ID IS NULL;

-- Q8
SELECT 講座.講座名, 開催.開催日
FROM 講座 LEFT OUTER JOIN 開催 ON 講座.講座コード = 開催.講座コード;

-- Q9  （開催番号の条件を落とすと、同じ講座の別開催とも結合して行が増える）
SELECT 従業員.氏名, 講座.講座名, 開催.開催日, 受講.結果
FROM 受講
INNER JOIN 従業員 ON 受講.従業員ID = 従業員.従業員ID
INNER JOIN 開催   ON 受講.講座コード = 開催.講座コード AND 受講.開催番号 = 開催.開催番号
INNER JOIN 講座   ON 開催.講座コード = 講座.講座コード;

-- Q10
SELECT 部署ID, COUNT(*) AS 人数 FROM 従業員 GROUP BY 部署ID;

-- Q11  （WHEREは集計の前、HAVINGは集計の後）
SELECT 部署ID, COUNT(*) AS 人数 FROM 従業員 GROUP BY 部署ID HAVING COUNT(*) >= 3;

-- Q12
SELECT 部署ID, AVG(給与) AS 平均給与 FROM 従業員 GROUP BY 部署ID ORDER BY 平均給与 DESC;

-- Q13
SELECT 氏名, 給与 FROM 従業員 WHERE 給与 > (SELECT AVG(給与) FROM 従業員);

-- Q14
SELECT 氏名 FROM 従業員
WHERE EXISTS (SELECT 1 FROM 受講 WHERE 受講.従業員ID = 従業員.従業員ID);

-- Q15
INSERT INTO 従業員 (従業員ID, 氏名, 部署ID, 給与) VALUES ('E0007', '中村', 'D04', 300000);
SELECT * FROM 従業員 WHERE 従業員ID = 'E0007';

-- Q16  （先に同じWHEREでSELECTして対象を確認する）
SELECT 氏名, 給与 FROM 従業員 WHERE 部署ID = 'D02';
UPDATE 従業員 SET 給与 = 給与 + 10000 WHERE 部署ID = 'D02';
SELECT 氏名, 給与 FROM 従業員 WHERE 部署ID = 'D02';

-- Q17  （暗証番号を省略 → DEFAULTの'1234'）
INSERT INTO 契約 (契約ID, 従業員ID, 事業者ID) VALUES ('C00004', 'E0004', 'N2');
SELECT * FROM 契約 WHERE 契約ID = 'C00004';

-- Q18  （参照先の部署'D99'が無いので、外部キー制約でエラーになる）
INSERT INTO 従業員 (従業員ID, 氏名, 部署ID, 給与) VALUES ('E0008', '小林', 'D99', 300000);

-- Q19
CREATE TABLE 端末 (
    端末ID  CHAR(5)     NOT NULL,
    機種名  VARCHAR(20) NOT NULL,
    状態    CHAR(1)     DEFAULT 'A' NOT NULL,
    PRIMARY KEY (端末ID)
);

-- Q20
ALTER TABLE 従業員 ADD 入社日 DATE;
SELECT * FROM 従業員;

-- Q21  （SQLiteでは作り直しで試す。試験の文では下の形で書く）
--   ALTER TABLE 端末 ADD 従業員ID CHAR(5);
--   ALTER TABLE 端末 ADD FOREIGN KEY (従業員ID) REFERENCES 従業員 (従業員ID);
DROP TABLE 端末;
CREATE TABLE 端末 (
    端末ID    CHAR(5)     NOT NULL,
    機種名    VARCHAR(20) NOT NULL,
    状態      CHAR(1)     DEFAULT 'A' NOT NULL,
    従業員ID  CHAR(5),
    PRIMARY KEY (端末ID),
    FOREIGN KEY (従業員ID) REFERENCES 従業員 (従業員ID)
);

-- Q22  （親の開催を消すと、子の受講が連鎖して消える）
SELECT * FROM 受講;
DELETE FROM 開催 WHERE 講座コード = 'K01' AND 開催番号 = 1;
SELECT * FROM 受講;

-- Q23  （DELETEは行を消す。DROPは表ごと消す）
DROP TABLE 端末;

-- Q24（書くだけ。SQLiteでは実行できない）
--   GRANT SELECT (従業員ID, 氏名) ON 従業員 TO 一般ユーザ;
-- Q25（書くだけ）
--   REVOKE UPDATE ON 従業員 FROM 人事課;

-- Q26
BEGIN;
UPDATE 従業員 SET 給与 = 0;
SELECT 氏名, 給与 FROM 従業員;
ROLLBACK;
SELECT 氏名, 給与 FROM 従業員;

-- Q27 の答え
--   ア: CHAR(4)    イ: DEFAULT '1234'    ウ: FOREIGN KEY    エ: SELECT
-- Q28 の答え
--   オ: CASCADE    カ: ON
