# Libraries ----
library(sidrar)
library(tidyverse)

# Get data para o setores da indústria de transformação ----

        ## Dados de salário 
        bkp_data_salario = get_sidra(api = "/t/1841/n1/all/v/all/p/all/C12762/all")
        data_salario = bkp_data_salario
        
        ## Dados de receitas
        bkp_data_receita = get_sidra(api = "/t/1845/n1/all/v/all/p/all/C12762/all")
        data_receita = bkp_data_receita
        
        ## Dados de custos e despesas
        bkp_data_custos_1 = get_sidra(api = "/t/1847/n1/all/v/all/p/2007,2008,2009,2010,2011,2012/C12762/all")
        bkp_data_custos_2 = get_sidra(api = "/t/1847/n1/all/v/all/p/2013,2014,2015,2016,2017,2018,2019/C12762/all")
        data_custos_1 = bkp_data_custos_1
        data_custos_2 = bkp_data_custos_2

# Get data IPCA ----
        
        ## Dados de IPCA
        data_ipca = get_sidra(api = "/t/1737/n1/all/v/2266/p/all")

# Ajustando base de inflação IPCA ----  
        
        ## Filtrando e calculando média para os números índices necessários para deflação das séries
        indicadores_ipca = data_ipca %>%
                filter(str_sub(`Mês (Código)`, start = 1, end = 4) > 2006) %>%
                group_by(str_sub(`Mês (Código)`, start = 1, end = 4)) %>%
                summarize(media_ano = mean(Valor, na.rm = T)) %>%
                as.data.frame()
                colnames(indicadores_ipca) = c("ano", "indice_ipca_medio")
                
        ## Definindo número índice para base de deflação
        INDICADOR_IPCA_BASE = indicadores_ipca[indicadores_ipca$ano == 2019, "indice_ipca_medio"]
        
# Remover dados referentes a "percentual do total geral" da bases ----
        
data_salario = data_salario[!str_detect(data_salario$Variável, "percentual do total geral"), ]
data_receita = data_receita[!str_detect(data_receita$Variável, "percentual do total geral"), ]
data_custos_1 = data_custos_1[!str_detect(data_custos_1$Variável, "percentual do total geral"), ]
data_custos_2 = data_custos_2[!str_detect(data_custos_2$Variável, "percentual do total geral"), ]


####################### EM CONSTRUÇÃO - DEFLACIONANDO SÉRIES #######################################

a = apply(data_salario[, c(4,5,11)], 1, function(x){
        
        if (x[1] == "Mil Reais") {
                
                as.numeric(x[2]) * INDICADOR_IPCA_BASE / indicadores_ipca[indicadores_ipca$ano == x[3], "indice_ipca_medio"] 
                
        } else {
                
                as.numeric(x[2])
                
        }        
        
})

a[sapply(a, is.null)] <- NA
a = unlist(a) %>% as.data.frame()



####################### EM CONSTRUÇÃO - DEFLACIONANDO SÉRIES #######################################
        
        
        
        
        
        
        
        
        
                
        