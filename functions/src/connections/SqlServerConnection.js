const sql = require("mssql");
const configData = require("../config.js");
const { log } = require("firebase-functions/logger");

const dbSettingsDev = {
  port: configData.port,
  user: configData.dbUser,
  password: configData.dbPassword,
  server: configData.dbServer,
  database: configData.dbDatabase,
  options: {
    encrypt: true, // for azure
    trustServerCertificate: true, // change to true for local dev / self-signed certs
    debug : true
  },
};

const dbSettingsQA = {
  user: configData.dbUser,
  password: configData.dbPassword,
  server: configData.dbServer,
  database: configData.dbDatabase,
  options: {
    encrypt: true, // for azure
    trustServerCertificate: true, // change to true for local dev / self-signed certs
  },
};

const dbSettingsProd = {
  user: configData.dbUser,
  password: configData.dbPassword,
  server: configData.dbServer,
  database: configData.dbDatabase,
  options: {
    encrypt: true, // for azure
    trustServerCertificate: true, // change to true for local dev / self-signed certs
  },
};

const getConnection = async () => {
  try {
    console.log(dbSettingsDev);
    const pool = await sql.connect(dbSettingsDev);
    return pool;
  } catch (error) {
    throw error;
  }
};

module.exports = {
  dbSettingsDev,
  dbSettingsQA,
  dbSettingsProd,
  getConnection,
  sql,
};