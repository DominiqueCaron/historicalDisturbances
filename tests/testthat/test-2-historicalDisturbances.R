if (!testthat::is_testing()) source(testthat::test_path("setup.R"))

test_that("test that the module works in small area in SK", {
  ## Gets throught simInit with default parameters
  simInitTest <- SpaDEStestMuffleOutput(
    simInit(
      times = list(start = 2000, end = 2001),
      modules = "historicalDisturbances",
      paths = list(
        modulePath = spadesTestPaths$temp$modules,
        inputPath = spadesTestPaths$temp$inputs,
        outputPath = spadesTestPaths$temp$outputs,
        cachePath = spadesTestPaths$temp$cache
      ),
      objects = list(rasterToMatch = {
        rtm <- reproducible::prepInputs(url = "https://drive.google.com/file/d/1zUyFH8k6Ef4c_GiWMInKbwAl6m6gvLJW/view?usp=drive_link", destinationPath = spadesTestPaths$temp$inputs)
        rtm[rtm == 0] <- NA
        rtm
      })
    )
  )
  # Run tests
  expect_s4_class(simInitTest, "simList")
  expect_equal(simInitTest$disturbanceMeta, 
               data.table(
                 eventID = 1L,
                 name = "Wildfire",
                 sourceValue = 1L,
                 sourceDelay = 0L,
                 sourceObjectName = "rstCurrentBurn",
                 disturbance_type_id = 1L
               ))
  expect_is(simInitTest$disturbanceRasters, "list")
  expect_equal(names(simInitTest$disturbanceRasters), "1")
  expect_equal(names(simInitTest$disturbanceRasters[["1"]]), c("2000", "2001"))
  expect_is(simInitTest$disturbanceRasters[["1"]][["2000"]], "SpatRaster")
  
  ## Get through init event:
  #  splits the cohort data and the yield tables
  simTest <- SpaDEStestMuffleOutput(
    spades(simInitTest)
  )
  expect_is(simTest$rstCurrentBurn, "SpatRaster")
  expect_equal(simTest$rstCurrentBurn, simInitTest$disturbanceRasters[["1"]][["2001"]])
  
  ## Gets throught simInit with default parameters
  simInitTest <- SpaDEStestMuffleOutput(
    simInit(
      times = list(start = 1990, end = 2000),
      modules = "historicalDisturbances",
      paths = list(
        modulePath = spadesTestPaths$temp$modules,
        inputPath = spadesTestPaths$temp$inputs,
        outputPath = spadesTestPaths$temp$outputs,
        cachePath = spadesTestPaths$temp$cache
      ),
      objects = list(rasterToMatch = {
        rtm <- reproducible::prepInputs(url = "https://drive.google.com/file/d/1zUyFH8k6Ef4c_GiWMInKbwAl6m6gvLJW/view?usp=drive_link", destinationPath = spadesTestPaths$temp$inputs)
        rtm[rtm == 0] <- NA
        rtm
      }),
      params = list(
        historicalDisturbances = list(
          disturbanceSource = "NTEMS",
          disturbanceYears = c(2000),
          disturbanceTypes = "harvesting"
        )
      )
    )
  )
  # Run tests
  expect_equal(
    simInitTest$disturbanceMeta,
    data.table(
      eventID = 2L,
      name = "Harvesting",
      sourceValue = 1L,
      sourceDelay = 0L,
      sourceObjectName = "rstCurrentHarvest",
      disturbance_type_id = 2L
    )
  )
  expect_equal(names(simInitTest$disturbanceRasters), "2")
  expect_equal(names(simInitTest$disturbanceRasters[["2"]]), "2000")
  expect_is(simInitTest$disturbanceRasters[["2"]][["2000"]], "SpatRaster")
  
  ## Get through init event:
  #  splits the cohort data and the yield tables
  simTest <- SpaDEStestMuffleOutput(
    spades(simInitTest)
  )
  expect_is(simTest$rstCurrentHarvest, "SpatRaster")
  expect_equal(simTest$rstCurrentHarvest, simInitTest$disturbanceRasters[["2"]][["2000"]])
  
  end(simInitTest) <- 2010
  simTest <- SpaDEStestMuffleOutput(
    spades(simInitTest)
  )
  expect_equal(simTest$rstCurrentHarvest, NULL)
})
  