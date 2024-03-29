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

dat_11 <- read_excel("Data/Raw/2011.xlsx", col_names = TRUE)

#Предподготовка

wd_11 <- dat_11
names(wd_11) <- c("case","gender","still_live","ag","gest","LB","WB","brain","heart","lung","liver","spleen","kidney","thymus","adrenal","pancreas","placenta","mac","CM","MP","IUGR","HC","CC")

wd_11 <- wd_11 %>% mutate(gender = ifelse(gender == "ж", "f" , "m"))

#ед сердцебиен???

wd_11 <- wd_11 %>% mutate(ag = ifelse(still_live %in% c("мертв","мертвый","мёртвый","мёритвый","интранатальная гибель плода"), 0 , ag)) %>%
  mutate(ag = ifelse(is.na(ag) == T, still_live, ag)) %>%
  mutate(still_live = ifelse(still_live %in% c("мертв","мертвый","мёртвый","мёритвый","интранатальная гибель плода"),"still","live"))

wd_11 <- wd_11 %>% mutate(ag = ifelse(ag %in% c("живой", "живший","жив", "живш"), NA , ag))

wd_11 <- wd_11 %>% mutate(mac = ifelse(mac == "да", "yes" , "no"))

wd_11 <- wd_11 %>% mutate(CM = CM %>% replace_na("no"), CM = ifelse(CM == "нет", "no",CM))

wd_11 <- wd_11 %>% mutate(MP = MP %>% replace_na("no")) %>% mutate(MP = ifelse(MP == "да","yes","no"))

wd_11 <- wd_11 %>% mutate(IUGR =  IUGR %>% as.character() %>% replace_na("no"))

#Добавляю год
wd_11 <- wd_11 %>% mutate(year =  2011)


wd_11 <- wd_11 %>% mutate(across(c(case, gest, LB, WB,brain, heart,lung,liver,spleen, kidney, thymus, adrenal, pancreas, placenta, HC, CC), ~ as.numeric(.x)), across(c(gender, still_live, mac, MP), ~ as.factor(.x)))


#Фильтрация

wd_11 <- wd_11 %>%
  filter (is.na(case) == FALSE) %>% #без протокола
  filter(gender %in% c("m","f")) #без пола

wd_11$ag <- gsub(",", ".", wd_11$ag)

wd_11$ag <- gsub("лет", "г", wd_11$ag)
wd_11$ag <- gsub("года", "г", wd_11$ag)
wd_11$ag <- gsub("госа", "г", wd_11$ag)
wd_11$ag <- gsub("г", "year", wd_11$ag)

wd_11$ag <- gsub("час", "ч", wd_11$ag)
wd_11$ag <- gsub("чов", "ч", wd_11$ag)
wd_11$ag <- gsub("ча", "ч", wd_11$ag)
wd_11$ag <- gsub("ч", "hour", wd_11$ag)


wd_11$ag <- gsub("минут", "мин", wd_11$ag)
wd_11$ag <- gsub("мин.", "мин", wd_11$ag)
wd_11$ag <- gsub("\"", "мин", wd_11$ag)
wd_11$ag <- gsub("'", "мин", wd_11$ag)
wd_11$ag <- gsub("мин", "minute", wd_11$ag)

wd_11$ag <- gsub("месяца", "ме", wd_11$ag)
wd_11$ag <- gsub("месяцев", "ме", wd_11$ag)
wd_11$ag <- gsub("месяц", "ме", wd_11$ag)
wd_11$ag <- gsub("мяцев", "ме", wd_11$ag)
wd_11$ag <- gsub("мяца", "ме", wd_11$ag)
wd_11$ag <- gsub("мев", "ме", wd_11$ag)
wd_11$ag <- gsub("мес", "ме", wd_11$ag)
wd_11$ag <- gsub("мяц", "ме", wd_11$ag)
wd_11$ag <- gsub("ма", "ме", wd_11$ag)
wd_11$ag <- gsub("ме", "month", wd_11$ag)
wd_11$ag <- gsub("м", "month", wd_11$ag)

wd_11$ag <- gsub("суток", "д", wd_11$ag)
wd_11$ag <- gsub("дней", "д", wd_11$ag)
wd_11$ag <- gsub("сутки", "д", wd_11$ag)
wd_11$ag <- gsub("сут", "д", wd_11$ag)
wd_11$ag <- gsub("ски", "д", wd_11$ag)
wd_11$ag <- gsub("дня", "д", wd_11$ag)
wd_11$ag <- gsub("дей", "д", wd_11$ag)
wd_11$ag <- gsub("дн", "д", wd_11$ag)
wd_11$ag <- gsub("с", "д", wd_11$ag)
wd_11$ag <- gsub("д", "day", wd_11$ag)


wd_11 <- wd_11 %>% mutate(Age = ifelse(still_live == "live",duration(wd_11$ag), 0))
wd_11 <- wd_11 %>% mutate(Age_1 = strsplit(as.character(Age), 's')) %>%
  mutate(Age_1 = sapply(Age_1, head, 1))
wd_11 <- wd_11 %>%  add_column(age_days = as.numeric(wd_11$Age_1), .after = 4)
wd_11$age_days <- round(wd_11$age_days/86400,4)

wd_11 <- wd_11 %>% mutate(Age = NULL, Age_1 = NULL, ag = NULL) %>%
  filter(age_days <= 1) %>%
  mutate(age_days = ifelse(age_days == 0, 0,1) %>% as.factor())

wd_11 <- wd_11 %>% filter (gest >= 14) %>%  #гестация < 14
  filter (mac == "no") %>% #мацерация
  filter (CM == "no") %>% #врождённые пороки
  filter (MP == "no") %>% #многоплодная
  filter (IUGR == "no") #СЗРП

write_rds(wd_11,"Data/Nastya_clean_data/2011.rds")