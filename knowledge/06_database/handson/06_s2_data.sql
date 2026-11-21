-- 総合2 注文管理: データ（表を作ってから実行する）
INSERT INTO customer VALUES ('C0001','yamada','tokyo'), ('C0002','sasaki','osaka'), ('C0003','ito','tokyo');
INSERT INTO product VALUES ('G001','pen',100), ('G002','notebook',200), ('G003','bag',3000);
INSERT INTO orders VALUES (1,'C0001','2026-10-03'), (2,'C0001','2026-11-02'), (3,'C0002','2026-11-05');
INSERT INTO order_item VALUES
  (1,1,'G001',10), (1,2,'G002',5),
  (2,1,'G003',1),
  (3,1,'G001',20), (3,2,'G003',2);
