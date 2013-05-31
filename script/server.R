source("config/application.R")

log_info("Connecting to redis instance")
# Timeout is 1 week
if (config.production) {
  redisConnect(host = Sys.getenv('REDIS_HOST'), port = Sys.getenv('REDIS_PORT'), timeout = 60*60*24*7)
  redisAuth(Sys.getenv('REDIS_PASS'))
} else {
  redisConnect(host = "localhost", port = 6379, timeout = 60*60*24*7)
}

config.queue.name <- 'rqueue:public_jobs'
config.failed_queue.name <- 'rqueue:failed'

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
      error = function(e) { log_error(paste("Enqueue to failed:", func.name, e)); redisRPush(config.failed_queue.name, func.name) })

  }
}

exit_status <- 0

tryCatch(MainLoop(),
  interrupt = function(e) { log_debug('Interruption of main loop'); redisClose(); },
  error = function(e) { log_fatal(as.character(e)); exit.status <<- 1 },
  finally = function() { log_info("Finnaly close connection"); redisClose() })

redisClose()

quit(save = 'no', status = exit.status, runLast = TRUE)
