#!/bin/bash

# ============================================================================= #
# |                    **** USAGE OF NETPROPHET 3.0 ****                      | #
# ============================================================================= #
usage(){
cat << EOF
    netprophet3.0 [options]
    
    INPUT parameters:
    --p_in_target            : input file for list of target genes
    --p_in_reg               : input file for list of regulators
    --p_in_sample            : input file for list of sample (condition) ids
    --p_in_expr_target       : input file for expression of target genes (target x sample)
    --p_in_expr_reg          : input file for expression of regulators (reg x sample)
    --p_in_net_de            : input file for network of differential expression
    --p_in_binding_event     : input file for binding events |REGULATOR|TARGET|VALUE|
    --seed                   : seed for generating the fold cross valition (default 747)
    
    LASSO parameters:
    --flag_local_shrinkage   : "ON" for estimating a shrinkage parameter for every target gene, "OFF" otherwise (default "ON")
    --flag_global_shrinkage  : "ON" for estimating a shrinkage parameter for all target genes, "OFF" otherwise (default "OFF")
    --flag_microarray        : "MICROARRAY" for microarray expression data, "RNA-SEQ" for RNA-Seq data
    --fname_net_lasso        : name of generated network for lasso
        
    BART parameters:
    --fname_net_bart         : name of generated network for bart
    
    COMBINE parameters:
    --nbr_cv_fold            : number of fold cross validation (default 10)
    --model                  : name of the model for combining networks
    --l_count_top            : array for feed forward run such (3000 2000 1000)
    
    OUTPUT parameters:
    --fname_net_np3          : name of generated network for netprophet
    
    SLURM parameters:
    --flag_slurm             : "ON" for parallel (slurm) run, "OFF" for sequential run
    --p_out_logs             : output file for logs (.out & .err) for slurm runs
    --mail_user              : mail address of the user for slurm run logs
    --mail_type              : when to send an email to the user (default FAIL)
    --data                   : prefix of job names for slurm jobs      
    
    
    
EOF
}

# ======================================================================================================= #
# |                                   **** PARSE ARGUMENTS ****                                         | #
# ======================================================================================================= #

# ------------------------------------------------------------------------------------- #
# |         *** Read default arguments: these arguments are not mandatory ***         | #
# ------------------------------------------------------------------------------------- #

p_src_code=/scratch/mblab/dabid/netprophet/code_netprophet3.0/
flag_debug="OFF"

# INPUT arguments
seed=747

# LASSO arguments
flag_local_shrinkage="ON"
flag_global_shrinkage="OFF"
flag_microarray="MICROARRAY"
fname_net_lasso=net_lasso.tsv

# BART arguments
fname_net_bart=net_bart

# COMBINATION arguments
nbr_cv_fold=10
l_count_top="NONE"

# OUTPUT argunments
fname_net_np3=net_np3.tsv

# SLURM arguments
mail_type=FAIL
mail_user=dabid@wustl.edu
flag_slurm="OFF"

# ------------------------------------------------------------------------------------- #
# |                   *** Read arguments provided by the user ***                     | #
# ------------------------------------------------------------------------------------- #
while getopts ":h-:" OPTION
do
  case "${OPTION}" in
    -)
      case "${OPTARG}" in
        p_in_target)
          p_in_target="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        p_in_reg)
          p_in_reg="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        p_in_sample)
          p_in_sample="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        p_in_expr_target)
          p_in_expr_target="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        p_in_expr_reg)
          p_in_expr_reg="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        flag_local_shrinkage)
          flag_local_shrinkage="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        flag_global_shrinkage)
          flag_global_shrinkage="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        flag_slurm)
          flag_slurm="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        flag_microarray)
          flag_microarray="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        seed)
          seed="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        nbr_cv_fold)
          nbr_cv_fold="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        p_out_dir)
          p_out_dir="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        fname_net_np3)
          fname_net_np3="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        fname_net_lasso)
          fname_net_lasso="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        fname_net_bart)
          fname_net_bart="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        p_in_net_de)
          p_in_net_de="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        p_in_binding_event)
          p_in_binding_event="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        model)
          model="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        p_src_code)
          p_src_code="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        p_out_logs)
          p_out_logs="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        mail_type)
          mail_type="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        mail_user)
          mail_user="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        l_count_top)
          l_count_top=()
          arg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
          i=1
          while [ -n "${arg}" ]
          do
            l_count_top+=(${arg})
            ((i+=1))
            arg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
          done
          ;;
        data)
          data="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          ;;
        
    esac;;

    h)
      usage
      exit 2
      ;;

  esac
done

# ======================================================================================================= #
# |                                    **** END PARSE ARGUMENTS ****                                    | #
# ======================================================================================================= #

# create the output directory if it doesn't exist
mkdir -p ${p_out_dir}

p_out_tmp=${p_out_dir}tmp/
mkdir -p ${p_out_tmp}

p_out_net=${p_out_dir}net/
mkdir -p ${p_out_net}
# ======================================================================================================= #
# |                                   *** GENERATE LASSO NETWORK ***                                    | #
# ======================================================================================================= #
job_id_lasso=1
# if (( ${flag_slurm} == "ON" ))
# then
# job_lasso=$(sbatch \
#   --mail-type=${mail_type} \
#   --mail-user=${mail_user} \
#   -J ${data}_lasso \
#   -o ${p_out_logs}${data}_lasso_%J.out \
#   -e ${p_out_logs}${data}_lasso_%J.err \
#   -n 11 \
#   -D ${p_src_code}code/netprophet1/ \
#   --mem-per-cpu=10GB \
#   --cpus-per-task=2 \
#   ${p_src_code}wrapper/lasso.sh \
#     ${p_in_target} \
#     ${p_in_reg} \
#     ${p_in_sample} \
#     ${p_in_expr_target} \
#     ${p_in_expr_reg} \
#     ${flag_global_shrinkage} \
#     ${flag_local_shrinkage} \
#     ${p_out_net} \
#     ${fname_net_lasso} \
#     ${flag_debug} \
#     ${flag_slurm} \
#     ${seed} \
#     ${nbr_cv_fold} \
#     ${flag_microarray} \
#     ${p_src_code})

# job_id_lasso=$(echo ${job_lasso} | awk '{split($0, a, " "); print a[4]}')

# elif (( ${flag_slurm} == "OFF" ))
# then
# ${p_src_code}wrapper/lasso.sh \
#   ${p_in_target} \
#   ${p_in_reg} \
#   ${p_in_sample} \
#   ${p_in_expr_target} \
#   ${p_in_expr_reg} \
#   ${flag_global_shrinkage} \
#   ${flag_local_shrinkage} \
#   ${p_out_net} \
#   ${fname_net_lasso} \
#   ${flag_debug} \
#   ${flag_slurm} \
#   ${seed} \
#   ${nbr_cv_fold} \
#   ${flag_microarray} \
#   ${p_src_code}
# fi

# ======================================================================================================= #
# |                                 *** END GENERATE LASSO NETWORK ***                                  | #
# ======================================================================================================= #



 
# ======================================================================================================= #
# |                                    *** GENERATE BART NETWORK ***                                    | #
# ======================================================================================================= #
job_id_bart=1

# if (( ${flag_slurm} == "ON" ))
# then
# job_bart=$(sbatch \
#   --mail-type=${mail_type} \
#   --mail-user=${mail_user} \
#   -J ${data}_bart \
#   -o ${p_out_logs}${data}_bart_%J.out \
#   -e ${p_out_logs}${data}_bart_%J.err \
#   -n 32 \
#   --mem=20GB \
#   ${p_src_code}wrapper/bart.sh \
#   ${p_in_target} \
#   ${p_in_reg} \
#   ${p_in_expr_target} \
#   ${p_in_sample} \
#   ${p_out_net}\
#   ${fname_net_bart} \
#   ${flag_slurm} \
#   ${p_src_code})
# job_id_bart=$(echo ${job_bart} | awk '{split($0, a, " "); print a[4]}')
# elif ((${flag_slurm} == "OFF"))
# then
# ${p_src_code}wrapper/bart.sh \
#   ${p_in_target} \
#   ${p_in_reg} \
#   ${p_in_expr_target} \
#   ${p_in_sample} \
#   ${p_out_net}\
#   ${fname_net_bart} \
#   ${flag_slurm} \
#   ${p_src_code}
# fi

# ======================================================================================================= #
# |                                  *** END GENERATE BART NETWORK ***                                  | #
# ======================================================================================================= #

 
# ======================================================================================================= #
# |                                       *** COMBINE NETWORKS ***                                      | #
# ======================================================================================================= #
job_id_combine_net=1
if (( ${flag_slurm} == "ON" ))
then
  job_combine_net=$(sbatch \
      --mail-type=${mail_type} \
      --mail-user=${mail_user} \
      -J ${data}_combine_net \
      -o ${p_out_logs}${data}_combine_net_%J.out \
      -e ${p_out_logs}${data}_combine_net_%J.err \
      --dependency=afterany:${job_id_lasso}:${job_id_bart} \
      ${p_src_code}wrapper/combine_networks_flag_feed_forward.sh \
        --p_out_tmp ${p_out_tmp} \
        --p_out_net ${p_out_net} \
        --p_net_lasso ${p_out_net}${fname_net_lasso} \
        --p_net_bart ${p_out_net}${fname_net_bart} \
        --p_net_de ${p_in_net_de} \
        --p_in_binding_event ${p_in_binding_event} \
        --model ${model} \
        --p_src_code ${p_src_code} \
        --p_net_np3 ${p_out_net}${fname_net_np3} \
        --flag_slurm ${flag_slurm} \
        --seed ${seed} \
        --p_in_reg ${p_in_reg} \
        --p_in_target ${p_in_target} \
        --l_count_top ${l_count_top[@]})
        
  job_id_combine_net=$(echo ${job_combine_net} | awk '{split($0, a, " "); print a[4]}')
  
elif (( ${flag_slurm} == "OFF" ))
then
  ${p_src_code}wrapper/combine_networks_flag_feed_forward.sh \
    --p_out_tmp ${p_out_tmp} \
    --p_out_net ${p_out_net} \
    --p_net_lasso ${p_out_net}${fname_net_lasso} \
    --p_net_bart ${p_out_net}${fname_net_bart} \
    --p_net_de ${p_in_net_de} \
    --p_in_binding_event ${p_in_binding_event} \
    --model ${model} \
    --p_src_code ${p_src_code} \
    --p_net_np3 ${p_out_net}${fname_net_np3} \
    --flag_slurm ${flag_slurm} \
    --seed ${seed} \
    --p_in_reg ${p_in_reg} \
    --p_in_target ${p_in_target} \
    --l_count_top ${l_count_top[@]}
fi
# ======================================================================================================= #
# |                                   *** END COMBINE NETWORKS ***                                      | #
# ======================================================================================================= #




# ======================================================================================================= #
# |                                       *** EVALUATE NETWORKS ***                                     | #
# ======================================================================================================= #
if (( ${flag_slurm} == "ON" ))
then
  job_evaluate_net=$(sbatch \
    --mail-type=${mail_type} \
    --mail-user=${mail_user} \
    -J ${data}_evaluate_net \
      -o ${p_out_logs}${data}_evaluate_net_%J.out \
      -e ${p_out_logs}${data}_evaluate_net_%J.err \
      --dependency=afterok:${job_id_combine_net} \
      ${p_src_code}wrapper/evaluate_network.sh \
        ${p_out_net} \
        ${p_out_net}evaluation.tsv \
        ${data} \
        ${p_in_reg} \
        ${p_in_target} \
        ${p_in_binding_event} \
        ${flag_slurm} \
        ${p_src_code})

elif (( ${flag_slurm} == "OFF" ))
then
  ${p_src_code}wrapper/evaluate_network.sh \
    ${p_out_net}${fname_net_np3} \
    ${p_out_net}eval_${fname_net_np3} \
    ${p_in_reg} \
    ${p_in_target} \
    ${p_in_binding_event}
    ${flag_slurm}
    ${p_src_code}
fi
# ======================================================================================================= #
# |                                   *** END EVALUATE NETWORKS ***                                     | #
# ======================================================================================================= #
