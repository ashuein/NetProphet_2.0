read_csv_indexed = function(p_df
                            , p_rownames
                            , p_colnames
                            , sep="\t"){
  df = read.csv(p_df, header=FALSE, sep=sep)
  rownames = read.csv(p_rownames, header=FALSE)[1]
  colnames = read.csv(p_colnames, header=FALSE)[1]
  df$row.names = rownames
  df$col.names = colnames
  df
}

withErrorTracing = function(expr, silentSuccess=FALSE) {
  hasFailed = FALSE
  messages = list()
  warnings = list()
  
  errorTracer = function(obj) {
    
    # Storing the call stack 
    calls = sys.calls()
    calls = calls[1:length(calls)-1]
    # Keeping the calls only
    trace = limitedLabels(c(calls, attr(obj, "calls")))
    
    # Printing the 2nd and 3rd traces that contain the line where the error occured
    # This is the part you might want to edit to suit your needs
    print(paste0("Error occuring: ", trace[length(trace):1][2:3]))
    
    # Muffle any redundant output of the same message
    optionalRestart = function(r) { res = findRestart(r); if (!is.null(res)) invokeRestart(res) }
    optionalRestart("muffleMessage")
    optionalRestart("muffleWarning")
  }
  
  vexpr = withCallingHandlers(withVisible(expr),  error=errorTracer)
  if (silentSuccess && !hasFailed) {
    cat(paste(warnings, collapse=""))
  }
  if (vexpr$visible) vexpr$value else invisible(vexpr$value)
}