library(dplyr)
library(lubridate)
library(tidyr)
library(tibble)
library(gtsummary)
library(readxl)
library(stringr)

work_dat <-read_excel("Data/Raw/2008.xlsx", col_names = TRUE) %>%
  filter(`пол` %in% c("м","ж")) %>% #без пола
  filter (`№ протокола` != "НЕТ ПРОТОКОЛА") %>% #без протокола
  mutate(`многоплодная` = replace_na(`многоплодная`, 'нет')) %>%
  mutate(across(c(`пол`, `мёртвый/живой`, `мацерация`, `многоплодная`), ~ as.factor(.x)), across(c(`№ протокола`, `длина тела`, `масса тела`,`мозг`,`сердце`,`лёгкие`,`печень`,`селезёнка`,`почки`,`тимус`, `н/п`,`пжж`,`плацента`,`окружность головы`,`окружность груди` ), ~ as.numeric(.x))) %>% 
  filter (`мацерация` != "да") %>% #мацерация
  filter (`многоплодная` != "да") %>% #многоплодная
  filter (`ВПР` == "нет") %>% #врождённые пороки
  filter (is.na(`СЗРП`)) #СЗРП

work_dat <- work_dat %>%
  mutate(`гестация` =  str_split_fixed(`гестация`, '-',2)) %>% 
  rowwise() %>% 
  mutate(`гестация` =  as.numeric(`гестация`[1]))

work_dat <- work_dat %>%
  filter (`гестация` >= 14)#гестация < 14

#Убираем строки с возрастом из колонки "мёртвый/живой"
work_dat <- work_dat %>%
  mutate(`мёртвый/живой` = as.character(`мёртвый/живой`)) %>%
  mutate(`возраст` = ifelse(!(`мёртвый/живой` %in% c("мертв", "М")) & is.na(`мёртвый/живой`) == FALSE,`мёртвый/живой`,`возраст`)) %>% 
  mutate(`мёртвый/живой` = ifelse(`мёртвый/живой` %in% c("мертв", "М") , "мертв", NA)) %>%
  mutate(`мёртвый/живой` = as.factor(`мёртвый/живой`))

#Работа с текстовым "возрастом"    
work_dat$возраст <- gsub("г", "лет", work_dat$возраст)
work_dat$возраст <- gsub("лет", "year", work_dat$возраст)
work_dat$возраст <- gsub("мес", "month", work_dat$возраст)
work_dat$возраст <- gsub("д", "day", work_dat$возраст)
work_dat$возраст <- gsub("ч", "hour", work_dat$возраст)
work_dat$возраст <- gsub("мин", "minute", work_dat$возраст)
work_dat$возраст <- gsub("м", "month", work_dat$возраст)

work_dat <- work_dat %>% 
  mutate(Age = ifelse(is.na(`мёртвый/живой`), duration(`возраст`), 0))

#???`мёртвый/живой` == "мертв"
work_dat <- work_dat %>% 
  mutate(Возраст = strsplit(as.character(Age), 's')) %>%
  mutate(Возраст = sapply(Возраст, head, 1)) 
work_dat <- work_dat %>%  
  add_column(`Возраст (сут)` = as.numeric(work_dat$Возраст), .after = 4)
work_dat$`Возраст (сут)` <- round(work_dat$`Возраст (сут)`/86400,4)

#Наконец, фильтруем по возрасту
work_dat <- work_dat %>% 
  mutate(Age = NULL, Возраст = NULL) %>%
  filter(`Возраст (сут)`<= 1)


write.csv2(work_dat,"Data/Processed/2008.csv")

