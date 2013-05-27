source("config/application.R")

info(logger, "Connecting to redis instance")
# Timeout is 1 week
redisConnect(host = "localhost", port = 6379, timeout = 60*60*24*7)

config.queue.name <- 'public_jobs'

MainLoop <- function() {
  while(1) {

    info(logger, "Waiting for a job...")
    list.element <- redisBLPop(config.queue.name, timeout = 0) # timeout is 0 mean it will block while the list is empty

    # TODO Deserialize the value (should be JSON stuff)
    func.name <- list.element[[1]]
    debug(logger, paste("Receive this function name:", func.name))

    result <- eval(parse(text = func.name))
    debug(logger, paste("Return of function:", as.character(result)))

  }
}

exit_status <- 0

tryCatch(MainLoop(),
  interrupt = function(e) { warn(logger, 'Interrupt') },
  error = function(e) { fatal(logger, as.character(e)); exit.status <<- 1 })

redisClose()

quit(save = 'no', status = exit.status, runLast = TRUE)
