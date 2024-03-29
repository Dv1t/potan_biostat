library(readxl)
library(dplyr)
library(tibble)
library(psych)
library(tidyr)
library(flextable)
library(tibble)
library(gtsummary)
library(lubridate)
library(readr)

Sys.setlocale("LC_CTYPE", "russian")

dat_12 <- read_excel("Data/Raw/2012.xlsx", col_names = TRUE)

#Предподготовка


wd_12 <- dat_12
names(wd_12) <- c("case","gender","still_live","ag","gest","LB","WB","brain","heart","lung","liver","spleen","kidney","thymus","adrenal","pancreas","placenta","mac","CM","MP","IUGR","HC","CC")


wd_12 <- wd_12 %>% mutate(gender = case_when(gender == "ж" ~ "f",
                                           gender == "м" ~ "m"), gender = ifelse(gender %in% c("f","m"),gender, NA))


wd_12 <- wd_12 %>% mutate(ag = ifelse(still_live %in% c("мертв","мертвый","мёртвый","мёритвый","интранатальная гибель плода"), 0 , ag)) %>%
  mutate(ag = ifelse(is.na(ag) == T, still_live, ag)) %>%
  mutate(still_live = ifelse(still_live %in% c("мертв","мертвый","мёртвый","мёритвый"),"still","live"))

wd_12 <- wd_12 %>% mutate(ag = ifelse(ag %in% c("живой", "живший","жив", "живш"), NA , ag))

wd_12 <- wd_12 %>% mutate(gest = ifelse(gest == "?", NA , gest))

wd_12 <- wd_12 %>% mutate(mac = ifelse(mac == "да", "yes" , "no"))

wd_12 <- wd_12 %>% mutate(CM = CM %>% replace_na("no"), CM = ifelse(CM == "нет", "no",CM))

wd_12 <- wd_12 %>% mutate(MP = MP %>% replace_na("no")) %>% mutate(MP = ifelse(MP == "да","yes","no")) 

wd_12 <- wd_12 %>% mutate(IUGR =  IUGR %>% as.character() %>% replace_na("no"))

#Добавляю год
wd_12 <- wd_12 %>% mutate(year =  2012)


wd_12 <- wd_12 %>% mutate(across(c(case, gest, LB, WB,brain, heart,lung,liver,spleen, kidney, thymus, adrenal, pancreas, placenta, HC, CC), ~ as.numeric(.x)), across(c(gender, still_live, mac, MP), ~ as.factor(.x)))

#Фильтрация

wd_12 <- wd_12 %>%
  filter (is.na(case) == FALSE) %>% #без протокола
  filter(gender %in% c("m","f")) #без пола

wd_12$ag <- gsub(",", ".", wd_12$ag)

wd_12$ag <- gsub("лет", "г", wd_12$ag)
wd_12$ag <- gsub("года", "г", wd_12$ag)
wd_12$ag <- gsub("госа", "г", wd_12$ag)
wd_12$ag <- gsub("г", "year", wd_12$ag)

wd_12$ag <- gsub("час", "ч", wd_12$ag)
wd_12$ag <- gsub("чов", "ч", wd_12$ag)
wd_12$ag <- gsub("ча", "ч", wd_12$ag)
wd_12$ag <- gsub("ч", "hour", wd_12$ag)

wd_12$ag <- gsub("нед", "week", wd_12$ag)

wd_12$ag <- gsub("минут", "мин", wd_12$ag)
wd_12$ag <- gsub("мин.", "мин", wd_12$ag)
wd_12$ag <- gsub("'", "мин", wd_12$ag)
wd_12$ag <- gsub("мин", "minute", wd_12$ag)

wd_12$ag <- gsub("месяца", "ме", wd_12$ag)
wd_12$ag <- gsub("месяцев", "ме", wd_12$ag)
wd_12$ag <- gsub("месяц", "ме", wd_12$ag)
wd_12$ag <- gsub("мяцев", "ме", wd_12$ag)
wd_12$ag <- gsub("мяца", "ме", wd_12$ag)
wd_12$ag <- gsub("мев", "ме", wd_12$ag)
wd_12$ag <- gsub("мес", "ме", wd_12$ag)
wd_12$ag <- gsub("мяц", "ме", wd_12$ag)
wd_12$ag <- gsub("ма", "ме", wd_12$ag)
wd_12$ag <- gsub("ме", "month", wd_12$ag)
wd_12$ag <- gsub("м", "month", wd_12$ag)

wd_12$ag <- gsub("сек", "second", wd_12$ag)

wd_12$ag <- gsub("суток", "д", wd_12$ag)
wd_12$ag <- gsub("дней", "д", wd_12$ag)
wd_12$ag <- gsub("сутки", "д", wd_12$ag)
wd_12$ag <- gsub("сут", "д", wd_12$ag)
wd_12$ag <- gsub("ски", "д", wd_12$ag)
wd_12$ag <- gsub("дня", "д", wd_12$ag)
wd_12$ag <- gsub("дей", "д", wd_12$ag)
wd_12$ag <- gsub("дн", "д", wd_12$ag)
wd_12$ag <- gsub("с", "д", wd_12$ag)
wd_12$ag <- gsub("д", "day", wd_12$ag)


wd_12 <- wd_12 %>% mutate(Age = ifelse(still_live == "live",duration(wd_12$ag), 0))
wd_12 <- wd_12 %>% mutate(Age_1 = strsplit(as.character(Age), 's')) %>%
  mutate(Age_1 = sapply(Age_1, head, 1)) 
wd_12 <- wd_12 %>%  add_column(age_days = as.numeric(wd_12$Age_1), .after = 4)
wd_12$age_days <- round(wd_12$age_days/86400,4)

wd_12 <- wd_12 %>% mutate(Age = NULL, Age_1 = NULL, ag = NULL) %>%
  filter(age_days <= 1) %>%
  mutate(age_days = ifelse(age_days == 0, 0,1) %>% as.factor())

wd_12 <- wd_12 %>% filter (gest >= 14) %>%  #гестация < 14
  filter (mac == "no") %>% #мацерация
  filter (CM == "no") %>% #врождённые пороки
  filter (MP == "no") %>% #многоплодная
  filter (IUGR == "no") #СЗРП

write_rds(wd_12,"Data/Nastya_clean_data/2012.rds")