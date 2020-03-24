# Sistema de Backup para o ipgg

# Logica de funcionamento do sistema
  Essa sessao por enquanto vai ser util para os desenvolvedores que sao o Paulo e o Levi
  O funcionamento do sistema é o seguinte...
  A gente monta a pasta de origem, o quer quer dizer que termos uma pasta local que é a pasta de origem montada
  A gente monta a pasta de destino que é a pasta do ip150, e aí a gente tem essa pasta de destino montada
  Lembrando que essa pasta de destino recebe todos os backups
  Obviamente os backups nao ficam tudo misturado na pasta de destino, claro. Qdo backapeamos a pasta Docs_NSI a gente cria uma pasta DOCS_NSI pra jogar  o backup dentro dela.
  Entao temos uma pasta de origem montada e uma pasta de destino montada com uma pasta criada dentro da pasta de destino especifcia para essa origem
  Entao a gente usa o rsync tirando pegando tudo que está na pasta de origem montada para a pasta especifica desta origem criada na pasta de destino
  Essa cópia entre as pastas montadas obviamente estarao indo para as respectivas pastas da rede, já que as pastas montadas sao apenas espelhos da pasta da rede

  Foi criado um trello público, por enquanto, pra organizar as tarefas a serem realizadas.
  https://trello.com/b/SBfVYPvP/bakcupipggbkviewipgg

  
  
  

  
