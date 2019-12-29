#!/bin/sh

# root
ROOT=`dirname $0`
cd $ROOT


# ファイル指定(argv)がある場合
while getopts f:d:m: OPT
do
  case $OPT in
    # 格納ディレクトリ [ (d)vendor]
    d ) dir="$OPTARG";;
    # 設定ファイル [ (d)vendor.json , *.json , *.csv]
    f ) filename="$OPTARG";;
    # モード [ (d)auto , check ]
    m ) mode="$OPTARG";;
  esac
done

if [ "$filename" = "" ];then
  filename="vendor.json"
fi
if [ "$dir" = "" ];then
  dir="vendor"
fi
if [ "$mode" = "" ];then
  mode="auto"
fi
echo $mode

if [ ! -e $filename ];then
  echo "Error ! not file $filename."
  exit 0
fi



# command-check
## check-git
check_git=`git --version`
if [ "$check_git" = "" ];then
  echo "Error : not install [git]."
  exit 0
fi



# 拡張子判定
get_extension(){
  filename=$@
  # 拡張子を取得
  ext=${filename##*.}
  # 拡張子を全て小文字に変換
  echo `echo $ext | tr [A-Z] [a-z]`
}
ext=`get_extension $filename`


## check-jq
check_jq=`jq --version`
if [ "$ext" = "json" -a "$check_jq" = "" ];then
  echo "Error : not install [jq]."
  exit 0
fi



# フォルダがない場合は作成
make_dir(){
  DIR=$@
  if [ ! -e $DIR ]; then
    mkdir $DIR
  fi
}
make_dir $dir


# 判定->処理実行
mode_auto(){
  filepath=${1}
  git=${2}
  if [ -e $filepath ];then
    CID0=`git -C $filepath log --pretty=format:"%H"|head -n 1`
    CID1=`git -C $filepath ls-remote origin HEAD|awk '{print $1}'`

    if [ $CID0 = $CID1 ]; then
      echo "Same : $filepath";
    else
      echo "Diff : $filepath";
      `git -C $filepath pull origin`
    fi
  else
    # clone
    echo "None : $filepath";
    git clone $git $filepath
  fi
}
# 判定->チェック
mode_check(){
  filepath=$@
  if [ -e $filepath ];then
    CID0=`git -C $filepath log --pretty=format:"%H"|head -n 1`
    CID1=`git -C $filepath ls-remote origin HEAD|awk '{print $1}'`

    if [ $CID0 = $CID1 ]; then
      echo "Same : $filepath";
    else
      echo "Diff : $filepath";
    fi
  else
    # clone
    echo "None : $filepath";
  fi
}


# JSON
proc_json(){
  filename=$@
  jq --compact-output -r '.[]' $filename | while read LINE;do
    # echo $LINE
    NAME=`echo $LINE | jq -r '.name'`
    GIT=`echo $LINE | jq -r '.git'`
    if [ "$mode" = "auto" ];then
      mode_auto "$DIR/$NAME" "$GIT"
    elif [ "$mode" = "check" ];then
      mode_check "$DIR/$NAME"
    fi
  done
}

# CSV
proc_csv(){
  filename=$@
  
  cat $filename | while read LINE;do
    # echo $LINE
    NAME=`echo $LINE | cut -d, -f1`
    GIT=`echo $LINE | cut -d, -f2`
    if [ "$mode" = "auto" ];then
      mode_auto "$DIR/$NAME" "$GIT"
    elif [ "$mode" = "check" ];then
      mode_check "$DIR/$NAME"
    fi
  done
}

# 拡張子別処理実行
if [ $ext = "json" ]; then
  # echo "json"
  proc_json $filename

elif [ $ext = "csv" ]; then
  # echo "csv"
  proc_csv $filename
fi
