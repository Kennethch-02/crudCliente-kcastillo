const functions = require('firebase-functions');
const express = require('express');
const bodyParser = require('body-parser');
const swaggerUi = require('swagger-ui-express');
const swaggerFile = require('../swagger_output.json');
const cors = require('cors');

const app = express();
app.use(bodyParser.json());

const clientsRoute = require('./routes/Client.routes');
const rolRoute = require('./routes/Rol.routes');
const contactRoute = require('./routes/Contact.routes');

app.use(cors());
app.use(express.json());

app.use('/client', clientsRoute);
app.use('/rol', rolRoute);
app.use('/contact', contactRoute);

app.use('/doc', swaggerUi.serve, swaggerUi.setup(swaggerFile));

exports.app = functions.https.onRequest(app);