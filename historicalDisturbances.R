## Everything in this file and any files in the R directory are sourced during `simInit()`;
## all functions and objects are put into the `simList`.
## To use objects, use `sim$xxx` (they are globally available to all modules).
## Functions can be used inside any function that was sourced in this module;
## they are namespaced to the module, just like functions in R packages.
## If exact location is required, functions will be: `sim$.mods$<moduleName>$FunctionName`.
defineModule(sim, list(
  name = "historicalDisturbances",
  description = "",
  keywords = "",
  authors = structure(list(list(given = c("First", "Middle"), family = "Last", role = c("aut", "cre"), email = "email@example.com", comment = NULL)), class = "person"),
  childModules = character(0),
  version = list(historicalDisturbances = "0.0.0.9000"),
  timeframe = as.POSIXlt(c(NA, NA)),
  timeunit = "year",
  citation = list("citation.bib"),
  documentation = list("NEWS.md", "README.md", "historicalDisturbances.Rmd"),
  reqdPkgs = list("SpaDES.core (>= 2.1.5.9003)", "ggplot2", "data.table", "terra"),
  parameters = bindrows(
    defineParameter(
      "disturbanceSource", "character", "CanLaD", NA_character_, NA_character_, 
      desc = paste("The disturbance data source.", 
                   "Refer to data/availableData.csv to see which data is available.")
      ),
    defineParameter(
      "disturbanceYears", "numeric", NA_integer_, NA_integer_, NA_integer_, 
      desc = paste("The range of years for which disturbances are extracted.",
                   "Refer to data/availableData.csv to see which data is available.")
      ),
    defineParameter(
      "disturbanceTypes", "character", "fire", NA_character_, NA_character_, 
      desc = paste("The type of disturbance extracted.", 
                   "Refer to data/availableData.csv to see which data is available.")
    ),
    defineParameter(".plots", "character", "screen", NA, NA,
                    "Used by Plots function, which can be optionally used here"),
    defineParameter(".plotInitialTime", "numeric", start(sim), NA, NA,
                    "Describes the simulation time at which the first plot event should occur."),
    defineParameter(".plotInterval", "numeric", NA, NA, NA,
                    "Describes the simulation time interval between plot events."),
    defineParameter(".useCache", "logical", FALSE, NA, NA,
                    "Should caching of events or module be used?")
  ),
  inputObjects = bindrows(
    expectsInput(
      objectName = "disturbanceRasters",
      objectClass = "list",
      desc = paste(
        "Set of spatial data sources containing locations of disturbance events for each year.",
        "List items must be named by disturbance event types.",
        "Within each event's list, items must be named by the 4 digit year the disturbances occured in.",
        "For example, fires for 2025 can be accessed with `disturbanceRasters[[\"fires\"]][[\"2025\"]]`.",
        "Each disturbance item is a terra SpatRaster layer.",
        "All non-NA areas will be considered events."
      )
    ), 
    expectsInput(objectName = "rasterToMatch", 
                 objectClass = "spatRaster", 
                 desc = "Raster template defining the study area. NA cells will be excluded from analysis.", 
                 sourceURL = NA)
  ),
  outputObjects = bindrows(
    createsOutput(objectName = "rstCurrentBurn", 
                  objectClass = "spatRaster", 
                  desc = "A binary raster with 1 values representing burned pixels."),
    createsOutput(objectName = "rstCurrentHarvest", 
                  objectClass = "spatRaster", 
                  desc = "A binary raster with 1 values representing harvested pixels.")
  )
))

doEvent.historicalDisturbances = function(sim, eventTime, eventType) {
  switch(
    eventType,
    init = {

      # schedule future event(s)
      if(any(!is.na(P(sim)$disturbanceYears))) {
        firstDistYear <- min(P(sim)$disturbanceYears)
      } else {
        firstDistYear <- start(sim)
      }
      
      sim <- scheduleEvent(sim, firstDistYear, "historicalDisturbances", "readDisturbances")
      
      sim <- scheduleEvent(sim, P(sim)$.plotInitialTime, "historicalDisturbances", "plot")
    },
    plot = {
      # ! ----- EDIT BELOW ----- ! #

      # ! ----- STOP EDITING ----- ! #
    },
    readDisturbances = {
      
      if ("wildfire" %in% P(sim)$disturbanceTypes){
        sim$rstCurrentBurn <- sim$disturbanceRasters[["fires"]][[as.character(time(sim))]]
      }
      
      if ("harvesting" %in% P(sim)$disturbanceTypes){
        sim$rstCurrentHarvest <- sim$disturbanceRasters[["harvesting"]][[as.character(time(sim))]]
      }
      
      if(any(!is.na(P(sim)$disturbanceYears))) {
        if(any(P(sim)$disturbanceYears[P(sim)$disturbanceYears > time(sim)])){
          nextDistYear <- min(P(sim)$disturbanceYears[P(sim)$disturbanceYears > time(sim)])
          sim <- scheduleEvent(sim, nextDistYear, "historicalDisturbances", "readDisturbances")
        }
      } else {
        nextDistYear <- time(sim) + 1
        sim <- scheduleEvent(sim, nextDistYear, "historicalDisturbances", "readDisturbances")
      }
      
    },
    warning(noEventWarning(sim))
  )
  return(invisible(sim))
}

.inputObjects <- function(sim) {

  #cacheTags <- c(currentModule(sim), "function:.inputObjects") ## uncomment this if Cache is being used
  dPath <- asPath(getOption("reproducible.destinationPath", dataPath(sim)), 1)
  message(currentModule(sim), ": using dataPath '", dPath, "'.")

  if (!suppliedElsewhere("disturbanceRasters")) {

    # By default, the module gets the disturbance for all simulation years, unless
    # specified otherwise in the parameters
    if(all(is.na(P(sim)$disturbanceYears))) {
      disturbanceYears <- start(sim):end(sim)
    } else {
      disturbanceYears <- P(sim)$disturbanceYears
    }
    
    # Get all the rasters
    sim$disturbanceRasters <- prepInputsDisturbances(
      source = P(sim)$disturbanceSource,
      types = P(sim)$disturbanceTypes,
      years = disturbanceYears,
      to = sim$rasterToMatch,
      destinationPath = inputPath(sim)
    ) |> Cache()
  }
  
  return(invisible(sim))
}

