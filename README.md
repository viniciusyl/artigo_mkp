# Repositório do projeto Artigo Mark-up

Repositório com arquivos relacionados ao projeto Artigo Mark-up

## Lista de arquvios

  1. get_mkp_data.r --> script R que busca informações da Pesquisa Industrial Anual (PIA) do IBGE via API do sistema SIDRA, utilizando o pacote do R sidrar. As informações são referentes aos temas Receita, Custos diretos e Salários dos setores da indústria nacional;
  
  2. data_receita_ext.csv --> arquivo .csv com dados de receita por setores;
  
  3. data_custo_ext.csv --> arquivo .csv com dados dos custos diretos de proução por setores;
  
  4. data_salario_ext.csv --> arquivo .csv com dados dos dos salários ligadas à produção por setores;
  
  5. adj_mkp_data.r --> script R que busca informações geradas pelo get_mkp_data.r e calcula os valores para o mark-up por setores da CNAE 2.0. Contém o script que desenvolve as bases a serem consumidas pelo App. 
  
  6. data_mkp.csv --> arquivo .csv com dados de receitas, custos, salários e mark-up calculados por setor. Arquivo com dados principais do App.
