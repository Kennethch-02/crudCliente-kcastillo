const {  getConnection } = require("../../connections/SqlServerConnection");
const sql = require("mssql");

const querys = {
    InsertContact: "EXEC sp_Insert_ClientContact @ClientID, @ContactTypeID, @ContactValue",
    DeleteContact: "EXEC sp_Delete_ClientContact @ClientContactID"
}
module.exports = {
    insertContact: async function (req, res) {
        try {
            const { ClientID, ContactTypeID ,ContactValue } = req.body;
            const pool = await getConnection();
            const resultCreate = await pool
                .request()
                .input("ClientID", sql.Int, ClientID)
                .input("ContactTypeID", sql.Int, ContactTypeID)
                .input("ContactValue", sql.NVarChar, ContactValue)
                .query(querys.InsertContact);
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
    deleteContact: async function (req, res) {
        try {
            const { ClientContactID } = req.body;
            const pool = await getConnection();
            const resultCreate = await pool
                .request()
                .input("ClientContactID", sql.Int, ClientContactID)
                .query(querys.DeleteContact);
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