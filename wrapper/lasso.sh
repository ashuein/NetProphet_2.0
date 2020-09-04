#!/bin/bash

echo "generate lasso network..."

# ======================================================================================================= #
# |                                       **** PARSE ARGUMENTS ****                                     | #
# ======================================================================================================= #
p_in_target=${1}
p_in_reg=${2}
p_in_sample=${3}
p_in_expr_target=${4}
p_in_expr_reg=${5}
flag_global_shrinkage=${6}
flag_local_shrinkage=${7}
p_out_dir=${8}
fname_lasso=${9}
flag_debug=${10}
flag_parallel=${11}
seed=${12}
nbr_cv_fold=${13}
flag_microarray=${14}
p_src_code=${15}

# ======================================================================================================= #
# |                                   *** GENERATE LASSO NETWORK ***                                    | #
# ======================================================================================================= #

if [ ${flag_parallel} == "ON" ]
then
  source ${p_src_code}wrapper/load_modules.sh
  mpirun -np ${SLURM_NTASKS} Rscript --no-save ${p_src_code}code/lasso.R \
    --p_in_target ${p_in_target} \
    --p_in_reg ${p_in_reg} \
    --p_in_sample ${p_in_sample} \
    --p_in_expr_target ${p_in_expr_target} \
    --p_in_expr_reg ${p_in_expr_reg} \
    --flag_global_shrinkage ${flag_global_shrinkage} \
    --flag_local_shrinkage ${flag_local_shrinkage} \
    --p_out_dir ${p_out_dir} \
    --fname_lasso ${fname_lasso} \
    --flag_debug ${flag_debug} \
    --flag_parallel ${flag_parallel} \
    --seed ${seed} \
    --nbr_cv_fold ${nbr_cv_fold} \
    --flag_microarray ${flag_microarray} \
    --p_src_code ${p_src_code}
  
elif [ ${flag_parallel} == "OFF" ]
then
  Rscript --no-save \
  ${p_src_code}code/lasso.R \
  --p_in_target ${p_in_target} \
  --p_in_reg ${p_in_reg} \
  --p_in_sample ${p_in_sample} \
  --p_in_expr_target ${p_in_expr_target} \
  --p_in_expr_reg ${p_in_expr_reg} \
  --flag_global_shrinkage ${flag_global_shrinkage} \
  --flag_local_shrinkage ${flag_local_shrinkage} \
  --p_out_dir ${p_out_dir} \
  --fname_lasso ${fname_lasso} \
  --flag_debug ${flag_debug} \
  --flag_parallel ${flag_parallel} \
  --seed ${seed} \
  --nbr_cv_fold ${nbr_cv_fold} \
  --flag_microarray ${flag_microarray}  \
  --p_src_code ${p_src_code}
fi

# ======================================================================================================= #
# |                                 *** END GENERATE LASSO NETWORK ***                                  | #
# ======================================================================================================= #
