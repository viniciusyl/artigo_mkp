options(scipen = 999)

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
        data_custos = rbind(data_custos_1, data_custos_2)
        rm(data_custos_1, data_custos_2)

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
        data_custos = data_custos[!str_detect(data_custos$Variável, "percentual do total geral"), ]
        
# Criar variável de custos diretos de produção na base de custos ----

        # Selecionar variáveis de custo direto
        variaveis_custo_direto = c("Consumo de matérias-primas, materiais auxiliares e componentes", "Custo das mercadorias adquiridas para revenda", "Compras de energia elétrica e consumo de combustíveis", "Consumo de peças, acessórios e pequenas ferramentas", "Serviços industriais prestados por terceiros e de manutenção", "Consumo de matérias-primas, materiais auxiliares e componentes (em valores de 2019)", "Custo das mercadorias adquiridas para revenda (em valores de 2019)", "Compras de energia elétrica e consumo de combustíveis (em valores de 2019)", "Consumo de peças, acessórios e pequenas ferramentas (em valores de 2019)", "Serviços industriais prestados por terceiros e de manutenção (em valores de 2019)")
        
        # Criar variável de total de custos diretos de produção
        data_custo_d= data_custos[data_custos$Variável %in% variaveis_custo_direto, ] %>%
                group_by(Ano, `Classificação Nacional de Atividades Econômicas (CNAE 2.0)`) %>%
                mutate(soma = sum(Valor, na.rm = T))
        
        data_custo_d = data_custo_d[str_detect(data_custo_d$Variável, "Consumo de matérias-primas, materiais auxiliares e componentes"), ]
        
        data_custo_d$Valor = data_custo_d$soma
        data_custo_d$soma = NULL
        data_custo_d$`Variável (Código)` = "AAA"
        data_custo_d$Variável = str_replace(data_custo_d$Variável, "Consumo de matérias-primas, materiais auxiliares e componentes", "Custo direto de produção - Total")
        data_custo_d[data_custo_d$Valor == 0, "Valor"] = NA
        
        # Unir variável total à base de custos
        data_custos = rbind(data_custos, data_custo_d)
        rm(data_custo_d)
        
# Adição de variáveis de valor com ajuste monetário para ano de 2019 ----
        
        # Criando lista de dataframes alvo
        ls_data = list(data_salario = data_salario, 
                       data_receita = data_receita,
                       data_custos = data_custos)
        
        # Processo de ajuste
        ls_data = lapply(ls_data, function(x){
                
                data_ajuste = x
                
                # Selecionar trecho da base necessária
                data_ajuste = data_ajuste[data_ajuste$`Unidade de Medida` == "Mil Reais", ]
                
                # Processo de normalização dos valores monetários
                valores_ajustados = apply(data_ajuste[, c("Valor", "Ano")], 1, function(y){
                        
                        round(as.numeric(y[1]) * INDICADOR_IPCA_BASE / indicadores_ipca[indicadores_ipca$ano == y[2], "indice_ipca_medio"], 0)
                        
                })
                valores_ajustados[sapply(valores_ajustados, is.null)] <- NA
                valores_ajustados = unlist(valores_ajustados) %>% as.vector()
                
                # Unir dados ajustados com base original
                data_ajuste$Valor = valores_ajustados
                data_ajuste$Variável = paste0(data_ajuste$Variável, " (em valores de 2019)")
                x = rbind(x, data_ajuste)
                
        })
        
        # Endereçar dataframes ajustados
        for (i in 1:length(ls_data)){
                
                assign(names(ls_data[i]), ls_data[[i]])        
                
        }

# Selecionar variáveis de interesse das bases de receita, custo e salários ----
        
        # Seleção base receita
        variaveis_receita = c("Número de empresas", "Receita líquida de vendas", "Receita líquida de vendas (em valores de 2019)")
        data_receita_ext = data_receita[data_receita$Variável %in% variaveis_receita, ]
        
        # Seleção base salário
        variaveis_salario = c("Salários, retiradas e outras remunerações de pessoal assalariado ligado à produção", "Salários, retiradas e outras remunerações de pessoal assalariado ligado à produção (em valores de 2019)")
        data_salario_ext = data_salario[data_salario$Variável %in% variaveis_salario, ]

        # Seleção base custos
        variaveis_custo = c("Consumo de matérias-primas, materiais auxiliares e componentes", "Custo das mercadorias adquiridas para revenda", "Compras de energia elétrica e consumo de combustíveis", "Consumo de peças, acessórios e pequenas ferramentas", "Serviços industriais prestados por terceiros e de manutenção", "Consumo de matérias-primas, materiais auxiliares e componentes (em valores de 2019)", "Custo das mercadorias adquiridas para revenda (em valores de 2019)", "Compras de energia elétrica e consumo de combustíveis (em valores de 2019)", "Consumo de peças, acessórios e pequenas ferramentas (em valores de 2019)", "Serviços industriais prestados por terceiros e de manutenção (em valores de 2019)", "Custo direto de produção - Total", "Custo direto de produção - Total (em valores de 2019)")
        data_custo_ext = data_custos[data_custos$Variável %in% variaveis_custo, ]

# Exportar arquivos
        
        write.csv2(data_receita_ext, "data_receita_ext.csv", row.names = F)
        write.csv2(data_salario_ext, "data_salario_ext.csv", row.names = F)
        write.csv2(data_custo_ext, "data_custo_ext.csv", row.names = F)
        
        

        