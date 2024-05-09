const express = require('express');
const router = express.Router();
const { Test, GetAll, addClient, updateClient, deleteClient, getClient } = require('../controllers/Client/Client.controller');
const { insertContact, deleteContact } = require('../controllers/Client/Client.Contact.controller');
const { getClientInfoAndContact } = require('../controllers/Client/Client.Data.controller');
router.get('/', (req, res) => {
  res.send('Sin ruta definida');
});

router.get('/test', Test); // Prueba de conexión a la base de datos
router.get('/getAll', GetAll)
router.post('/get', getClient)
router.post('/add', addClient)
router.put('/update', updateClient)
router.delete('/delete', deleteClient)
//Contact
router.post('/contact/add', insertContact)
router.delete('/contact/delete', deleteContact)
//Data
router.post('/data/get', getClientInfoAndContact)

module.exports = router;