# Boot ChampaignR

champaignr.root = getwd()

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
level(logger) <- log4r:::INFO

info(logger, 'Booting...')

# -- Loading initializers

sourceDirectory(file.path('config', 'initializers'))

# -- Loading app

sourceDirectory('app')

