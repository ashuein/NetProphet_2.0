#!/bin/bash

# =================================================== # 
# |    *** Prepare data for netprophet input **     | #
# =================================================== #

module load anaconda3/4.1.1

source activate netprophet

python /scratch/mblab/dabid/netprophet/NetProphet_2.0/CODE/prepare_resources.py \
-g /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_zev_90_genes \
-r /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/common_regulators \
-e /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_zev_90_data.expr \
-c /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_zev_90_conditions \
-or /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_zev_90_tmp_tf159/rdata.expr \
-of /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_zev_90_tmp_tf159/data.fc.tsv \
-oa /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_zev_90_tmp_tf159/allowed.adj \
-op1 /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_zev_90_tmp_tf159/data.pert.adj \
-op2 /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_zev_90_tmp_tf159/data.pert.tsv

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
-t /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_zev_90_data.expr \
-d /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_zev_15_de.shrunken.adj \
-a /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_zev_90_tmp_tf159/allowed.adj \
-p /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_zev_90_tmp_tf159/data.pert.adj \
-g /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_zev_90_genes \
-f /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/common_regulators \
-r /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_zev_90_tmp_tf159/rdata.expr \
-o /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_zev_90_net_tf159 \
-n /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_zev_90_net_tf159/expr_zev_90_tf159 \
-e /scratch/mblab/dabid/netprophet/NetProphet_2.0/LOG/expr_zev_90_tf159 \
-j expr_zev_90_tf159
