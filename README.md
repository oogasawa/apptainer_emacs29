# apptainer_emacs29

## 動機

既存の開発環境になるべく影響を与えずにdoom emacs + lsp-javaで開発できる環境を作りたい。

1. doom emacsは`~/.emacs.d`ディレクトリの構成にどうしても影響を与えてしまうが、
Emacs29からは`--init-directory`オプションが新設されたので、これを使えばdoom emacsを標準のディレクトリ構成とは異なる構成で起動できるため、
Emacs29を使えば開発環境にほとんど影響を与えない。
2. 遺伝研スパコンはCentOS 7で動作しておりEmacs29をインストールする作業がそもそも面倒である。
3. lsp-javaで最新のJDK (現在だとJDK20)を使いたい。

以上の状況を解決するためにUbuntu Linux 22.04にEmacs29をインストールしたApptainerコンテナイメージを作成した。

## 使用方法

1, ルート権限を持ったLinux環境上でApptainerコンテナイメージを作成する。

```
git clone https://github.com/oogasawa/apptainer_emacs29
cd apptainer_emacs29

# => emacs29.def中のユーザアカウント名を自分のアカウントに編集した後以下を実行する。

sudo apptainer build emacs29.sif emacs29.def
```

2, 目的の環境(遺伝研スパコンなど）にdoom emacsをインストールする。

```
```

