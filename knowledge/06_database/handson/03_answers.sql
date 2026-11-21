-- ============================================================
-- 答え（先に見ない）。 python3 sql.py reset のあと、1問ずつ試す。
-- 全体を流すとき: python3 sql.py reset && python3 sql.py -f 03_answers.sql
-- ============================================================

-- Q1
SELECT name, salary FROM staff ORDER BY salary DESC;

-- Q2
SELECT name FROM staff WHERE dept_id = 'D02';

-- Q3  （NULLは「値がない」ので、= で比べても真にならない。IS NULL を使う）
SELECT * FROM enrollment WHERE result IS NULL;

-- Q4
SELECT * FROM staff WHERE salary BETWEEN 350000 AND 400000;

-- Q5
SELECT staff.name, department.department_name
FROM staff INNER JOIN department ON staff.dept_id = department.dept_id;

-- Q6  （総務部は従業員が無いので、氏名がNULLで残る）
SELECT department.department_name, staff.name
FROM department LEFT OUTER JOIN staff ON department.dept_id = staff.dept_id;

-- Q7
SELECT department.department_name
FROM department LEFT OUTER JOIN staff ON department.dept_id = staff.dept_id
WHERE staff.staff_id IS NULL;

-- Q8
SELECT course.course_name, session.session_date
FROM course LEFT OUTER JOIN session ON course.course_code = session.course_code;

-- Q9  （開催番号の条件を落とすと、同じ講座の別開催とも結合して行が増える）
SELECT staff.name, course.course_name, session.session_date, enrollment.result
FROM enrollment
INNER JOIN staff ON enrollment.staff_id = staff.staff_id
INNER JOIN session   ON enrollment.course_code = session.course_code AND enrollment.session_no = session.session_no
INNER JOIN course   ON session.course_code = course.course_code;

-- Q10
SELECT dept_id, COUNT(*) AS headcount FROM staff GROUP BY dept_id;

-- Q11  （WHEREは集計の前、HAVINGは集計の後）
SELECT dept_id, COUNT(*) AS headcount FROM staff GROUP BY dept_id HAVING COUNT(*) >= 3;

-- Q12
SELECT dept_id, AVG(salary) AS 平均給与 FROM staff GROUP BY dept_id ORDER BY 平均給与 DESC;

-- Q13
SELECT name, salary FROM staff WHERE salary > (SELECT AVG(salary) FROM staff);

-- Q14
SELECT name FROM staff
WHERE EXISTS (SELECT 1 FROM enrollment WHERE enrollment.staff_id = staff.staff_id);

-- Q15
INSERT INTO staff (staff_id, name, dept_id, salary) VALUES ('E0007', '中村', 'D04', 300000);
SELECT * FROM staff WHERE staff_id = 'E0007';

-- Q16  （先に同じWHEREでSELECTして対象を確認する）
SELECT name, salary FROM staff WHERE dept_id = 'D02';
UPDATE staff SET salary = salary + 10000 WHERE dept_id = 'D02';
SELECT name, salary FROM staff WHERE dept_id = 'D02';

-- Q17  （暗証番号を省略 → DEFAULTの'1234'）
INSERT INTO contract (contract_id, staff_id, carrier_id) VALUES ('C00004', 'E0004', 'N2');
SELECT * FROM contract WHERE contract_id = 'C00004';

-- Q18  （参照先の部署'D99'が無いので、外部キー制約でエラーになる）
INSERT INTO staff (staff_id, name, dept_id, salary) VALUES ('E0008', '小林', 'D99', 300000);

-- Q19
CREATE TABLE 端末 (
    端末ID  CHAR(5)     NOT NULL,
    機種名  VARCHAR(20) NOT NULL,
    status    CHAR(1)     DEFAULT 'A' NOT NULL,
    PRIMARY KEY (端末ID)
);

-- Q20
ALTER TABLE staff ADD 入社日 DATE;
SELECT * FROM staff;

-- Q21  （SQLiteでは作り直しで試す。試験の文では下の形で書く）
--   ALTER TABLE 端末 ADD 従業員ID CHAR(5);
--   ALTER TABLE 端末 ADD FOREIGN KEY (従業員ID) REFERENCES 従業員 (従業員ID);
DROP TABLE 端末;
CREATE TABLE 端末 (
    端末ID    CHAR(5)     NOT NULL,
    機種名    VARCHAR(20) NOT NULL,
    status      CHAR(1)     DEFAULT 'A' NOT NULL,
    staff_id  CHAR(5),
    PRIMARY KEY (端末ID),
    FOREIGN KEY (staff_id) REFERENCES staff (staff_id)
);

-- Q22  （親の開催を消すと、子の受講が連鎖して消える）
SELECT * FROM enrollment;
DELETE FROM session WHERE course_code = 'K01' AND session_no = 1;
SELECT * FROM enrollment;

-- Q23  （DELETEは行を消す。DROPは表ごと消す）
DROP TABLE 端末;

-- Q24（書くだけ。SQLiteでは実行できない）
--   GRANT SELECT (従業員ID, 氏名) ON 従業員 TO 一般ユーザ;
-- Q25（書くだけ）
--   REVOKE UPDATE ON 従業員 FROM 人事課;

-- Q26
BEGIN;
UPDATE staff SET salary = 0;
SELECT name, salary FROM staff;
ROLLBACK;
SELECT name, salary FROM staff;

-- Q27 の答え
--   ア: CHAR(4)    イ: DEFAULT '1234'    ウ: FOREIGN KEY    エ: SELECT
-- Q28 の答え
--   オ: CASCADE    カ: ON
