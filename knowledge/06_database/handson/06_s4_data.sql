-- 総合4 ポイント管理: データ（表を作ってから実行する）
INSERT INTO member VALUES ('M001','sato',300), ('M002','suzuki',160), ('M003','takahashi',0);
INSERT INTO point_history VALUES
  (1,'M001',500,'2026-09-01'),
  (2,'M001',-200,'2026-09-15'),
  (3,'M002',150,'2026-10-01');
