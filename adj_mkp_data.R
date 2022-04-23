options(scipen = 999)

# Libraries ----
library(readr)
library(tidyverse)

# Get data ----
data_receita = readr::read_csv2("https://raw.githubusercontent.com/viniciusyl/artigo_mkp/main/data_receita_ext.csv")
data_custo = readr::read_csv2("https://raw.githubusercontent.com/viniciusyl/artigo_mkp/main/data_custo_ext.csv")
data_salario = readr::read_csv2("https://raw.githubusercontent.com/viniciusyl/artigo_mkp/main/data_salario_ext.csv")

# Criar valor mkp e associar a setor CNAE 2.0 ----

        # Criar link entre dataframes
        data_receita$link = str_c(data_receita$Ano, "_", data_receita$`Classificação Nacional de Atividades Econômicas (CNAE 2.0)`)
        data_custo$link = str_c(data_custo$Ano, "_", data_custo$`Classificação Nacional de Atividades Econômicas (CNAE 2.0)`)
        data_salario$link = str_c(data_salario$Ano, "_", data_salario$`Classificação Nacional de Atividades Econômicas (CNAE 2.0)`)

        # Criar data mkp         
        data_mkp = unique(data_receita[c("Ano", "Classificação Nacional de Atividades Econômicas (CNAE 2.0)")])
        data_mkp$link = str_c(data_mkp$Ano, "_", data_mkp$`Classificação Nacional de Atividades Econômicas (CNAE 2.0)`)
        
        # Unir informações
        data_mkp = left_join(data_mkp, data_receita[data_receita$Variável == "Receita líquida de vendas", c("Valor", "link")], by = "link")
        names(data_mkp)[4] = "Receita líquida de vendas"
        data_mkp = left_join(data_mkp, data_custo[data_custo$Variável == "Custo direto de produção - Total", c("Valor", "link")], by = "link")
        names(data_mkp)[5] = "Custo direto de produção - Total"
        data_mkp = left_join(data_mkp, data_salario[data_salario$Variável == "Salários, retiradas e outras remunerações de pessoal assalariado ligado à produção", c("Valor", "link")], by = "link")
        names(data_mkp)[6] = "Salários, retiradas e outras remunerações de pessoal assalariado ligado à produção"
        
        # Calcular mark-up
        data_mkp$mkp = data_mkp$`Receita líquida de vendas` / (data_mkp$`Custo direto de produção - Total` + data_mkp$`Salários, retiradas e outras remunerações de pessoal assalariado ligado à produção`)

# Identificar agrupamento de setores ----
data_mkp[str_detect(data_mkp$`Classificação Nacional de Atividades Econômicas (CNAE 2.0)`, "[0-9]+[0-9][[:space:]]"), ]



