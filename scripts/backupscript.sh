#!/bin/bash

#needs to
#install cifs-utils
#pass ssh public key to remote backup machine

# this script accetp a taskname
# it will search in ../tarefas-salvas/tarefas.txt for taskname line
# taskname line founded, use the line data to proceed with specific task
# the taks is a backup with rsync.
# in order to issue rsync this script mount windows shared folder de origem e o windows shared folder de destino
# so, runs rsync in the mounted origem to mounted de destino

nomeDaTarefa=$1
if [ "X$nomeDaTarefa" == "X" ];
then
    echo "[ERRO]Passe o nome da tarefa como primeiro parametro, veja arquivo tarefas.txt"
    exit 1
fi

nomeDaTarefaFounded=-1
basePathToMountOrigem=/home/wagner


# Esta funcao busca pela linha referente ao nome da tarefa recebida no parametro deste script
# apos sua execuca, caso hava um nome de tarefa igual ao nome de tarefa recebido como parametro
# esta funcao cria essas variaveis que sao os dados necessarios para execucao da tarefa
# lTaskNameSelected
# lTaskOrigem
# lTaskDestino
# lTaskVer
function getTaskLineByTaskName(){

    while read line; do
        IFS=';'
        read -ra l <<< $line;
        lTaskName=$(echo ${l[0]} | xargs) #trim l[0] string

        if [ "$nomeDaTarefa" = "$lTaskName" ];
        then
            nomeDaTarefaFounded="1"
            lTaskNameSelected=$(echo ${l[0]} | xargs)
            lTaskOrigem=$(echo ${l[1]} | xargs)
            lTaskDestino=$(echo ${l[2]} | xargs)
            lTaskVers=$(echo ${l[3]} | xargs)
        fi
        
    done < ../tarefas-salvas/tarefas.txt

    IFS=';'
}


#Funcoes extrai ip e nome da pasta de origem
#ela recebe como parametro algo como: //192.168.0.40/Docs_NSI
#que he o conteudo da variavel lTaskOrigem
#Apos sua execucao, obtem-se as variaveis
#ipDeOrigem que seria 192.168.0.40
#pastaDeOrigem que seria Docs_NSI
#isso nos interessa porque vamos querer montar a pasta de origem
#no servidor onde este script estiver rodando
#essa pasta montada devera ter o nome 192.168.0.40DocsNSI
#pra deixar bem claro a qual pasta compartilhada ela esta se referindo
function extraiIpENomeDaPastaOrigem(){
    origemRevertida=$(rev <<< $1);
    echo $origemRevertida
    IFS='/' #  (/) is set as delimiter

    read -ra ADDR <<< "$origemRevertida" # origemRevertida is read into an array as tokens separated by IFS
    ipDeOrigem=$(rev <<< ${ADDR[1]})
    pastaDeOrigem=$(rev <<< ${ADDR[0]})

    IFS=' ' # reset to default value after usage

    echo [extraiIpENomeDaPastaOrigem] ipDeOrigem $ipDeOrigem
    echo [extraiIpENomeDaPastaOrigem] pastaDeOrigem $pastaDeOrigem
}

#Todos os backups irao para pasta //192.168.0.150/Backup_IPGG
#Por isso a gente monta ela em /home/$USER/mnt/mnt150Backup_IPGG
#function montaPastaPadraoDeDestidoDeTodosOsBackupsmontaPastaPadraoDeDestidoDeTodosOsBackups(){
#    mkdir -p "/home/$USER/BACKUPS/mnt150Backup_IPGG"
#    mount -t cifs "//192.168.0.150/Backup_IPGG" "/home/$USER/mnt/mnt150Backup_IPGG" -o username=admin,dom=STORAGEBACKUP,file_mode=0777,dir_mode=0777,vers=2.0
#}

#Antes de fazer a copia da pasta de origem a agente precisa montar ela
#ess funcao faz isso, mas pra isso ela quer receber o path para montagem e o shared name da pasta  a ser montada
# montaPastaDeOrigem  //192.168.0.40/Docs_NSI /home/$USER/mnt/192.168.0.40DocsNSI
function montaPastaDeOrigem(){
    sharedNameDaPastaDeOrigem=$1 #algo do tipo //192.168.0.40/Docs_NSI
    pathDeMontagemParaOrigem=$2 #algo do tipo /home/$USER/mnt/192.168.0.40DocsNSI
    echo "sharedNameDaPastaDeOrigem=$sharedNameDaPastaDeOrigem"
    echo "pathDeMontagemParaOrigem=$pathDeMontagemParaOrigem"
    
    options="credentials=$mountCifsCredentialFile,file_mode=0777,dir_mode=0777,vers=$lTaskVers"    
    mkdir -p $pathDeMontagemParaOrigem
    echo [montaPastaDeOrigem] mount -t cifs $sharedNameDaPastaDeOrigem $pathDeMontagemParaOrigem -o $options
    echo "nicolas1" | sudo -S mount -t cifs $sharedNameDaPastaDeOrigem $pathDeMontagemParaOrigem -o $options
}




getTaskLineByTaskName
if [ $nomeDaTarefaFounded -ne "1" ] ; 
   then
       echo "??? Tarefa $nomeDaTarefa nao encontrada"
       exit 1
fi

mountCifsCredentialFile="$(pwd)/domainUserCredentials"
#testar se as variaveis foram criadas, caso contrario nao vale a pena continuar
# a execucao do script
# lTaskNameSelected
# lTaskOrigem
# lTaskDestino
# lTaskVer


# monta a pasta padrao de destino de todos backups
# as pastas especificas de destino cada backup devem ser criadas
# dentro dessa pasta padrao mnt150Backup_IPGG
#montaPastaPadraoDeDestidoDeTodosOsBackups 

extraiIpENomeDaPastaOrigem $lTaskOrigem # cria as vars  $ipDeOrigem e $pastaDeOrigem

montaPastaDeOrigem "//$ipDeOrigem/$pastaDeOrigem" "$basePathToMountOrigem/mnt/$pastaDeOrigem"



files=$(shopt -s nullglob dotglob; echo $basePathToMountOrigem/mnt/$pastaDeOrigem/*)
if (( ${#files} ))
then
    echo "contains files"
    echo rsync -va $basePathToMountOrigem/mnt/$pastaDeOrigem admin@192.168.0.150:/admin@192.168.0.150:/share/Backup_IPGG/
    rsync -ratlzv $basePathToMountOrigem/mnt/$pastaDeOrigem admin@192.168.0.150:/share/Backup_IPGG/
else 
  echo "empty (or does not exist or is a file)"
fi


