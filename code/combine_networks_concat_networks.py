from json import load

#d_config__value = load(open('config.json', 'r'))
#FLAG_DEBUG = d_config__value['debug']
#P_CONFIG = d_config__value['p_config']


def concat_networks(p_in_dir_data
                    , p_in_dir_pred
                    , p_out_file
                    , file_suffix
                    , flag_matrix
                    , p_in_reg
                    , p_in_target
                   ):
    from pandas import read_csv, concat, DataFrame, pivot_table
    from json import load

    # concatenate the sub-networks
    df_net = DataFrame()
    for i in range(10):
        p_pred_test = p_in_dir_pred + "fold" + str(i) + (file_suffix if file_suffix else "_pred_test.tsv")
        df = read_csv(p_pred_test, header=None, sep="\t")
        if len(list(df.columns)) > 3:  # matrix format
            l_reg = list(read_csv(p_in_dir_data + "fold" + str(i) + "_test_reg", header=None, sep="\t")[0])
            df.index = l_reg
        df_net = concat([df_net, df], axis="index")

    if len(list(df.columns)) > 3:  # reindex the matrix in case of matrix
        # extract info about regulators from config file
        # d_run_config__value = load(open(P_CONFIG, 'r'))
        #  p_reg = d_run_config__value['p_reg']
        l_reg_all = list(read_csv(p_reg, header=None)[0])
        df_net = df_net.reindex(l_reg_all, axis='index')
    elif flag_matrix == "ON":
        df_net.columns = ['REGULATOR', 'TARGET', 'VALUE']
        df_net = pivot_table(df_net, values='VALUE', index=['REGULATOR'], columns=['TARGET'])
        l_reg = list(read_csv(p_in_reg, header=None)[0])
        l_target = list(read_csv(p_in_target, header=None)[0])
        df_net = df_net.reindex(l_reg, axis='index', fill_value=0)
        df_net = df_net.reindex(l_target, axis='columns', fill_value=0) 
    df_net.to_csv(p_out_file, header=False, index=False, sep='\t')
    

def main():
    FLAG_DEBUG = 'OFF'
    if FLAG_DEBUG == 'ON':
        concat_networks(p_in_dir_data='/Users/dhohaabid/Documents/netprophet3.0/net_out/kem_data_10cv_seed7/'
                        , p_in_dir_pred='/Users/dhohaabid/Documents/netprophet3.0/net_out/kem_netprophet_10cv_seed7/'
                        , p_out_file='/Users/dhohaabid/Documents/netprophet3.0/net_out/debug/concatenated.tsv'
                        , file_suffix=None)
    else:
        from argparse import ArgumentParser

        parser = ArgumentParser()
        parser.add_argument("--p_in_dir_data", "-p_in_dir_data", help="path of input directory of training/testing files")
        parser.add_argument("--p_in_dir_pred", "--p_in_dir_pred", help="path of input directory of model and predictions")
        parser.add_argument("--p_out_file", "-p_out_file", help="path of output directory")
        parser.add_argument("--file_suffix", "-file_suffix", nargs='?', default=None,
                            help="suffix of files for concatenation")
        parser.add_argument("--flag_matrix", "-flag_matrix", nargs="?", default="OFF"
                            , help="ON or OFF, for outputing matrix network or not")
        parser.add_argument("--p_in_reg", "-p_in_reg", help="path of file for regulators")
        parser.add_argument("--p_in_target", "-p_in_target", help="path of file for targets")
        args = parser.parse_args()

        concat_networks(p_in_dir_data=args.p_in_dir_data
                        , p_in_dir_pred=args.p_in_dir_pred
                        , p_out_file=args.p_out_file
                        , file_suffix=args.file_suffix
                        , flag_matrix=args.flag_matrix
                        , p_in_reg=args.p_in_reg
                        , p_in_target=args.p_in_target
                        )


if __name__ == "__main__":
    main()
