generate_lasso_net = function(p_in_target
                              , p_in_reg
                              , p_in_sample
                              , p_in_expr_target
                              , p_in_expr_reg
                              , p_out_dir
                              , flag_global_shrinkage
                              , flag_local_shrinkage
                              , flag_rerank_greenfield
                              , flag_greenfield_method
                              , fname_lasso
                              , flag_debug
                             ){
  
   # ================================================== #
   # |         **** Load local R libraries ****       | #
   # ================================================== #
   source("/scratch/mblab/dabid/netprophet/code_NetProphet_2.0/SRC/NetProphet1/global.lars.regulators.r")  # for generating lasso network
   source("/scratch/mblab/dabid/netprophet/code_NetProphet_2.0/prepare_data.R")  # for preparing data
   
   if (flag_debug == "ON"){
      p_in_target = '/scratch/mblab/dabid/netprophet/net_debug/target'
      p_in_reg = '/scratch/mblab/dabid/netprophet/net_debug/reg'
      p_in_sample = '/scratch/mblab/dabid/netprophet/net_debug/sample'
      p_in_expr_target ='/scratch/mblab/dabid/netprophet/net_debug/expr_target'
      p_in_expr_reg = '/scratch/mblab/dabid/netprophet/net_debug/expr_reg'
      flag_global_shrinkage = 'ON'
      flag_local_shrinkage = 'OFF'
      p_out_dir = '/scratch/mblab/dabid/netprophet/net_debug/'
      fname_lasso = '/scratch/mblab/dabid/netprophet/net_debug/net_lasso.tsv'
      flag_rerank_greenfield = "ON"
      flag_greenfield_method ="TWO"
   }
   
   
   # if output directory doesn't exist, create it
   ifelse(!dir.exists(file.path(p_out_dir))
          , dir.create(file.path(p_out_dir), showWarnings=FALSE)
          , FALSE
          )
   # read list of target genes, regulators, and samples
   l_in_target = read.csv(p_in_target, header=FALSE)[[1]]
   l_in_reg = read.csv(p_in_reg, header=FALSE)[[1]]
   l_in_sample = read.csv(p_in_sample, header=FALSE)[[1]]
   
   # generate intermediate files (allowed and perturbed)
   df_allowed_perturbed = generate_allowed_perturbed_matrices(l_in_target, l_in_reg, l_in_sample, p_out_dir)
   df_allowed = as.matrix(df_allowed_perturbed[[1]])
   df_perturbed = as.matrix(df_allowed_perturbed[[2]])
 
   # scale and normalize expression matrix of target genes
   df_expr_target = read.csv(p_in_expr_target, header=FALSE, sep="\t")
   df_expr_target = scale_normalize_expr_matrix(df_expr_target)
   df_expr_target = as.matrix(df_expr_target)
   # scale and normalizr expression matrix of regulators
   df_expr_reg = read.csv(p_in_expr_reg, header=FALSE, sep="\t")
   df_expr_reg = scale_normalize_expr_matrix(df_expr_reg)
   df_expr_reg = as.matrix(df_expr_reg)
  
   # generate lasso network
   if (flag_local_shrinkage == "ON"){
     df_lasso_net = lars.local(df_expr_target
                            , df_expr_reg
                            , df_perturbed
                            , prior
                            , df_allowed
                            , skip_reg
                            ,skip_gen)
     } else if(flag_global_shrinkage == "ON"){
     df_prior = matrix(1,ncol=dim(df_expr_target)[1] ,nrow=dim(df_expr_reg)[1] )
     df_lasso_net = lars.multi.optimize(df_expr_target
                                     , df_expr_reg
                                     , df_perturbed
                                     , df_prior
                                     , df_allowed)[[1]]
     } else if(flag_rerank_greenfield == "ON"){
      
      # generate lasso with all regulators and calculate MSE for every target
      df_prior = matrix(1, ncol=dim(df_expr_target)[1], nrow=dim(df_expr_reg)[1])
      df_lasso_net_full_reg = lars.multi.optimize(df_expr_target
                                                  , df_expr_reg
                                                  , df_perturbed
                                                  , df_prior
                                                  , df_allowed)[[1]]
      # calculate MSE for full-regulator lasso
      mse_full_reg = list()
      for (idx_target in seq(1, length(l_in_target), 1)){
         mse_full_reg[idx_target] = 1/length(l_in_sample) * sum((df_expr_target[idx_target, ] - (t(df_expr_reg) %*% df_lasso_net_full_reg[, idx_target]))**2)
      }
      # generate lasso with removing a predictor each time
      net_lasso_greenfield = list()
      for (idx_reg in seq(1, length(l_in_reg), 1)){
         # generate the allowed and perturbed matrices for reg minus
         df_allowed_perturbed_minus_reg = generate_allowed_perturbed_matrices(l_in_target, l_in_reg[-idx_reg], l_in_sample, p_out_dir)
         df_allowed_minus_reg = as.matrix(df_allowed_perturbed_minus_reg[[1]])
         df_perturbed_minus_reg = as.matrix(df_allowed_perturbed_minus_reg[[2]])
         # create the df_expr_reg_minus_reg
         df_expr_reg_minus_reg = df_expr_reg[-idx_reg, ]
         df_prior_minus_reg = matrix(1,ncol=dim(df_expr_target)[1] ,nrow=dim(df_expr_reg_minus_reg)[1])
         
         if (flag_greenfield_method == "TWO"){
            df_lasso_net_minus_reg = lars.multi.optimize(df_expr_target
                                                         , df_expr_reg_minus_reg
                                                         , df_perturbed_minus_reg
                                                         , df_prior_minus_reg
                                                         , df_allowed_minus_reg)[[1]]
         }
         else if (flag_greenfield_method == "ONE"){
            df_lasso_net_minus_reg = df_lasso_net_full_reg[-idx_reg, ]
         }
         
         # calculate MSE for minus-regulator for every target
         mse_minus_reg = list()
         for (idx_target in seq(1, length(l_in_target), 1)){
            mse_minus_reg[idx_target] = 1/length(l_in_sample) * sum((df_expr_target[idx_target, ] -(t(df_expr_reg_minus_reg) %*% df_lasso_net_minus_reg[, idx_target]))**2)
         }
         
         net_lasso_greenfield[[idx_reg]] = mapply("-"
                                                    , matrix(1, ncol=1, nrow = length(l_in_target))
                                                    ,(mapply("/",mse_full_reg,mse_minus_reg,SIMPLIFY = FALSE))
                                                    , SIMPLIFY=FALSE
                                                    )
         df_lasso_net = data.frame(matrix(unlist(net_lasso_greenfield), ncol=max(lengths(net_lasso_greenfield)), byrow=TRUE))
      }
   }
   
   # write lasso network
   write.table(df_lasso_net
               , file.path(p_out_dir, fname_lasso)
               , row.names=FALSE
               , col.names=FALSE
               , quote=FALSE
               )
   return(0)
}

if (sys.nframe() == 0){
  # =========================================== #
  # |       *** Install packages ***          | #
  # =========================================== #
  if (!require(optparse)) {  # library for parsing arguments
    install.packages("optparse", repo="http://cran.rstudio.com/")
    library("optparse")
  }
  
  # =========================================== #
  # |         **** Parse Arguments ****       | #
  # =========================================== #
  p_in_expr_target = make_option(c("--p_in_expr_target"), type="character", help='input - path of expression of target genes')
  p_in_expr_reg = make_option(c("--p_in_expr_reg"), type="character", help="input - path of expression of regulators")
  p_in_target = make_option(c("--p_in_target"), type="character", default=NULL, help="input - path of list of target gene ids")
  p_in_reg = make_option(c("--p_in_reg"), type="character", default=NULL, help="input - path of list of regulator ids")
  p_in_sample = make_option(c("--p_in_sample"), type="character", default=NULL, help="path of list of samples ids")
  flag_global_shrinkage = make_option(c("--flag_global_shrinkage"), type="character", default="OFF", help="ON or OFF for netprophet1.0 global shrinkage")
  flag_local_shrinkage = make_option(c("--flag_local_shrinkage"), type="character", default="OFF", help="ON or OFF for netprophet1.0 local shrinkage")
  flag_rerank_greenfield = make_option(c("--flag_rerank_greenfield"), type="character", default="OFF", help="ON or OFF for reranking LASSO using the method of greenfiled paper")
  flag_greenfield_method = make_option(c("--flag_greenfield_method"), type="character", default="ONE", help="ONE or TWO for greenfield method 1 or 2")
  fname_lasso = make_option(c("--fname_lasso"), type="character", default=NULL, help="output - path of generated lasso network")
  p_out_dir = make_option(c("--p_out_dir"), type="character", default=NULL, help="output - path of output directory for results")
  flag_debug = make_option(c("--flag_debug"), type="character", default="OFF", help="flag for debugging mode.")
  
  opt_parser = OptionParser(option_list=list(p_in_target, p_in_reg, p_in_sample, p_in_expr_target, p_in_expr_reg
                                             , flag_global_shrinkage, flag_local_shrinkage, flag_rerank_greenfield
                                             , flag_greenfield_method, p_out_dir, fname_lasso, flag_debug
                                             ))
  opt = parse_args(opt_parser)
  
  if (is.null(opt$p_in_target) || is.null(opt$p_in_reg) || is.null(opt$p_in_sample)
      || is.null(opt$p_in_expr_target) || is.null(opt$p_in_expr_reg)
      ){
    print_help(opt_parser)
    stop("all arguments p_in_target, p_in_reg, p_in_sample, p_in_expr_target, p_in_expr_reg are mandatory")
  }
  
  quit(status=generate_lasso_net(p_in_target=opt$p_in_target
                                 , p_in_reg=opt$p_in_reg
                                 , p_in_sample=opt$p_in_sample
                                 , p_in_expr_target=opt$p_in_expr_target
                                 , p_in_expr_reg=opt$p_in_expr_reg
                                 , flag_global_shrinkage=opt$flag_global_shrinkage
                                 , flag_local_shrinkage=opt$flag_local_shrinkage
                                 , flag_rerank_greenfield=opt$flag_rerank_greenfield
                                 , flag_greenfield_method=opt$flag_greenfield_method
                                 , p_out_dir=opt$p_out_dir
                                 , fname_lasso=opt$fname_lasso
                                 , flag_debug=opt$flag_debug
                                 ))
}









