# bash
grep all branches remote and local
git branch -a | tr -d \* | sed '/->/d' | xargs git grep <REGEXEXPR>
