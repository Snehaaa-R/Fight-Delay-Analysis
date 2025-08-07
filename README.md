# ✈️ Fight-Delay-Analysis
An R-based project analyzing U.S. flight delays by airline, airport, weekday, and flight duration, with a focus on Pennsylvania. Includes data cleaning, feature engineering, and geospatial mapping to uncover patterns in delay behavior using real-world flight and airport datasets.

> 📌 _Note: This analysis is limited to flights to and from Pennsylvania (mainly Philadelphia) to narrow the scope and provide focused regional insights._





# 🔎 Objectives

# Files
```bash
.  
├── RScript_Final.R                 # Main R script with all visualizations  
├── T_ONTIME_REPORTING_2.0.csv      # U.S. flight performance dataset    
├── README.md                       # Project documentation (this file)  
├── plots/                          # All generated plots  
│   ├── 1. Bar Graph.png            # Avg arrival delay by airline  
│   ├── 1. line Graph.png           # Delay trends by weekday  
│   ├── 3. Box plot.png             # Departure delay by PA airports  
│   ├── 4. Histogram1.png           # Early departures  
│   ├── 5. Histogram2.png           # Early arrivals  
│   ├── 6. Histogram3.png           # Arrival delay by flight type  
│   ├── 7. Histogram4.png           # Departure delay by flight type  
│   ├── 8. Bubbleplot.png           # Top 10 busiest origin airports  
│   ├── 9. mapline.png              # Avg delay for top airports  
│   └── 10. Choropleth.png          # Avg delay by origin state (U.S. map)

```
# Libraries Used

* `library(tidyverse)`
* `library(lubridate)`
* `library(dplyr)`
* `library(ggplot2)`
* `library(maps)`

# Dataset Overview
The dataset `T_ONTIME_REPORTING_2.0.csv` contains detailed records of domestic U.S. flights, including scheduled and actual departure/arrival times, delays, carrier information, and airport codes. It is part of the U.S. Department of Transportation’s on-time performance data, commonly used for air traffic and delay pattern analysis.

Key attributes include:

* `FL_DATE`– Flight date
* `OP_CARRIER` – Airline code
* `ORIGIN`, `DEST` – Airport codes
* `ORIGIN_CITY_NAME`, `DEST_CITY_NAME` – Airport locations
* `DEP_DELAY`, `ARR_DELAY` – Delay durations (in minutes)
* `AIR_TIME` – Actual time in the air
* `ORIGIN_STATE_ABR`, `DEST_STATE_ABR` – U.S. state codes

This dataset allows for both time-series and geospatial analysis of flight behavior and is especially useful in evaluating delay patterns across airlines, airports, and states.

---
To enrich the flight delay dataset with geographic context, an external airport dataset was merged using the airport IATA codes (Origin_IATA). The external dataset, sourced from the OpenFlights GitHub repository, contains detailed airport information including city, country, latitude, and longitude.

Here is the link: 
https://raw.githubusercontent.com/jpatokal/openflights/master/data/airports.dat

After merging, the resulting dataset includes both flight performance metrics and airport geolocation attributes, enabling advanced geospatial visualizations such as bubble maps and choropleth plots.

Key added fields:

* `CITY `– Airport city name
* `LAT`, `LON` – Geographic coordinates (latitude, longitude)
* `COUNTRY` – Country of the airport (filtered to the United States)

This merged dataset allowed for:

* Mapping delays by U.S. state and city
* Identifying the busiest origin airports to Pennsylvania (PA)
* Visualizing spatial patterns in delay duration and frequency
* The integration of location data transformed the project from basic delay analysis into a comprehensive spatio-temporal visualization of air traffic performance.
