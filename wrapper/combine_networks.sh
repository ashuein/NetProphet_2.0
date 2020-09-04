#!/bin/bash

p_out_dir=${1}
p_net_lasso=${2}
p_net_bart=${3}
p_net_de=${4}
p_net_binding=${5}
model=${6}
p_src_code=${7}
p_net_np3=${8}
flag_slurm=${9}
seed=${10}
p_in_reg=${11}
p_in_target=${12}

echo "combine networks ${p_net_np3}"

# ======================================================================================================= #
# |                            *** SELECT 10-CV TRAINING/TESTING SETS ***                               | #
# ======================================================================================================= #

mkdir -p ${p_out_dir}data_cv/
mkdir -p ${p_out_dir}data_pred/


echo "select 10-fold cv.."
source activate netprophet
python ${p_src_code}code/combine_networks_select_write_training_testing_10_fold_cv.py \
  --l_net_name binding lasso de bart \
  --l_p_net ${p_net_binding} \
            ${p_net_lasso} \
            ${p_net_de} \
            ${p_net_bart} \
  --p_out_dir ${p_out_dir}data_cv/ \
  --exclude_tf "ON" \
  --seed ${seed} \
  --p_reg ${p_in_reg} \
  --p_target ${p_in_target} \
  --p_src_code ${p_src_code}
  
source deactivate netprophet
  

# ======================================================================================================= #
# |                                *** TRAIN/TEST FOR COMBINING NETWORKS ***                            | #
# ======================================================================================================= #  
echo "train/test.."
for f in {0..9}
do
  Rscript ${p_src_code}code/combine_networks_train_test.R \
    --p_in_train_binding ${p_out_dir}data_cv/fold${f}_train_binding.tsv \
    --p_in_train_lasso ${p_out_dir}data_cv/fold${f}_train_lasso.tsv \
    --p_in_train_de ${p_out_dir}data_cv/fold${f}_train_de.tsv \
    --p_in_train_bart ${p_out_dir}data_cv/fold${f}_train_bart.tsv \
    --p_in_test_lasso ${p_out_dir}data_cv/fold${f}_test_lasso.tsv \
    --p_in_test_de ${p_out_dir}data_cv/fold${f}_test_de.tsv \
    --p_in_test_bart ${p_out_dir}data_cv/fold${f}_test_bart.tsv \
    --in_model ${model} \
    --p_out_pred_train ${p_out_dir}data_pred/fold${f}_pred_train.tsv \
    --p_out_pred_test ${p_out_dir}data_pred/fold${f}_pred_test.tsv \
    --p_out_model_summary ${p_out_dir}data_pred/fold${f}_model_summary
done


# ======================================================================================================= #
# |                              *** CONCATENATE THE 10 TESTING NETWORKS ***                            | #
# ======================================================================================================= #
echo "concatenate networks.."

source activate netprophet
python ${p_src_code}code/combine_networks_concat_networks.py \
--p_in_dir_data ${p_out_dir}data_cv/ \
--p_in_dir_pred ${p_out_dir}data_pred/ \
--p_out_file ${p_net_np3}
source deactivate netprophet