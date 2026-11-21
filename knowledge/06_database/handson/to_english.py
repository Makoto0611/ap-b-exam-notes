#!/usr/bin/env python3
"""06_database の教材にある SQL の表名・列名・値を、英語表記に置き換える（使い捨てのツール）

使い方（knowledge/06_database/handson で実行）:
  python3 to_english.py --check   # 置き換えずに、対応表にない日本語の語を一覧する
  python3 to_english.py --apply   # 置き換える（git diff で差分を確認できる）

置き換える場所:
  - .sql ファイル（-- コメントは除く）と、test_01.py / sql.py
  - .md の ```（コードブロック）の中と、`インラインコード` の中
  - .md の「期待:」のあとの値（例: 期待: 鈴木 2）
  説明の文章（コードの外）は、日本語のまま残す。
置き換えは「語が対応表に一致したとき」だけ。対応表にない語は、そのまま残り、--check で一覧に出る。
"""
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)  # knowledge/06_database
MARK = "名前の対応表（日本語→英語）"

# ---- 対応表（語が完全に一致したときだけ置き換える）----
MAP = {
    # 表
    "課": "dept", "社員": "employee", "備品": "equipment", "貸出": "loan",
    "注文": "orders", "注文明細": "order_item", "顧客": "customer", "商品": "product",
    "明細": "order_detail", "出荷": "shipment", "組織": "organization",
    "商品在庫": "product_stock", "受付": "reception", "返品": "return_item",
    "会議室": "room", "利用者": "room_user", "予約": "reservation",
    "会員": "member", "ポイント履歴": "point_history", "従業員": "staff",
    "契約": "contract", "顧客名簿": "customer_list", "貸出中": "on_loan",
    "例1": "ex1", "例1b": "ex1b", "例2": "ex2", "例2b": "ex2b", "例3": "ex3",
    "例4": "ex4", "例5": "ex5", "例6": "ex6", "例7": "ex7",
    "注文_顧客": "orders_customer_idx",
    # 列
    "課ID": "dept_id", "課名": "dept_name", "社員ID": "employee_id", "氏名": "name",
    "備品ID": "equipment_id", "備品名": "equipment_name", "区分": "category",
    "状態": "status", "貸出ID": "loan_id", "貸出日": "loan_date", "返却日": "return_date",
    "備考": "note", "顧客ID": "customer_id", "顧客名": "customer_name", "地域": "region",
    "商品ID": "product_id", "商品名": "product_name", "単価": "unit_price",
    "注文番号": "order_no", "注文日": "order_date", "行番号": "line_no", "数量": "quantity",
    "注文ID": "order_id", "明細番号": "detail_no", "出荷日": "ship_date",
    "電話番号": "phone", "電話番号2": "phone2", "室ID": "room_id", "室名": "room_name",
    "定員": "capacity", "利用者ID": "user_id", "予約日": "reserve_date", "時間帯": "time_slot",
    "会員ID": "member_id", "ポイント": "points", "履歴ID": "history_id", "増減": "delta",
    "日付": "event_date", "部署ID": "dept_id", "上位部署ID": "parent_dept_id",
    "倉庫コード": "warehouse_code", "在庫数": "stock_qty", "受付ID": "reception_id",
    "受付日時": "received_at", "返品ID": "return_id", "メールアドレス": "email",
    # 別名
    "合計": "total", "件数": "cnt", "人数": "headcount", "状況": "status_label",
    "電話": "phone_label", "順位": "rank_no", "月": "month", "ランク": "rank_label",
    "残高": "balance", "履歴合計": "history_total",
    # 値
    "山田": "yamada", "鈴木": "suzuki", "山本": "yamamoto", "佐藤": "sato",
    "東京": "tokyo", "大阪": "osaka", "福岡": "fukuoka", "新規": "new", "処理済": "done",
    "未登録": "unregistered", "在庫": "in_stock", "周辺": "peripheral", "山": "yama",
    "ゴールド": "gold", "シルバー": "silver", "ブロンズ": "bronze", "マウス": "mouse",
    "総務": "general_affairs", "開発": "development", "営業": "sales", "経理": "accounting",
    "仕入": "purchasing", "営業課": "sales_dept", "経理課": "accounting_dept",
    "仕入課": "purchasing_dept", "総務課": "general_affairs_dept", "会員システム": "member_system",
    # 01_setup.sql（研修管理・部署・端末契約）
    "部署": "department", "部署名": "department_name", "従業員ID": "staff_id", "給与": "salary",
    "通信事業者": "carrier", "事業者ID": "carrier_id", "事業者名": "carrier_name",
    "暗証番号": "pin", "契約ID": "contract_id", "講座": "course", "講座コード": "course_code",
    "講座名": "course_name", "開催": "session", "開催番号": "session_no", "開催日": "session_date",
    "受講": "enrollment", "結果": "result",
    "本社": "head_office", "営業部": "sales_division", "開発部": "dev_division",
    "営業一課": "sales_section1", "総務部": "ga_division", "高橋": "takahashi", "田中": "tanaka",
    "伊藤": "ito", "A通信": "carrier_a", "B通信": "carrier_b",
    "セキュリティ基礎": "security_basics", "プロジェクト管理": "project_mgmt",
    "SQL入門": "sql_intro", "合格": "pass", "不合格": "fail",
}

TOKEN = re.compile(r"[A-Za-z0-9_]*[ぁ-んァ-ヶー一-龥々][ぁ-んァ-ヶー一-龥々A-Za-z0-9_]*")
PURE_JP = re.compile(r"[ぁ-んァ-ヶー一-龥々]+")
SQL_WORDS = re.compile(r"\b(CREATE|INSERT|SELECT|DROP|ALTER|UPDATE|DELETE|FROM|WHERE|GRANT)\b")


class Stat:
    def __init__(self):
        self.old = {}       # すでに対応表にある行
        self.used = {}      # 日本語 -> 英語（出てきた順）
        self.unmapped = {}  # 日本語 -> 出てきた場所

    def use(self, jp):
        self.used.setdefault(jp, MAP[jp])

    def miss(self, jp, where):
        self.unmapped.setdefault(jp, where)


def conv(text, stat, where, report=True, pattern=TOKEN):
    def sub(m):
        t = m.group(0)
        if t in MAP:
            stat.use(t)
            return MAP[t]
        if report:
            stat.miss(t, where)
        return t
    return pattern.sub(sub, text)


def split_comment(line):
    """行を（コード部分, コメント部分）に分ける。引用符の中の -- は無視する"""
    inq = False
    i = 0
    while i < len(line):
        c = line[i]
        if c == "'":
            inq = not inq
        elif not inq and line.startswith("--", i):
            return line[:i], line[i:]
        i += 1
    return line, ""


def conv_code_line(line, stat, where, report=True):
    code, cmt = split_comment(line)
    return conv(code, stat, where, report) + cmt


def process_sql(text, stat, where):
    out = []
    for line in text.split("\n"):
        out.append(conv_code_line(line, stat, where))
    return "\n".join(out)


def process_py(text, stat, where):
    out = []
    for line in text.split("\n"):
        if line.lstrip().startswith("#"):
            out.append(line)
            continue
        report = bool(SQL_WORDS.search(line))
        out.append(conv(line, stat, where, report))
    return "\n".join(out)


EXPECT = re.compile(r"(期待[:：])([^）)\n]*)")


def strip_tables(lines):
    """すでに入っている対応表を取り除き、行（日本語→英語）を節ごとに集める"""
    out = []
    old = [{}]
    i = 0
    while i < len(lines):
        ln = lines[i]
        if ln.startswith("# 総合"):
            old.append({})
        if ln in ("### " + MARK, "## " + MARK):
            while out and out[-1] == "":
                out.pop()
            i += 1
            seen = False
            while i < len(lines):
                row = lines[i]
                if row.startswith("|"):
                    seen = True
                    m = re.match(r"\| (.+?) \| `(.+?)` \|$", row)
                    if m:
                        old[-1][m.group(1)] = m.group(2)
                    i += 1
                    continue
                if seen:
                    break
                i += 1
            while i < len(lines) and lines[i] == "":
                i += 1
            continue
        out.append(ln)
        i += 1
    return out, old


def process_md(text, stat_for_section, path):
    """見出し '# 総合' ごとに Stat を切り替える。既存の対応表は取り除いて、あとで統合して作り直す"""
    lines, old = strip_tables(text.split("\n"))
    out = []
    sections = []          # (見出しの出力位置, Stat)
    cur = Stat()
    cur.old = old[0]
    sections.append((None, cur))
    in_fence = False
    for line in lines:
        if line.startswith("# 総合"):
            cur = Stat()
            cur.old = old[len(sections)] if len(sections) < len(old) else {}
            sections.append((len(out), cur))
            out.append(line)
            continue
        if line.startswith("```"):
            in_fence = not in_fence
            out.append(line)
            continue
        if in_fence:
            out.append(conv_code_line(line, cur, os.path.basename(path) + " (code)"))
            continue
        # コードの外
        def inline(m):
            return "`" + conv(m.group(1), cur, os.path.basename(path) + " (inline)", report=False) + "`"
        new = re.sub(r"`([^`\n]+)`", inline, line)
        new = EXPECT.sub(lambda m: m.group(1) + conv(m.group(2), cur, os.path.basename(path) + " (期待)", True, PURE_JP), new)
        out.append(new)
    return out, sections


def table(used):
    rows = ["| 日本語 | 英語 |", "| --- | --- |"]
    for jp, en in used.items():
        rows.append(f"| {jp} | `{en}` |")
    return rows


def finish_md(out, sections, path):
    base = os.path.basename(path)
    # 見出し '# 総合' ごとに表を差し込む（後ろから）
    if base == "06_integrated.md":
        for pos, st in reversed([s for s in sections if s[0] is not None]):
            merged = dict(st.old)
            merged.update(st.used)
            if merged:
                block = ["", f"### {MARK}", ""] + table(merged) + [""]
                out[pos + 1:pos + 1] = block
    else:
        total = {}
        for _, st in sections:
            total.update(st.old)
            total.update(st.used)
        if total:
            while out and out[-1] == "":
                out.pop()
            out.extend(["", f"## {MARK}", "",
                        "SQLの例の表名・列名・値は、英語で書いてある。日本語との対応は次のとおり。", ""] + table(total) + [""])
    return "\n".join(out)


def targets():
    res = []
    for dp, dn, fn in os.walk(ROOT):
        dn[:] = [d for d in dn if d != ".git"]
        for f in fn:
            p = os.path.join(dp, f)
            if f == "to_english.py" or f.endswith(".db"):
                continue
            if f.endswith((".md", ".sql", ".py")):
                res.append(p)
    return sorted(res)


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else ""
    if mode not in ("--check", "--apply"):
        print(__doc__)
        return
    unmapped = {}
    changed = 0
    for p in targets():
        raw = open(p, encoding="utf-8", newline="").read()
        crlf = "\r\n" in raw
        text = raw.replace("\r\n", "\n")
        st = Stat()
        if p.endswith(".sql"):
            new = process_sql(text, st, os.path.basename(p))
        elif p.endswith(".py"):
            new = process_py(text, st, os.path.basename(p))
        else:
            out, sections = process_md(text, None, p)
            for _, s in sections:
                for k, v in s.unmapped.items():
                    st.miss(k, v)
            new = finish_md(out, sections, p)
        for k, v in st.unmapped.items():
            unmapped.setdefault(k, v)
        if new != text:
            changed += 1
            if mode == "--apply":
                with open(p, "w", encoding="utf-8", newline="") as f:
                    f.write(new.replace("\n", "\r\n") if crlf else new)
            print(("置換 " if mode == "--apply" else "対象 ") + os.path.relpath(p, ROOT))
    print(f"\n{changed} ファイル")
    print("\n対応表にない日本語の語（コードの中）:")
    for k, v in sorted(unmapped.items(), key=lambda kv: (kv[1], kv[0])):
        print(f"  {k}\t{v}")
    if mode == "--apply":
        print("\n--- 動作確認 ---")
        for cmd in (["python3", "sql.py", "reset"], ["python3", "test_01.py"]):
            r = subprocess.run(cmd, cwd=HERE, capture_output=True, text=True)
            print(" ".join(cmd), "->", r.stdout.strip().splitlines()[-1] if r.stdout.strip() else r.stderr.strip()[-200:])
        r = subprocess.run(["python3", "sql.py", "-f", "06_answers.sql"], cwd=HERE, capture_output=True, text=True)
        errs = [l for l in r.stdout.splitlines() if l.startswith("エラー")]
        print("python3 sql.py -f 06_answers.sql -> エラー", len(errs), "件")
        for e in errs[:10]:
            print("   ", e)


if __name__ == "__main__":
    main()
