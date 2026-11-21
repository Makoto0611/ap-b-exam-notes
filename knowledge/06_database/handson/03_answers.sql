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
SELECT dept_id, AVG(salary) AS avg_salary FROM staff GROUP BY dept_id ORDER BY avg_salary DESC;

-- Q13
SELECT name, salary FROM staff WHERE salary > (SELECT AVG(salary) FROM staff);

-- Q14
SELECT name FROM staff
WHERE EXISTS (SELECT 1 FROM enrollment WHERE enrollment.staff_id = staff.staff_id);

-- Q15
INSERT INTO staff (staff_id, name, dept_id, salary) VALUES ('E0007', 'nakamura', 'D04', 300000);
SELECT * FROM staff WHERE staff_id = 'E0007';

-- Q16  （先に同じWHEREでSELECTして対象を確認する）
SELECT name, salary FROM staff WHERE dept_id = 'D02';
UPDATE staff SET salary = salary + 10000 WHERE dept_id = 'D02';
SELECT name, salary FROM staff WHERE dept_id = 'D02';

-- Q17  （暗証番号を省略 → DEFAULTの'1234'）
INSERT INTO contract (contract_id, staff_id, carrier_id) VALUES ('C00004', 'E0004', 'N2');
SELECT * FROM contract WHERE contract_id = 'C00004';

-- Q18  （参照先の部署'D99'が無いので、外部キー制約でエラーになる）
INSERT INTO staff (staff_id, name, dept_id, salary) VALUES ('E0008', 'kobayashi', 'D99', 300000);

-- Q19
CREATE TABLE device (
    device_id    CHAR(5)     NOT NULL,
    model_name   VARCHAR(20) NOT NULL,
    status       CHAR(1)     DEFAULT 'A' NOT NULL,
    PRIMARY KEY (device_id)
);

-- Q20
ALTER TABLE staff ADD hire_date DATE;
SELECT * FROM staff;

-- Q21  （SQLiteでは作り直しで試す。試験の文では下の形で書く）
--   ALTER TABLE device ADD staff_id CHAR(5);
--   ALTER TABLE device ADD FOREIGN KEY (staff_id) REFERENCES staff (staff_id);
DROP TABLE device;
CREATE TABLE device (
    device_id    CHAR(5)     NOT NULL,
    model_name   VARCHAR(20) NOT NULL,
    status       CHAR(1)     DEFAULT 'A' NOT NULL,
    staff_id     CHAR(5),
    PRIMARY KEY (device_id),
    FOREIGN KEY (staff_id) REFERENCES staff (staff_id)
);

-- Q22  （親の開催を消すと、子の受講が連鎖して消える）
SELECT * FROM enrollment;
DELETE FROM session WHERE course_code = 'K01' AND session_no = 1;
SELECT * FROM enrollment;

-- Q23  （DELETEは行を消す。DROPは表ごと消す）
DROP TABLE device;

-- Q24（書くだけ。SQLiteでは実行できない）
--   GRANT SELECT (staff_id, name) ON staff TO general_user;
-- Q25（書くだけ）
--   REVOKE UPDATE ON staff FROM hr_dept;

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

-- Q29（書くだけ。SQLiteでは実行できない）
--   ALTER TABLE contract ADD CONSTRAINT uq_staff_carrier UNIQUE (staff_id, carrier_id);

-- Q30
CREATE TABLE dev_staff (
    staff_id  CHAR(5)     NOT NULL,
    name      VARCHAR(30) NOT NULL,
    PRIMARY KEY (staff_id)
);
INSERT INTO dev_staff (staff_id, name)
SELECT staff_id, name FROM staff WHERE dept_id = 'D02';
SELECT * FROM dev_staff;   -- 3行

-- Q31  （reset 直後なら5行。head_office と ga_division は 0。全体を流したあとは、Q15の追加で ga_division が 0 でなくなる）
WITH dept_max AS (
    SELECT dept_id, MAX(salary) AS max_salary FROM staff GROUP BY dept_id
)
SELECT department.department_name, COALESCE(dept_max.max_salary, 0) AS max_salary
FROM department LEFT OUTER JOIN dept_max ON department.dept_id = dept_max.dept_id;

-- Q32 の答え（表ごとに、C→R→U→D の順にまとめる）
--           dev_staff  staff  contract  enrollment
--   処理1   C          R
--   処理2              R      U
--   処理3                               D
--   処理4              RU
--   まとめ  C          RU     U         D
--   （処理4は、自分の値を読んで更新するので RU。staff は、処理1・処理2の R と合わせて RU）
