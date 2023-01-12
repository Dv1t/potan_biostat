library(dplyr)
library(lubridate)
library(tidyr)
library(tibble)
library(gtsummary)
library(readxl)
library(stringr)

work_dat2013 <-read_excel("Data/Raw/2013.xlsx", col_names = TRUE) %>%
  filter(`пол` %in% c("м","ж")) %>% #без пола
  filter (`№ протокола` != "НЕТ ПРОТОКОЛА") %>% #без протокола
  mutate(`многоплодная` = replace_na(`многоплодная`, 'нет')) %>%
  mutate(across(c(`пол`, `мёртвый/живой`, `мацерация`, `многоплодная`), ~ as.factor(.x)), across(c(`№ протокола`, `длина тела`, `масса тела`,`мозг`,`сердце`,`лёгкие`,`печень`,`селезёнка`,`почки`,`тимус`, `н/п`,`пжж`,`плацента`,`окружность головы`,`окружность груди` ), ~ as.numeric(.x))) %>% 
  filter (`мацерация` != "да") %>% #мацерация
  filter (`многоплодная` != "да") %>% #многоплодная
  filter (`ВПР` == "нет") %>% #врождённые пороки
  filter (is.na(`СЗРП`)) #СЗРП

work_dat2013 <- work_dat2013 %>%
  mutate(`гестация` =  str_split_fixed(`гестация`, '-',2)) %>% 
  rowwise() %>% 
  mutate(`гестация` =  as.numeric(`гестация`[1]))

work_dat2013 <- work_dat2013 %>%
  filter (`гестация` >= 14)#гестация < 14

#Убираем строки с возрастом из колонки "мёртвый/живой"
work_dat2013 <- work_dat2013 %>%
  mutate(`мёртвый/живой` = as.character(`мёртвый/живой`)) %>%
  mutate(`возраст` = ifelse(!(`мёртвый/живой` %in% c("мертв", "М")) & is.na(`мёртвый/живой`) == FALSE,`мёртвый/живой`,`возраст`)) %>% 
  mutate(`мёртвый/живой` = ifelse(`мёртвый/живой` %in% c("мертв", "М") , "мертв", NA)) %>%
  mutate(`мёртвый/живой` = as.factor(`мёртвый/живой`))

#Работа с текстовым "возрастом"    
work_dat2013$возраст <- gsub("г", "лет", work_dat2013$возраст)
work_dat2013$возраст <- gsub("лет", "year", work_dat2013$возраст)
work_dat2013$возраст <- gsub("мес", "month", work_dat2013$возраст)
work_dat2013$возраст <- gsub("д", "day", work_dat2013$возраст)
work_dat2013$возраст <- gsub("ч", "hour", work_dat2013$возраст)
work_dat2013$возраст <- gsub("мин", "minute", work_dat2013$возраст)
work_dat2013$возраст <- gsub("м", "month", work_dat2013$возраст)
work_dat2013$возраст <- gsub("сек", "seconds", work_dat2013$возраст)

work_dat2013 <- work_dat2013 %>% 
  mutate(Age = ifelse(is.na(`мёртвый/живой`), duration(`возраст`), 0))

work_dat2013 <- work_dat2013 %>% 
  mutate(Возраст = strsplit(as.character(Age), 's')) %>%
  mutate(Возраст = sapply(Возраст, head, 1)) 

work_dat2013 <- work_dat2013 %>%  
  add_column(`Возраст (сут)` = as.numeric(work_dat2013$Возраст), .after = 4)

work_dat2013$`Возраст (сут)` <- round(work_dat2013$`Возраст (сут)`/86400,4)

# фильтруем по возрасту
work_dat2013 <- work_dat2013 %>% 
  mutate(Age = NULL, Возраст = NULL) %>%
  filter(`Возраст (сут)`<= 1)

#names
colnames(work_dat2013)[1] = "case"
colnames(work_dat2013)[2] = "gender"
colnames(work_dat2013)[3] = "still_live"
colnames(work_dat2013)[4] = "age"
colnames(work_dat2013)[5] = "age_day"
colnames(work_dat2013)[6] = "gest"
colnames(work_dat2013)[7] = "LB"
colnames(work_dat2013)[8] = "WB"
colnames(work_dat2013)[9] = "brain"
colnames(work_dat2013)[10] = "heart"
colnames(work_dat2013)[11] = "lung"
colnames(work_dat2013)[12] = "liver"
colnames(work_dat2013)[13] = "spleen"
colnames(work_dat2013)[14] = "kidney"
colnames(work_dat2013)[15] = "thymus"
colnames(work_dat2013)[16] = "adrenal"
colnames(work_dat2013)[17] = "pancreas"
colnames(work_dat2013)[18] = "placenta"
colnames(work_dat2013)[19] = "mac"
colnames(work_dat2013)[20] = "CM"
colnames(work_dat2013)[21] = "MP"
colnames(work_dat2013)[22] = "IUGR"
colnames(work_dat2013)[23] = "HC"
colnames(work_dat2013)[24] = "CC"


write.csv2(work_dat2013,"Data/2013.csv")