#!/bin/bash

# =================================================== # 
# |    *** Prepare data for netprophet input **     | #
# =================================================== #

#module load anaconda3/4.1.1

#source activate netprophet

#python /scratch/mblab/dabid/netprophet/NetProphet_2.0/CODE/prepare_resources.py \
#-g /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_kemmerenKO_genes \
#-r /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_kemmerenKO_regulators \
#-e /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_kemmerenKO_data.expr \
#-c /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_kemmerenKO_conditions \
#-or /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_kemmerenKO_tmp/rdata.expr \
#-of /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_kemmerenKO_tmp/data.fc.tsv \
#-oa /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_kemmerenKO_tmp/allowed.adj \
#-op1 /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_kemmerenKO_tmp/data.pert.adj \
#-op2 /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_kemmerenKO_tmp/data.pert.tsv

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
-t /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_kemmerenKO_data.expr \
-d /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_kemmerenKO_tmp/data.fc.tsv \
-a /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_kemmerenKO_tmp/allowed.adj \
-p /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_kemmerenKO_tmp/data.pert.adj \
-g /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_kemmerenKO_genes \
-f /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_kemmerenKO_regulators \
-r /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_kemmerenKO_tmp/rdata.expr \
-o /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_kemmerenKO_net \
-n /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_tfa/expr_kemmerenKO_net/expr_kemmerenKO
