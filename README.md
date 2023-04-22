# apptainer_emacs29

## 動機

既存の開発環境になるべく影響を与えずにdoom emacs + lsp-javaで開発できる環境を作りたい。

1. doom emacsは`~/.emacs.d`ディレクトリの構成にどうしても影響を与えてしまうが、
Emacs29からは`--init-directory`オプションが新設されたので、これを使えばdoom emacsを標準のディレクトリ構成とは異なる構成で起動できるため、
Emacs29を使えば開発環境にほとんど影響を与えない。
2. 遺伝研スパコンはCentOS 7で動作しておりEmacs29をインストールする作業がそもそも面倒である。
3. lsp-javaで最新のJDK (現在だとJDK20)を使いたい。

以上の状況を解決するためにUbuntu Linux 22.04にEmacs29をインストールしたApptainerコンテナイメージを作成した。

## 使用方法　(1) 単純にEmacs29を動作させる。

1, ルート権限を持ったLinux環境上でApptainerコンテナイメージを作成する。

```
git clone https://github.com/oogasawa/apptainer_emacs29
cd apptainer_emacs29

# => emacs29.def中のユーザアカウント名を自分のアカウントに編集した後以下を実行する。

sudo apptainer build emacs29.sif emacs29.def
```

2, Apptainerコンテナイメージ`emacs29.sif`を対象の環境にscpする。

```
scp emacs29.sif you@your.environment.com:/home/you
```

3, Apptainerコンテナイメージを起動する。

```
apptainer exec emacs29.sif emacs your_file
```

これでEmacs 29が起動する。


## 使用方法 (2) Doom Emacs

上記に加えて、対象の環境で以下の作業を行う。

1, 目的の環境(遺伝研スパコンなど）にdoom emacsをインストールする。

doom emacsの公式githubリポジトリの説明通りdoom emacsをクローンする。ただし、好きなディレクトリ名でクローンすれば良い。

```
git clone --depth 1 https://github.com/doomemacs/doomemacs your_favorite_dir
```

2, doom install, doom syncを実行する。

実行する前にシェルで`emacs`とコマンドを打つとapptainerイメージ内のemacsが起動するようにする。
以下では、`emacs29.sif`は`$HOME`に置かれている。

```
cd apptainer_emacs29
chown +x emacs
export PATH=$HOME/apptainer_emacs29:$PATH
```


## 使用方法 (3) lsp-javaで最新のJDKを使用する



your_favorite_dir/bin/doom install
```

