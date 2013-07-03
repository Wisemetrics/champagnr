source("config/application.R")

RqueueConnect()

MainLoop <- function() {
  while(1) {

    log_info("Waiting for a job...")
    list.element <- redisBLPop(config.queue.name, timeout = 0) # timeout is 0 mean it will block while the list is empty

    # TODO Deserialize the value (should be JSON stuff)
    func.name <- list.element[[1]]
    log_debug(paste("Receive this function name:", func.name))

    JobEvaluation <- function() {
      result <- eval(parse(text = func.name))
      log_debug(paste("Return of function:", as.character(result)))
    }
    tryCatch(JobEvaluation(),
      error = function(e) { log_error(paste("Enqueuing to failed:", func.name, e)); redisRPush(config.failed_queue.name, charToRaw(func.name)) })

  }
}

exit_status <- 0

tryCatch(MainLoop(),
  interrupt = function(e) { log_debug('Interruption of main loop'); redisClose(); },
  error = function(e) { log_fatal(as.character(e)); exit.status <<- 1 },
  finally = function() { log_info("Finnaly close connection"); redisClose() })

redisClose()

quit(save = 'no', status = exit.status, runLast = TRUE)
