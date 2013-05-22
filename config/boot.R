# Boot ChampaignR

# -- Loading packages

# Defining framework's needed packages
config.framework.packages <- c('R.utils', 'yaml', 'log4r')

# Default CRAN miror
options(repos='http://cran.univ-paris1.fr')

# Install/load framework's packages
for (package in config.framework.packages) {
  tryCatch(library(package, character.only=TRUE),
    error=function(e) { install.packages(package, dependencies=TRUE); library(package, character.only=TRUE) } )
}

# Defining application's packages from file "packages.yml"
config.packages <- yaml.load_file("config/packages.yml")

# Redefining CRAN miror
options(repos=config.packages$miror)

# Install/load application's packages
for (package in config.packages$packages) {
  tryCatch(library(package, character.only=TRUE),
    error=function(e) { install.packages(package, dependencies=TRUE); library(package, character.only=TRUE) } )
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

sourceDirectory('config/initializers')

# -- Loading app

sourceDirectory('app')

