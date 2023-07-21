# County level unemployment data from LAUS for EARNCon visualization workshop


#### Libraries ####
library(tidyverse)
library(here)
library(janitor)
library(labelled)
library(readxl)
library(openxlsx)
library(data.table)


#### Download county LAUS from BLS ####

# URL to BLS county LAUS data
raw_laus <- 'https://www.bls.gov/web/metro/laucntycur14.zip'

# Download URL
system(paste0('wget -U "" -N --progress=bar:force --header="Accept-Encoding: gzip" ', raw_laus, " -P input/"))

# Unzip file
unzip(here("input/laucntycur14.zip"), exdir = here("input"))



#### Read and clean LAUS excel file ####
laus_county <- read_excel(here('input/laucntycur14.xlsx'), range = 'A5:I45086') %>% 
  clean_names() %>% 
  #Convert string to date
  mutate(date = as.Date(paste("01-", period, sep = ""), format = "%d-%b-%y")) %>% 
  filter(!is.na(code_2)) %>% 
  
  #rename vars
  rename(seriesid = laus_code,
         statefips = code_2,
         countyfips = code_3,
         labforce = force,
         urate = percent
         ) %>% 
  
  #create state and county columns
  separate(col = county_name_state_abbreviation,
           into = c('county', 'state'), sep=",") %>% 
  #Remove white space from statefips. Give DC a statefip code
  mutate(state = str_squish(state),
         state = replace(state, county=='District of Columbia', 'DC'))


#### Create workbook for visualization workshop ####
clean_laus <- laus_county %>% 
  select(seriesid, date, statefips, countyfips, state, county, labforce, employed, unemployed, urate) %>% 
  write_csv(here('output/clean_county_laus.csv'))
  

