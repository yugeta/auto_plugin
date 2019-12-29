Auto Plugin
==

![title-banner](docs/banner.png)

```
Author : Yugeta.Koji
Date   : 2019.12.27
```

# Summary
各種ライブラリをgithubなどのリポジトリから自動取得する。
また、アップデートの確認を即座に行う。


# Specification
- json

- csv

- Github | other Repository


# Setting-file

- json
[
  {
    "name" : "ライブラリ名（plugin/***/の文字列）",
    "git"  : "gitリポジトリのアドレス(url)"
  }
]

- csv
%name,$git-repository



# Howto
- ライブラリを自動ダウンロード、自動更新
$ sh auto.sh -m auto -f sample/sample.json -d data

- ライブラリの存在確認とアップデート確認
$ sh auto.sh -m check -f sample/sample.json -d data


[argv]
-m : モード [ (default) auto (自動データ処理) , check (確認のみ) ]
-f : 設定ファイルパス
-d : 出力先ディレクトリ (ddefault:data)


