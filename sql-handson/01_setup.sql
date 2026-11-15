-- ============================================================
-- B科目 問6 ハンズオン用データ（SQLite）
-- 題材: 研修管理 + 部署 + 端末契約（過去問の型を再現した自作データ）
-- 実行: python3 sql.py reset
-- ============================================================
PRAGMA foreign_keys = ON;   -- SQLiteは既定でFKが無効。これを忘れるとON DELETE CASCADEも効かない

DROP TABLE IF EXISTS 受講;
DROP TABLE IF EXISTS 開催;
DROP TABLE IF EXISTS 講座;
DROP TABLE IF EXISTS 契約;
DROP TABLE IF EXISTS 通信事業者;
DROP TABLE IF EXISTS 従業員;
DROP TABLE IF EXISTS 部署;

-- ---- 部署（自己参照: 上位部署ID → 部署ID） ----
CREATE TABLE 部署 (
    部署ID      CHAR(3)     NOT NULL,
    部署名      VARCHAR(20) NOT NULL,
    上位部署ID  CHAR(3),                       -- NULL許可（最上位はNULL）
    PRIMARY KEY (部署ID),
    FOREIGN KEY (上位部署ID) REFERENCES 部署 (部署ID)
);

-- ---- 従業員 ----
CREATE TABLE 従業員 (
    従業員ID  CHAR(5)     NOT NULL,
    氏名      VARCHAR(30) NOT NULL,
    部署ID    CHAR(3)     NOT NULL,
    給与      INTEGER     NOT NULL,
    PRIMARY KEY (従業員ID),
    FOREIGN KEY (部署ID) REFERENCES 部署 (部署ID)
);

-- ---- 通信事業者・契約（DEFAULT / 初期値 / 暗証番号の型） ----
CREATE TABLE 通信事業者 (
    事業者ID  CHAR(2)     NOT NULL,
    事業者名  VARCHAR(20) NOT NULL,
    PRIMARY KEY (事業者ID)
);

CREATE TABLE 契約 (
    契約ID    CHAR(6)  NOT NULL,
    従業員ID  CHAR(5)  NOT NULL,
    事業者ID  CHAR(2)  NOT NULL,
    暗証番号  CHAR(4)  DEFAULT '1234' NOT NULL,
    PRIMARY KEY (契約ID),
    FOREIGN KEY (従業員ID) REFERENCES 従業員 (従業員ID),
    FOREIGN KEY (事業者ID) REFERENCES 通信事業者 (事業者ID)
);

-- ---- 講座・開催・受講（複合主キー／ON DELETE CASCADE） ----
CREATE TABLE 講座 (
    講座コード  CHAR(3)     NOT NULL,
    講座名      VARCHAR(30) NOT NULL,
    PRIMARY KEY (講座コード)
);

CREATE TABLE 開催 (
    講座コード  CHAR(3) NOT NULL,
    開催番号    INTEGER NOT NULL,
    開催日      DATE    NOT NULL,
    PRIMARY KEY (講座コード, 開催番号),
    FOREIGN KEY (講座コード) REFERENCES 講座 (講座コード)
);

CREATE TABLE 受講 (
    従業員ID    CHAR(5) NOT NULL,
    講座コード  CHAR(3) NOT NULL,
    開催番号    INTEGER NOT NULL,
    結果        VARCHAR(4),                    -- 合格/不合格/NULL（未判定）
    PRIMARY KEY (従業員ID, 講座コード, 開催番号),
    FOREIGN KEY (従業員ID) REFERENCES 従業員 (従業員ID),
    FOREIGN KEY (講座コード, 開催番号) REFERENCES 開催 (講座コード, 開催番号)
        ON DELETE CASCADE
);

-- ============================ データ ============================
INSERT INTO 部署 VALUES ('D00', '本社',       NULL);
INSERT INTO 部署 VALUES ('D01', '営業部',     'D00');
INSERT INTO 部署 VALUES ('D02', '開発部',     'D00');
INSERT INTO 部署 VALUES ('D03', '営業一課',   'D01');
INSERT INTO 部署 VALUES ('D04', '総務部',     'D00');   -- 従業員がいない部署（外部結合の練習用）

INSERT INTO 従業員 VALUES ('E0001', '山田', 'D03', 320000);
INSERT INTO 従業員 VALUES ('E0002', '鈴木', 'D03', 280000);
INSERT INTO 従業員 VALUES ('E0003', '佐藤', 'D02', 410000);
INSERT INTO 従業員 VALUES ('E0004', '高橋', 'D02', 380000);
INSERT INTO 従業員 VALUES ('E0005', '田中', 'D02', 350000);
INSERT INTO 従業員 VALUES ('E0006', '伊藤', 'D01', 450000);

INSERT INTO 通信事業者 VALUES ('N1', 'A通信');
INSERT INTO 通信事業者 VALUES ('N2', 'B通信');

INSERT INTO 契約 (契約ID, 従業員ID, 事業者ID, 暗証番号) VALUES ('C00001', 'E0001', 'N1', '9876');
INSERT INTO 契約 (契約ID, 従業員ID, 事業者ID)           VALUES ('C00002', 'E0002', 'N1');   -- 暗証番号は初期値'1234'になる
INSERT INTO 契約 (契約ID, 従業員ID, 事業者ID)           VALUES ('C00003', 'E0003', 'N2');

INSERT INTO 講座 VALUES ('K01', 'セキュリティ基礎');
INSERT INTO 講座 VALUES ('K02', 'プロジェクト管理');
INSERT INTO 講座 VALUES ('K03', 'SQL入門');            -- まだ開催されていない講座

INSERT INTO 開催 VALUES ('K01', 1, '2026-04-10');
INSERT INTO 開催 VALUES ('K01', 2, '2026-10-09');
INSERT INTO 開催 VALUES ('K02', 1, '2026-05-15');

INSERT INTO 受講 VALUES ('E0001', 'K01', 1, '合格');
INSERT INTO 受講 VALUES ('E0002', 'K01', 1, '不合格');
INSERT INTO 受講 VALUES ('E0003', 'K01', 2, NULL);      -- 結果が未判定
INSERT INTO 受講 VALUES ('E0003', 'K02', 1, '合格');
INSERT INTO 受講 VALUES ('E0004', 'K02', 1, '合格');
INSERT INTO 受講 VALUES ('E0006', 'K01', 1, '合格');
