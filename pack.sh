#git archive HEAD -o ${PWD##*/}.zip


stashName=`git stash create`;
git archive --prefix=Gladdy/ -o ${PWD##*/}.zip $stashName