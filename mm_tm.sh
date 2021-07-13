export TEAMLABDIR=/mount/studenten/arbeitsdaten-studenten1/team-lab-phonetics/2021/student_directories/Vanessa_Dengel
cd $TEAMLABDIR
 
cd kaldi/egs/Automatic-speech-recognition/s5
 
. ./path.sh
. ./cmd.sh

local=data/local
lang=data/lang
arpa2fst --disambig-symbol=#0 --read-symbol-table=$lang/words.txt $local/tmp/lm.arpa $lang/G.fst
 
steps/train_mono.sh --nj $nj --cmd "$train_cmd" data/train_teamlab data/lang exp/mono
 
utils/mkgraph.sh --mono data/lang exp/mono exp/mono/graph
 
steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" exp/mono/graph data/dev_teamlab  exp/mono/decode

# triphone model 
nj=1
 
steps/align_si.sh --nj $nj --cmd "$train_cmd" data/train_teamlab data/lang exp/mono exp/mono_ali
 
steps/train_deltas.sh --cmd "$train_cmd" 2000 11000 data/train_teamlab data/lang exp/mono_ali exp/tri1
 
utils/mkgraph.sh data/lang exp/tri1 exp/tri1/graph
 
steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" exp/tri1/graph data/dev_teamlab exp/tri1/decode
