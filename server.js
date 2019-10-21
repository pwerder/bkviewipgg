const express = require('express');
const app = express();
const path = require('path');

const porta = 8080;

app.use(express.static('public'))

app.get('/', function(req, res) {
    res.sendFile(path.join(__dirname + 'public/'));
});

app.listen(porta);
console.log(`PORT ${porta}`)