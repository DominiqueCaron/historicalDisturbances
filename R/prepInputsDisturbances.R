prepInputsDisturbances <- function(source, types, years, to, destinationPath) {
  # Make sure that the combination of source, years and types are available:
  checkParameters(source, types, years)
  
  if (source == "CanLaD") {
    disturbanceRasters <- prepInputsDisturbancesCanLaD(types = types,
                                                       years = years,
                                                       to = to, 
                                                       destinationPath = destinationPath)
  } else if (source == "NTEMS") {
    disturbanceRasters <- prepInputsDisturbancesNTEMS(types = types,
                                                      years = years,
                                                      to = to, 
                                                      destinationPath = destinationPath)
  } else if (source == "NBAC") {
    disturbanceRasters <- prepInputsDisturbancesNBAC(types = types,
                                                      years = years,
                                                      to = to, 
                                                      destinationPath = destinationPath)
  }
  
  return(disturbanceRasters)
}

prepInputsDisturbancesCanLaD <- function(types, years, to, destinationPath){
  
  disturbanceRasters <- list()
  
  for (year in years){
    message("Reading CanLaD disturbances for year: ", year)
    CanLadDisturbances <- prepInputs(
      url = paste0(
        "https://ftp.maps.canada.ca/pub/nrcan_rncan/Forests_Foret/canlad_including_insect_defoliation/v1/Disturbances_Time_Series/canlad_annual_", year, "_v1.tif"
      ),
      to = to,
      destinationPath = destinationPath
    )
    
    # CanLaD legend:
    # 0= Undisturbed the current year
    # 1= Wildfire
    # 2= Harvesting
    # 3= Windthrows
    # 4= Water extension
    # 5= Defoliation and Harvesting
    # 6= Low severity defoliation
    # 7= Medium severity defoliation	
    # 8= High severity defoliation
    if ("wildfire" %in% types){
      fires <- CanLadDisturbances
      fires[fires != 1] <- 0
      disturbanceRasters[["wildfire"]][[as.character(year)]] <- fires
    }
    if ("harvesting" %in% types){
      harvests <- CanLadDisturbances
      harvests[harvests != 2] <- 0
      harvests[harvests == 2] <- 1
      disturbanceRasters[["harvesting"]][[as.character(year)]] <- harvests
    }
  }
  
  return(disturbanceRasters)
}

prepInputsDisturbancesNTEMS <- function(types, years, to, destinationPath){
  
  disturbanceRasters <- list()

  if ("wildfire" %in% types){
    NTEMSFires <- prepInputs(
      url = "https://opendata.nfis.org/downloads/forest_change/CA_Forest_Fire_1985-2020.zip",
      to = to,
      destinationPath = destinationPath
    ) 
    
    for (year in years){
      fires <- NTEMSFires
      fires[fires != year] <- 0
      fires[fires == year] <- 1
      disturbanceRasters[["wildfire"]][[as.character(year)]] <- fires
    }
  }
  
  if ("harvesting" %in% types){
    NTEMSHarvests <- prepInputs(
      url = "https://opendata.nfis.org/downloads/forest_change/CA_Forest_Harvest_1985-2020.zip",
      to = to,
      destinationPath = destinationPath
    ) 
    
    for (year in years){
      harvests <- NTEMSHarvests
      harvests[harvests != year] <- 0
      harvests[harvests == year] <- 1
      disturbanceRasters[["harvesting"]][[as.character(year)]] <- harvests
    }
  }
  
  return(disturbanceRasters)
}

prepInputsDisturbancesNBAC <- function(types, years, to, destinationPath){
  
  disturbanceRasters <- list()
  NBACfires <- prepInputs(
    url = "https://cwfis.cfs.nrcan.gc.ca/downloads/nbac/NBAC_1972to2024_20250506_shp.zip",
    to = to,
    destinationPath = destinationPath
  ) 
  
  for (year in years){
    fires <- vect(NBACfires[NBACfires$YEAR == year,])
    fires <- rasterize(fires, to, field = 1, background = 0)
    fires <- mask(fires, to)
    disturbanceRasters[["wildfire"]][[as.character(year)]] <- fires
  }
  
  return(disturbanceRasters)
}


checkParameters <- function(source, types, years) {
  availableData <- fread(
    "https://raw.githubusercontent.com/DominiqueCaron/historicalDisturbances/refs/heads/main/data/availableData.csv",
    showProgress = FALSE
  )
  
  # 1. Check that the data source is available
  if (!(source %in% availableData$disturbanceSource)) {
    stop(
      paste(
        source,
        "is not currently available in historicalDisturbances.",
        "Refer to data/availableData.csv to see which data are available."
      )
    )
  }
  availableData <- availableData[disturbanceSource == source]
  
  # 2. Check that disturbance types are available
  if (!(all(types %in% availableData$disturbanceTypes))) {
    notAvailableTypes <- setdiff(types, availableData$disturbanceTypes)
    
    if (length(notAvailableTypes) == 1) {
      stop(
        paste(
          notAvailableTypes,
          "is currently not available in historicalDisturbances.",
          "Refer to data/availableData.csv to see which data are available."
        )
      )
    } else {
      stop(
        paste(
          paste(notAvailableTypes, collapse = " and "),
          "are currently not available in historicalDisturbances.",
          "Refer to data/availableData.csv to see which data are available."
        )
      )
    }
  } else {
    
    for (type in types) {
      # 3. Check that disturbance years are available
      availableYears <- as.numeric(strsplit(availableData[disturbanceTypes == type, disturbanceYears], ":")[[1]]) |> (\(x) x[1]:x[2])()
      if (!all(years %in% availableYears)) {
        stop(
          paste0(
            "Some years are currently not available for ",
            type,
            " in historicalDisturbances.",
            "Refer to data/availableData.csv to see which data are available."
          )
        )
      }
    }
  }
}
