## Getting Started

ローカルでアプリケーションを起動するまでの手順を示す。

---

リポジトリをクローンします。

```
git clone
```

ローカル環境にデータベースとテーブルを作成します。PostgreSQL がインストールされている必要があります（バージョン 18 で動作確認済み）

```
psql -d postgres -f create_database.sql
```

```
psql -d memo_app -f create_table.sql
```

gem をインストールします。

```
bundle install
```

アプリケーションを起動します。

```
bundle exec ruby memo_app.rb
```

http://localhost:4567/memos でアプケーションにアクセスできます。
