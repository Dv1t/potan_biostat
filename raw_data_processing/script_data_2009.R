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

Data <- read_xlsx ("Data/Raw/2009.xlsx")

summary(Data)
Data %>% as.tibble()

#Замена названий переменных на соответствующие названия на английском

Data_en <- Data %>% rename(gender = "пол", still_live = "мёртвый/живой", age_days = "возраст",
case = "№ протокола", gest = "гестация", LB	= "длина тела", WB =	"масса тела", brain =	"мозг", heart = "сердце", lung	= "лёгкие", liver	= "печень", spleen	= "селезенка", kidney =	"почки", thymus	= "тимус", adrenal = "н/п", pancreas = "пжж", placenta =	"плацента", mac	= "мацерация", CM	= "ВПР", MP = "многоплодная", IUGR	= "СЗРП", HC = "окружность головы", CC	= "окружность груди")
View (Data_en)
summary(Data_en)
Data_en %>% as.tibble()

table(Data_en$gender, useNA = "always") # есть 5NA
table(Data_en$case, useNA = "always")
sum (is.na(Data_en$case))
summary (Data_en$case, useNA = "always")


# отбираем наблюдения с указанным полом "м" или "ж"  (-5 наблюдений)

Data_step1 <- Data_en %>%
   filter(!is.na(case)) %>%
  filter(gender %in% c("m","f")) %>%
  filter(as.numeric(age_days) <= (1)) # удаляем наблюдения со значением переменной > 1
#на данном этапе остается 831 наблюдений

# Фильтрация по переменным "gest", "mac", "CM", "MP", IUGR
table(Data_step1$gest, useNA = "always") # 1 наблюдение <14 недель
table(Data_step1$mac, useNA = "always") #556 наблюдений без мацерации
table(Data_step1$CM, useNA = "always") # из оставшихся токлько 397 без CM (NA и нет)
table(Data_step1$IUGR, useNA = "always") # из них 394 без IUGR
table(Data_step1$MP, useNA = "always") # 357 одноплодных

Data_step2 <- Data_step1 %>%
  filter(!is.na(gest) & as.numeric(gest)>=14) %>% # фильтрация по неделям гестации
  filter(mac == "нет") %>%
  filter(is.na(CM) | CM == "нет") %>%
  filter(is.na(IUGR)) %>%
  filter(MP == "нет") # 357 одноплодных

#фильтруем по значению веса, удаляем более 5000 г,
summary(Data_step2$WB)
Data_step2$WB > 5000
Data_step2$WB <- as.numeric(Data_step2$WB)
Data_step2 <- Data_step2 %>%
filter (WB <= 5000)
summary(Data_step2$WB) # 356
#приводим still_live к бинарному виду (мертворожденный-0, живорожденный -1
Data_step2 <- Data_step2 %>%
   mutate(still_live = ifelse(age_days == 0, "still", "live"))
Data_step2$still_live <- as.factor(Data_step2$still_live)

table (Data_step2$still_live,  useNA = "always")
table (Data_step2$mac,  useNA = "always")
table (Data_step2$CM,  useNA = "always")
table (Data_step2$MP,  useNA = "always")
table (Data_step2$IUGR,  useNA = "always")

Data_step2$mac [Data_step2$mac == 'нет'] <- 'no'

Data_step2$CM <- Data_step2$CM %>% replace_na ("no")
Data_step2$CM [Data_step2$CM == 'нет'] <- 'no'
Data_step2$MP [Data_step2$MP == 'нет'] <- 'no'
Data_step2$IUGR <- Data_step2$IUGR %>% replace_na ("no")

#приводим данные к соответствующим типам

Data_step2 %>% as.tibble()

Data_step2$brain <- as.numeric(Data_step2$brain)
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


#округляем тип numeric до 2 знака
Data_step2$brain <- round(Data_step2$brain, 2)
Data_step2$heart <- round(Data_step2$heart, 2)
Data_step2$lung <- round(Data_step2$lung, 2) #NA introduced
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
 mutate(across(c(gender, age_days, still_live, mac, CM, MP, IUGR), ~ as.factor(.x)), across(c(case), ~ as.numeric(.x)))

#добавляем колонку с годом
Data_step2 <- Data_step2 %>% add_column(year = "2009", .after = 23)

write_rds(Data_step2, "Data/Raw/D2009.rds")
write_csv(Data_step2, "Data/Raw/Data_clean_2009.csv")

