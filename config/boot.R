# Boot ChampaignR

champaignr.root = getwd()

args <- commandArgs(TRUE)

config.production <- "production" %in% args

# -- Loading packages

library('yaml')

# Defining application's packages from file "packages.yml"
config.packages <- yaml.load_file(file.path('config', 'packages.yml'))

# Loading
for (package in config.packages$packages) {
  library(package, character.only=TRUE)
}

# -- Setup logging

# Defining default logger
config.logger <- create.logger()

# Create custom functions to avoid collisions
log_debug <- function(message) {
  log4r::debug(config.logger, message)
}
log_info <- function(message) {
  log4r::info(config.logger, message)
}
log_warn <- function(message) {
  log4r::warn(config.logger, message)
}
log_error <- function(message) {
  log4r::error(config.logger, message)
}
log_fatal <- function(message) {
  log4r::fatal(config.logger, message)
}

# Defining path of the log file
logfile(config.logger) <- file.path('log', 'application.log')

# Set the current level of log
if (config.production) {
  level(config.logger) <- log4r:::INFO
} else {
  level(config.logger) <- log4r:::DEBUG
}

log_info('Booting...')

if (config.production) {
  log_info('Production mode')
} else {
  log_info('Development mode')
}

# -- Loading initializers & app

if(config.production) {
  enableJIT(3)
}

sourceDirectory(file.path('config', 'initializers'))
sourceDirectory('app')
