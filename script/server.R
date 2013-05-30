source("config/application.R")

log_info("Connecting to redis instance")
# Timeout is 1 week
redisConnect(host = "localhost", port = 6379, timeout = 60*60*24*7)

config.queue.name <- 'public_jobs'

MainLoop <- function() {
  while(1) {

    log_info("Waiting for a job...")
    list.element <- redisBLPop(config.queue.name, timeout = 0) # timeout is 0 mean it will block while the list is empty

    # TODO Deserialize the value (should be JSON stuff)
    func.name <- list.element[[1]]
    log_debug(paste("Receive this function name:", func.name))

    result <- eval(parse(text = func.name))
    log_debug(paste("Return of function:", as.character(result)))

  }
}

exit_status <- 0

tryCatch(MainLoop(),
  interrupt = function(e) { log_warn('Interrupt') },
  error = function(e) { log_fatal(as.character(e)); exit.status <<- 1 })

redisClose()

quit(save = 'no', status = exit.status, runLast = TRUE)
