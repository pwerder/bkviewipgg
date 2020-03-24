const fs = require('fs');

let nomeArquivo = document.getElementById('nome');
let origemArquivo = document.getElementById('origem');
let destinoArquivo = document.getElementById('destino');
let buttonArquivo = document.querySelector('button');


let nome =  nomeArquivo.value;
let origem = origemArquivo.value;
let destino = destinoArquivo.value;

buttonArquivo.onclick = function() {

    fs.appendFile('teste.txt', `${nome} ; ${origem} ; ${destino} ; 2.0\r\n`, function (err) {
        if (err) throw err;
        console.log('Saved!');
    });

}