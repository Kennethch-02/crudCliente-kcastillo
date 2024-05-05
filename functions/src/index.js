const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const functions = require('firebase-functions');
const express = require('express');
const bodyParser = require('body-parser');

const app = express();
app.use(bodyParser.json());

const clientsRoute = require('./routes/clientsRoutes');

app.use('/client', clientsRoute);


exports.app = functions.https.onRequest(app);