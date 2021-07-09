export TEAMLABDIR=/mount/studenten/arbeitsdaten-studenten1/team-lab-phonetics/2021/student_directories/Vanessa_Dengel # put your teamlab directory path here

cd $TEAMLABDIR

cd kaldi/egs/teamlab/s5
. ./path.sh
. ./cmd.sh

local=data/local
ngram-count -order 1 -kndiscount1 -write-vocab $local/tmp/vocab-full.txt -wbdiscount -text $local/corpus.txt -lm $local/tmp/lm.arpa

lang=data/lang
arpa2fst --disambig-symbol=#0 --read-symbol-table=$lang/words.txt $local/tmp/lm.arpa $lang/G.fst
