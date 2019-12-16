#!/bin/bash


origem=$1
destino=$2


#Funcoes extrai ip e nome da pasta de origem fazem sentido
#porque a gente recebe a origem no formado
#//192.168.0.40/Docs_NSI por exemplo
function extraiIpENomeDaPastaOrigem(){
 	
	origemRevertida=$(rev <<< $origem);	
	
	IFS='/' #  (/) is set as delimiter

	read -ra ADDR <<< "$origemRevertida" # origemRevertida is read into an array as tokens separated by IFS
	ipDeOrigem=$(rev <<< ${ADDR[0]})
	pastaDeOrigem=$(rev <<< ${ADDR[1]})
	
	IFS=' ' # reset to default value after usage
}


function montaPastaPadraoDeDestidoDeTodosOsBackups(){
	mkdir -p "/home/$USER/BACKUPS/mnt150Backup_IPGG"
	mount -t cifs "//192.168.0.150/Backup_IPGG" "/home/$USER/BACKUPS/mnt150Backup_IPGG" -o username=admin,dom=STORAGEBACKUP,file_mode=0777,dir_mode=0777,vers=2.0
}


function montaPasta(){
	mkdir -p $1
      	mount -t cifs $origem $1 -o username=backup,dom=ipgg,file_mode=0777,dir_mode=0777,vers=2.0
}


# monta a pasta padrao de destino de todos backups
# as pastas especificas de destino cada backup devem ser criadas
# dentro dessa pasta padrao mnt150Backup_IPGG
montaPastaPadraoDeDestidoDeTodosOsBackups 

extraiIpENomeDaPastaOrigem
montaPasta "/home/$USER/BACKUPS/mnt$ipDeOrigem$pastaDeOrigem"



#rsync

echo $pastaDeOrigem


