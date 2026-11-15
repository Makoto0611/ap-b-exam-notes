#!/usr/bin/env python3
"""ハンズオン用の小さなSQL実行ツール（標準ライブラリのsqlite3だけで動く）

使い方:
  python3 sql.py reset                 # 01_setup.sql でDBを作り直す（毎回まっさらに戻せる）
  python3 sql.py "SELECT * FROM 従業員"  # SQLを1つ実行して結果を表で表示
  python3 sql.py -f my.sql             # ファイルのSQLをまとめて実行
  python3 sql.py tables                # 表の一覧と行数
  python3 sql.py schema 契約            # 表の定義を表示
  python3 sql.py repl                  # 対話モード（空行で実行、quitで終了）
"""
import os
import sqlite3
import sys
import unicodedata

HERE = os.path.dirname(os.path.abspath(__file__))
DB = os.path.join(HERE, "handson.db")
SETUP = os.path.join(HERE, "01_setup.sql")


def width(s):
    """全角を2桁として数える（表をそろえるため）"""
    return sum(2 if unicodedata.east_asian_width(c) in "WF" else 1 for c in s)


def pad(s, w):
    return s + " " * (w - width(s))


def show(cur):
    if cur.description is None:
        return
    cols = [d[0] for d in cur.description]
    rows = [["NULL" if v is None else str(v) for v in r] for r in cur.fetchall()]
    ws = [max([width(c)] + [width(r[i]) for r in rows]) for i, c in enumerate(cols)]
    print(" | ".join(pad(c, ws[i]) for i, c in enumerate(cols)))
    print("-+-".join("-" * w for w in ws))
    for r in rows:
        print(" | ".join(pad(v, ws[i]) for i, v in enumerate(r)))
    print(f"({len(rows)} 行)")


def connect():
    con = sqlite3.connect(DB, isolation_level=None)  # 自動コミット（BEGIN/ROLLBACKも手動で試せる）
    con.execute("PRAGMA foreign_keys = ON")
    return con


def run_script(con, text):
    """複数文を順に実行し、SELECTの結果は表示する"""
    buf = ""
    if not text.rstrip().endswith(";"):
        text = text.rstrip() + ";"
    for line in text.splitlines():
        if line.strip().startswith("--"):
            continue
        buf += line + "\n"
        if sqlite3.complete_statement(buf):
            stmt = buf.strip()
            buf = ""
            if not stmt:
                continue
            try:
                cur = con.execute(stmt)
                if cur.description:
                    show(cur)
                else:
                    print(f"OK ({cur.rowcount} 行に作用)" if cur.rowcount >= 0 else "OK")
            except sqlite3.Error as e:
                print(f"エラー: {e}")


def main():
    args = sys.argv[1:]
    if not args:
        print(__doc__)
        return
    cmd = args[0]
    if cmd == "reset":
        if os.path.exists(DB):
            os.remove(DB)
        con = connect()
        with open(SETUP, encoding="utf-8") as f:
            con.executescript(f.read())
        con.commit()
        print("DBを作り直しました。tables で確認できます。")
    elif cmd == "tables":
        con = connect()
        for (name,) in con.execute(
            "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name"
        ).fetchall():
            n = con.execute(f'SELECT COUNT(*) FROM "{name}"').fetchone()[0]
            print(f"{name}: {n} 行")
    elif cmd == "schema":
        con = connect()
        for (sql,) in con.execute(
            "SELECT sql FROM sqlite_master WHERE name=?", (args[1],)
        ).fetchall():
            print(sql)
    elif cmd == "-f":
        run_script(connect(), open(args[1], encoding="utf-8").read())
    elif cmd == "repl":
        con = connect()
        print("SQLを入力。空行で実行、quitで終了。")
        buf = []
        while True:
            try:
                line = input("sql> " if not buf else "...> ")
            except EOFError:
                break
            if line.strip().lower() == "quit":
                break
            if line.strip() == "" and buf:
                run_script(con, "\n".join(buf))
                buf = []
            elif line.strip():
                buf.append(line)
    else:
        run_script(connect(), " ".join(args))


if __name__ == "__main__":
    main()
