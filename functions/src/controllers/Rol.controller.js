const {  getConnection } = require("../connections/SqlServerConnection");
const sql = require("mssql");

const querys = {
    GetAllRols :"EXEC sp_Get_AllRoles"

}
module.exports = {
    // Get All Clients
    GetAll: async function (req, res) {
        try {
            const pool = await getConnection();
            const resultCreate = await pool
                .request()
                .query(querys.GetAllRols);
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