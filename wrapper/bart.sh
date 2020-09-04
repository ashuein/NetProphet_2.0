#!/bin/bash

echo "generate the bart network.."

# =================================================================================== #
# |                             **** READ ARGUMENTS ****                            | #
# =================================================================================== #
p_in_target=${1}
p_in_reg=${2}
p_in_expr_target=${3}
p_in_sample=${4}
p_out_net=${5}
fname_bart=${6}
flag_slurm=${7}
p_src_code=${8}


# =================================================================================== #
# |                           **** PREPARE RESSOURCES ****                          | #
# =================================================================================== #

if (( ${flag_slurm} == "ON"  ))
then
    source ${p_src_code}wrapper/load_modules.sh
fi

source activate netprophet

prep_data=${p_out_net}tmp/prepare_resources/
mkdir -p ${prep_data}

python ${p_src_code}code/netprophet2/prepare_resources.py \
-g ${p_in_target} \
-r ${p_in_reg} \
-e ${p_in_expr_target} \
-c ${p_in_sample} \
-or ${prep_data}rdata_expr \
-of ${prep_data}data_fc \
-oa ${prep_data}allowed \
-op1 ${prep_data}pert_adj \
-op2 ${prep_data}pert_tsv

source deactivate netprophet



# =================================================================================== #
# |                               **** BUILD BART ****                              | #
# =================================================================================== #

if (( ${flag_slurm} == "ON" ))
then

	Rscript --vanilla ${p_src_code}code/netprophet2/build_bart_network.r \
    fcFile=${prep_data}data_fc \
    isPerturbedFile=${prep_data}pert_tsv \
    tfNameFile=${p_in_reg} \
    saveTo=${p_out_net}${fname_bart}.tsv \
    useMpi=TRUE \
    mpiBlockSize=32

elif (( ${flag_slurm} == "OFF" ))
then
    Rscript --vanilla ${p_src_code}code/netprophet2/build_bart_network.r \
    fcFile=${prep_data}data_fc \
    isPerturbedFile=${prep_data}pert_tsv \
    tfNameFile=${p_in_reg} \
    saveTo=${p_out_net}${fname_bart}.tsv \
    useMpi=FALSE
fi


sed '1d' ${p_out_net}${fname_bart}.tsv > ${p_out_net}${fname_bart}
awk -i inplace '{sub(/^\S+\s*/,"")}1' ${p_out_net}${fname_bart}
mv ${p_out_net}${fname_bart} ${p_out_net}${fname_bart}_old
sed -r 's/(.*)\s+[^\s]+$/\1/'  ${p_out_net}${fname_bart}_old > ${p_out_net}${fname_bart}
rm ${p_out_net}${fname_bart}_old
