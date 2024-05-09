const swaggerAutogen = require('swagger-autogen')();

const outputFile = './swagger_output.json';
const endpointsFiles = ['./src/index.js']; // Archivo principal de tu API

swaggerAutogen(outputFile, endpointsFiles);