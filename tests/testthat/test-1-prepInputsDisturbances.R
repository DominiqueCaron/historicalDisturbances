if (!testthat::is_testing()) source(testthat::test_path("setup.R"))

test_that("function checkParameters works", {
  # Correct inputs
  expect_no_error(checkParameters("NBAC", types = "wildfire", years = 1990))
  expect_no_error(checkParameters("NTEMS", types = c("harvesting", "wildfire"), years = c(1990:2000)))
  # Incorrect inputs
  expect_error(checkParameters("notAsource", types = "wildfire", years = 1990))
  expect_error(checkParameters("CanLaD", types = "pest", years = 1990))
  expect_error(checkParameters("NTEMS", types = "harvesting", years = 1970))
})
  
test_that("function prepInputsDisturbancesNBAC works", {
  rtm <- reproducible::prepInputs(
    url = "https://drive.google.com/file/d/1zUyFH8k6Ef4c_GiWMInKbwAl6m6gvLJW/view?usp=drive_link",
    destinationPath = spadesTestPaths$temp$inputs
  )
  rtm[rtm == 0] <- NA
  NBAC1998 <- prepInputsDisturbancesNBAC("wildfire", 1998, rtm, destinationPath = spadesTestPaths$temp$inputs)
  expect_equal(names(NBAC1998), "1")
  expect_equal(names(NBAC1998[["1"]]), "1998")
  expect_is(NBAC1998, "list")
  expect_is(NBAC1998[["1"]][["1998"]], "SpatRaster")
})

test_that("function prepInputsDisturbancesNTEMS works", {
  NTEMS20092010 <- prepInputsDisturbancesNTEMS("harvesting", c(2009,2010), rtm, destinationPath = spadesTestPaths$temp$inputs)
  expect_equal(names(NTEMS20092010), "2")
  expect_equal(names(NTEMS20092010[["2"]]), c("2009", "2010"))
  expect_is(NTEMS20092010, "list")
  expect_is(NTEMS20092010[["2"]][["2009"]], "SpatRaster")
})


test_that("function prepInputsDisturbancesCanLaD works", {
  CanLaD2005 <- prepInputsDisturbancesCanLaD(c("harvesting", "wildfire"), 2005, rtm, destinationPath = spadesTestPaths$temp$inputs)
  expect_equal(names(CanLaD2005), c("1","2"))
  expect_equal(names(CanLaD2005[["1"]]), "2005")
  expect_is(CanLaD2005, "list")
  expect_is(CanLaD2005[["2"]][["2005"]], "SpatRaster")
})

