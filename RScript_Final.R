#____________________________LOADING NECESSARY LIBRARIES________________________

library(tidyverse)
library(lubridate)
library(dplyr)
library(ggplot2)
library(maps)


#________________________________LOADING THE DATA_______________________________


airlines_data <- read.csv("T_ONTIME_REPORTING_2.0.csv", stringsAsFactors = FALSE)


#_________________________________DATA CLEANING_________________________________
#Removing NA's
airlines_data_clean <- airlines_data %>%
  drop_na()         


airlines_data_clean <- airlines_data %>%
  select(FL_DATE, OP_CARRIER_AIRLINE_ID, ORIGIN_CITY_NAME, DEST_CITY_NAME, 
         DEP_DELAY, ARR_DELAY, ORIGIN,
         ORIGIN_STATE_ABR, AIR_TIME, DEST_STATE_ABR,OP_CARRIER) %>%
  rename(
    Airline = OP_CARRIER_AIRLINE_ID,
    Origin = ORIGIN_CITY_NAME,
    Destination = DEST_CITY_NAME,
    DepDelay = DEP_DELAY,
    ArrDelay = ARR_DELAY,
    Origin_IATA = ORIGIN,
    Origin_st_abr = ORIGIN_STATE_ABR,
    Air_time = AIR_TIME,
    Dest_st_abr = DEST_STATE_ABR,
    Airline_name = OP_CARRIER
  )


#________________________________MUTATING THE DATE______________________________


airlines_data_clean <- airlines_data_clean %>%
  mutate(FL_DATE = mdy_hms(FL_DATE, quiet = FALSE))

#____________________________FILTERING THE DATA FOR VISUALIZATION_______________
airlines_delay <- airlines_data_clean %>%
  filter(DepDelay >= 0, ArrDelay >= 0) 

#____________________________Flights from PA TO PA______________________________
pa_flights <- airlines_delay %>%
  filter(Dest_st_abr == "PA", Origin_st_abr == "PA") 

#__________________________________Bar Chart____________________________________

airlines_delay <- airlines_delay %>% 
  mutate(Airline_full = case_when(
    Airline_name == "AA" ~ "American Airlines",
    Airline_name == "DL" ~ "Delta Air Lines",
    Airline_name == "UA" ~ "United Airlines",
    Airline_name == "WN" ~ "Southwest Airlines",
    Airline_name == "B6" ~ "JetBlue Airways",
    Airline_name == "OO" ~ "SkyWest Airlines",
    Airline_name == "G4" ~ "Allegiant Air",
    Airline_name == "OH" ~ "PSA Airlines" ,
    Airline_name == "F9" ~ "Frontier Airlines",
    Airline_name == "9E" ~ "Endeavor Air",
    Airline_name == "MQ" ~ "Envoy Air",
    Airline_name == "NK" ~ "Spirit Airlines",
    Airline_name == "AS" ~ "Alaska Airlines",
    Airline_name == "YX" ~ "Republic Airways"
  ))


airlines_delay %>%
  group_by(Airline_full) %>%
  summarize(AvgArrDelay = mean(ArrDelay)) %>%
  ggplot(aes(y = reorder(Airline_full, AvgArrDelay), x = AvgArrDelay,
             )) +
  geom_bar(stat = "identity", fill = "#27408B") +
  #scale_fill_gradient(low = "yellow", high = "darkgreen") + 
  labs(
    title = "Average Arrival Delay by Airlines",
    x = "Average Delay (minutes)",
    y = "",
    fill = "Avg Delay"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 15, face = "bold", hjust = 0.5))


ggsave("1. Bar Graph.png", bg="white")


#_______________________________Distribution by Airline_________________________
# Compute median delays for ordering
airlines_delay$Airline_full <- reorder(airlines_delay$Airline_full, airlines_delay$ArrDelay, FUN = median)

# Plot with ordered boxplots
ggplot(airlines_delay, aes(y = reorder(Airline_full, ArrDelay, FUN = median), 
                           x = ArrDelay, fill = Airline_full)) +
  geom_boxplot() +  # Uses default fill colors
  theme_minimal() +
  labs(title = "Distribution of Arrival Delays by Airline",
       y = "Airlines",
       x = "Arrival Delay (minutes)") +
  theme(legend.position = "none",
        plot.title = element_text(face = "bold", hjust = 0.5)) +
  xlim(0, 1000)




#___________________________________Line Graph__________________________________

airlines_delay %>%
  mutate(Weekday = wday(FL_DATE, label = TRUE, week_start = 1)) %>% #extracting week from dates
  group_by(Weekday) %>%
  summarize(AvgArrDelay = mean(ArrDelay, na.rm = TRUE)) %>%
  ggplot(aes(x = Weekday, y = AvgArrDelay, group = 1)) +
  geom_line(color = "purple", linewidth = 1) +
  geom_point(color = "orange", size = 3) +
  labs(
    title = "Average Arrival Delay by Day of weeks",
    x = "Day of weeks",
    y = "Average Delay (minutes)"
  ) +
  theme_minimal()+
  theme(
    plot.title = element_text(size = 15, face = "bold", hjust = 0.5))

ggsave("1. line Graph.png", bg="white")




#____________________________________Boxplot_______________________________________


airlines_delay <- airlines_delay %>%
  separate(Origin, into = c("City", "State"), sep = ", ", remove = FALSE)

airlines_delay %>%
  filter(Origin_st_abr == "PA") %>%
  ggplot(aes(y = reorder(City, DepDelay, median, na.rm = TRUE), x = DepDelay, fill = Origin_IATA)) +
  geom_boxplot(outlier.shape = NA) +
  coord_cartesian(xlim = c(-20, 300)) +
  labs(
    title = "Departure Delay Distribution of PA Airports",
    y = "Airports",
    x = "Departure Delay (Minutes)"
  ) +
  theme_minimal()+
  theme(
    plot.title = element_text(size = 15, face = "bold", hjust = 0.5),
    legend.position = "none")

ggsave("3. Box plot.png", bg="white")
#____________________________________Histograms_________________________________

early_departures <- airlines_data_clean %>% 
  filter(DepDelay < 0)

ggplot(early_departures, aes(x = DepDelay)) +
  geom_histogram(binwidth = 5, fill = "steelblue", color = "black", alpha = 0.7) +
  xlim(-60, 0) +  # Set consistent x-axis scale
  labs(
    title = "Distribution of Early Departures",
    x = "Departure Delay (Minutes)",
    y = "Frequency"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 15, face = "bold", hjust = 0.5)
  )

ggsave("4. Histogram1.png", bg = "white")


early_arrivals <- airlines_data_clean %>% 
  filter(ArrDelay < 0)

ggplot(early_arrivals, aes(x = ArrDelay)) +
  geom_histogram(binwidth = 5, fill = "steelblue", color = "black", alpha = 0.7) +
  xlim(-60, 0) + 
  ylim(0, 6000)+# Set the same x-axis scale as departures
  labs(
    title = "Distribution of Early Arrivals",
    x = "Arrival Delay (Minutes)",
    y = "Frequency"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 15, face = "bold", hjust = 0.5)
  )

ggsave("5. Histogram2.png", bg = "white")

#Histogram for Arrival basis on Trip Duration

airlines_delay$FLIGHT_TYPE <- NA  # Create an empty column

airlines_delay$FLIGHT_TYPE[airlines_delay$Air_time <= 180] <- "Short"
airlines_delay$FLIGHT_TYPE[airlines_delay$Air_time > 180] <- "Long"

# Plot Arrival Delay Distribution by Flight Type
ggplot(airlines_delay, aes(x = ArrDelay, fill = factor(FLIGHT_TYPE, levels = c("Short", "Long")))) +
  geom_histogram(binwidth = 5, alpha = 0.7, position = "identity") +
  xlim(0, 500) +
  labs(
    title = "Arrival Delay Distribution by Flight Type",
    x = "Arrival Delay (Minutes)",
    y = "Frequency",
    fill = "Flight Type"
  ) +
  theme_minimal()+
  theme(
    plot.title = element_text(size = 15, face = "bold", hjust = 0.5))+
  scale_fill_manual(values = c("Long" = "darkred", "Short" = "lightblue"))


ggsave("6. Histogram3.png", bg="white")

#Histogram for Arrival basis on Trip Duration

ggplot(airlines_delay, aes(x = DepDelay, fill = factor(FLIGHT_TYPE, levels = c("Short", "Long")))) +
  geom_histogram(binwidth = 5, alpha = 0.7, position = "identity") +
  xlim(0, 500) +
  labs(
    title = "Departure Delay Distribution by Flight Type",
    x = "Departure Delay (Minutes)",
    y = "Frequency",
    fill = "Flight type"
  ) +
  theme_minimal()+
  theme(
    plot.title = element_text(size = 15, face = "bold", hjust = 0.5))+
  
  scale_fill_manual(values = c("Long" = "darkred", "Short" = "lightblue"))

ggsave("7. Histogram4.png", bg="white")

#_________________________________Geospatial Map____________________________________

#reading the data from external source to obtain the LAT and LON
airports <- read.csv("https://raw.githubusercontent.com/jpatokal/openflights/master/data/airports.dat", header = FALSE, stringsAsFactors = FALSE)


#Importing required columns
airports <- airports[, c(3, 4, 5, 6, 7, 8)]
colnames(airports) <- c("CITY", "COUNTRY", "IATA_CITY", "IATA_COUNTRY", "LAT", "LON")

#filtering only USA
airports <- airports %>%
  filter(COUNTRY == "United States")

#removing NA's

airports <- airports %>%
  mutate(IATA_CITY = na_if(IATA_CITY, "\\N"))

airports[airports == "\\N"] <- NA

sum(is.na(airports$IATA_CITY))

airports <- airports[!is.na(airports$IATA_CITY), ]

sum(is.na(airports$IATA_CITY))

#joining the LAT LON data to Airlines_delay
airlines_delay <- airlines_delay %>% left_join(airports, by = c("Origin_IATA" = "IATA_CITY"))

#Calculating average delay
airlines_delay <-airlines_delay %>% 
  mutate(DELAY = (DepDelay + ArrDelay) / 2)


#finding top 10 busiest airport
top_10_busiest <- airlines_delay %>%
  group_by(Origin, City, LAT, LON) %>%
  summarise(flight_count = n(), avg_delay = mean(DELAY, na.rm = TRUE), .groups = 'drop') %>%
  arrange(desc(flight_count)) %>%
  slice_head(n = 10)

map_data_us <- map_data("state")


#Plotting the map
ggplot() +
  geom_polygon(data = map_data_us, aes(x = long, y = lat, group = group),
               fill = "lightgray", color = "white") +
  geom_point(
    data = top_10_busiest,
    aes(x = LON, y = LAT, size = avg_delay, color = avg_delay),
    alpha = 0.8
  ) +
  geom_text(
    data = top_10_busiest,
    aes(x = LON, y = LAT, label = City),
    size = 3, hjust = -0.3, vjust = -0.3
  ) +
  scale_color_gradient(low = "lightyellow", high = "darkred") +
  guides(size = "none"
  ) +
  labs(
    title = "Top 10 Busiest Origin Airports for Flights to PA",
    x = "Longitude",
    y = "Latitude",
    color = "Avg Delay (min)"
    ) +
  theme_void() +
  theme(
    plot.title = element_text(size = 15, face = "bold", hjust = 0.5),
    
  )

ggsave("8. Bubbleplot.png", bg="white")

top_10_busiest %>%
  ggplot(aes(y = reorder(City, avg_delay), x = avg_delay)) +
  geom_bar(stat = "identity",fill = "") +
  #geom_point(size = 2, color = "orange") +
  labs(
    title = "Average Delay for Top 10 Busiest Origin Airports",
    y = "",
    x = "Average Delay (Minutes)"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 15, face = "bold", hjust = 0.5)
  )

ggsave("9. mapline.png", bg="white")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#Choropleth

state_delays <- airlines_delay %>%
  filter(Dest_st_abr == "PA") %>% # Exclude PA as destination
  group_by(Origin_st_abr) %>%
  summarize(avg_delay = mean(DELAY, na.rm = TRUE), .groups = "drop")


state_name_mapping <- data.frame(
  Origin_st_abr = state.abb,
  state_name = tolower(state.name)
)


state_delays <- state_delays %>%
  left_join(state_name_mapping, by = "Origin_st_abr")


states_map <- map_data("state")


map_data_with_delay <- left_join(states_map, state_delays, by = c("region" = "state_name"))


state_centers <- map_data_with_delay %>%
  group_by(region) %>%
  summarise(
    long = mean(range(long), na.rm = TRUE),
    lat = mean(range(lat), na.rm = TRUE),
    Origin_st_abr = first(Origin_st_abr),
    .groups = "drop"
  )



ggplot() +
  geom_polygon(
    data = map_data_with_delay,
    aes(x = long, y = lat, group = group, fill = avg_delay),
    color = "black"
  ) +
  #geom_text(
    #data = state_centers,
    #aes(x = long, y = lat, label = Origin_st_abr),
    #size = 3
 # ) +
  scale_fill_gradient(low = "lightyellow", high = "darkred", na.value = "white") +
  labs(
    title = "Average Flight Delay by State",
    fill = "Avg Delay (min)",
    x = "Longitude",
    y = "Latitude"
  ) +
  theme_void()+
  theme(
    plot.title = element_text(size = 15, face = "bold", hjust = 0.5)
  )

ggsave("10. Choropleth.png", bg="white")




