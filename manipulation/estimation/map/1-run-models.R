# knitr::stitch_rmd(script="./___/___.R", output="./___/stitched-output/___.md")
#These first few lines run only when the file is run in RStudio, !!NOT when an Rmd/Rnw file calls it!!
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.
cat("\f") # clear console

# ---- load-sources ------------------------------------------------------------
# Call `base::source()` on any repo file that defines functions needed below.  Ideally, no real operations are performed.

# load functions that generate scripts
source("./scripts/mplus/functions-to-generate-Mplus-scripts.R")

# ---- load-packages -----------------------------------------------------------
# Attach these packages so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
library(magrittr) # enables piping : %>%
# Verify these packages are available on the machine, but their functions need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
requireNamespace("ggplot2") # graphing
requireNamespace("tidyr") # data manipulation
requireNamespace("dplyr") # Avoid attaching dplyr, b/c its function names conflict with a lot of packages (esp base, stats, and plyr).
requireNamespace("testit")# For asserting conditions meet expected patterns.
# requireNamespace("car") # For it's `recode()` function.
requireNamespace("reshape2") # data transformations
requireNamespace("data.table") # data transformations
requireNamespace("MplusAutomation")
requireNamespace("stringr")
requireNamespace("IalsaSynthesis")

# ---- declare-globals ---------------------------------------------------------
options(width=160)
path_generic_data  <- "./data/unshared/derived/map-1/wide-dataset.dat"
path_generic_names <- "./data/unshared/derived/map-1/wide-variable-names.txt"

varnames_physical <- c(
  # "fev100",          # forced expiratory volume
  "fev",             # forced expiratory volume
  "gait",            # Gait Speed - MAP
  "grip"             # Extremity strength
)
varnames_cognitive <- c(
  "bnt"              # Boston naming
  ,"bostordel"       # East Boston story - delayed recall
  ,"bostorim"        # East Boston story - immediate
  ,"catfluency"      # Category fluency
  ,"complexideas"    # Complex ideas
  ,"digitbackward"   # Digits backwards
  ,"digitforward"    # Digits forwards
  ,"digitorder"      # Digit ordering
  ,"lineorientation" # Line orientation -
  ,"logimemdel"      # Logical memory IIa
  ,"logimemim"       # Logical memory Ia - immediate
  ,"matrices"        # Progressive Matrices -
  ,"mmse"            # Mini Mental State Examination
  ,"nart"            # Reading test-NART
  ,"numbercomparison"# Number comparison
  ,"symbol"          # Symbol digit modalitities
  ,"wordlistdel"     # Word list II - delayed
  ,"wordlistim"      # Word list I- immediate-
  ,"wordlistrecog"   # Word list III - recognition
)

# ---- load-data ---------------------------------------------------------------
ds_long <- readRDS("./data/unshared/derived/map-1/data-long.rds")
ds_wide <- readRDS("./data/unshared/derived/map-1/data-wide.rds")


testit::assert("File does not exist",file.exists(path_generic_data))
testit::assert("File does not exist",file.exists(path_generic_names))

# file.copy(from=path_generic_names,to= "./sandbox/pipeline-demo-1/outputs/",overwrite = T)

# ---- inspect-data -------------------------------------------------------------

# ---- tweak-data --------------------------------------------------------------

# ---- basic-table --------------------------------------------------------------

# ---- basic-graph --------------------------------------------------------------



## Run the lines above to load the needed functions
## Execute script snippets for each pair individually below this
# ---- create-predictor-selector -----------------------------
ls_model_number <- list(
  "univariate_flat"      = "u0",
  "univariate_linear"    = "u1",
  "univariate_quadratic" = "u2",
  "bivariate_flat"       = "b0",
  "bivariate_linear"     = "b1",
  "bivariate_quadratic"  = "b2"
)
ls_subgroup = list(
  "male" = "male"
  ,"female" = "female"
  # ,"unisex" = "unisex"
)
ls_model_type <- list(
  "a"       = c("age_c70")
  ,"ae"      = c("age_c70","edu_c7")
  ,"aeh"     = c("age_c70","edu_c7","htm_c")
  ,"aehplus" = c("age_c70","edu_c7","htm_c", "smoke","cardio","diabetes")
  # ,"aeplus" = c("age_c70","edu_c7", "smoke","stroke","diabetes")
)


############################################################ GRIP #####
## @knitr dummy_1
# Use the first example as the template for further pairs

wave_set_modeled <-  c(0,1,2,3,4)
subset_condition_1 <- "dementia_baseline NE 1" # additional subgroup constraints
folder_data        = "./data/unshared/derived/map-1" # where data resides
path_prototype     = "./manipulation/estimation/prototype-wide.inp" # Mplus stencil
folder_output      = "./output/studies/map/phys-cog-baseline-dementia/" # where the output will go
# folder_data        = "./data/unshared/derived/map"
# folder_output      = "./output/studies/map/phys-cog/pulmonary"

# single model
# mplus_generator_bivariate(
#    model_number       = "b1"
#   ,subgroup           = "male"
#   ,model_type         = "aehplus"
#   ,process_a          = 'fev'# item name of process (A), goes into file name
#   ,process_b          = 'numbercomparison'# item name of process (B), goes into file name
#   ,wave_set_modeled   = wave_set_modeled
#   ,subset_condition_1 = subset_condition_1 # subset data to member of this group
#   ,path_prototype     = path_prototype
#   ,folder_data        = folder_data
#   ,folder_output      = folder_output
#   ,run_models         = TRUE # If TRUE then Mplus runs estimation to produce .out, .gh5, and/or, other files
# )

# loop over conditions
#for(phys_measure in "fev"){
for(phys_measure in varnames_physical){
  #for(cog_measure in "wordlistim"){
  for(cog_measure in varnames_cognitive){
    for(subgroup in names(ls_subgroup)){
      for(model_type in names(ls_model_type)){
        mplus_generator_bivariate(
          model_number        = "b1"
          ,subgroup           = subgroup
          ,model_type         = model_type
          ,process_a          = phys_measure# item name of process (A), goes into file name
          ,process_b          = cog_measure# item name of process (B), goes into file name
          ,wave_set_modeled   = wave_set_modeled
          ,subset_condition_1 = subset_condition_1 # subset data to member of this group
          ,path_prototype     = path_prototype
          ,folder_data        = folder_data
          ,folder_output      = folder_output
          ,run_models         = TRUE # If TRUE then Mplus runs estimation to produce .out, .gh5, and/or, other files
        )
      }
    }
  }
}



# ---- examine-created-output ----------------
source("./scripts/mplus/mplus.R") # downloaded from http://www.statmodel.com/mplus-R/mplus.R
path_gh5 <- "./output/studies/map/phys-cog/fev-wordlistim/b1_male_aehplus_fev_wordlistim.gh5"

# view options: https://www.statmodel.com/mplus-R/GH5_R.shtml

mplus.list.variables(path_gh5) # variables in the gh5 file
mplus.view.plots(path_gh5)  # available graphs for this type of gh5 file
# histograms
mplus.plot.histogram(path_gh5, "SA") # slope of process A
mplus.plot.histogram(path_gh5, "SB") # slope of process B
# scatterplots
mplus.plot.scatterplot(path_gh5, "IA", "IB") # intercepts
mplus.plot.scatterplot(path_gh5, "SA", "SB") # slopes
mplus.plot.scatterplot(path_gh5, "IA", "SA") # physical
mplus.plot.scatterplot(path_gh5, "IB", "SB") # cognitive

ds <- mplus.get.data(path_gh5, "SA")

summary(ds)
head(ds)

#### ----- development ----------------------

# Grip - Boston Naming Task #
# # from "./sandbox/syntax-creator/extraction_functions.R  script
# collect_model_results(folder = "outputs/pairs/grip_bnt") # collect and save into the same folder
# ds <- readRDS(file.path(pathFolder,"grip_bnt.rds")) # load the data for outcome pair
# # from "./scripts/graphs/koval_brown_profiles.R"
# kb_profiles(ds,  vertical="wave_count",  border=5) # produces the kb_profile graph
#




