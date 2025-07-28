prepInputsDisturbances <- function(source, types, years, to, destinationPath) {
  # Make sure that the combination of source, years and types are available:
  if (source == "CanLaD") {
    disturbanceRasters <- prepInputsCanLaD(types = types,
                                           years = years,
                                           to = to, 
                                           destinationPath = destinationPath)
  } else {
    stop(
      paste(
        source, " is not currently available in historicalDisturbances.",
        "refer to data/availableData.csv to see which sources are available."
      )
    )
  }
  return(disturbanceRasters)
}

prepInputsCanLaD <- function(types, years, to, destinationPath){
  
  availableTypes <- "fire"
  if(!(availableTypes %in% types)){
    stop(
      paste(
        types, " is not currently available with CanLaD.",
        "refer to data/availableData.csv to see which sources are available."
      )
    )
  }
  
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
    if ("fire" %in% types){
      fires <- CanLadDisturbances
      fires[fires != 1] <- NA
      disturbanceRasters[["fires"]][[as.character(year)]] <- fires
    }
    
  }
  
  return(disturbanceRasters)
}