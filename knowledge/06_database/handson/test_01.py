import re, sqlite3, sys
import os
text = open(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '01_condition_to_sql.md'), encoding='utf-8').read()
blocks = re.findall(r"```sql\n(.*?)```", text, re.S)

PRE = """
CREATE TABLE customer (customer_id CHAR(5) NOT NULL, name VARCHAR(30) NOT NULL, phone VARCHAR(15), region VARCHAR(10), PRIMARY KEY (customer_id));
CREATE TABLE product (product_id CHAR(5) NOT NULL, product_name VARCHAR(30) NOT NULL, unit_price INTEGER NOT NULL, PRIMARY KEY (product_id));
CREATE TABLE orders (order_id CHAR(6) NOT NULL, customer_id CHAR(5) NOT NULL, order_date DATE NOT NULL, status CHAR(1) DEFAULT 'N' NOT NULL, PRIMARY KEY (order_id), FOREIGN KEY (customer_id) REFERENCES customer (customer_id));
CREATE TABLE order_detail (order_id CHAR(6) NOT NULL, detail_no INTEGER NOT NULL, product_id CHAR(5) NOT NULL, quantity INTEGER NOT NULL, PRIMARY KEY (order_id, detail_no), FOREIGN KEY (order_id) REFERENCES orders (order_id) ON DELETE CASCADE, FOREIGN KEY (product_id) REFERENCES product (product_id));
CREATE TABLE shipment (order_id CHAR(6) NOT NULL, detail_no INTEGER NOT NULL, ship_date DATE NOT NULL, PRIMARY KEY (order_id, detail_no));
INSERT INTO customer VALUES ('C0001','yamada','090','tokyo'),('C0002','suzuki',NULL,'osaka'),('C0003','yamamoto',NULL,'tokyo'),('C0004','sato','080','fukuoka');
INSERT INTO product VALUES ('P0001','A',100),('P0002','B',300),('P0003','C',500);
INSERT INTO orders VALUES ('O00001','C0001','2026-01-01','N'),('O00002','C0001','2026-01-02','C'),('O00003','C0002','2026-01-03','N');
INSERT INTO order_detail VALUES ('O00001',1,'P0001',2),('O00001',2,'P0002',1),('O00002',1,'P0003',1),('O00003',1,'P0001',5);
INSERT INTO shipment VALUES ('O00001',1,'2026-01-05'),('O00003',1,'2026-01-06');
"""

ok = skip = bad = 0
for i, b in enumerate(blocks, 1):
    if '実行不可' in b:
        skip += 1
        continue
    con = sqlite3.connect(':memory:', isolation_level=None)
    con.execute('PRAGMA foreign_keys = OFF')
    for name in re.findall(r"CREATE TABLE (\S+) \(", b):
        pass
    con.executescript(PRE)
    # ブロックが作る表と同名の前提表は先に消す
    for name in re.findall(r"CREATE TABLE (\S+) \(", b):
        con.execute(f'DROP TABLE IF EXISTS {name}')
    con.execute('PRAGMA foreign_keys = ON')
    if 'DROP COLUMN phone2' in b:
        con.execute('ALTER TABLE customer ADD phone2 VARCHAR(15)')  # 直前の例の続き
    try:
        stmts = [s for s in re.split(r";\s*\n|;\s*$", b) if s.strip()]
        for s in stmts:
            con.execute(s)
        ok += 1
    except Exception as e:
        bad += 1
        print(f'NG block {i}: {e}\n{b}')
print(f'実行OK={ok} 対象外(実行不可)={skip} NG={bad} / 全{len(blocks)}ブロック')
sys.exit(1 if bad else 0)
