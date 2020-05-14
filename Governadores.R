rm(list=ls())

require(readxl)
require(DT)

gov = read_excel('C:/Corona/Governadores/Governadores_2018.xlsx')

gov = gov %>%
  dplyr::arrange(UF)

gov$UF = as.factor(gov$UF)
dim(gov)

# Georeferenciamento do Brasil
Brasil_Dia = read.csv('c:/Corona/Dados/MS/BRASIL_Dia.csv',
                      encoding="UTF-8", na.strings=0)
Brasil_Dia[is.na(Brasil_Dia)] <- 0

dim(Brasil_Dia)

gover = merge(Brasil_Dia, gov, by.x='state', by.y='Sigla')
names(gover)

gover$Casos_Por_Milhão = format(round(gover$confirmed / gover$População_estimada * 1000000, 2), big.mark='.', decimal.mark=',')
gover$Obitos_Por_Milhão = format(round(gover$deaths / gover$População_estimada * 1000000, 2), big.mark='.', decimal.mark=',')
gover$População_estimada = format(gover$População_estimada, big.mark='.', decimal.mark=',')
gover$Densidade_Demog = format(round(gover$Densidade_Demog, 2), big.mark='.', decimal.mark=',')
gover$IDH = format(gover$IDH, big.mark='.', decimal.mark=',')


# Georeferenciamento do Brasil
BRA = readOGR('c:/Corona/Brasil/BR/BRUFE250GC_SIR.shp',
              encoding="UTF-8", stringsAsFactors=FALSE)

BRA@data$NM_ESTADO <- iconv(BRA@data$NM_ESTADO, from="UTF-8",
                            to="ISO-8859-1")

Estados = merge(BRA, gover, by.x="CD_GEOCUF", by.y="city_ibge_code",
                duplicateGeoms=FALSE)
Estados = Estados[order(Estados$CD_GEOCUF), ]

#----------------------------------------------
Resumo <- gover %>%
  arrange(-deaths) %>%
  select(Partido, UF, População_estimada, Casos_Por_Milhão, Obitos_Por_Milhão, Densidade_Demog, IDH)

Resumo[is.na(Resumo)] <- 0

datatable(data = Resumo,
          rownames = FALSE,
          colnames = c("Partidos", "Estados", "População Estimada", "Casos (por milhão de hab.)", "Óbitos (por milhão de hab.)", "Densidade Demográfica (hab/km^2)", "IDH"),
          options = list(
            columnDefs = list(
              list(className='dt-right', targets=1:6)),
            pageLength=nrow(Resumo)))
