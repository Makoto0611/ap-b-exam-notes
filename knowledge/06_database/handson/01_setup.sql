-- ============================================================
-- B科目 問6 ハンズオン用データ（SQLite）
-- 題材: 研修管理 + 部署 + 端末契約（過去問の型を再現した自作データ）
-- 実行: python3 sql.py reset
-- ============================================================
PRAGMA foreign_keys = ON;   -- SQLiteは既定でFKが無効。これを忘れるとON DELETE CASCADEも効かない

DROP TABLE IF EXISTS enrollment;
DROP TABLE IF EXISTS session;
DROP TABLE IF EXISTS course;
DROP TABLE IF EXISTS contract;
DROP TABLE IF EXISTS carrier;
DROP TABLE IF EXISTS staff;
DROP TABLE IF EXISTS department;

-- ---- 部署（自己参照: 上位部署ID → 部署ID） ----
CREATE TABLE department (
    dept_id      CHAR(3)     NOT NULL,
    department_name      VARCHAR(20) NOT NULL,
    parent_dept_id  CHAR(3),                       -- NULL許可（最上位はNULL）
    PRIMARY KEY (dept_id),
    FOREIGN KEY (parent_dept_id) REFERENCES department (dept_id)
);

-- ---- 従業員 ----
CREATE TABLE staff (
    staff_id  CHAR(5)     NOT NULL,
    name      VARCHAR(30) NOT NULL,
    dept_id    CHAR(3)     NOT NULL,
    salary      INTEGER     NOT NULL,
    PRIMARY KEY (staff_id),
    FOREIGN KEY (dept_id) REFERENCES department (dept_id)
);

-- ---- 通信事業者・契約（DEFAULT / 初期値 / 暗証番号の型） ----
CREATE TABLE carrier (
    carrier_id  CHAR(2)     NOT NULL,
    carrier_name  VARCHAR(20) NOT NULL,
    PRIMARY KEY (carrier_id)
);

CREATE TABLE contract (
    contract_id    CHAR(6)  NOT NULL,
    staff_id  CHAR(5)  NOT NULL,
    carrier_id  CHAR(2)  NOT NULL,
    pin  CHAR(4)  DEFAULT '1234' NOT NULL,
    PRIMARY KEY (contract_id),
    FOREIGN KEY (staff_id) REFERENCES staff (staff_id),
    FOREIGN KEY (carrier_id) REFERENCES carrier (carrier_id)
);

-- ---- 講座・開催・受講（複合主キー／ON DELETE CASCADE） ----
CREATE TABLE course (
    course_code  CHAR(3)     NOT NULL,
    course_name      VARCHAR(30) NOT NULL,
    PRIMARY KEY (course_code)
);

CREATE TABLE session (
    course_code  CHAR(3) NOT NULL,
    session_no    INTEGER NOT NULL,
    session_date      DATE    NOT NULL,
    PRIMARY KEY (course_code, session_no),
    FOREIGN KEY (course_code) REFERENCES course (course_code)
);

CREATE TABLE enrollment (
    staff_id    CHAR(5) NOT NULL,
    course_code  CHAR(3) NOT NULL,
    session_no    INTEGER NOT NULL,
    result        VARCHAR(4),                    -- 合格/不合格/NULL（未判定）
    PRIMARY KEY (staff_id, course_code, session_no),
    FOREIGN KEY (staff_id) REFERENCES staff (staff_id),
    FOREIGN KEY (course_code, session_no) REFERENCES session (course_code, session_no)
        ON DELETE CASCADE
);

-- ============================ データ ============================
INSERT INTO department VALUES ('D00', 'head_office',       NULL);
INSERT INTO department VALUES ('D01', 'sales_division',     'D00');
INSERT INTO department VALUES ('D02', 'dev_division',     'D00');
INSERT INTO department VALUES ('D03', 'sales_section1',   'D01');
INSERT INTO department VALUES ('D04', 'ga_division',     'D00');   -- 従業員がいない部署（外部結合の練習用）

INSERT INTO staff VALUES ('E0001', 'yamada', 'D03', 320000);
INSERT INTO staff VALUES ('E0002', 'suzuki', 'D03', 280000);
INSERT INTO staff VALUES ('E0003', 'sato', 'D02', 410000);
INSERT INTO staff VALUES ('E0004', 'takahashi', 'D02', 380000);
INSERT INTO staff VALUES ('E0005', 'tanaka', 'D02', 350000);
INSERT INTO staff VALUES ('E0006', 'ito', 'D01', 450000);

INSERT INTO carrier VALUES ('N1', 'carrier_a');
INSERT INTO carrier VALUES ('N2', 'carrier_b');

INSERT INTO contract (contract_id, staff_id, carrier_id, pin) VALUES ('C00001', 'E0001', 'N1', '9876');
INSERT INTO contract (contract_id, staff_id, carrier_id)           VALUES ('C00002', 'E0002', 'N1');   -- 暗証番号は初期値'1234'になる
INSERT INTO contract (contract_id, staff_id, carrier_id)           VALUES ('C00003', 'E0003', 'N2');

INSERT INTO course VALUES ('K01', 'security_basics');
INSERT INTO course VALUES ('K02', 'project_mgmt');
INSERT INTO course VALUES ('K03', 'sql_intro');            -- まだ開催されていない講座

INSERT INTO session VALUES ('K01', 1, '2026-04-10');
INSERT INTO session VALUES ('K01', 2, '2026-10-09');
INSERT INTO session VALUES ('K02', 1, '2026-05-15');

INSERT INTO enrollment VALUES ('E0001', 'K01', 1, 'pass');
INSERT INTO enrollment VALUES ('E0002', 'K01', 1, 'fail');
INSERT INTO enrollment VALUES ('E0003', 'K01', 2, NULL);      -- 結果が未判定
INSERT INTO enrollment VALUES ('E0003', 'K02', 1, 'pass');
INSERT INTO enrollment VALUES ('E0004', 'K02', 1, 'pass');
INSERT INTO enrollment VALUES ('E0006', 'K01', 1, 'pass');
