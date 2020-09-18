#!/bin/bash

while getopts ":h-:" OPTION
do
    case "${OPTION}" in
        h)
            echo "help"
            ;;
        -)
            case "${OPTARG}" in
                p_in_reg)
                    p_in_reg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_in_target)
                    p_in_target="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_in_binding_event)
                    p_in_binding_event="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                flag_slurm)
                    flag_slurm="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_src_code)
                    p_src_code="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_out_file_eval)
                    p_out_file_eval="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                l_p_in_net)
                    l_p_in_net=()
                    nargs="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    for (( i=1; i<`expr ${nargs}+1`; i++ ))
                    do
                        arg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                        l_p_in_net+=("${arg}")
                    done
                    ;;
                l_fname_net)
                    l_fname_net=()
                    nargs="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    for (( i=1; i<`expr ${nargs}+1`; i++ ))
                    do
                        arg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                        l_fname_net+=("${arg}")
                    done
                    ;;
                p_in_dir_net)
                    p_in_dir_net="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                esac;;
        esac
done


if [ ${flag_slurm} == "ON" ]
then
  source ${p_src_code}wrapper/load_modules.sh
fi

source activate netprophet
for (( i=0; i<${#l_p_in_net[@]}; i++))
do
    p_in_net=${l_p_in_net[i]}
    fname_net=${l_fname_net[i]}
    echo "p_in_net: ${p_in_net}"
    echo "fname_net: ${fname_net}"
    python ${p_src_code}code/evaluate_network.py \
      --p_in_net ${p_in_net} \
      --p_out_eval ${p_out_file_eval} \
      --fname_net ${fname_net} \
      --p_in_reg ${p_in_reg} \
      --p_in_target ${p_in_target} \
      --p_in_binding_event ${p_in_binding_event}
done

pushd ${p_in_dir_net} > /dev/null
for fname_net in ./net_*
do
  python ${p_src_code}code/evaluate_network.py \
    --p_in_net ${p_in_dir_net}${fname_net} \
    --p_out_eval ${p_out_file_eval} \
    --fname_net ${fname_net} \
    --p_in_reg ${p_in_reg} \
    --p_in_target ${p_in_target} \
    --p_in_binding_event ${p_in_binding_event}
done

source deactivate netprophet
