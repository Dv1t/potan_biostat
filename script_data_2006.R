library(dplyr)
library(lubridate)
library(tidyr)
library(tibble)
library(gtsummary)
library(readxl)
library(stringr)
library(readr)


work_dat <-read_excel("Data/Raw/2006.xlsx", col_names = TRUE) %>%
  mutate(`пол` = ifelse(`пол`== "м","m", ifelse(`пол`== "ж","f",NA))) %>%
  filter(`пол` %in% c("m","f")) %>% #без пола
  filter (`№ протокола` != "НЕТ ПРОТОКОЛА") %>% #без протокола
  #mutate(`многоплодная` = replace_na(`многоплодная`, 'нет')) %>%
  #mutate(across(c(`пол`, `мёртвый/живой`, `мацерация`, `многоплодная`), ~ as.factor(.x)), across(c(`№ протокола`, `длина тела`, `масса тела`,`мозг`,`сердце`,`лёгкие`,`печень`,`селезёнка`,`почки`,`тимус`, `н/п`,`пжж`,`плацента`,`окружность головы`,`окружность груди` ), ~ as.numeric(.x))) %>% 
  filter (`мацерация` != "да" | is.na(`мацерация`)) %>% #мацерация
  filter (`многоплодная` != "да" | is.na(`многоплодная`)) %>% #многоплодная
  filter (`ВПР` == "нет" | is.na(`ВПР`)) %>% #врождённые пороки
  filter (is.na(`СЗРП`) | `СЗРП` == "нет") #СЗРП

work_dat <- work_dat %>%
  mutate(`гестация` =  str_split_fixed(`гестация`, '-',2)) %>% 
  rowwise() %>% 
  mutate(`гестация` =  as.numeric(`гестация`[1]))

work_dat <- work_dat %>%
  filter (`гестация` >= 14)#гестация < 14

#Убираем строки с возрастом из колонки "мёртвый/живой"
work_dat <- work_dat %>%
  mutate(`мёртвый/живой` = as.character(`мёртвый/живой`)) %>%
  mutate(`возраст` = ifelse(!(`мёртвый/живой` %in% c("мертв", "М")) & is.na(`мёртвый/живой`) == FALSE,`мёртвый/живой`,`возраст`))

#Работа с текстовым "возрастом"    
work_dat$возраст <- gsub("г", "лет", work_dat$возраст)
work_dat$возраст <- gsub("лет", "year", work_dat$возраст)
work_dat$возраст <- gsub("мес", "month", work_dat$возраст)
work_dat$возраст <- gsub("д", "day", work_dat$возраст)
work_dat$возраст <- gsub("суток", "day", work_dat$возраст)
work_dat$возраст <- gsub("часов", "hour", work_dat$возраст)
work_dat$возраст <- gsub("ч", "hour", work_dat$возраст)
work_dat$возраст <- gsub("мин", "minute", work_dat$возраст)
work_dat$возраст <- gsub("м", "month", work_dat$возраст)

work_dat <- work_dat %>% 
  mutate(Age = ifelse(!is.na(`возраст`), duration(`возраст`), 0))

#???`мёртвый/живой` == "мертв"
work_dat <- work_dat %>% 
  mutate(Возраст = strsplit(as.character(Age), 's')) %>%
  mutate(Возраст = sapply(Возраст, head, 1)) 
work_dat <- work_dat %>%  
  add_column(`Возраст (сут)` = as.numeric(work_dat$Возраст), .after = 4)
work_dat$`Возраст (сут)` <- round(work_dat$`Возраст (сут)`/86400,4)

#Наконец, фильтруем по возрасту
work_dat <- work_dat %>% 
  mutate(Age = NULL, Возраст = NULL, возраст = NULL) %>%
  filter(`Возраст (сут)`<= 1)

work_dat <- work_dat %>% 
  mutate(`мёртвый/живой` = ifelse(`Возраст (сут)` == 0, 0, 1))
work_dat$`мёртвый/живой` <- as.factor(work_dat$`мёртвый/живой`)

work_dat <- work_dat %>%
  rename(gender = "пол", still_live = "мёртвый/живой", age_days = "Возраст (сут)",	
         case = "№ протокола", gest = "гестация", LB	= "длина тела", 
         WB =	"масса тела", brain =	"мозг", heart = "сердце", 
         lung	= "лёгкие", liver	= "печень", spleen	= "селезёнка", 
         kidney =	"почки", thymus	= "тимус", adrenal = "н/п", 
         pancreas = "пжж", placenta =	"плацента", mac	= "мацерация",
         CM	= "ВПР", MP = "многоплодная", IUGR	= "СЗРП",
         HC = "окружность головы", CC	= "окружность груди")


#приводим значения gender к стандартному виду на англ.языке
work_dat <- work_dat %>% 
  mutate(gender = ifelse(gender == "м", "m", "f"))
work_dat$gender <- as.factor(work_dat$gender) #gender

work_dat <- work_dat %>% 
  mutate(CM = ifelse(CM == "нет", "no", "yes"))
work_dat$CM <- as.factor(work_dat$CM)

work_dat <- work_dat %>% 
  mutate(MP = ifelse(MP == "нет", "no", "yes"))
work_dat$MP <- as.factor(work_dat$MP)

#приводим значения CM,MP, IUGR, mac к стандартному виду на англ.языке
table (work_dat$mac, useNA = "always")
table (work_dat$CM, useNA = "always")
table (work_dat$IUGR, useNA = "always")
table (work_dat$MP, useNA = "always")

work_dat$mac [work_dat$mac == 'нет'] <- 'no'
work_dat$MP <- work_dat$MP %>% replace_na ("no")
work_dat$CM <- work_dat$CM %>% replace_na ("no")
work_dat$IUGR <- as.character(work_dat$IUGR)
work_dat$IUGR <- work_dat$IUGR %>% replace_na ("no")

#приводим данные к соответствующим типам

work_dat$brain <- as.numeric(work_dat$brain)
work_dat$heart <- as.numeric(work_dat$heart)
work_dat$lung <- as.numeric(work_dat$lung)
work_dat$liver <- as.numeric(work_dat$liver)
work_dat$spleen <- as.numeric(work_dat$spleen)
work_dat$kidney <- as.numeric(work_dat$kidney)
work_dat$thymus <- as.numeric(work_dat$thymus)
work_dat$adrenal <- as.numeric(work_dat$adrenal)
work_dat$pancreas <- as.numeric(work_dat$pancreas)
work_dat$placenta<- as.numeric(work_dat$placenta)
work_dat$HC<- as.numeric(work_dat$HC)
work_dat$CC<- as.numeric(work_dat$CC)


#округляем тип numeric до 2 знака
work_dat$brain <- round(work_dat$brain, 2)
work_dat$heart <- round(work_dat$heart, 2)
work_dat$lung <- round(work_dat$lung, 2)
work_dat$liver <- round(work_dat$liver, 2)
work_dat$spleen <- round(work_dat$spleen, 2)
work_dat$kidney <- round(work_dat$kidney, 2)
work_dat$thymus <- round(work_dat$thymus, 2)
work_dat$adrenal <- round(work_dat$adrenal, 2)
work_dat$pancreas <- round(work_dat$pancreas, 2)
work_dat$placenta <- round(work_dat$placenta, 2)
work_dat$HC <- round(work_dat$HC, 2)
work_dat$CC <- round(work_dat$CC, 2)

#приводим типы для остальных переменных

work_dat <-  work_dat %>%
  mutate(across(c(gender, still_live, mac, CM, MP, IUGR), ~ as.factor(.x)), across(c(case, age_days, gest, LB, WB), ~ as.numeric(.x))) 


#добавляем год
work_dat$year <- 2006

#age приводим к факторной со значениями 0 и 1
work_dat <- work_dat %>% 
  mutate(age_days = ifelse(age_days == 0, 0, 1))
work_dat$age_days <- as.factor (work_dat$age_days)

write_rds(work_dat, "Data/Processed/D2006.rds")

