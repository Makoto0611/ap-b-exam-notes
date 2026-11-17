# 午後（科目B）過去の出題テーマ一覧

IPAの採点講評から、問1・問6・問7・問8・問10の出題テーマと、講評の「低い／やや低い」の設問をまとめる。問9は `09_pm.md`。
過去問の本文は転記しない。

## 共通の注意
- 取得日: 2026-11-15。対象は令7秋〜平21春の33回（令2春は中止、平23は特別試験を含む）。平21春〜平26秋は問題番号が現在と違う（平21〜25は 問9=セキュリティ、問6=DB、問7=組込み、問8=開発、問10=PM、問11=サービス。平26は 問1=セキュリティ、問9=PM、問10=サービス。平25秋だけはDB=問5、組込み=問6、開発=問7、セキュリティ=問8、PM=問9、サービス=問10）が、分野は同じなので、表に「（当時問N）」と書いて入れた
- 2026-11-15に、講評PDFの原文のテキストと、問1・6・7・8・9・10の評価と設問番号を突き合わせた（令4春はPDFを直接確認）。「知識の種類（用語・計算・読解）」は講評からの推定を含む
- 表の「評価未記録」「評価語なし」は、講評にその設問への言及はあるが、高い／低いなどの評価語がなく、誤答の傾向だけが書かれているもの（原文に評価語がないので、評価は付けていない）
- 平21春〜平26秋の講評は「正答率が高かった／低かった」という書き方。表では「高い／低い」にそろえた。平21春〜平22秋のPDFは日本語フォントが埋め込まれておらず、docx版から原文を取り出した
- 平27春〜平31春の全体評価は、講評に書かれているものだけを記録している。原本のPDFは、作者のGoogle Driveに保管している（公開リポジトリには置かない）
- 講評の「高い／低い」は受験者全体の傾向で、設問ごとの数値は公表されていない
- 令3秋の問2は、データベースではなくデジタルマーケティング。データベースは問6（電子書籍サービス）
- IPAの講評は、各問の全設問を評価していない。講評に書かれた設問は、各問で数設問にとどまる（講評に載らない設問は「記載なし」）
- 令元秋の講評は「高い／低い」の2段階で、各問の全体評価の記載がない
- 全体評価の一覧は 00_overall_ratings.md
- 問8の題材は年度ごとに大きく変わる（画面設計、クラス設計、スレッド、Git、レビューなど）

## ファイル
各問の知識メモは `../knowledge/<問番号>_<分野>/`（問1=01_security、問6=06_database、問7=07_embedded、問8=08_development、問9=09_pm、問10=10_service）。フォルダ内のファイルは、01から順に通し番号を付けている（正答率が低かったテーマのファイルは各フォルダの末尾）。

- 01_security.md（問1 情報セキュリティ）
- 06_database.md（問6 データベース）
- 07_embedded.md（問7 組込みシステム開発）
- 08_development.md（問8 情報システム開発）
- 09_pm.md（問9 プロジェクトマネジメント。知識メモは `../knowledge/09_pm/`）
- 10_service.md（問10 サービスマネジメント）

## 正答率が低かったテーマの詳しい解説と確認問題（選択式）
平21春〜平30秋の講評で「正答率が低かった」とされたテーマは、各分野の次のファイルに、詳しい解説と選択式の確認問題をまとめた。見出しの末尾の「（低い）」は、IPA講評で正答率が低いとされたことを示す。
- `../knowledge/01_security/02_low_accuracy_themes.md`
- `../knowledge/06_database/04_low_accuracy_themes.md`
- `../knowledge/07_embedded/02_low_accuracy_themes.md`
- `../knowledge/08_development/02_low_accuracy_themes.md`
- `../knowledge/09_pm/09_low_accuracy_themes.md`
- `../knowledge/10_service/02_low_accuracy_themes.md`

## 全分野に共通する失点の型（講評の「低い」から）
1. 本文・表・図の条件を読み落とす（小数点の桁、設問が指定した観点、本文にない項目の解答）
2. 設問が問う種類を取り違える（原因と結果、目的と手段、事実と欠陥）
3. 用語の基本を知らない（暗記で取れる設問が、毎回「低い」に入る）
4. 単位変換や計算の前提の見落とし（時間、周波数、台数）

## 取得元（IPA 採点講評PDF）
- 令7秋: https://www.ipa.go.jp/shiken/mondai-kaiotu/nl10bi0000009lh8-att/2025r07a_ap_pm_cmnt.pdf
- 令7春: https://www.ipa.go.jp/shiken/mondai-kaiotu/nl10bi0000009lh8-att/2025r07h_ap_pm_cmnt.pdf
- 令6秋: https://www.ipa.go.jp/shiken/mondai-kaiotu/m42obm000000afqx-att/2024r06a_ap_pm_cmnt.pdf
- 令6春: https://www.ipa.go.jp/shiken/mondai-kaiotu/m42obm000000afqx-att/2024r06h_ap_pm_cmnt.pdf
- 令5秋: https://www.ipa.go.jp/shiken/mondai-kaiotu/ps6vr70000010d6y-att/2023r05a_ap_pm_cmnt.pdf
- 令5春: https://www.ipa.go.jp/shiken/mondai-kaiotu/ps6vr70000010d6y-att/2023r05h_ap_pm_cmnt.pdf
- 令4秋: https://www.ipa.go.jp/shiken/mondai-kaiotu/gmcbt80000008smf-att/2022r04a_ap_pm_cmnt.pdf
- 令4春: https://www.ipa.go.jp/shiken/mondai-kaiotu/gmcbt80000009sgk-att/2022r04h_ap_pm_cmnt.pdf
- 令3秋: https://www.ipa.go.jp/shiken/mondai-kaiotu/gmcbt8000000apad-att/2021r03a_ap_pm_cmnt.pdf
- 令3春: https://www.ipa.go.jp/shiken/mondai-kaiotu/gmcbt8000000d5ru-att/2021r03h_ap_pm_cmnt.pdf
- 令2秋: https://www.ipa.go.jp/shiken/mondai-kaiotu/gmcbt8000000d05l-att/2020r02o_ap_pm_cmnt.pdf
- 令元秋: https://www.ipa.go.jp/shiken/mondai-kaiotu/gmcbt8000000dict-att/2019r01a_ap_pm_cmnt.pdf
- 平31春: https://www.ipa.go.jp/shiken/mondai-kaiotu/gmcbt8000000ddiw-att/2019h31h_ap_pm_cmnt.pdf
