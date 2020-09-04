#!/bin/bash
#SBATCH --mem 5G
# p_in_net=/scratch/mblab/dabid/netprophet/net_out/kem_feed_netprophet_seed0_10cv_seed0_by_12400/top_12400_seed0_netprophet/net_test_netprophet_12400
# p_out_eval=eval.tsv
# fname_net=test
# p_in_reg=/scratch/mblab/dabid/netprophet/net_in/sub3_in_reg_tf_124
# p_in_target=/scratch/mblab/dabid/netprophet/net_in/sub3_in_target_5111
# p_in_binding_event=/scratch/mblab/dabid/netprophet/data_binding/reg_target_cc_exo_chip_exclusive.txt
# flag_slurm="ON"
# p_src_code=/scratch/mblab/dabid/netprophet/code_netprophet3.0/

p_in_net=${1}
p_out_eval=${2}
p_in_reg=${4}
p_in_target=${5}
p_in_binding_event=${6}
flag_slurm=${7}
p_src_code=${8}

if (( ${flag_slurm} == "ON" ))
then
  source ${p_src_code}wrapper/load_modules.sh
fi

source activate netprophet
pushd ${p_in_net}
for fname_net in ./net_*
do
  python ${p_src_code}code/evaluate_network.py \
    --p_in_net ${p_in_net}${fname_net} \
    --p_out_eval ${p_out_eval} \
    --fname_net ${fname_net} \
    --p_in_reg ${p_in_reg} \
    --p_in_target ${p_in_target} \
    --p_in_binding_event ${p_in_binding_event}
done
source deactivate netprophet
