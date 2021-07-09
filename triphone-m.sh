export TEAMLABDIR=/mount/studenten/arbeitsdaten-studenten1/team-lab-phonetics/2021/student_directories/Vanessa_Dengel # put your teamlab directory path here
 
cd $TEAMLABDIR
 
cd kaldi/egs/teamlab/s5
 
. ./path.sh
. ./cmd.sh
 
nj=1
 
steps/align_si.sh --nj $nj --cmd "$train_cmd" data/train_teamlab data/lang exp/mono exp/mono_ali
 
steps/train_deltas.sh --cmd "$train_cmd" 2000 11000 data/train_teamlab data/lang exp/mono_ali exp/tri1
 
utils/mkgraph.sh data/lang exp/tri1 exp/tri1/graph
 
steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" exp/tri1/graph data/dev_teamlab exp/tri1/decode
