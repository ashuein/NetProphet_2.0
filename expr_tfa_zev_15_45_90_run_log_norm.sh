#!/bin/bash

# =================================================== # 
# |    *** Prepare data for netprophet input **     | #
# =================================================== #

#module load anaconda3/4.1.1

#source activate netprophet

#python /scratch/mblab/dabid/netprophet/NetProphet_2.0/CODE/prepare_resources.py \
#-g /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_zev_15_45_90_genes \
#-r /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/common_regulators \
#-e /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_tfa_zev_15_45_90_data.expr_log_norm \
#-c /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_zev_15_45_90_conditions \
#-or /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_tfa_zev_15_45_90_tmp_log_norm/rdata.expr \
#-of /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_tfa_zev_15_45_90_tmp_log_norm/data.fc.tsv \
#-oa /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_tfa_zev_15_45_90_tmp_log_norm/allowed.adj \
#-op1 /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_tfa_zev_15_45_90_tmp_log_norm/data.pert.adj \
#-op2 /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_tfa_zev_15_45_90_tmp_log_norm/data.pert.tsv

# ============================================ #
# |          *** Run NetProphet ***          | #
# ============================================ #

# load modules
module load R/3.2.1
module load openmpi/1.8.3

# run command
/scratch/mblab/dabid/netprophet/NetProphet_2.0/SRC/NetProphet1/netprophet \
-m -c \
-u /scratch/mblab/dabid/netprophet/NetProphet_2.0/SRC/NetProphet1 \
-t /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_tfa_zev_15_45_90_data.expr_log_norm \
-d /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_zev_15_de.shrunken.adj \
-a /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_tfa_zev_15_45_90_tmp_log_norm/allowed.adj \
-p /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_tfa_zev_15_45_90_tmp_log_norm/data.pert.adj \
-g /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_zev_15_45_90_genes \
-f /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/common_regulators \
-r /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_tfa_zev_15_45_90_tmp_log_norm/rdata.expr \
-o /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_tfa_zev_15_45_90_net_log_norm \
-n /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_tfa_zev_15_45_90_net_log_norm/expr_tfa_zev_15_45_90_log_norm \
-e /scratch/mblab/dabid/netprophet/NetProphet_2.0/LOG/expr_tfa_zev_15_45_90_log_norm \
-j expr_tfa_zev_15_45_90_log_norm