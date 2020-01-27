#!/bin/bash

# =============================================== # 
# |    *** Load packages for NetProphet ***     | #
# =============================================== # 
module load R/3.2.1
module load openmpi/1.8.3
module load anaconda3/4.1.1

#  prepare the data
#python /scratch/mblab/dabid/netprophet/NetProphet_2.0/CODE/prepare_resources.py \
#-g /scratch/mblab/dabid/netprophet/NetProphet_2.0/RESOURCES/genes \
#-r /scratch/mblab/dabid/netprophet/NetProphet_2.0/RESOURCES/regulators \
#-e /scratch/mblab/dabid/netprophet/NetProphet_2.0/RESOURCES/data.expr \
#-c /scratch/mblab/dabid/netprophet/NetProphet_2.0/RESOURCES/conditions \
#-or /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_test/tmp/rdata.expr \
#-of /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_test/tmp/data.fc.tsv \
#-oa /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_test/tmp/allowed.adj \
#-op1 /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_test/tmp/data.pert.adj \
#-op2 /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_test/tmp/data.pert.tsv

# =================================================== # 
# |         *** Run NetProphet 1.0 ***              | #
# | NetProphet 1.0 is wrapped within NetProphet 2.0 | #
# | and no need to have the SBATCH header in this   | #
# | bash file.                                      | #
# =================================================== # 

source activate netprophet

/scratch/mblab/dabid/netprophet/NetProphet_2.0/SRC/NetProphet1/netprophet \
-m -c \
-u /scratch/mblab/dabid/netprophet/NetProphet_2.0/SRC/NetProphet1 \
-t /scratch/mblab/dabid/netprophet/NetProphet_2.0/RESOURCES/data.expr \
-d /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_test/tmp/data.fc.tsv \
-a /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_test/tmp/allowed.adj \
-p /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_test/tmp/data.pert.adj \
-g /scratch/mblab/dabid/netprophet/NetProphet_2.0/RESOURCES/genes \
-f /scratch/mblab/dabid/netprophet/NetProphet_2.0/RESOURCES/regulators \
-r /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_test/tmp/rdata.expr \
-o /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_test/networks \
-n /scratch/mblab/dabid/netprophet/NetProphet_2.0/run_test/networks/test_trace_run.txt \
-j "TraceRun" \
-e /scratch/mblab/dabid/netprophet/NetProphet_2.0/LOG/test_trace_run
