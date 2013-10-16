config.queue.name <- 'rqueue:public_jobs'
config.failed_queue.name <- 'rqueue:failed'

RqueueConnect <- function() {
  log_info("Connecting to redis instance")
  # Timeout is 1 week
  if (config.production) {
    redisConnect(host = Sys.getenv('REDIS_HOST'), port = as.numeric(Sys.getenv('REDIS_PORT')), timeout = 60*60*24*7, password = Sys.getenv('REDIS_PASS'))
  } else {
    redisConnect(host = "localhost", port = 6379, timeout = 60*60*24*7)
  }
}

RqueuePublicJobsSize <- function() {
  redisLLen(config.queue.name)
}

RqueueFailedSize <- function() {
  redisLLen(config.failed_queue.name)
}

RqueueClearFailed <- function(limit = 500) {
  i <- 0
  repeat {
    if (is.null(redisLPop(config.failed_queue.name))) {
      break
    } else {
      i <- i + 1
      if (i >= limit) break
    }
  }
  i
}

RqueueRetryFailed <- function(limit = 500) {
  i <- 0
  repeat {
    if (is.null(redisRPopLPush(config.failed_queue.name, config.queue.name))) {
      break
    } else {
      i <- i + 1
      if (i >= limit) break
    }
  }
  i
}
