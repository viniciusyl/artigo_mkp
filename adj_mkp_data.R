options(scipen = 999)

# Libraries ----
library(readr)
library(tidyverse)

# Get data ----
data_receita = readr::read_csv2("https://raw.githubusercontent.com/viniciusyl/artigo_mkp/main/data_receita_ext.csv?token=GHSAT0AAAAAABT24GZDZCZ2WLQAR74OFSDSYTD5XIQ")
data_custo = readr::read_csv2("https://raw.githubusercontent.com/viniciusyl/artigo_mkp/main/data_custo_ext.csv?token=GHSAT0AAAAAABT24GZCEXVUP2SEVUQ3RN4YYTD5WAQ")
data_salario = readr::read_csv2("https://raw.githubusercontent.com/viniciusyl/artigo_mkp/main/data_salario_ext.csv?token=GHSAT0AAAAAABT24GZCGP6KX4V6A4TZK56IYTD5WWA")

# Criar valor mkp e associar a setor CNAE 2.0
mkp = data_receita[data_receita$Variável == "Receita líquida de vendas", "Valor"] / (data_custo[data_custo$Variável == "Custo direto de produção - Total", "Valor"] + data_salario[data_salario$Variável == "Salários, retiradas e outras remunerações de pessoal assalariado ligado à produção", "Valor"])
data_mkp = cbind.data.frame(data_receita[data_receita$Variável == "Receita líquida de vendas", c("Ano", "Classificação Nacional de Atividades Econômicas (CNAE 2.0)")], mkp)

# Identificar agrupamento de setores 
data_mkp[str_detect(data_mkp$`Classificação Nacional de Atividades Econômicas (CNAE 2.0)`, "[0-9]+[0-9][[:space:]]"), ]



