#git archive HEAD -o ${PWD##*/}.zip


stashName=`git stash create`;
git archive -o ${PWD##*/}.zip $stashName