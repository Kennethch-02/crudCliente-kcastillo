const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
  res.send('Obtener todos los clientes');
});

module.exports = router;