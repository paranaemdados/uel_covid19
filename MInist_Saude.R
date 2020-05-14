#-------------------------------------------
# Código para gerar os dados do Brasil_Dia -
# com dados do Ministério da Saúde.        -
#-------------------------------------------
rm(list=ls())

require(data.table)
require(dplyr)

#--------------------------------
# Dados do Brasil.io            -
# Para ter o Georeferenciamento -
#--------------------------------
Brasil = read.csv('C:/Corona/Dados_Anteriores/21_04_2020/BRASIL_Dia.csv', encoding="UTF-8", na.strings=0)
Brasil[is.na(Brasil)] <- 0

Brasil = Brasil %>%
  select(state, city, estimated_population_2019, city_ibge_code, death_rate) %>%
  arrange(state)

#------------------------------------------------------------
# Dados do Ministério da Saúde: https://covid.saude.gov.br/ -
#------------------------------------------------------------
Brasil_MS = read.csv2('c:/Corona/Dados/MS/arquivo_geral.csv')
brasil_MS = Brasil_MS[c(1:2754), ]

#brasil_MS = Brasil_MS[c(2727:2755), ]

# brasil_MS = brasil_MS %>%
#  select(regiao, estado, data, casosNovos, casosAcumulados, obitosNovos, obitosAcumulados) %>%
#  filter(!casosAcumulados %in% 0, !obitosAcumulados %in% 0)

#----------------------------------------
# Criando o arquivo do BRASIL, por dia. -
#----------------------------------------
Ultima_Data = last(brasil_MS$data)

brasil = brasil_MS %>%
  select(regiao, state=estado, date=data, casosNovos, obitosNovos,
         confirmed=casosAcumulados, deaths=obitosAcumulados) %>%
  filter(date==Ultima_Data) %>%
  arrange(state, date)

brasil$date <- factor(brasil$date)
brasil$state <- factor(brasil$state)

# Criando o arquivo do BRASIL, por dia.
Brasil_Dia = merge(brasil, Brasil, by.x='state', by.y='state')
head(Brasil_Dia)
tail(Brasil_Dia)

# Salvando o Arquivo CSV
write.csv(Brasil_Dia, 'C:/Corona/Dados/MS/Brasil_Dia.csv')


#--------------------------------------------------
# Criando o arquivo do BRASIL para TODAS as DATAS -
#--------------------------------------------------
bra = brasil_MS %>%
  select(regiao, state=estado, date=data, casosNovos, obitosNovos,
         confirmed=casosAcumulados, deaths=obitosAcumulados) %>%
  arrange(state, date)

Brasil_ = read.csv('C:/Corona/Dados_Anteriores/21_04_2020/Brasil_Datas.csv', encoding="UTF-8", na.strings=0)
Brasil_D = Brasil_[25:51, c(2,8,9)]
Brasil_geo = Brasil_D %>%
  arrange(state)

Brasil_Datas = merge(bra, Brasil_geo)
Brasil_datas <- data.table(Brasil_Datas)
Brasil_datas = Brasil_datas[ , sum(confirmed), by=date]

Brasil_datas = Brasil_datas %>%
  filter(V1 != 0)

colnames(Brasil_datas)[2] <- 'confirmed'
Brasil_datas$date = lubridate::ymd(Brasil_datas$date)

Brasil_datas
  droplevels(Brasil_datas)$date

# Salvando o arquivo Brasil_Datas
write.csv(Brasil_Datas, 'c:/Corona/Dados/MS/Brasil_Datas.csv')


#---------------------------------
# Dados do Paraná - Paraná-Datas -
#---------------------------------
Parana = bra %>%
  filter(state=='PR' & !confirmed %in% 0) %>%
  mutate(city_ibge_code=41, estimated_population_2019=11433957)

Parana$date <- factor(Parana$date)
Parana$state <- factor(Parana$state)

Parana$date = lubridate::ymd(Parana$date)
droplevels(Parana)$date

write.csv(Parana, 'c:/Corona/Dados/MS/Parana_Datas.csv')
