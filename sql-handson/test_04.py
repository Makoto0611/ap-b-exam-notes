import re, sqlite3, sys
import os
text = open(os.path.join(os.path.dirname(os.path.abspath(__file__)), '04_condition_to_sql.md'), encoding='utf-8').read()
blocks = re.findall(r"```sql\n(.*?)```", text, re.S)

PRE = """
CREATE TABLE 顧客 (顧客ID CHAR(5) NOT NULL, 氏名 VARCHAR(30) NOT NULL, 電話番号 VARCHAR(15), 地域 VARCHAR(10), PRIMARY KEY (顧客ID));
CREATE TABLE 商品 (商品ID CHAR(5) NOT NULL, 商品名 VARCHAR(30) NOT NULL, 単価 INTEGER NOT NULL, PRIMARY KEY (商品ID));
CREATE TABLE 注文 (注文ID CHAR(6) NOT NULL, 顧客ID CHAR(5) NOT NULL, 注文日 DATE NOT NULL, 状態 CHAR(1) DEFAULT 'N' NOT NULL, PRIMARY KEY (注文ID), FOREIGN KEY (顧客ID) REFERENCES 顧客 (顧客ID));
CREATE TABLE 明細 (注文ID CHAR(6) NOT NULL, 明細番号 INTEGER NOT NULL, 商品ID CHAR(5) NOT NULL, 数量 INTEGER NOT NULL, PRIMARY KEY (注文ID, 明細番号), FOREIGN KEY (注文ID) REFERENCES 注文 (注文ID) ON DELETE CASCADE, FOREIGN KEY (商品ID) REFERENCES 商品 (商品ID));
CREATE TABLE 出荷 (注文ID CHAR(6) NOT NULL, 明細番号 INTEGER NOT NULL, 出荷日 DATE NOT NULL, PRIMARY KEY (注文ID, 明細番号));
INSERT INTO 顧客 VALUES ('C0001','山田','090','東京'),('C0002','鈴木',NULL,'大阪'),('C0003','山本',NULL,'東京'),('C0004','佐藤','080','福岡');
INSERT INTO 商品 VALUES ('P0001','A',100),('P0002','B',300),('P0003','C',500);
INSERT INTO 注文 VALUES ('O00001','C0001','2026-01-01','N'),('O00002','C0001','2026-01-02','C'),('O00003','C0002','2026-01-03','N');
INSERT INTO 明細 VALUES ('O00001',1,'P0001',2),('O00001',2,'P0002',1),('O00002',1,'P0003',1),('O00003',1,'P0001',5);
INSERT INTO 出荷 VALUES ('O00001',1,'2026-01-05'),('O00003',1,'2026-01-06');
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
    if 'DROP COLUMN 電話番号2' in b:
        con.execute('ALTER TABLE 顧客 ADD 電話番号2 VARCHAR(15)')  # 直前の例の続き
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
