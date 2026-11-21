-- ============================================================
-- 総合問題1〜4 の答え（先に見ない）
-- 実行: python3 sql.py -f 06_answers.sql   （答え合わせ用。全部通る）
-- 各行の「-- [記号]」が、06_integrated.md の空欄の答え
-- GRANT / REVOKE は SQLite にないため、コメントで示す
-- ============================================================
PRAGMA foreign_keys = ON;

-- ############ 総合1 備品貸出管理 ############
DROP TABLE IF EXISTS loan;
DROP TABLE IF EXISTS equipment;
DROP TABLE IF EXISTS employee;
DROP TABLE IF EXISTS dept;

CREATE TABLE dept (
    dept_id  CHAR(3)     NOT NULL,
    dept_name  VARCHAR(20) NOT NULL,
    PRIMARY KEY (dept_id)
);
CREATE TABLE employee (
    employee_id  CHAR(4)     NOT NULL,
    name    VARCHAR(20) NOT NULL,
    dept_id    CHAR(3)     NOT NULL,
    PRIMARY KEY (employee_id),
    FOREIGN KEY (dept_id) REFERENCES dept (dept_id)
);
CREATE TABLE equipment (
    equipment_id  CHAR(5)     NOT NULL,
    equipment_name  VARCHAR(30) NOT NULL,
    category    CHAR(2)     NOT NULL CHECK (category IN ('PC', 'peripheral')),   -- [ア]
    status    CHAR(2)     DEFAULT 'in_stock' NOT NULL,                   -- [イ]
    PRIMARY KEY (equipment_id)
);
CREATE TABLE loan (
    loan_id  INTEGER  NOT NULL,
    equipment_id  CHAR(5)  NOT NULL,
    employee_id  CHAR(4)  NOT NULL,
    loan_date  DATE     NOT NULL,
    return_date  DATE,                                                   -- [ウ] NOT NULL を付けない
    PRIMARY KEY (loan_id),                                           -- [エ]
    FOREIGN KEY (equipment_id) REFERENCES equipment (equipment_id),                  -- [オ]
    FOREIGN KEY (employee_id) REFERENCES employee (employee_id)
);
-- [カ] GRANT SELECT (備品ID, 備品名, 状態) ON 備品 TO 総務課;
ALTER TABLE equipment ADD note VARCHAR(50);                              -- [キ]
CREATE VIEW on_loan AS                                               -- [ク]
    SELECT equipment_id, employee_id, loan_date FROM loan WHERE return_date IS NULL;

-- データ投入（06_s1_data.sql と同じ内容）
INSERT INTO dept VALUES ('K01','general_affairs'), ('K02','development'), ('K03','sales');
INSERT INTO employee VALUES ('E001','sato','K01'), ('E002','suzuki','K02'), ('E003','takahashi','K02'), ('E004','tanaka','K02');
INSERT INTO equipment (equipment_id, equipment_name, category, status) VALUES
  ('P0001','ノートPC-A','PC','loan'),
  ('P0002','ノートPC-B','PC','in_stock'),
  ('P0003','モニタ','peripheral','loan'),
  ('P0004','キーボード','peripheral','in_stock'),
  ('P0005','mouse','peripheral','in_stock');
INSERT INTO loan VALUES
  (1,'P0001','E002','2026-10-01',NULL),
  (2,'P0003','E002','2026-10-05',NULL),
  (3,'P0002','E003','2026-09-20','2026-09-30'),
  (4,'P0004','E004','2026-10-10','2026-10-12'),
  (5,'P0001','E003','2026-08-01','2026-08-31');

-- [ケ] いま2点以上借りている社員（結果: 鈴木 2）
SELECT employee.name, COUNT(*) AS cnt
  FROM employee INNER JOIN loan ON employee.employee_id = loan.employee_id
 WHERE loan.return_date IS NULL
 GROUP BY employee.employee_id, employee.name
HAVING COUNT(*) >= 2;

-- [コ] 一度も貸し出されていない備品（結果: マウス）
SELECT equipment.equipment_name
  FROM equipment LEFT OUTER JOIN loan ON equipment.equipment_id = loan.equipment_id
 WHERE loan.loan_id IS NULL;

-- [サ] 課ごとの貸出中の件数（0件の課も出す。結果: 総務0・開発2・営業0）
SELECT dept.dept_name, COUNT(loan.loan_id) AS on_loan
  FROM dept
  LEFT OUTER JOIN employee ON dept.dept_id = employee.dept_id
  LEFT OUTER JOIN loan ON employee.employee_id = loan.employee_id AND loan.return_date IS NULL
 GROUP BY dept.dept_id, dept.dept_name;

-- [シ] P0002 を E004 に貸し出す（2つの表を同時に更新 → 1つのトランザクション）
BEGIN;
INSERT INTO loan (loan_id, equipment_id, employee_id, loan_date) VALUES (6, 'P0002', 'E004', '2026-11-15');
UPDATE equipment SET status = 'loan' WHERE equipment_id = 'P0002';
COMMIT;

-- [ス] P0001 を返却（返却日 IS NULL の行だけ）
BEGIN;
UPDATE loan SET return_date = '2026-11-15' WHERE equipment_id = 'P0001' AND return_date IS NULL;
UPDATE equipment SET status = 'in_stock' WHERE equipment_id = 'P0001';
COMMIT;

SELECT equipment_id, equipment_name, status FROM equipment ORDER BY equipment_id;


-- ############ 総合2 注文管理 ############
DROP TABLE IF EXISTS order_item;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS customer;

CREATE TABLE customer (
    customer_id  CHAR(5)     NOT NULL,
    customer_name  VARCHAR(20) NOT NULL,
    region    VARCHAR(10) NOT NULL,
    PRIMARY KEY (customer_id)
);
CREATE TABLE product (
    product_id  CHAR(4)     NOT NULL,
    product_name  VARCHAR(30) NOT NULL,
    unit_price    INTEGER     NOT NULL CHECK (unit_price > 0),                  -- [ア]
    PRIMARY KEY (product_id)
);
CREATE TABLE orders (
    order_no  INTEGER  NOT NULL,
    customer_id    CHAR(5)  NOT NULL,
    order_date    DATE     NOT NULL,
    PRIMARY KEY (order_no),
    FOREIGN KEY (customer_id) REFERENCES customer (customer_id)
);
CREATE TABLE order_item (
    order_no  INTEGER  NOT NULL,
    line_no    INTEGER  NOT NULL,
    product_id    CHAR(4)  NOT NULL,
    quantity      INTEGER  NOT NULL CHECK (quantity > 0),
    PRIMARY KEY (order_no, line_no),                                 -- [イ]
    FOREIGN KEY (order_no) REFERENCES orders (order_no) ON DELETE CASCADE,  -- [ウ]
    FOREIGN KEY (product_id) REFERENCES product (product_id)
);
-- [エ] GRANT SELECT ON 注文明細 TO 経理課;
-- [オ] GRANT UPDATE (単価) ON 商品 TO 仕入課;

INSERT INTO customer VALUES ('C0001','yamada','tokyo'), ('C0002','佐々木','osaka'), ('C0003','ito','tokyo');
INSERT INTO product VALUES ('G001','ペン',100), ('G002','ノート',200), ('G003','バッグ',3000);
INSERT INTO orders VALUES (1,'C0001','2026-10-03'), (2,'C0001','2026-11-02'), (3,'C0002','2026-11-05');
INSERT INTO order_item VALUES
  (1,1,'G001',10), (1,2,'G002',5),
  (2,1,'G003',1),
  (3,1,'G001',20), (3,2,'G003',2);

-- [カ] 注文ごとの合計金額（結果: 1→2000、2→3000、3→8000）
SELECT order_item.order_no, SUM(product.unit_price * order_item.quantity) AS total
  FROM order_item INNER JOIN product ON order_item.product_id = product.product_id
 GROUP BY order_item.order_no;

-- [キ] 顧客ごとの合計が、全顧客の平均を上回る顧客（結果: 佐々木 8000）
SELECT customer.customer_name, SUM(product.unit_price * order_item.quantity) AS total
  FROM customer
  INNER JOIN orders ON customer.customer_id = orders.customer_id
  INNER JOIN order_item ON orders.order_no = order_item.order_no
  INNER JOIN product ON order_item.product_id = product.product_id
 GROUP BY customer.customer_id, customer.customer_name
HAVING SUM(product.unit_price * order_item.quantity) >
       (SELECT AVG(小計) FROM
           (SELECT SUM(product.unit_price * order_item.quantity) AS 小計
              FROM orders
              INNER JOIN order_item ON orders.order_no = order_item.order_no
              INNER JOIN product ON order_item.product_id = product.product_id
             GROUP BY orders.customer_id));

-- [ク] 一度も注文していない顧客（結果: 伊藤）
SELECT customer_name FROM customer
 WHERE NOT EXISTS (SELECT 1 FROM orders WHERE orders.customer_id = customer.customer_id);

-- [ケ] 月ごとの注文件数（結果: 2026-10→1、2026-11→2）
SELECT SUBSTR(order_date, 1, 7) AS 年月, COUNT(*) AS cnt
  FROM orders GROUP BY SUBSTR(order_date, 1, 7);

-- [コ] 値上げ: 1000円未満は+10円、1000円以上は+100円（1回のUPDATEで）
UPDATE product
   SET unit_price = CASE WHEN unit_price < 1000 THEN unit_price + 10 ELSE unit_price + 100 END;
SELECT * FROM product;

-- [サ] 注文1を削除 → 明細も連鎖して消える
DELETE FROM orders WHERE order_no = 1;
SELECT COUNT(*) AS 注文1の明細 FROM order_item WHERE order_no = 1;   -- 0


-- ############ 総合3 会議室予約 ############
DROP TABLE IF EXISTS reservation;
DROP TABLE IF EXISTS room_user;
DROP TABLE IF EXISTS room;

CREATE TABLE room (
    room_id    CHAR(3)     NOT NULL,
    room_name    VARCHAR(20) NOT NULL,
    capacity    INTEGER     NOT NULL CHECK (capacity > 0),
    PRIMARY KEY (room_id)
);
CREATE TABLE room_user (
    user_id  CHAR(3)     NOT NULL,
    name      VARCHAR(20) NOT NULL,
    PRIMARY KEY (user_id)
);
CREATE TABLE reservation (
    room_id      CHAR(3)  NOT NULL,
    reserve_date    DATE     NOT NULL,
    time_slot    CHAR(1)  NOT NULL CHECK (time_slot IN ('A', 'B')),       -- [ア]
    user_id  CHAR(3)  NOT NULL,
    PRIMARY KEY (room_id, reserve_date, time_slot),                             -- [イ]
    FOREIGN KEY (room_id) REFERENCES room (room_id),                    -- [ウ]
    FOREIGN KEY (user_id) REFERENCES room_user (user_id)
);
-- [エ] GRANT SELECT ON 予約 TO 全社員;  GRANT INSERT, DELETE ON 予約 TO 総務課;

INSERT INTO room VALUES ('R01','大会議室',20), ('R02','小会議室',6), ('R03','面談室',2);
INSERT INTO room_user VALUES ('U01','sato'), ('U02','suzuki'), ('U03','takahashi');
INSERT INTO reservation VALUES
  ('R01','2026-11-16','A','U01'),
  ('R01','2026-11-16','B','U02'),
  ('R02','2026-11-16','A','U01'),
  ('R02','2026-11-17','A','U03'),
  ('R01','2026-11-17','B','U01');

-- [オ] 会議室ごとの予約件数（0件の会議室も出す。結果: R01→3、R02→2、R03→0）
SELECT room.room_name, COUNT(reservation.room_id) AS cnt
  FROM room LEFT OUTER JOIN reservation ON room.room_id = reservation.room_id
 GROUP BY room.room_id, room.room_name;

-- [カ] 同じ日に2件以上予約した利用者（結果: 佐藤 2026-11-16）
SELECT room_user.name, reservation.reserve_date, COUNT(*) AS cnt
  FROM room_user INNER JOIN reservation ON room_user.user_id = reservation.user_id
 GROUP BY room_user.user_id, room_user.name, reservation.reserve_date
HAVING COUNT(*) >= 2;

-- [キ] 2026-11-16 の午前（A）に空いている会議室（結果: 面談室）
SELECT room_name FROM room
 WHERE NOT EXISTS (SELECT 1 FROM reservation
                    WHERE reservation.room_id = room.room_id
                      AND reservation.reserve_date = '2026-11-16'
                      AND reservation.time_slot = 'A');

-- [ク] 定員が最大の会議室（結果: 大会議室）
SELECT room_name FROM room WHERE capacity = (SELECT MAX(capacity) FROM room);

-- [ケ] 予約の取消（主キーの3列をすべて指定する）
DELETE FROM reservation WHERE room_id = 'R02' AND reserve_date = '2026-11-17' AND time_slot = 'A';
SELECT COUNT(*) AS 残り FROM reservation;   -- 4

-- 二重予約は主キー違反で失敗する（試す用。実行するとエラーになる）
-- INSERT INTO 予約 VALUES ('R01','2026-11-16','A','U03');


-- ############ 総合4 ポイント管理 ############
DROP TABLE IF EXISTS point_history;
DROP TABLE IF EXISTS member;

CREATE TABLE member (
    member_id  CHAR(4)     NOT NULL,
    name    VARCHAR(20) NOT NULL,
    points  INTEGER   DEFAULT 0 NOT NULL CHECK (points >= 0),   -- [ア]
    PRIMARY KEY (member_id)
);
CREATE TABLE point_history (
    history_id  INTEGER  NOT NULL,
    member_id  CHAR(4)  NOT NULL,
    delta    INTEGER  NOT NULL,
    event_date    DATE     NOT NULL,
    PRIMARY KEY (history_id),
    FOREIGN KEY (member_id) REFERENCES member (member_id)                   -- [イ]
);
-- [ウ] GRANT SELECT ON ポイント履歴 TO 経理課;
-- [エ] GRANT SELECT, UPDATE (ポイント) ON 会員 TO 会員システム;
-- [オ] REVOKE DELETE ON ポイント履歴 FROM 会員システム;

INSERT INTO member VALUES ('M001','sato',300), ('M002','suzuki',160), ('M003','takahashi',0);
INSERT INTO point_history VALUES
  (1,'M001',500,'2026-09-01'),
  (2,'M001',-200,'2026-09-15'),
  (3,'M002',150,'2026-10-01');

-- [カ] ランク表示（300以上ゴールド、100以上シルバー、それ以外ブロンズ）
SELECT name, points,
       CASE WHEN points >= 300 THEN 'gold'
            WHEN points >= 100 THEN 'silver'
            ELSE 'bronze' END AS rank_label
  FROM member;

-- [キ] 履歴が1件もない会員（結果: 高橋）
SELECT member.name
  FROM member LEFT OUTER JOIN point_history ON member.member_id = point_history.member_id
 WHERE point_history.history_id IS NULL;

-- [ク] 会員表のポイントが、履歴の合計と合わない会員（結果: 鈴木 160 と 150）
SELECT name, points,
       COALESCE((SELECT SUM(delta) FROM point_history WHERE point_history.member_id = member.member_id), 0) AS history_total
  FROM member
 WHERE points <> COALESCE((SELECT SUM(delta) FROM point_history WHERE point_history.member_id = member.member_id), 0);

-- [ケ] 月ごとの付与ポイント合計（増減がプラスのものだけ）
SELECT SUBSTR(event_date, 1, 7) AS 年月, SUM(delta) AS 付与
  FROM point_history WHERE delta > 0 GROUP BY SUBSTR(event_date, 1, 7);

-- [コ] M001 が100ポイント使う（会員表の更新と履歴の追加を、1つのトランザクションで）
BEGIN;
UPDATE member SET points = points - 100 WHERE member_id = 'M001';
INSERT INTO point_history VALUES (4, 'M001', -100, '2026-11-15');
COMMIT;
SELECT member_id, points FROM member ORDER BY member_id;

-- [サ] 残高を超えて使うと CHECK 違反になる → ROLLBACK で全部戻す（実行するとエラー）
-- BEGIN;
-- UPDATE 会員 SET ポイント = ポイント - 1000 WHERE 会員ID = 'M003';
-- ROLLBACK;
