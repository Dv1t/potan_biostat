library(dplyr)
library(lubridate)
library(tidyr)
library(tibble)
library(gtsummary)
library(readxl)
library(stringr)

work_dat2014 <-read_excel("Data/Raw/2014.xlsx", col_names = TRUE) %>%
  filter(`пол` %in% c("м","ж")) %>% #без пола
  filter (`№ протокола` != "НЕТ ПРОТОКОЛА") %>% #без протокола
  mutate(`многоплодная` = replace_na(`многоплодная`, 'нет')) %>%
  mutate(across(c(`пол`, `мёртвый/живой`, `мацерация`, `многоплодная`), ~ as.factor(.x)), across(c(`№ протокола`, `длина тела`, `масса тела`,`мозг`,`сердце`,`лёгкие`,`печень`,`селезёнка`,`почки`,`тимус`, `н/п`,`пжж`,`плацента`,`окружность головы`,`окружность груди` ), ~ as.numeric(.x))) %>% 
  filter (`мацерация` != "да") %>% #мацерация
  filter (`многоплодная` != "да") %>% #многоплодная
  filter (`ВПР` == "нет") %>% #врождённые пороки
  filter (is.na(`СЗРП`)) #СЗРП

work_dat2014 <- work_dat2014 %>%
  mutate(`гестация` =  str_split_fixed(`гестация`, '-',2)) %>% 
  rowwise() %>% 
  mutate(`гестация` =  as.numeric(`гестация`[1]))

work_dat2014 <- work_dat2014 %>%
  filter (`гестация` >= 14)#гестация < 14

#Убираем строки с возрастом из колонки "мёртвый/живой"
work_dat2014 <- work_dat2014 %>%
  mutate(`мёртвый/живой` = as.character(`мёртвый/живой`)) %>%
  mutate(`возраст` = ifelse(!(`мёртвый/живой` %in% c("мертв", "М")) & is.na(`мёртвый/живой`) == FALSE,`мёртвый/живой`,`возраст`)) %>% 
  mutate(`мёртвый/живой` = ifelse(`мёртвый/живой` %in% c("мертв", "М") , "мертв", NA)) %>%
  mutate(`мёртвый/живой` = as.factor(`мёртвый/живой`))

#Работа с текстовым "возрастом"    
work_dat2014$возраст <- gsub("г", "лет", work_dat2014$возраст)
work_dat2014$возраст <- gsub("лет", "year", work_dat2014$возраст)
work_dat2014$возраст <- gsub("мес", "month", work_dat2014$возраст)
work_dat2014$возраст <- gsub("д", "day", work_dat2014$возраст)
work_dat2014$возраст <- gsub("ч", "hour", work_dat2014$возраст)
work_dat2014$возраст <- gsub("мин", "minute", work_dat2014$возраст)
work_dat2014$возраст <- gsub("м", "month", work_dat2014$возраст)
work_dat2014$возраст <- gsub("сек", "seconds", work_dat2014$возраст)

work_dat2014 <- work_dat2014 %>% 
  mutate(Age = ifelse(is.na(`мёртвый/живой`), duration(`возраст`), 0))

work_dat2014 <- work_dat2014 %>% 
  mutate(Возраст = strsplit(as.character(Age), 's')) %>%
  mutate(Возраст = sapply(Возраст, head, 1)) 

work_dat2014 <- work_dat2014 %>%  
  add_column(`Возраст (сут)` = as.numeric(work_dat2014$Возраст), .after = 4)

work_dat2014$`Возраст (сут)` <- round(work_dat2014$`Возраст (сут)`/86400,4)

# фильтруем по возрасту
work_dat2014 <- work_dat2014 %>% 
  mutate(Age = NULL, Возраст = NULL) %>%
  filter(`Возраст (сут)`<= 1)

#names
colnames(work_dat2014)[1] = "case"
colnames(work_dat2014)[2] = "gender"
colnames(work_dat2014)[3] = "still_live"
colnames(work_dat2014)[4] = "age"
colnames(work_dat2014)[5] = "age_day"
colnames(work_dat2014)[6] = "gest"
colnames(work_dat2014)[7] = "LB"
colnames(work_dat2014)[8] = "WB"
colnames(work_dat2014)[9] = "brain"
colnames(work_dat2014)[10] = "heart"
colnames(work_dat2014)[11] = "lung"
colnames(work_dat2014)[12] = "liver"
colnames(work_dat2014)[13] = "spleen"
colnames(work_dat2014)[14] = "kidney"
colnames(work_dat2014)[15] = "thymus"
colnames(work_dat2014)[16] = "adrenal"
colnames(work_dat2014)[17] = "pancreas"
colnames(work_dat2014)[18] = "placenta"
colnames(work_dat2014)[19] = "mac"
colnames(work_dat2014)[20] = "CM"
colnames(work_dat2014)[21] = "MP"
colnames(work_dat2014)[22] = "IUGR"
colnames(work_dat2014)[23] = "HC"
colnames(work_dat2014)[24] = "CC"

write.csv2(work_dat2014,"Data/2014.csv")

saveRDS(work_dat2014, "work_dat2014.rds")