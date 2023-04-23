
# apptainer_emacs29

## Motivation

You want to create an environment where you can develop with doom emacs + lsp-java without affecting the existing development environment as much as possible.


1. Although doom emacs inevitably affects the `~/.emacs.d` directory structure, the `--init-directory` option was newly added to Emacs29, so doom emacs can be started with a different directory structure than the standard one. Therefore, Emacs29 will have little effect on the development environment.
2. The NIG supercomputer is running on CentOS 7, and installing Emacs29 is troublesome to begin with.
3. You want to use the latest JDK (currently JDK20) with lsp-java, but you can't (sometimes) use it if you follow the instructions on the official Doom Emacs website.

To solve the above situation, I created an Apptainer container image with Emacs29 installed on Ubuntu Linux 22.04.

## Usage (1) Simply run Emacs29.

1, Create Apptainer container image on Linux environment with root privileges.

```

git clone https://github.com/oogasawa/apptainer_emacs29
cd apptainer_emacs29
```

Edit the user account name to your account in the following part of `emacs29.def`.

It is assumed that JDK and maven are already installed in `$HOME/local/`. If not, install them properly and rewrite the relevant part of the `emacs29.def`. In Apptainer, the user's home directory is mounted on the container from the beginning and is visible from inside the container, so it is easy to install JDK and maven under the home directory. Otherwise, it is necessary to mount them appropriately at the time of starting Apptainer. (Please refer to the manual of Apptainer for how to do so.)

```bash
    mkdir /home/you

%environment
    export JAVA_HOME=/home/you/local/jdk-20.0.1
    export MAVEN_HOME=/home/you/local/apache-maven-3.8.6
    export PATH=$JAVA_HOME/bin:$MAVEN_HOME/bin:$PATH
```

Create the Apptainer container image (emacs29.sif) by executing the following

```
sudo apptainer build emacs29.sif emacs29.def
```

2, `scp` the Apptainer container image emacs29.sif to the target environment.

```bash
scp emacs29.sif you@your.environment.com:/home/you
```


3, Start Apptainer container image.

``` bash
apptainer exec emacs29.sif emacs your_file
```

Now Emacs 29 will start.

## Usage (2) Doom Emacs

In addition to the above, perform the following tasks in the target environment.

1, Install doom emacs in the target environment (such as the NIG supercomputer).

Clone doom emacs as described in the official github repository of doom emacs. However, you can clone it with any directory name you like.

``` bash
git clone --depth 1 https://github.com/doomemacs/doomemacs your_doom_dir
```

2, Place the shell script for calling Apptainer container image in the path.

The following is an example

``` bash
chmod +x apptainer_emacs20/emacs
cp apptainer_emacs29/emacs $HOME/local/bin
export PATH=$HOME/local/bin:$PATH
```

the `apptainer_emacs20/emacs` assumes that `emacs29.sif` is placed directly under the home directory. If not, rewrite it appropriately.

3, Execute doom install and doom sync.

``` bash
your_doom_dir/bin/doom install
your_doom_dir/bin/doom sync
```

4, Start emacs.

``` bash
emacs --init-directory your_doom_dir
```


## Usage (3) Using the latest JDK with lsp-java

### Outline of work

First, open some *.java file with emacs and let doom emacs install jdtls.

After that, you can use the latest JDK with lsp-java by following the steps below.

1. Edit lsp-java.el.
2. Delete lsp-java.elc.
3. Remove the old jdt language server (jdtls).
4. Restart emacs, open some *.java file, and let doom emacs reinstall jdtls.

### Does Eclipse's LSP server support the latest JDK?

This site shows that Eclipse will support Java 20 in March 2023.

https://marketplace.eclipse.org/content/java-20-support-eclipse-2023-03-427


### Where can I download Eclipse's LSP server?

https://github.com/eclipse/eclipse.jdt.ls/ has the following download source.

- Download and extract a milestone build from http://download.eclipse.org/jdtls/milestones/
- Download and extract a snapshot build from http://download.eclipse.org/jdtls/snapshots/

### What files does lsp-java download?

Looking at the lsp-java github repository ( https://github.com/emacs-lsp/lsp-java/blob/master/lsp-java.el ), as of 2023.04.22, it says

``` emacs-lisp
(defcustom lsp-java-jdt-download-url "https://download.eclipse.org/jdtls/milestones/1.12.0/jdt-language-server-1.12.0-202206011637. tar.gz"
  "JDT JS download url.
Use http://download.eclipse.org/che/che-ls-jdt/snapshots/che-jdt-language-server-latest.tar.gz if you want to use Eclipse Che JDT LS."
  :group 'lsp-java
  :type 'string)
```

### Edit lsp-java.el

First, find `lsp-java.el`.

The following is an example.

``` bash
$ find your_doom_dir -name "lsp-java.el"
/home/you/your_doom_dir/.local/straight/repos/lsp-java/lsp-java.el
/home/you/your_doom_dir/.local/straight/build-29.0.90/lsp-java/lsp-java.el
/home/you/your_doom_dir/.local/straight/build-27.1/lsp-java/lsp-java.el
/home/you/your_doom_dir/.local/straight/build-28.2/lsp-java/lsp-java.el
```

Since you can find some of them as shown in the example, edit the above-mentioned part of `lsp-java.el` under the build-29.0.90 directory, for example, as follows. (Refer to the above site for the download source.)

``` emacs-lisp
(defcustom lsp-java-jdt-download-url "https://download.eclipse.org/jdtls/milestones/1.22.0/jdt-language-server-1.22.0-202304131553. tar.gz"
   "JDT JS download url.
 Use http://download.eclipse.org/che/che-ls-jdt/snapshots/che-jdt-language-server-latest.tar.gz if you want to use Eclipse Che JDT LS."
   :group 'lsp-java
   :type 'string)
```

### Delete lsp-java.elc

First, find the `lsp-java.elc` that has already been created.

The following is an example.

``` bash
$ find ~/.emacs.d -name "lsp-java.elc"
/home/you/your_doom_dir/.local/straight/build-29.0.90/lsp-java/lsp-java.elc
/home/you/your_doom_dir/.local/straight/build-27.1/lsp-java/lsp-java.elc          
```

Delete `lsp-java.elc` under the build-29.0.90 directory, as some are found in the example.

### Remove the old jdt language server (jdtls).

The following is an example.

``` bash
rm -Rf /home/you/your_doom_dir/.local/etc/java-workspace
rm -Rf /home/you/your_doom_dir/.local/etc/lsp
```

### Restart emacs, open some `*.java` file, and let doom emacs reinstall jdtls.

Start emacs normally. （doom emacs will start up)

``` bash
emacs --init-directory your_doom_dir
```

Open some `*.java` file and let doom emacs reinstall `jdtls`. You should now be able to edit the file without any problems.

### Troubleshooting

The reason for the error is that the directory names inside and outside the container do not match. When you create the Apptainer image file at the beginning, make sure you edit the user account name in emacs29.def to your account.

---

# apptainer_emacs29

## 動機

既存の開発環境になるべく影響を与えずに doom emacs + lsp-java で開発できる環境を作りたい。

1. doom emacs は`~/.emacs.d`ディレクトリの構成にどうしても影響を与えてしまうが、
Emacs29 からは`--init-directory`オプションが新設されたので、これを使えば doom emacs を標準のディレクトリ構成とは異なる構成で起動できるため、
Emacs29 を使えば開発環境にほとんど影響を与えない。
2. 遺伝研スパコンは CentOS 7 で動作しており Emacs29 をインストールする作業がそもそも面倒である。
3. lsp-java で最新の JDK (現在だと JDK20)を使いたいが、Doom Emacs の公式サイトの手順のままだと使えない（ことがある。）

以上の状況を解決するために Ubuntu Linux 22.04 に Emacs29 をインストールした Apptainer コンテナイメージを作成した。

## 使用方法　(1) 単純に Emacs29 を動作させる。

1, ルート権限を持った Linux 環境上で Apptainer コンテナイメージを作成する。

```
git clone https://github.com/oogasawa/apptainer_emacs29
cd apptainer_emacs29
```

`emacs29.def`中の以下の部分についてユーザアカウント名を自分のアカウントに編集する。

- JDK や maven は`$HOME/local/`にすでにインストールされているものと仮定されているので、違う場合には適切にインストールし、`emacs29.def`の該当部分を書き換えること。(Apptainer ではユーザのホームディレクトリは最初からコンテナにマウントされておりコンテナ内部から見えているので、JDK や maven はホームディレクトリ以下にインストールするのが簡便である。そうでない場合は apptainer 起動時に適切にマウントする必要がある。そのやり方は Apptainer のマニュアルを参照のこと。）

```
    mkdir /home/you

%environment
    export JAVA_HOME=/home/you/local/jdk-20.0.1
    export MAVEN_HOME=/home/you/local/apache-maven-3.8.6
    export PATH=$JAVA_HOME/bin:$MAVEN_HOME/bin:$PATH

```

以下を実行して Apptainer コンテナイメージ(`emacs29.sif`)を作る。

```
sudo apptainer build emacs29.sif emacs29.def
```

2, Apptainer コンテナイメージ`emacs29.sif`を対象の環境に scp する。

```
scp emacs29.sif you@your.environment.com:/home/you
```

3, Apptainer コンテナイメージを起動する。

```
apptainer exec emacs29.sif emacs your_file
```

これで Emacs 29 が起動する。


## 使用方法 (2) Doom Emacs

上記に加えて、対象の環境で以下の作業を行う。

1, 目的の環境(遺伝研スパコンなど）に doom emacs をインストールする。

doom emacs の公式 github リポジトリの説明通り doom emacs をクローンする。ただし、好きなディレクトリ名でクローンすれば良い。

```
git clone --depth 1 https://github.com/doomemacs/doomemacs your_doom_dir
```

2, Apptainer コンテナイメージ呼び出し用のシェルスクリプトをパスの通った場所に設置する。

以下は一例

```
chmod +x apptainer_emacs20/emacs
cp apptainer_emacs29/emacs $HOME/local/bin
export PATH=$HOME/local/bin:$PATH
```

- `apptainer_emacs20/emacs`は`emacs29.sif`がホームディレクトリ直下に置かれていると仮定している。そうなっていない場合は適切に書き換える。


3, doom install, doom sync を実行する。

```
your_doom_dir/bin/doom install
your_doom_dir/bin/doom sync
```

4, emacs を起動する。

```
emacs --init-directory your_doom_dir
```


## 使用方法 (3) lsp-java で最新の JDK を使用する

### 作業概要

まず、一度なにか`*.java`ファイルを emacs で開いて、jdtls を doom emacs にインストールさせる。

その後、以下の手順を行うことで lsp-java で最新の JDK が使えるようになる。

1. lsp-java.el を編集する。
2. lsp-java.elc は削除する。
3. 古い jdt language server (jdtls)を削除する。
4. emacs を再起動して、なにか`*.java`ファイルを開き、doom emacs に jdtls を再インストールさせる。

### Eclipse の LSP server は最新の JDK に対応しているか？

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

### lsp-java.el の編集

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

### lsp-java.elc の削除

まず、すでにできている`lsp-java.elc`を探す。

以下は一例。

```
$ find ~/.emacs.d -name "lsp-java.elc"
/home/you/your_doom_dir/.local/straight/build-29.0.90/lsp-java/lsp-java.elc
/home/you/your_doom_dir/.local/straight/build-27.1/lsp-java/lsp-java.elc          
```

例のようにいくつか見つかるので、`build-29.0.90`ディレクトリの下の`lsp-java.elc`を削除する。

### 古い jdt language server (jdtls)を削除する。

以下は一例。

```
rm -Rf /home/you/your_doom_dir/.local/etc/java-workspace
rm -Rf /home/you/your_doom_dir/.local/etc/lsp
```

### emacs を再起動して、なにか`*.java`ファイルを開き、doom emacs に jdtls を再インストールさせる。

普通に emacs を起動する。（doom emacs が起動する。)

```
emacs --init-directory your_doom_dir
```


なにか`*.java`ファイルを開き、doom emacs に jdtls を再インストールさせる。これで問題なく編集できるようになる。

### Troubleshooting

これでエラーが出る際のはディレクトリ名がコンテナの内部と外部とで合っていないのが原因。
冒頭の Apptainer イメージファイルを作る際に、`emacs29.def`中のユーザアカウント名を自分のアカウントに編集するところを確認すること。

<
