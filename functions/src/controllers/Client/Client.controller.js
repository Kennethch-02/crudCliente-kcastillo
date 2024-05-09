const {  getConnection } = require("../../connections/SqlServerConnection");
const sql = require("mssql");

const querys = {
    Test : "SELECT 1 FROM spLogMessage",
    GetAllClient :"EXEC sp_Get_ClientList",
    NewClient :"EXEC sp_Insert_ClientInfo @FirstName, @LastName, @RolTypeID",
    UpdateClient :"EXEC sp_Update_ClientInfo @ClientID, @FirstName, @LastName, @RolTypeID",
    DeleteClient :"EXEC sp_Delete_ClientInfo @ClientID",
    GetClient: "EXEC sp_Get_ClientInfo @ClientID"
}
module.exports = {
    // Test Conectiion
    Test: async function (req, res) {
        try {
            const pool = await getConnection();
            const resultCreate = await pool
                .request()
                .query(querys.Test);
            res.json(resultCreate);
        } catch (error) {
            res.send(error.message);
        }
    },
    // Get All Clients
    GetAll: async function (req, res) {
        try {
            const pool = await getConnection();
            const resultCreate = await pool
                .request()
                .query(querys.GetAllClient);
            if(resultCreate.recordset[0].Data){
                resultCreate.recordset[0].Data = JSON.parse(resultCreate.recordset[0].Data);
            }
            res.status(resultCreate.recordset[0].Code);
            res.json(resultCreate.recordset[0]);
        } catch (error) {
            res.status(500);
            res.send(error.message);
        }
    },
    addClient: async function (req, res) {
        try {
            const { FirstName, LastName, RolType } = req.body;
            const pool = await getConnection();
            const resultCreate = await pool
                .request()
                .input("FirstName", sql.NVarChar, FirstName)
                .input("LastName", sql.NVarChar, LastName)
                .input("RolTypeID", sql.Int, RolType)
                .query(querys.NewClient);
            if(resultCreate.recordset[0].Data){
                resultCreate.recordset[0].Data = JSON.parse(resultCreate.recordset[0].Data);
            }
            res.status(resultCreate.recordset[0].Code);
            res.json(resultCreate.recordset[0]);
        } catch (error) {
            res.status(500);
            res.send(error.message);
        }
    },
    updateClient: async function (req, res) {
        try {
            const { ClientID ,FirstName, LastName, RolType } = req.body;
            const pool = await getConnection();
            const resultCreate = await pool
                .request()
                .input("ClientID", sql.Int, ClientID)
                .input("FirstName", sql.NVarChar, FirstName)
                .input("LastName", sql.NVarChar, LastName)
                .input("RolTypeID", sql.Int, RolType)
                .query(querys.UpdateClient);
            if(resultCreate.recordset[0].Data){
                resultCreate.recordset[0].Data = JSON.parse(resultCreate.recordset[0].Data);
            }
            res.status(resultCreate.recordset[0].Code);
            res.json(resultCreate.recordset[0]);
        } catch (error) {
            res.status(500);
            res.send(error.message);
        }
    },
    deleteClient: async function (req, res) {
        try {
            const { ClientID } = req.body;
            const pool = await getConnection();
            const resultCreate = await pool
                .request()
                .input("ClientID", sql.Int, ClientID)
                .query(querys.DeleteClient);
            if(resultCreate.recordset[0].Data){
                resultCreate.recordset[0].Data = JSON.parse(resultCreate.recordset[0].Data);
            }
            res.status(resultCreate.recordset[0].Code);
            res.json(resultCreate.recordset[0]);
        } catch (error) {
            res.status(500);
            res.send(error.message);
        }
    },
    getClient: async function (req, res) {
        try {
            const { ClientID } = req.body;
            const pool = await getConnection();
            const resultCreate = await pool
                .request()
                .input("ClientID", sql.Int, ClientID)
                .query(querys.GetClient);
            if(resultCreate.recordset[0].Data){
                resultCreate.recordset[0].Data = JSON.parse(resultCreate.recordset[0].Data);
            }
            res.status(resultCreate.recordset[0].Code);
            res.json(resultCreate.recordset[0]);
        } catch (error) {
            res.status(500);
            res.send(error.message);
        }
    },
    getClientContactList: async function (req, res) {
        try {
            const { ClientID } = req.body;
            const pool = await getConnection();
            const resultCreate = await pool
                .request()
                .input("ClientID", sql.Int, ClientID)
                .query(querys.GetClientContactList);
            if(resultCreate.recordset[0].Data){
                resultCreate.recordset[0].Data = JSON.parse(resultCreate.recordset[0].Data);
            }
            res.status(resultCreate.recordset[0].Code);
            res.json(resultCreate.recordset[0]);
        } catch (error) {
            res.status(500);
            res.send(error.message);
        }
    }

  };