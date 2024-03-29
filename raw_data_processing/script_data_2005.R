#Загрузим необходимые пакеты.
library(readr)
library(readxl)
library(dplyr)
library(tibble)
library(psych)
library(tidyr)
library(flextable)
library(tibble)
library(lubridate)
library(gtsummary)

#Загрузим данные
Data_en <- read_xlsx ("Data/Raw/2005.xlsx")
summary(Data_en)
Data_en %>% as.tibble()

table(Data_en$gender, useNA = "always")
table(Data_en$age, useNA = "always")
table(Data_en$case, useNA = "always")

# отбираем наблюдения с указанным возрастом, полом "м" или "ж"  (420ж и 532м) с наличием протокола (-2 наблюдения)
Data_step1 <- Data_en %>%
    filter (case != "НЕТ ПРОТОКОЛА") %>%
    filter(gender %in% c("м","ж")) #952 наблюдения

#переносим возраст из колнки still_live в колонку age
table(Data_step1$still_live, useNA = "always") #590 мертв; 359 NA (жив); 2 - указан возраст
table(Data_step1$age, useNA = "always")

# заполняем значения NA в переменной age значениями из вектора still_live
 Data_step1$age <-  coalesce (Data_step1$still_live, Data_step1$age) #592 NA


#создаем новую переменную age_days, в которой заменяем значение мертв на 0
Data_step1 <- Data_step1 %>%
  add_column(age_days = NA, .after = 3)

Data_step1 <- Data_step1 %>%
  mutate(age_days = ifelse(age == "мертв", "0 д", `age`))

table(Data_step1$age_days, useNA = "always")

#удаляем значение "не указан"
Data_step1 <- Data_step1 %>%
    filter (age_days != "не указан") #951 случай

#Приводим переменную age к одному типу, фильтруем по значению age < 86400

dd <- as.data.frame(Data_step1$age_days)
colnames(dd) <- c('время')
dd$время <- gsub("г", "лет", dd$время)
dd$время <- gsub(",", ".", dd$время)
dd$time <- gsub("лет", "year", dd$время)
dd$time <- gsub("мес", "month", dd$time)
dd$time <- gsub("дн", "day", dd$time)
dd$time <- gsub("д", "day", dd$time)
dd$time <- gsub("ч", "hour", dd$time)
dd$time <- gsub("мин", "minute", dd$time)
dd$time <- gsub("м", "month", dd$time)
dd$time <- trimws(dd$time)


dd$time_tot <- duration(dd$time)
dd$time_seconds <- strsplit(as.character(dd$time_tot), 's')
dd$time_seconds <- sapply(dd$time_seconds, head, 1)
Data_step1$age_days <- dd$time_seconds
Data_step1 <- Data_step1 %>%
    filter(as.numeric(age_days) <= (86400)) # на данном этапе остается 692 наблюдений

# Фильтрация по переменным "gest", "mac", "CM", "MP", IUGR
table(Data_step1$mac, useNA = "always") #удаляем 227 "да" и 7 NA
table(Data_step1$CM, useNA = "always") # из оставшихся токлько 227 без CM
table(Data_step1$IUGR, useNA = "always") # из оставшихся 226 без IUGR
table(Data_step1$MP, useNA = "always") # из оставшихся токлько 207 одноплодных
table(Data_step1$gest, useNA = "always") #3NA
summary(Data_step1$WB)

Data_step2 <- Data_step1 %>%
  filter(mac == "нет") %>%
  filter(CM == "нет") %>%
  filter(is.na(IUGR)) %>%
  filter(MP=="нет")

Data_step2$WB <- as.numeric(Data_step2$WB)
summary(Data_step2$WB) #удаляем значений веса более 5000 г (-2)

Data_step2 <- Data_step2 %>%
  filter(WB <= 5000) #итого 205 наблюдений

table(Data_step2$CM, useNA = "always")
table(Data_step2$IUGR, useNA = "always")
table(Data_step2$MP, useNA = "always")
table(Data_step2$MP, useNA = "always")

#удаляем колонку age
Data_step2 <- Data_step2[,-5]

# в колонке age_days присваеваем 1,  если значение отлично от 0
Data_step2 <- Data_step2 %>% mutate(age_days = ifelse(age_days == 0, 0, 1))

#приводим значения gender к стандартному виду на англ.языке
as.tibble(Data_step2)
table (Data_step2$gender)
table (Data_step2$still_live)

Data_step2 <- Data_step2 %>%
  mutate(gender = ifelse(gender == "м", "m", "f"))
Data_step2$gender <- as.factor(Data_step2$gender)

#приводим значения still_live к стандартному виду на англ.языке
Data_step2$still_live <- as.character(Data_step2$still_live)
Data_step2$still_live <- Data_step2$still_live %>% replace_na ("жив")

Data_step2 <- Data_step2 %>%
  mutate(still_live = ifelse( still_live == "мертв", "still", "live"))

#приводим значения CM и mac к стандартному виду на англ.языке
table(Data_step2$mac, useNA = "always")
table(Data_step2$CM, useNA = "always")
table(Data_step2$IUGR, useNA = "always")
table(Data_step2$MP, useNA = "always")

Data_step2$CM<- as.character(Data_step2$CM)
Data_step2$CM [Data_step2$CM == 'нет'] <- 'no'
Data_step2$mac<- as.character(Data_step2$mac)
Data_step2$mac [Data_step2$mac == 'нет'] <- 'no'
Data_step2$MP <- as.character(Data_step2$MP)
Data_step2$MP [Data_step2$MP == 'нет'] <- 'no'
Data_step2$IUGR <- as.character(Data_step2$IUGR)
Data_step2$IUGR <- Data_step2$IUGR %>% replace_na ("no")

#приводим данные к соответствующим типам

Data_step2$brain <- as.numeric(Data_step2$brain)
Data_step2$LB <- as.numeric(Data_step2$LB)
Data_step2$WB <- as.numeric(Data_step2$WB)
Data_step2$heart <- as.numeric(Data_step2$heart)
Data_step2$lung <- as.numeric(Data_step2$lung)
Data_step2$liver <- as.numeric(Data_step2$liver)
Data_step2$spleen <- as.numeric(Data_step2$spleen)
Data_step2$kidney <- as.numeric(Data_step2$kidney)
Data_step2$thymus <- as.numeric(Data_step2$thymus)
Data_step2$adrenal <- as.numeric(Data_step2$adrenal)
Data_step2$pancreas <- as.numeric(Data_step2$pancreas)
Data_step2$placenta<- as.numeric(Data_step2$placenta)
Data_step2$HC<- as.numeric(Data_step2$HC)
Data_step2$CC<- as.numeric(Data_step2$CC)
Data_step2$gest<- as.numeric(Data_step2$gest)


#округляем тип numeric до 2 знака
Data_step2$brain <- round(Data_step2$brain, 2)
Data_step2$LB <- round(Data_step2$LB, 2)
Data_step2$WB <- round(Data_step2$WB, 2)
Data_step2$heart <- round(Data_step2$heart, 2)
Data_step2$lung <- round(Data_step2$lung, 2)
Data_step2$liver <- round(Data_step2$liver, 2)
Data_step2$spleen <- round(Data_step2$spleen, 2)
Data_step2$kidney <- round(Data_step2$kidney, 2)
Data_step2$thymus <- round(Data_step2$thymus, 2)
Data_step2$adrenal <- round(Data_step2$adrenal, 2)
Data_step2$pancreas <- round(Data_step2$pancreas, 2)
Data_step2$placenta <- round(Data_step2$placenta, 2)
Data_step2$HC <- round(Data_step2$HC, 2)
Data_step2$CC <- round(Data_step2$CC, 2)

#приводим типы для остальных переменных

Data_step2 <-  Data_step2 %>%
 mutate(across(c(gender, age_days, still_live, mac, CM, MP, IUGR), ~ as.factor(.x)), across(c(gest), ~ as.numeric(.x)))

summary(Data_step2)
#добавляем колонку с годом

Data_step2 <- Data_step2 %>% add_column(year = "2005", .after = 23)
write_rds(Data_step2, "Data/Raw/D2005.rds")
read_rds("Data/Raw/D2005.rds")