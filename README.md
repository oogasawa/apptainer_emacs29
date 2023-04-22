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
git clone --depth 1 https://github.com/doomemacs/doomemacs your_doom_dir
```

2, Apptainerコンテナイメージ呼び出し用のシェルスクリプトをパスの通った場所に設置する。

以下は一例

```
chmod +x apptainer_emacs20/emacs
cp apptainer_emacs29/emacs $HOME/local/bin
export PATH=$HOME/local/bin:$PATH
```

- `apptainer_emacs20/emacs`は`emacs29.sif`がホームディレクトリ直下に置かれていると仮定している。そうなっていない場合は適切に書き換える。


3, doom install, doom syncを実行する。

```
your_doom_dir/bin/doom install
your_doom_dir/bin/doom sync
```

4, emacsを起動する。

```
emacs
```


## 使用方法 (3) lsp-javaで最新のJDKを使用する

### 作業概要

まず、一度なにか`*.java`ファイルをemacsで開いて、jdtlsをdoom emacsにインストールさせる。

その後、以下の手順を行うことでlsp-javaで最新のJDKが使えるようになる。

1. lsp-java.elを編集する。
2. lsp-java.elcは削除する。
3. 古いjdt language server (jdtls)を削除する。
4. emacsを再起動して、なにか`*.java`ファイルを開き、doom emacsにjdtlsを再インストールさせる。

### Eclipse の LSP server は最新のJDKに対応しているか？

このサイトを見ると Eclipse は 2023 年 3 月に Java 20 に対応していることがわかる。

- https://marketplace.eclipse.org/content/java-20-support-eclipse-2023-03-427

### Eclipse の LSP server はどこからダウンロードできるか?

https://github.com/eclipse/eclipse.jdt.ls/ にダウンロード元が以下のように書いてある。

- Download and extract a milestone build from http://download.eclipse.org/jdtls/milestones/
- Download and extract a snapshot build from http://download.eclipse.org/jdtls/snapshots/

### lsp-java はどのファイルをダウンロードしているのか？

lsp-java の github リポジトリ ( https://github.com/emacs-lsp/lsp-java/blob/master/lsp-java.el )を見ると、 2023.04.22 時点では以下のように書いてあった。

```
(defcustom lsp-java-jdt-download-url "https://download.eclipse.org/jdtls/milestones/1.12.0/jdt-language-server-1.12.0-202206011637.tar.gz"
  "JDT JS download url.
Use http://download.eclipse.org/che/che-ls-jdt/snapshots/che-jdt-language-server-latest.tar.gz if you want to use Eclipse Che JDT LS."
  :group 'lsp-java
  :type 'string)
```

### lsp-java.elの編集

まず、`lsp-java.el`を探す。

以下は一例。

```
$ find your_doom_dir -name "lsp-java.el"
/home/you/your_doom_dir/.local/straight/repos/lsp-java/lsp-java.el
/home/you/your_doom_dir/.local/straight/build-29.0.90/lsp-java/lsp-java.el
/home/you/your_doom_dir/.local/straight/build-27.1/lsp-java/lsp-java.el
/home/you/your_doom_dir/.local/straight/build-28.2/lsp-java/lsp-java.el
```

例のようにいくつか見つかるので、`build-29.0.90`ディレクトリの下の`lsp-java.el`の上記該当部分を例えば以下のように編集する。（ダウンロード元は上記サイトを参考にする。）

```
(defcustom lsp-java-jdt-download-url "https://download.eclipse.org/jdtls/milestones/1.22.0/jdt-language-server-1.22.0-202304131553.tar.gz"
   "JDT JS download url.
 Use http://download.eclipse.org/che/che-ls-jdt/snapshots/che-jdt-language-server-latest.tar.gz if you want to use Eclipse Che JDT LS."
   :group 'lsp-java
   :type 'string)
```

### lsp-java.elcの削除

まず、すでにできている`lsp-java.elc`を探す。

以下は一例。

```
$ find ~/.emacs.d -name "lsp-java.elc"
/home/you/your_doom_dir/.local/straight/build-29.0.90/lsp-java/lsp-java.elc
/home/you/your_doom_dir/.local/straight/build-27.1/lsp-java/lsp-java.elc          
```

例のようにいくつか見つかるので、`build-29.0.90`ディレクトリの下の`lsp-java.elc`を削除する。

### 古いjdt language server (jdtls)を削除する。

以下は一例。

```
rm -Rf /home/you/your_doom_dir/.local/etc/java-workspace
rm -Rf /home/you/your_doom_dir/.local/etc/lsp
```

### emacsを再起動して、なにか`*.java`ファイルを開き、doom emacsにjdtlsを再インストールさせる。

普通にemacsを起動する。（doom emacsが起動する。)

```
emacs
```

なにか`*.java`ファイルを開き、doom emacsにjdtlsを再インストールさせる。これで問題なく編集できるようになる。

### Troubleshooting

これでエラーが出る際のはディレクトリ名がコンテナの内部と外部とで合っていないのが原因。
冒頭のApptainerイメージファイルを作る際に、`emacs29.def`中のユーザアカウント名を自分のアカウントに編集するところを確認すること。

