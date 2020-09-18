combine_networks = function(p_in_train_binding
                            , p_in_train_lasso
                            , p_in_train_de
                            , p_in_train_bart
                            , p_in_train_pwm
                            , p_in_test_binding
                            , p_in_test_lasso
                            , p_in_test_de
                            , p_in_test_pwm
                            , p_in_test_bart
                            , in_model
                            , p_out_pred_train
                            , p_out_pred_test
                            , p_out_model_summary
                            , sep
                            , p_in_train_reg
                            , p_in_test_reg
                            ){
  # ==================================================================== #
  # |                     *** READ INPUT DATA ***                      | #
  # ==================================================================== #
  # ------------------------------------ #
  # |         ** Training **           | #
  # ------------------------------------ #
  # BINDING
  if (!is.null(p_in_train_binding)){
    df_in_train_binding = read.csv(p_in_train_binding, header=FALSE, sep=sep)
    if (length(colnames(df_in_train_binding)) > 3){
      train_binding= unlist(df_in_train_binding)
    } else{
      train_binding = df_in_train_binding[3]
      colnames(train_binding) = "binding"
      l_train_reg = df_in_train_binding[1]
      colnames(l_train_reg) = "REGULATOR"
      l_train_target = df_in_train_binding[2]
      colnames(l_train_target) = "TARGET"
    }
  }
  # LASSO
  if (!is.null(p_in_train_lasso) & p_in_train_lasso != "NONE"){
    df_in_train_lasso = read.csv(p_in_train_lasso, header=FALSE, sep=sep)
    if (length(colnames(df_in_train_lasso)) > 3){
      train_lasso = unlist(df_in_train_lasso)
    } else{
      train_lasso = df_in_train_lasso[3]
    }
      colnames(train_lasso) = "lasso"
  }
  # DE
  if (!is.null(p_in_train_de) & p_in_train_de != "NONE"){
    df_in_train_de = read.csv(p_in_train_de, header=FALSE, sep=sep)  
    if (length(colnames(df_in_train_de)) > 3){
      train_de = unlist(df_in_train_de)
    } else{
      train_de = df_in_train_de[3]
    }
    colnames(train_de) = "de"
  }
  # BART
  if (!is.null(p_in_train_bart) & p_in_train_bart != "NONE"){
    df_in_train_bart = read.csv(p_in_train_bart, header=FALSE, sep=sep)
    if (length(colnames(df_in_train_bart)) > 3){
      train_bart = unlist(df_in_train_bart)
    } else{
      train_bart = df_in_train_bart[3]
    }
    colnames(train_bart) = "bart"
  }
  # PWM
  if (!is.null(p_in_train_pwm) & p_in_train_pwm != "NONE") {
    df_in_train_pwm = read.csv(p_in_train_pwm, header=FALSE, sep=sep)
    if (length(colnames(df_in_train_pwm)) > 3){
      train_pwm = unlist(df_in_train_pwm)
    } else{
      train_pwm = df_in_train_pwm[3]
    }
    colnames(train_pwm) = "pwm"
  }
  # list of regulators for traning
  if (!is.null(p_in_train_reg)){
    l_in_train_reg = read.csv(p_in_train_reg, header=FALSE)[[1]]
  }
  
  # ------------------------------------ #
  # |         ** Testing **            | #
  # ------------------------------------ #
  # LASSO
  if (!is.null(p_in_test_lasso) & p_in_test_lasso != "NONE"){
    df_in_test_lasso = read.csv(p_in_test_lasso, header=FALSE, sep=sep)
    if (length(colnames(df_in_test_lasso)) > 3){
      df_in_test_lasso = unlist(df_in_test_lasso)
    } else{
      test_lasso = df_in_test_lasso[3]
      colnames(test_lasso) = "lasso"
      l_test_reg = df_in_test_lasso[1]
      colnames(l_test_reg) = "REGULATOR"
      l_test_target = df_in_test_lasso[2]
      colnames(l_test_target) = "TARGET"
    }
  }
  # DE
  if (!is.null(p_in_test_de) & p_in_test_de != "NONE"){
    df_in_test_de = read.csv(p_in_test_de, header=FALSE, sep=sep)
    if (length(colnames(df_in_test_de)) > 3){
      test_de = unlist(df_in_test_de)
    } else{
      test_de = df_in_test_de[3]
    }
    colnames(test_de) = "de"
  }
  # BART
  if (!is.null(p_in_test_bart) &  p_in_test_bart != "NONE"){
    df_in_test_bart = read.csv(p_in_test_bart, header=FALSE, sep=sep)
    if (length(colnames(df_in_test_bart)) > 3){
      test_bart = unlist(df_in_test_bart)
    } else{
      test_bart = df_in_test_bart[3]
    }
    colnames(test_bart) = "bart"
  }
  # PWM
  if (!is.null(p_in_test_pwm) & p_in_test_pwm != "NONE"){
    df_in_test_pwm = read.csv(p_in_test_pwm, header=FALSE, sep=sep)
    if (length(colnames(df_in_test_pwm)) > 3){
      test_pwm = unlist(df_in_test_pwm)
    } else{
      test_pwm = df_in_test_pwm[3]
    }
    colnames(test_pwm) = "pwm"
  }
  # list of regulators for testing
  if (!is.null(p_in_test_reg)){
      l_in_test_reg = read.csv(p_in_test_reg, header=FALSE)[[1]]
  }
  
  # ==================================================================== #
  # |                  *** END READ INPUT DATA ***                     | #
  # ==================================================================== #
 
  
  # ==================================================================== #
  # |                    *** START TRAIN MODELS ***                    | #
  # ==================================================================== #
  if (in_model == "signdummy"){
    
  }else if (in_model == "netprophet1_all cases"){
    # interaction term
    if (!is.null(p_in_train_lasso) & p_in_train_lasso != "NONE"){
      train_interact = train_lasso
    }
    if (!is.null(p_in_train_bart) & p_in_train_bart != "NONE"){
      train_interact = train_interact * train_bart
    }
    if (!is.null(p_in_train_de) & p_in_train_de != "NONE"){
      train_interact = train_interact * train_de
    }
    if (!is.null(p_in_train_pwm) & p_in_train_pwm != "NONE"){
      train_interact = train_interact * train_pwm
    }
    
    # 
    df_train_interact = data.frame()
    
  } else if (in_model == "netprophet1"){
    # ================================================================ #
    # | this is the implementation of netprophet1 with the six cases | #
    # | of LASSO and DE. In this model, LASSO and DE predictors are  | #
    # | mandatory. BART and PWM are not                              | #
    # ================================================================ #
    # -------------------------------------------------------------- #
    # |         ** Prepare Training data & Train model ***         | #
    # -------------------------------------------------------------- #
    
    # predictors and interaction terms
    df_train_lasso_de_interact = data.frame(lasso=abs(train_lasso), de=abs(train_de))
    train_interact = train_lasso * train_de
    if (!is.null(p_in_train_bart) & p_in_train_bart != "NONE"){
      train_interact = train_interact * train_bart
      df_train_lasso_de_interact$bart = abs(train_bart)
    }
    if (!is.null(p_in_train_pwm) & p_in_train_pwm != "NONE"){
      train_interact = train_interact * train_pwm
      df_train_lasso_de_interact$pwm = abs(train_pwm)
    }
    colnames(train_interact) = "interact"
    df_train_lasso_de_interact$interact = abs(train_interact)
    
    # df_training with all 6 cases
    df_training = data.frame(binding=train_binding
                             , pos_pos=as.integer(train_lasso>0 & train_de>0) * df_train_lasso_de_interact
                             , neg_neg=as.integer(train_lasso<0 & train_de<0) * df_train_lasso_de_interact
                             , pos_neg=as.integer(train_lasso>0 & train_de<0) * df_train_lasso_de_interact
                             , neg_pos=as.integer(train_lasso<0 & train_de>0) * df_train_lasso_de_interact
                             , nz_z=as.integer(train_lasso != 0 & train_de == 0) * data.frame(lasso_nz=abs(train_lasso))
                             , z_nz=as.integer(train_lasso == 0 & train_de != 0) * data.frame(de_nz=abs(train_de))
                             )
    # train model
    model = glm(binding ~ ., data=df_training, family = binomial)
    
    # -------------------------------------------------------------- #
    # |          ** Prepare Testing data & Test model ***          | #
    # -------------------------------------------------------------- #
    # predictors and interaction terms
    df_test_lasso_de_interact = data.frame(lasso=abs(test_lasso), de=abs(test_de))
    test_interact = test_lasso*test_de
    if (!is.null(p_in_test_bart) & p_in_test_bart != "NONE"){
      test_interact = test_interact * test_bart
      df_test_lasso_de_interact$bart = abs(test_bart)
    }
    if (!is.null(p_in_test_pwm) & p_in_test_pwm != "NONE"){
      test_interact = test_interact * test_pwm
      df_test_lasso_de_interact$pwm = abs(test_pwm)
    }
    colnames(test_interact) = "interact"
    df_test_lasso_de_interact$interact = abs(test_interact)
    # prepare testing data for all 6 cases
    df_testing = data.frame(pos_pos=as.integer(test_lasso>0 & test_de>0) * df_test_lasso_de_interact
                            , neg_neg=as.integer(test_lasso<0 & test_de<0) * df_test_lasso_de_interact
                            , pos_neg=as.integer(test_lasso>0 & test_de<0) * df_test_lasso_de_interact
                            , neg_pos=as.integer(test_lasso<0 & test_de>0) * df_test_lasso_de_interact
                            , nz_z=as.integer(test_lasso != 0 & test_de == 0) * data.frame(lasso_nz=abs(test_lasso))
                            , z_nz=as.integer(test_lasso == 0 & test_de != 0) * data.frame(de_nz=abs(test_de)))
    
    # -------------------------------------------------------------- #
    # |            ** PREDICT Training & Testing data **           | #
    # -------------------------------------------------------------- #
    predict_train = predict(model, df_training, type="response")
    predict_test = predict(model, df_testing, type="response")
    
    # -------------------------------------------------------------- #
    # |              ** Write Predictions in Files ***             | #
    # -------------------------------------------------------------- #
    # write the model
    capture.output(summary(model), file=p_out_model_summary, append=FALSE)
    
    # Write prediction for training data
    if (!is.null(p_in_train_reg)){  # if list of regulators of training is provided, write the prediction into a matrix
      write.table(file=file(p_out_pred_train)
                  , x=data.frame(matrix(predict_train, nrow=length(l_in_train_reg), byrow=FALSE)))
    } else{  # else write them into a list |REGULATOR|TARGET|VALUE|
      write.table(file=file(p_out_pred_train)
                  , x=data.frame(REGULATOR=l_train_reg, TARGET=l_train_target, VALUE=predict_train)
                  , row.names=FALSE, col.names=FALSE, sep="\t", quote=FALSE)
    }
    
    # write predition for testing data
    if (!is.null(p_in_test_reg)){
      write.table(file=file(p_out_pred_test)
                  , x=data.frame(matrix(predict_test, nrow=length(l_in_test_reg), byrow=FALSE))
                  , row.names=FALSE, col.names=FALSE, sep="\t")
    } else{
      write.table(file=file(p_out_pred_test)
                  , x=data.frame(REGULATOR=l_test_reg, TARGET=l_test_target, VALUE=predict_test)
                  , row.names=FALSE, col.names=FALSE, sep="\t", quote=FALSE)
    }
    
    
  }
  # ==================================================================== #
  # |                       *** END TRAIN MODEL ***                    | #
  # ==================================================================== #
}

if (sys.nframe() == 0){
  if (!require(optparse)){
    install.packages("optparse", repo="http://cran.rstudio.com/")
    library("optparse")
  }
  # training input
  p_in_train_binding = make_option(c("--p_in_train_binding"), type="character", help="path of binding network for training")
  p_in_train_lasso = make_option(c("--p_in_train_lasso"), type="character", help="path of lasso network for training")
  p_in_train_de = make_option(c("--p_in_train_de"), type="character", help="path of de network for training")
  p_in_train_bart = make_option(c("--p_in_train_bart"), type="character", default=NULL, help="path of bart network for training")
  p_in_train_pwm = make_option(c("--p_in_train_pwm"), type="character", default=NULL, help="path of pwm network for training")
  
  # testing input
  p_in_test_binding = make_option(c("--p_in_test_binding"), type="character", help="path of binding network for testing")
  p_in_test_lasso = make_option(c("--p_in_test_lasso"), type="character", help="path of lasso network for testing")
  p_in_test_de = make_option(c("--p_in_test_de"), type="character", help="path of de network for testing")
  p_in_test_bart = make_option(c("--p_in_test_bart"), type="character", default=NULL, help="path of bart network testing")
  p_in_test_pwm = make_option(c("--p_in_test_pwm"), type="character", default=NULL, help="path of pwm network for testing")
  
  in_model = make_option(c("--in_model"), type="character", help="name of the model such netprophet")
  p_out_pred_train = make_option(c("--p_out_pred_train"), type="character", help="path of trained network for training data")
  p_out_pred_test = make_option(c("--p_out_pred_test"), type="character", help="path of training network for testing data")
  p_out_model_summary = make_option(c("--p_out_model_summary"), type="character", help="path of the summary model")
  sep = make_option(c("--sep"), type="character", default="\t", help="separator used in the input networks")
  p_in_train_reg = make_option(c("--p_in_train_reg"), type="character", default=NULL, help="path of file for the list of training regulators")
  p_in_test_reg = make_option(c("--p_in_test_reg"), type="character", default=NULL, help="path of file for the list of testing regulators")
  
  opt_parser = OptionParser(option_list=list(p_in_train_binding, p_in_train_lasso, p_in_train_de, p_in_train_bart
                                             , p_in_test_binding, p_in_test_lasso, p_in_test_de, p_in_test_bart
                                             , in_model, p_out_pred_train, p_out_pred_test, p_out_model_summary
                                             , sep, p_in_train_reg, p_in_test_reg, p_in_train_pwm, p_in_test_pwm
                                             ))
  
  opt = parse_args(opt_parser)
  combine_networks(
    p_in_train_binding=opt$p_in_train_binding
    , p_in_train_lasso=opt$p_in_train_lasso
    , p_in_train_de=opt$p_in_train_de
    , p_in_train_bart=opt$p_in_train_bart
    , p_in_train_pwm=opt$p_in_train_pwm
    
    , p_in_test_binding=opt$p_in_test_binding
    , p_in_test_lasso=opt$p_in_test_lasso
    , p_in_test_de=opt$p_in_test_de
    , p_in_test_bart=opt$p_in_test_bart
    , p_in_test_pwm=opt$p_in_test_pwm
    
    , in_model=opt$in_model
    , p_out_pred_train=opt$p_out_pred_train
    , p_out_pred_test=opt$p_out_pred_test
    , p_out_model_summary=opt$p_out_model_summary
    , sep=opt$sep
    
    , p_in_train_reg=opt$p_in_train_reg
    , p_in_test_reg=opt$p_in_test_reg
  )
  
}


