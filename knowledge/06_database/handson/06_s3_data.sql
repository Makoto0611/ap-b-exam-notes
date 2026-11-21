-- 総合3 会議室予約: データ（表を作ってから実行する）
INSERT INTO room VALUES ('R01','大会議室',20), ('R02','小会議室',6), ('R03','面談室',2);
INSERT INTO room_user VALUES ('U01','sato'), ('U02','suzuki'), ('U03','takahashi');
INSERT INTO reservation VALUES
  ('R01','2026-11-16','A','U01'),
  ('R01','2026-11-16','B','U02'),
  ('R02','2026-11-16','A','U01'),
  ('R02','2026-11-17','A','U03'),
  ('R01','2026-11-17','B','U01');
