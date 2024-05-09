const {  getConnection } = require("../../connections/SqlServerConnection");
const sql = require("mssql");

const querys = {
    GetClientContactList: "EXEC sp_Get_ClientInfoAndContact @ClientID"
}
module.exports = {
    getClientInfoAndContact: async function (req, res) {
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