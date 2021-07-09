#!/usr/bin/env bash

# Copyright 2013  Arnab Ghoshal, Pawel Swietojanski

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# THIS CODE IS PROVIDED *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY IMPLIED
# WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A PARTICULAR PURPOSE,
# MERCHANTABLITY OR NON-INFRINGEMENT.
# See the Apache 2 License for the specific language governing permissions and
# limitations under the License.

# To be run from one directory above this script.
# command to run when in .../data: bash /mount/studenten/arbeitsdaten-studenten1/team-lab-phonetics/2021/student_directories/Vanessa_Dengel/kaldi/egs/teamlab/s5/ami_train_lms.sh ./train_teamlab/text ./dev_teamlab/text ./local/dict/lexicon.txt ./local/lm


export TEAMLABDIR=/mount/studenten/arbeitsdaten-studenten1/team-lab-phonetics/2021/student_directories/Vanessa_Dengel # put your teamlab directory path here

cd $TEAMLABDIR

cd kaldi/egs/teamlab/s5
. ./path.sh
. ./cmd.sh


# Begin configuration section.
fisher=/mount/studenten/arbeitsdaten-studenten1/team-lab-phonetics/2021/student_directories/Vanessa_Dengel/kaldi/egs/teamlab/s5/data/local/corpusTUTDOC.txt
order=3
ted=/mount/studenten/arbeitsdaten-studenten1/team-lab-phonetics/2021/student_directories/Vanessa_Dengel/kaldi/egs/teamlab/s5/data/local/TED_LIUM_preprocessed.txt
google=
web_sw=
kaldi_web=/mount/studenten/arbeitsdaten-studenten1/team-lab-phonetics/2021/student_directories/Vanessa_Dengel/kaldi/egs/teamlab/s5/data/local/kaldi_tutorial_preprocessed.txt
web_mtg=
# end configuration sections

help_message="Usage: "`basename $0`" [options] <train-txt> <dev-txt> <dict> <out-dir>
Train language models for AMI and optionally for Switchboard, Fisher and web-data from University of Washington.\n
options:
  --help          # print this message and exit
  --fisher DIR    # directory for Fisher transcripts
  --order N       # N-gram order (default: '$order')
  --ted DIR      # Directory for Switchboard transcripts
  --web-sw FILE   # University of Washington (191M) Switchboard web data
  --web-fsh FILE  # University of Washington (525M) Fisher web data
  --web-mtg FILE  # University of Washington (150M) CMU+ICSI+NIST meeting data
";

. utils/parse_options.sh

cd ./data

if [ $# -ne 4 ]; then
  printf "$help_message\n";
  exit 1;
fi

train=$1    # data/ihm/train/text
dev=$2      # data/ihm/dev/text
lexicon=$3  # data/ihm/dict/lexicon.txt
dir=$4      # data/local/lm

for f in "$text" "$lexicon"; do
  [ ! -f $x ] && echo "$0: No such file $f" && exit 1;
done

set -o errexit
mkdir -p $dir
export LC_ALL=C

if ! command -v ngram-count 2>/dev/null; then
  echo "$0: SRILM is not installed.  Please install SRILM with:"
  echo "pushd $KALDI_ROOT; cd tools; extras/install_srilm.sh; popd"
  echo "[note: this may require registering on the SRILM website.]"
  exit 1
fi

cut -d' ' -f2- $train | gzip -c > $dir/train.gz # modified: before f6
cut -d' ' -f2- $dev | gzip -c > $dir/dev.gz  # modified: before f6

awk '{print $1}' $lexicon | sort -u > $dir/wordlist.lex
gunzip -c $dir/train.gz | tr ' ' '\n' | grep -v ^$ | sort -u > $dir/wordlist.train
sort -u $dir/wordlist.lex $dir/wordlist.train > $dir/wordlist

#ngram-count -text ./local/corpusTUTDOC.txt -order $order -limit-vocab -vocab $dir/wordlist \
#  -unk -map-unk "<unk>" -kndiscount -interpolate -lm $dir/kaldi_transcript.o${order}g.kn.arpa
ngram-count -text ./local/corpusTUTDOC.txt -order $order -kndiscount -interpolate -write-vocab $dir/vocab-kaldi_transcript.txt -lm $dir/kaldi_transcript.o${order}g.kn.arpa
echo "PPL for Kaldi transcript LM:"
ngram -order ${order} -unk -lm $dir/kaldi_transcript.o${order}g.kn.arpa -ppl $dir/dev.gz
ngram -order ${order} -unk -lm $dir/kaldi_transcript.o${order}g.kn.arpa -ppl $dir/dev.gz -debug 2 >& $dir/ppl2
mix_ppl="$dir/ppl2"
mix_tag="kaldi_transcript"
mix_lms=( "$dir/kaldi_transcript.o${order}g.kn.arpa" )
num_lms=1



if [ ! -z "/ted" ]; then
  mkdir -p $dir/ted
  # ngram-count -text ./local/TED_LIUM_preprocessed.txt -order $order -limit-vocab -vocab $dir/wordlist \
  # -unk -map-unk "<unk>" -kndiscount -interpolate -lm $dir/ted.o${order}g.kn.arpa
  ngram-count -text ./local/TED_LIUM_preprocessed.txt -order $order -kndiscount -interpolate -write-vocab $dir/vocab-TED.txt -lm $dir/ted.o${order}g.kn.arpa
  
  echo "PPL for TED LM:"
  ngram -order ${order} -unk -lm $dir/ted.o${order}g.kn.arpa -ppl $dir/dev.gz
  ngram -order ${order} -unk -lm $dir/ted.o${order}g.kn.arpa -ppl $dir/dev.gz -debug 2 \
    >& $dir/ted/ppl2

  mix_ppl="$mix_ppl $dir/ted/ppl2"
  mix_tag="${mix_tag}_ted"
  mix_lms=("${mix_lms[@]}" "$dir/ted.o${order}g.kn.arpa")
  num_lms=$[ num_lms + 1 ]
fi


if [ ! -z "/kaldi_web" ]; then
  mkdir -p $dir/kaldi_web
  #ngram-count -text ./local/kaldi_tutorial_preprocessed.txt -order $order -limit-vocab -vocab $dir/wordlist \
  # -unk -map-unk "<unk>" -kndiscount -interpolate -lm $dir/kaldi_web.o${order}g.kn.arpa
  ngram-count -text ./local/kaldi_tutorial_preprocessed.txt -order $order -kndiscount -interpolate -write-vocab $dir/vocab-kaldi_web.txt -lm $dir/kaldi_web.o${order}g.kn.arpa
  
  echo "PPL for Kaldi Web LM:"
  ngram -order ${order} -unk -lm $dir/kaldi_web.o${order}g.kn.arpa -ppl $dir/dev.gz
  ngram -order ${order} -unk -lm $dir/kaldi_web.o${order}g.kn.arpa -ppl $dir/dev.gz -debug 2 \
    >& $dir/kaldi_web/ppl2

  mix_ppl="$mix_ppl $dir/kaldi_web/ppl2"
  mix_tag="${mix_tag}_kaldi_web"
  mix_lms=("${mix_lms[@]}" "$dir/kaldi_web.o${order}g.kn.arpa")
  num_lms=$[ num_lms + 1 ]
fi



if [ $num_lms -gt 1  ]; then
  echo "Computing interpolation weights from: $mix_ppl"
  compute-best-mix $mix_ppl >& $dir/mix.log
  grep 'best lambda' $dir/mix.log \
    | perl -e '$_=<>; s/.*\(//; s/\).*//; @A = split; for $i (@A) {print "$i\n";}' \
    > $dir/mix.weights
  weights=( `cat $dir/mix.weights` )
  cmd="ngram -order ${order} -lm ${mix_lms[0]} -lambda ${weights[0]} -mix-lm ${mix_lms[1]}"
  for i in `seq 2 $((num_lms-1))`; do
    cmd="$cmd -mix-lm${i} ${mix_lms[$i]} -mix-lambda${i} ${weights[$i]}"
  done
  cmd="$cmd -unk -write-lm $dir/${mix_tag}.o${order}g.kn.arpa"
  echo "Interpolating LMs with command: \"$cmd\""
  $cmd
  echo "PPL for the interolated LM:"
  ngram -order ${order} -unk -lm $dir/${mix_tag}.o${order}g.kn.arpa -ppl $dir/dev.gz
fi

#save the lm name for further use
echo "${mix_tag}.o${order}g.kn" > $dir/final_lm








#if [ ! -z "/ted" ]; then
#  mkdir -p $dir/ted
#
#  find /ted -iname '*-trans.text' -exec cat {} \; | cut -d' ' -f4- \
 #   | gzip -c > $dir/ted/text0.gz
 # gunzip -c $dir/ted/text0.gz | swbd_map_words.pl | gzip -c \
 #   > $dir/ted/text1.gz
 # ngram-count -text $dir/ted/text1.gz -order $order -limit-vocab \
 #   -vocab $dir/wordlist -unk -map-unk "<unk>" -kndiscount -interpolate \
 #   -lm $dir/ted.o${order}g.kn.gz
  
  
 # echo "PPL for SWBD LM:"
 # ngram -order ${order} -unk -lm $dir/ted.o${order}g.kn.gz -ppl $dir/dev.gz
 # ngram -order ${order} -unk -lm $dir/ted.o${order}g.kn.gz -ppl $dir/dev.gz -debug 2 \
 #   >& $dir/ted/ppl2

 # mix_ppl="$mix_ppl $dir/ted/ppl2"
 # mix_tag="${mix_tag}_swbd"
#  mix_lms=("${mix_lms[@]}" "$dir/ted.o${order}g.kn.gz")
 # num_lms=$[ num_lms + 1 ]
#fi

# if [ ! -z "$fisher" ]; then
#   [ ! -d "$fisher/data/trans" ] \
#     && echo "Cannot find transcripts in Fisher directory: '$fisher'" \
#     && exit 1;
#   mkdir -p $dir/fisher

#   find $fisher -follow -path '*/trans/*fe*.txt' -exec cat {} \; | grep -v ^# | grep -v ^$ \
#     | cut -d' ' -f4- | gzip -c > $dir/fisher/text0.gz
#   gunzip -c $dir/fisher/text0.gz | local/fisher_map_words.pl \
#     | gzip -c > $dir/fisher/text1.gz
#   ngram-count -debug 0 -text $dir/fisher/text1.gz -order $order -limit-vocab \
#     -vocab $dir/wordlist -unk -map-unk "<unk>" -kndiscount -interpolate \
#     -lm $dir/fisher/fisher.o${order}g.kn.gz
#   echo "PPL for Fisher LM:"
#   ngram -order ${order} -unk -lm $dir/fisher/fisher.o${order}g.kn.gz -ppl $dir/dev.gz
#   ngram -order ${order} -unk -lm $dir/fisher/fisher.o${order}g.kn.gz -ppl $dir/dev.gz -debug 2 \
#    >& $dir/fisher/ppl2

#   mix_ppl="$mix_ppl $dir/fisher/ppl2"
#   mix_tag="${mix_tag}_fsh"
#   mix_lms=("${mix_lms[@]}" "$dir/fisher/fisher.o${order}g.kn.gz")
#   num_lms=$[ num_lms + 1 ]
# fi

# if [ ! -z "$google1B" ]; then
#   mkdir -p $dir/google
#   wget -O $dir/google/cantab.lm3.bz2 http://vm.cantabresearch.com:6080/demo/cantab.lm3.bz2
#   wget -O $dir/google/150000.lex http://vm.cantabresearch.com:6080/demo/150000.lex

#   ngram -order ${order} -unk -limit-vocab -vocab $dir/wordlist -lm $dir/google.cantab.lm3.bz3 \
#      -write-lm $dir/google/google.o${order}g.kn.gz

#   mix_ppl="$mix_ppl $dir/goog1e/ppl2"
#   mix_tag="${mix_tag}_fsh"
#   mix_lms=("${mix_lms[@]}" "$dir/google/google.o${order}g.kn.gz")
#   num_lms=$[ num_lms + 1 ]
# fi

# ## The University of Washington conversational web data can be obtained as:
# ## wget --no-check-certificate http://ssli.ee.washington.edu/data/191M_conversational_web-filt+periods.gz
# if [ ! -z "$web_sw" ]; then
#   echo "Interpolating web-LM not implemented yet"
# fi

# ## The University of Washington Fisher conversational web data can be obtained as:
# ## wget --no-check-certificate http://ssli.ee.washington.edu/data/525M_fisher_conv_web-filt+periods.gz
# if [ ! -z "$web_fsh" ]; then
#   echo "Interpolating web-LM not implemented yet"
# fi

# ## The University of Washington meeting web data can be obtained as:
# ## wget --no-check-certificate http://ssli.ee.washington.edu/data/150M_cmu+icsi+nist-meetings.gz
# if [ ! -z "$web_mtg" ]; then
#   echo "Interpolating web-LM not implemented yet"
# fi

# if [ $num_lms -gt 1  ]; then
#   echo "Computing interpolation weights from: $mix_ppl"
#   compute-best-mix $mix_ppl >& $dir/mix.log
#   grep 'best lambda' $dir/mix.log \
#     | perl -e '$_=<>; s/.*\(//; s/\).*//; @A = split; for $i (@A) {print "$i\n";}' \
#     > $dir/mix.weights
#   weights=( `cat $dir/mix.weights` )
#   cmd="ngram -order ${order} -lm ${mix_lms[0]} -lambda ${weights[0]} -mix-lm ${mix_lms[1]}"
#   for i in `seq 2 $((num_lms-1))`; do
#     cmd="$cmd -mix-lm${i} ${mix_lms[$i]} -mix-lambda${i} ${weights[$i]}"
#   done
#   cmd="$cmd -unk -write-lm $dir/${mix_tag}.o${order}g.kn.gz"
#   echo "Interpolating LMs with command: \"$cmd\""
#   $cmd
#   echo "PPL for the interolated LM:"
#   ngram -order ${order} -unk -lm $dir/${mix_tag}.o${order}g.kn.gz -ppl $dir/dev.gz
# fi

# #save the lm name for further use
# echo "${mix_tag}.o${order}g.kn" > $dir/final_lm

