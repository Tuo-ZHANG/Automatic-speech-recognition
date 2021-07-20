export TEAMLABDIR=/mount/studenten/arbeitsdaten-studenten1/team-lab-phonetics/2021/student_directories/Vanessa_Dengel
 
cd $TEAMLABDIR
 
cd kaldi/egs/teamlab_pronunciation/s5

 
. ./path.sh
. ./cmd.sh
 
utils/fix_data_dir.sh data/train_teamlab
utils/fix_data_dir.sh data/dev_teamlab
 
nj=38
mfccdir=mfcc
 
# edit conf/mfcc.conf to allow upsampling (run 'compute-mfcc-feats' for more information)
 
steps/make_mfcc.sh --nj $nj --cmd "$train_cmd" data/train_teamlab exp/make_mfcc/train_teamlab $mfccdir

steps/make_mfcc.sh --nj $nj --cmd "$train_cmd" data/dev_teamlab exp/make_mfcc/dev_teamlab $mfccdir
 
steps/compute_cmvn_stats.sh data/train_teamlab exp/make_mfcc/train_teamlab $mfccdir
steps/compute_cmvn_stats.sh data/dev_teamlab exp/make_mfcc/dev_teamlab $mfccdir
