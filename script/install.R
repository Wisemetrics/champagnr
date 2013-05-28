cat("Installing packages...\n")

# Defining CRAN miror
options(repos='http://cran.univ-paris1.fr')

InstallIfMissing = function(p) {
  if (p %in% rownames(installed.packages()) == FALSE) {
    install.packages(p, dependencies = TRUE)
  }
  else {
    cat(paste("Existing package:", p, "\n"))
  }
}

InstallIfMissing('yaml')
library('yaml')

# Defining application's packages from file "packages.yml"
config.packages <- yaml.load_file(file.path('config', 'packages.yml'))

# Defining CRAN miror
options(repos=config.packages$miror)

# Install/load application's packages
for (package in config.packages$packages) {
  InstallIfMissing(package)
}

cat("Done.\n")
