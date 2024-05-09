const express = require('express');
const router = express.Router();
const { GetAll } = require('../controllers/Rol.controller');

router.get('/get', GetAll)

module.exports = router;