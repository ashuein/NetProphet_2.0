#TODO add a description for this function
generate_allowed_perturbed_matrices = function (l_in_target
                                                , l_in_reg
                                                , l_in_sample
                                                , p_out_dir
                                               ){
  # DEBUG MODE
  # p_in_target='/scratch/mblab/dabid/netprophet/net_in/sub3_in_target_5111'
  # p_in_reg='/scratch/mblab/dabid/netprophet/net_in/sub3_in_reg_tf_124'
  # p_in_sample='/scratch/mblab/dabid/netprophet/net_in/kem_in_condition_1485'
  # p_out_dir='/scratch/mblab/dabid/netprophet/net_debug/'
  
  source("/scratch/mblab/dabid/netprophet/code_NetProphet_2.0/helper.R")
  out = tryCatch(
    {
      # generated the allowed matrix
      df_allowed = data.frame(matrix(1, length(l_in_reg), length(l_in_target)))
      rownames(df_allowed) = l_in_reg
      colnames(df_allowed) = l_in_target
      for (reg in l_in_reg){
        df_allowed[reg, reg] = 0
      }
      
      # generate the perturbed matrix
      df_perturbed = data.frame(matrix(0, length(l_in_target), length(l_in_sample)))
      rownames(df_perturbed) = l_in_target
      colnames(df_perturbed) = l_in_sample
      for (target in l_in_target){
        df_perturbed[target, target] = 1
      }
      
      if (!is.null(p_out_dir)){
        # if output directory doesn't exit, create it
        ifelse(!dir.exists(file.path(p_out_dir, 'tmp')), dir.create(file.path(p_out_dir, 'tmp'), showWarnings = FALSE), FALSE)
        # write allowed matrix
        write.table(file=file(paste(p_out_dir, 'tmp/', 'allowed.tsv', sep=''))
                    , x=df_allowed
                    , row.names=FALSE
                    , col.names=FALSE
                    , sep="\t"
        )
        # write perturbed matrix
        write.table(file=file(paste(p_out_dir, 'tmp/','perturbed.tsv', sep=''))
                    , x=df_perturbed
                    , row.names=FALSE
                    , col.names=FALSE
                    , sep="\t"
        )
      }
    }, warning = function(war) {
      message("warning - prepare_data.R")
      message(war$message)
      message(war$call)
      return(1)
    }, error = function(err){
      err <<- err
      message("error - prepare_data.R")
      message(err$message, "\nin ")
      message(err$call)
      return(1)
    }, finally = {
      message("prepare_data.R exited")
    }
  )
  # return allowed and perturbed matrices
  data = list()
  data[[1]] = df_allowed
  data[[2]] = df_perturbed
  
  data
}

scale_normalize_expr_matrices = function(p_in_expr_target
                                         , p_in_expr_reg
                                         ){
  
  # DEBUG MODE
  # p_in_expr_target = '/scratch/mblab/dabid/netprophet/net_in/sub2_kem_expr_6023_1485'
  # p_in_expr_reg = '/scratch/mblab/dabid/netprophet/net_in/sub2_kem_expr_reg_151_1485'
  
  # scale target expression
  df_expr_target = read.csv(p_in_expr_target, header=FALSE, sep="\t")
  df_expr_target = df_expr_target - apply(df_expr_target, 1, mean)
  sd_expr_target = apply(df_expr_target,1,sd)
  sd_floor_expr_target = mean(sd_expr_target) + sd(sd_expr_target)
  norm_expr_target = apply(rbind(rep(sd_floor_expr_target,times=length(sd_expr_target)),sd_expr_target),2,max) / sqrt(dim(df_expr_target)[2])
  df_expr_target = df_expr_target / (norm_expr_target* sqrt(dim(df_expr_target)[2]-1))
  
  # scale regulator expression
  df_expr_reg = read.csv(p_in_expr_reg, header=FALSE, sep="\t") 
  df_expr_reg = df_expr_reg - apply(df_expr_reg, 1, mean) # center data
  sd_expr_reg = apply(df_expr_reg,1,sd)
  sd_floor_expr_reg = mean(sd_expr_reg) + sd(sd_expr_reg)
  norm_expr_reg = apply(rbind(rep(sd_floor_expr_reg,times=length(sd_expr_reg)),sd_expr_reg),2,max) / sqrt(dim(df_expr_reg)[2])
  df_expr_reg = df_expr_reg / (norm_expr_reg * sqrt(dim(df_expr_reg)[2]-1))
  
  # return scaled and normalized expression matrices for target and regulators
  data = list()
  data[[1]] = df_expr_target
  data[[2]] = df_expr_reg
  data
}

if (sys.nframe() == 0){
# if (identical (environment (), globalenv ())){
  # install and load optparse package
  if (!require(optparse)){
    install.packages("optparse", repo="http://cran.rstudio.com/")
    library("optparse")
  }

  # parse arguments
  p_in_target = make_option(c("--p_in_target"), type="character", default=NULL, help="input - file of list of target gene ids")
  p_in_reg =  make_option(c("--p_in_reg"), type="character", default=NULL, help="input - file of list of regulator ids")
  p_in_sample = make_option(c("--p_in_sample"), type="character", default=NULL, help="input - file of list of sample ids")
  p_out_dir = make_option(c("--p_out_dir"), type="character", default=NULL, help="output - directory of output files")
  opt_parser = OptionParser(option_list=list(p_in_target, p_in_reg, p_in_sample, p_out_dir))
  opt = parse_args(opt_parser)

  if (is.null(opt$p_in_target) || is.null(opt$p_in_reg) || is.null(opt$p_in_sample)){
    print_help(opt_parser)
    stop("all arguments p_in_target, p_in_reg, and p_in_sample are mandatory")
  }

  # read the lists of target genes, regualtors, and samples
  l_in_target = read.csv(opt$p_in_target, header=FALSE)[[1]]
  l_in_reg = read.csv(opt$p_in_reg, header=FALSE)[[1]]
  l_in_sample = read.csv(opt$p_in_sample, header=FALSE)[[1]]

  # call prepare_data function
  quit(status=prepare_data(l_in_target=l_in_target
                           , l_in_reg=l_in_reg
                           , l_in_sample=l_in_sample
                           , p_out_dir=opt$p_out_dir
                          ));
}

