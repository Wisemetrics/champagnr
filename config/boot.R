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

compileAndLoadDirectory <- function(directory, pattern = ".*[.](r|R|s|S|q)([.](lnk|LNK))*$", recursive = TRUE) {
  dir.create(file.path('compiled', directory), showWarnings = FALSE, recursive = TRUE)

  sources <- list.files(directory, pattern = pattern, recursive = recursive)
  for (source in sources) {
    source.path <- file.path(directory, source)

    target <- file.path('compiled', paste(source.path, 'c', sep = ''))
    dir.create(dirname(target), showWarnings = FALSE, recursive = TRUE)

    cmpfile(source.path, target)
    loadcmp(target)
  }
}

if(config.production) {
  compileAndLoadDirectory(file.path('config', 'initializers'))
  compileAndLoadDirectory('app')
} else {
  sourceDirectory(file.path('config', 'initializers'))
  sourceDirectory('app')
}
