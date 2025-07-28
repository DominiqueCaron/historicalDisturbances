---
title: "historicalDisturbances Manual"
subtitle: "v.0.0.0.9000"
date: "Last updated: 2025-07-28"
output:
  bookdown::html_document2:
    toc: true
    toc_float: true
    theme: sandstone
    number_sections: false
    df_print: paged
    keep_md: yes
editor_options:
  chunk_output_type: console
  bibliography: citations/references_historicalDisturbances.bib
link-citations: true
always_allow_html: true
---

# historicalDisturbances Module

<!-- the following are text references used in captions for LaTeX compatibility -->
(ref:historicalDisturbances) *historicalDisturbances*



[![made-with-Markdown](figures/markdownBadge.png)](https://commonmark.org)

<!-- if knitting to pdf remember to add the pandoc_args: ["--extract-media", "."] option to yml in order to get the badge images -->

#### Authors:

Dominique, Caron, dominique.caron@nrcan-rncan.gc.ca, aut, cre
<!-- ideally separate authors with new lines, '\n' not working -->

## Module Overview

### Module summary

The module download disturbance data from various sources and prepare them to be used in other modules. The following disturbance product available are the following:

Table \@ref(tab:data-historicalDisturbances) shows the full list of module inputs.

<table class="table" style="color: black; margin-left: auto; margin-right: auto;">
<caption>(\#tab:data-historicalDisturbances)(\#tab:data-historicalDisturbances)Available disturbance products</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> disturbanceSource </th>
   <th style="text-align:left;"> disturbanceTypes </th>
   <th style="text-align:left;"> disturbanceYears </th>
   <th style="text-align:left;"> url </th>
   <th style="text-align:left;"> citation </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> CanLaD </td>
   <td style="text-align:left;"> wildfire </td>
   <td style="text-align:left;"> 1985:2024 </td>
   <td style="text-align:left;"> https://doi.org/10.23687/902801fd-4d9d-4df4-9e95-319e429545cc </td>
   <td style="text-align:left;"> Perbet, P., Guindon, L., Correia D.L.P., P. Villemaire, O., Reisi Gahrouei R. St-Amant, Canada Landsat Disturbance with pest (CanLaD): a Canada-wide Landsat-based 30-m resolution product of fire, harvest and pest outbreak detection and attribution since 1987. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CanLaD </td>
   <td style="text-align:left;"> harvesting </td>
   <td style="text-align:left;"> 1985:2024 </td>
   <td style="text-align:left;"> https://doi.org/10.23687/902801fd-4d9d-4df4-9e95-319e429545cc </td>
   <td style="text-align:left;"> Perbet, P., Guindon, L., Correia D.L.P., P. Villemaire, O., Reisi Gahrouei R. St-Amant, Canada Landsat Disturbance with pest (CanLaD): a Canada-wide Landsat-based 30-m resolution product of fire, harvest and pest outbreak detection and attribution since 1987. </td>
  </tr>
</tbody>
</table>

### Module inputs and parameters

Table \@ref(tab:moduleInputs-historicalDisturbances) shows the full list of module inputs.

<table class="table" style="color: black; margin-left: auto; margin-right: auto;">
<caption>(\#tab:moduleInputs-historicalDisturbances)(\#tab:moduleInputs-historicalDisturbances)List of (ref:historicalDisturbances) input objects and their description.</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> objectName </th>
   <th style="text-align:left;"> objectClass </th>
   <th style="text-align:left;"> desc </th>
   <th style="text-align:left;"> sourceURL </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> disturbanceRasters </td>
   <td style="text-align:left;"> list </td>
   <td style="text-align:left;"> Set of spatial data sources containing locations of disturbance events for each year. List items must be named by disturbance event types. Within each event's list, items must be named by the 4 digit year the disturbances occured in. For example, fires for 2025 can be accessed with `disturbanceRasters[["fires"]][["2025"]]`. Each disturbance item is a terra SpatRaster layer. All non-NA areas will be considered events. </td>
   <td style="text-align:left;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> rasterToMatch </td>
   <td style="text-align:left;"> spatRaster </td>
   <td style="text-align:left;"> Raster template defining the study area. NA cells will be excluded from analysis. </td>
   <td style="text-align:left;"> NA </td>
  </tr>
</tbody>
</table>

Summary of user-visible parameters (Table \@ref(tab:moduleParams-historicalDisturbances))


<table class="table" style="color: black; margin-left: auto; margin-right: auto;">
<caption>(\#tab:moduleParams-historicalDisturbances)(\#tab:moduleParams-historicalDisturbances)List of (ref:historicalDisturbances) parameters and their description.</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> paramName </th>
   <th style="text-align:left;"> paramClass </th>
   <th style="text-align:left;"> default </th>
   <th style="text-align:left;"> min </th>
   <th style="text-align:left;"> max </th>
   <th style="text-align:left;"> paramDesc </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> disturbanceSource </td>
   <td style="text-align:left;"> character </td>
   <td style="text-align:left;"> CanLaD </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> The disturbance data source. Refer to data/availableData.csv to see which data is available. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> disturbanceYears </td>
   <td style="text-align:left;"> numeric </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> The range of years for which disturbances are extracted. Refer to data/availableData.csv to see which data is available. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> disturbanceTypes </td>
   <td style="text-align:left;"> character </td>
   <td style="text-align:left;"> wildfire </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> The type of disturbance extracted. Refer to data/availableData.csv to see which data is available. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> .plots </td>
   <td style="text-align:left;"> character </td>
   <td style="text-align:left;"> screen </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> Used by Plots function, which can be optionally used here </td>
  </tr>
  <tr>
   <td style="text-align:left;"> .plotInitialTime </td>
   <td style="text-align:left;"> numeric </td>
   <td style="text-align:left;"> 0 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> Describes the simulation time at which the first plot event should occur. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> .plotInterval </td>
   <td style="text-align:left;"> numeric </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> Describes the simulation time interval between plot events. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> .useCache </td>
   <td style="text-align:left;"> logical </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> Should caching of events or module be used? </td>
  </tr>
</tbody>
</table>


### Module outputs

Description of the module outputs (Table \@ref(tab:moduleOutputs-historicalDisturbances)).

<table class="table" style="color: black; margin-left: auto; margin-right: auto;">
<caption>(\#tab:moduleOutputs-historicalDisturbances)(\#tab:moduleOutputs-historicalDisturbances)List of (ref:historicalDisturbances) outputs and their description.</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> objectName </th>
   <th style="text-align:left;"> objectClass </th>
   <th style="text-align:left;"> desc </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> rstCurrentBurn </td>
   <td style="text-align:left;"> spatRaster </td>
   <td style="text-align:left;"> A binary raster with 1 values representing burned pixels. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> rstCurrentHarvest </td>
   <td style="text-align:left;"> spatRaster </td>
   <td style="text-align:left;"> A binary raster with 1 values representing harvested pixels. </td>
  </tr>
</tbody>
</table>


