#! /bin/bash

# Tasks File
file="tasks.csv"

# Add Task to Tasks File
function _add {
  echo "0,$1,\"$2\"" >> "$file"
  echo "Task '$2' Added to List."
}

# List Tasks
function _list {
  row_num=1
  while IFS=, read -r f1 f2 f3; do
    echo "$row_num | $f1 | $f2 | $f3"
    row_num=$((row_num + 1))
  done <"$file"
}

# Clear Tasks
function _clear {
  : > "$file"
  echo "Tasks Cleared!"
}

# Find Tasks by Title
function _find {
  grep -n "$1" "$file" | sed 's/,/ | /g' | sed 's/:/ | /g'
}

# Mark Task as Done
function _done {
  line_num=$1
  awk -v l_num="$line_num" 'BEGIN{FS=OFS=","} NR==l_num { $1=1 } 1' "$file" >temp.csv && mv temp.csv "$file"
}

case $1 in
"add")
  shift
  while getopts ":t:p:" option; do
    case $option in
      t)
        if [ -z "$OPTARG" ] || [[ "$OPTARG" == -* ]]; then
          echo "Option -t|--title Needs a Parameter"
          exit 1
        else
          title="$OPTARG"
        fi
        ;;
      p)
        if [ "$OPTARG" != "L" ] && [ "$OPTARG" != "M" ] && [ "$OPTARG" != "H" ]; then
          echo "Option -p|--priority Only Accept L|M|H"
          exit 1
        else
          priority=$OPTARG
        fi
        ;;
      \?)
        echo "Invalid option: -$OPTARG"
        exit 1
        ;;
    esac
  done

  if [ -z "$title" ]; then
    echo "Option -t|--title Needs a Parameter"
    exit 1
  fi

  if [ -z "$priority" ]; then
    priority="L"
  fi

  _add "$priority" "$title"
  ;;

"list")
  _list
  ;;

"clear")
  _clear
  ;;

"find")
  shift
  _find "$1"
  ;;

"done")
  shift
  _done "$1"
  ;;

*)
  echo "Command Not Supported!"
  ;;
esac
