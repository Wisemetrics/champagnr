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
logger <- create.logger()

# Defining path of the log file
logfile(logger) <- file.path('log', 'application.log')

# Set the current level of log
if (config.production) {
  level(logger) <- log4r:::INFO
} else {
  level(logger) <- log4r:::DEBUG
}

info(logger, 'Booting...')

if (config.production) {
  info(logger, 'Production mode')
} else {
  info(logger, 'Development mode')
}

# -- Loading initializers & app

if(config.production) {
  enableJIT(3)
}

sourceDirectory(file.path('config', 'initializers'))
sourceDirectory('app')
