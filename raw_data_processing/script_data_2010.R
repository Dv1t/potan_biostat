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


dat_10 <- read_excel("Data/Raw/2010.xlsx", col_names = TRUE)

#Предподготовка
wd_10 <- dat_10
names(wd_10) <- c("case","gender","still_live","ag","gest","LB","WB","brain","heart","lung","liver","spleen","kidney","thymus","adrenal","pancreas","placenta","mac","CM","MP","IUGR","HC","CC","wth")

#СТРАННОСТЬ!!!
wd_10 <- wd_10 %>% mutate(wth = NULL)

wd_10 <- wd_10 %>% mutate(gender = ifelse(gender == "ж", "f" , "m"))

wd_10 <- wd_10 %>% mutate(ag = ifelse(still_live %in% c("мертв","мертвый","мёртвый"), 0 , ifelse(still_live == "живой", ag, still_live))) %>%
  mutate(still_live = ifelse(ag == 0,"still","live")) %>%
  mutate(ag = ifelse(ag == "1", "1 сут",ag))

wd_10 <- wd_10 %>% mutate(ag = ifelse(ag == "живой", NA , ag))

wd_10 <- wd_10 %>% mutate(mac = ifelse(mac == "да", "yes" , "no"))

wd_10 <- wd_10 %>% mutate(CM = CM %>% replace_na("no"))

wd_10 <- wd_10 %>% mutate(MP = MP %>% replace_na("no")) %>% mutate(MP = ifelse(MP == "да","yes","no"))

wd_10 <- wd_10 %>% mutate(IUGR =  IUGR %>% as.character() %>% replace_na("no"))

#Добавляем год
wd_10 <- wd_10 %>% mutate(year =  2010)


wd_10 <- wd_10 %>% mutate(across(c(case, gest, LB, WB,brain, heart,lung,liver,spleen, kidney, thymus, adrenal, pancreas, placenta, HC, CC), ~ as.numeric(.x)), across(c(gender, still_live, mac, MP), ~ as.factor(.x)))

#Фильтрация

wd_10 <- wd_10 %>%
  filter (is.na(case) == FALSE) %>% #без протокола
  filter(gender %in% c("m","f")) #без пола

#сей?

wd_10$ag <- gsub(",", ".", wd_10$ag)

wd_10$ag <- gsub("лет", "г", wd_10$ag)
wd_10$ag <- gsub("года", "г", wd_10$ag)
wd_10$ag <- gsub("госа", "г", wd_10$ag)
wd_10$ag <- gsub("г", "year", wd_10$ag)

wd_10$ag <- gsub("час", "ч", wd_10$ag)
wd_10$ag <- gsub("чов", "ч", wd_10$ag)
wd_10$ag <- gsub("ча", "ч", wd_10$ag)
wd_10$ag <- gsub("ч", "hour", wd_10$ag)

wd_10$ag <- gsub("минут", "мин", wd_10$ag)
wd_10$ag <- gsub("мин.", "мин", wd_10$ag)
wd_10$ag <- gsub("'", "мин", wd_10$ag)
wd_10$ag <- gsub("мин", "minute", wd_10$ag)

wd_10$ag <- gsub("месяца", "ме", wd_10$ag)
wd_10$ag <- gsub("месяцев", "ме", wd_10$ag)
wd_10$ag <- gsub("месяц", "ме", wd_10$ag)
wd_10$ag <- gsub("мяцев", "ме", wd_10$ag)
wd_10$ag <- gsub("мяца", "ме", wd_10$ag)
wd_10$ag <- gsub("мев", "ме", wd_10$ag)
wd_10$ag <- gsub("мес", "ме", wd_10$ag)
wd_10$ag <- gsub("мяц", "ме", wd_10$ag)
wd_10$ag <- gsub("ма", "ме", wd_10$ag)
wd_10$ag <- gsub("ме", "month", wd_10$ag)
wd_10$ag <- gsub("м", "month", wd_10$ag)

wd_10$ag <- gsub("суток", "д", wd_10$ag)
wd_10$ag <- gsub("сутки", "д", wd_10$ag)
wd_10$ag <- gsub("дней", "д", wd_10$ag)
wd_10$ag <- gsub("сут", "д", wd_10$ag)
wd_10$ag <- gsub("ски", "д", wd_10$ag)
wd_10$ag <- gsub("дня", "д", wd_10$ag)
wd_10$ag <- gsub("сей", "д", wd_10$ag) #!!!!
wd_10$ag <- gsub("дей", "д", wd_10$ag)
wd_10$ag <- gsub("дн", "д", wd_10$ag)
wd_10$ag <- gsub("с", "д", wd_10$ag)
wd_10$ag <- gsub("д", "day", wd_10$ag)


wd_10 <- wd_10 %>% mutate(Age = ifelse(still_live == "live",duration(wd_10$ag), 0))
wd_10 <- wd_10 %>% mutate(Age_1 = strsplit(as.character(Age), 's')) %>%
  mutate(Age_1 = sapply(Age_1, head, 1))
wd_10 <- wd_10 %>%  add_column(age_days = as.numeric(wd_10$Age_1), .after = 4)
wd_10$age_days <- round(wd_10$age_days/86400,4)

wd_10 <- wd_10 %>% mutate(Age = NULL, Age_1 = NULL, ag = NULL) %>%
  filter(age_days <= 1) %>%
  mutate(age_days = ifelse(age_days == 0, 0,1) %>% as.factor())

wd_10 <- wd_10 %>% filter (gest >= 14) %>%  #гестация < 14
  filter (mac == "no") %>% #мацерация
  filter (CM == "no") %>% #врождённые пороки
  filter (MP == "no") %>% #многоплодная
  filter (IUGR == "no") #СЗРП

write_rds(wd_10,"Data/Nastya_clean_data/2010.rds")