#!/bin/bash


while getopts ":h-:" OPTION
do
  case "${OPTION}" in
    -)
      case "${OPTARG}" in
      p_out_tmp)
        p_out_tmp="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
        ;;
      p_out_net)
        p_out_net="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
        ;;
      p_net_lasso)
        p_net_lasso="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
        ;;
      p_net_bart)
        p_net_bart="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
        ;;
      p_net_de)
        p_net_de="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
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
      p_net_np3)
        p_net_np3="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
        ;;
      flag_slurm)
        flag_slurm="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
        ;;
      seed)
        seed="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
        ;;
      p_in_reg)
        p_in_reg="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
        ;;
      p_in_target)
        p_in_target="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
        ;;
      l_count_top)
        l_count_top=()
        arg="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
        i=1
        while [ -n "${arg}" ]
        do
          l_count_top+=(${arg})
          ((i+=1))
          arg="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
        done
        ;;
      esac;;
    
    h)
      echo "usage"
      exit 2
      ;;
  esac
done

echo "combine_network_flag_feed_forward.sh ${l_count_top[@]}"

if (( ${flag_slurm} == "ON" ))
then
  source ${p_src_code}wrapper/load_modules.sh
fi

echo "create binding network from binding events.."
p_net_binding=${p_out_tmp}net_binding.tsv

${p_src_code}wrapper/create_binding_network.sh \
  ${p_in_binding_event} \
  ${p_in_reg} \
  ${p_in_target} \
  ${p_net_binding} \
  ${flag_slurm} \
  ${p_src_code}

echo "combine networks.."
${p_src_code}wrapper/combine_networks.sh \
    ${p_out_tmp} \
    ${p_net_lasso} \
    ${p_net_bart} \
    ${p_net_de} \
    ${p_net_binding} \
    ${model} \
    ${p_src_code} \
    ${p_net_np3} \
    ${flag_slurm} \
    ${seed} \
    ${p_in_reg} \
    ${p_in_target}

echo "Start feed.."
if (( ${l_count_top} != "NONE" ))
then
    p_in_top_net=${p_net_np3}
    for (( i=0; i<${#l_count_top[@]}; i++ ))
    do
        count_top=${l_count_top[i]}
        mkdir -p ${p_out_tmp}top_${count_top}/

        echo "select top ${count_top}"
        source activate netprophet
        python ${p_src_code}code/select_top_k_edges.py \
            --p_in_top_net ${p_in_top_net} \
            --l_net_name binding lasso de bart\
            --l_p_in_net ${p_net_binding} ${p_net_lasso} ${p_net_de} ${p_net_bart} \
            --p_out_dir ${p_out_tmp}top_${count_top}/ \
            --l_out_fname_net binding.tsv lasso.tsv de.tsv bart.tsv \
            --top ${count_top} \
            --p_reg ${p_in_reg} \
            --p_target ${p_in_target}
        source deactivate netprophet
        
        echo "combine networks top ${count_top}"
        ${p_src_code}wrapper/combine_networks.sh \
            ${p_out_tmp}top_${count_top}/ \
            ${p_out_tmp}top_${count_top}/lasso.tsv \
            ${p_out_tmp}top_${count_top}/bart.tsv \
            ${p_out_tmp}top_${count_top}/de.tsv \
            ${p_out_tmp}top_${count_top}/binding.tsv \
            ${model} \
            ${p_src_code} \
            ${p_out_net}net_np3_${count_top}.tsv \
            ${flag_slurm} \
            ${seed} \
            ${p_in_reg} \
            ${p_in_target}
        
        p_in_top_net=${p_out_net}net_np3_${count_top}.tsv 
    done
fi