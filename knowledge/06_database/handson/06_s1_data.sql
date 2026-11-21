-- 総合1 備品貸出管理: データ（表を作ってから実行する）
INSERT INTO dept VALUES ('K01','general_affairs'), ('K02','development'), ('K03','sales');
INSERT INTO employee VALUES ('E001','sato','K01'), ('E002','suzuki','K02'), ('E003','takahashi','K02'), ('E004','tanaka','K02');
INSERT INTO equipment (equipment_id, equipment_name, category, status) VALUES
  ('P0001','laptop-A','PC','loan'),
  ('P0002','laptop-B','PC','in_stock'),
  ('P0003','monitor','peripheral','loan'),
  ('P0004','keyboard','peripheral','in_stock'),
  ('P0005','mouse','peripheral','in_stock');
INSERT INTO loan VALUES
  (1,'P0001','E002','2026-10-01',NULL),
  (2,'P0003','E002','2026-10-05',NULL),
  (3,'P0002','E003','2026-09-20','2026-09-30'),
  (4,'P0004','E004','2026-10-10','2026-10-12'),
  (5,'P0001','E003','2026-08-01','2026-08-31');
