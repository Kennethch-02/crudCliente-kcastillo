DROP TABLE IF EXISTS client_contact
DROP TABLE IF EXISTS client_info
DROP TABLE IF EXISTS rol_type
DROP TABLE IF EXISTS contact_type
DROP TABLE IF EXISTS log_spUse
DROP TABLE IF EXISTS spLogMessage
DROP TABLE IF EXISTS spLogMessage
DROP VIEW IF EXISTS vw_client_contact
DROP VIEW IF EXISTS vw_client_info
DROP VIEW IF EXISTS vw_client_info_contact
DROP VIEW IF EXISTS vw_spLogMessage
GO
CREATE TABLE rol_type(
    ID INT PRIMARY KEY IDENTITY(1,1),
    Type NVARCHAR(100) NOT NULL,
    InsertDate DATETIME NOT NULL DEFAULT GETDATE(),
    UpdateDate DATETIME NOT NULL DEFAULT GETDATE(),
    IsActive BIT NOT NULL DEFAULT 1
)
GO
CREATE TABLE client_info(
    ID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    RolTypeID INT NOT NULL FOREIGN KEY REFERENCES rol_type(ID) ,
    InsertDate DATETIME NOT NULL DEFAULT GETDATE(),
    UpdateDate DATETIME NOT NULL DEFAULT GETDATE(),
    IsActive BIT NOT NULL DEFAULT 1
)
GO
CREATE TABLE contact_type(
    ID INT PRIMARY KEY IDENTITY(1,1),
    Type NVARCHAR(100) NOT NULL,
    Regex NVARCHAR(100) NOT NULL,
    InsertDate DATETIME NOT NULL DEFAULT GETDATE(),
    UpdateDate DATETIME NOT NULL DEFAULT GETDATE(),
    IsActive BIT NOT NULL DEFAULT 1
)
GO
CREATE TABLE client_contact(
    ID INT PRIMARY KEY IDENTITY(1,1),
    ClientID INT NOT NULL FOREIGN KEY REFERENCES client_info(ID),
    ContactTypeID INT NOT NULL FOREIGN KEY REFERENCES contact_type(ID),
    ContactValue NVARCHAR(100) NOT NULL,
    InsertDate DATETIME NOT NULL DEFAULT GETDATE(),
    UpdateDate DATETIME NOT NULL DEFAULT GETDATE(),
    IsActive BIT NOT NULL DEFAULT 1
)
GO
CREATE TABLE spLogMessage(
    ID INT PRIMARY KEY IDENTITY(1,1),
    Message NVARCHAR(2000),
    Code INT,
    InternalCode VARCHAR(10),
    IsActive BIT NOT NULL DEFAULT 1
)
GO
CREATE TABLE log_spUse(
    ID INT PRIMARY KEY IDENTITY(1,1),
    SpName NVARCHAR(100),
    Parameters NVARCHAR(2000),
    Detail NVARCHAR(2000),
    SpUseDate DATETIME NOT NULL DEFAULT GETDATE()
)
GO
CREATE VIEW vw_client_contact AS
SELECT cc.ID [ClientContactID], ci.FirstName, ci.LastName, ct.Type, cc.ContactValue
FROM client_contact cc
JOIN client_info ci ON cc.ClientID = ci.ID
JOIN contact_type ct ON cc.ContactTypeID = ct.ID
WHERE cc.IsActive = 1
GO
CREATE VIEW vw_client_info AS
SELECT ci.ID [ClientID], ci.FirstName, ci.LastName, rt.Type [RolType]
FROM client_info ci
JOIN rol_type rt ON ci.RolTypeID = rt.ID
WHERE ci.IsActive = 1
GO
CREATE VIEW vw_client_info_contact AS
SELECT ci.ID [ClientID], ci.FirstName, ci.LastName, rt.Type [RolType], ct.Type [ContactType], cc.ContactValue
FROM client_info ci
JOIN rol_type rt ON ci.RolTypeID = rt.ID
JOIN client_contact cc ON ci.ID = cc.ClientID
JOIN contact_type ct ON cc.ContactTypeID = ct.ID
WHERE ci.IsActive = 1 AND cc.IsActive = 1
GO
CREATE VIEW vw_spLogMessage AS
SELECT Message, Code, InternalCode
FROM spLogMessage
WHERE IsActive = 1
GO
INSERT INTO rol_type(Type) VALUES('Admin'), ('Manager'), ('Guest')
GO
INSERT INTO contact_type(Type, Regex) VALUES('Email', '%@%.%'), ('Phone', '[0-9]%'), ('Address', '%')
GO
INSERT INTO client_info(FirstName, LastName, RolTypeID) VALUES('Kenneth', 'Castillo', 1), ('Jane', 'Doe', 2), ('John', 'Doe', 3)
GO
INSERT INTO client_contact(ClientID, ContactTypeID, ContactValue) VALUES(1, 1, 'kenneth@gmail.com'), (1, 2, '123456789'), (1, 3, '1234 Main St')
INSERT INTO client_contact(ClientID, ContactTypeID, ContactValue) VALUES(2, 1, 'Jane@gmail.com'), (2, 2, '987654321'), (2, 3, '1234 Main St')
INSERT INTO client_contact(ClientID, ContactTypeID, ContactValue) VALUES(3, 1, 'John@gmail.com')

GO

INSERT INTO spLogMessage(Message, Code, InternalCode) 
VALUES('Success: Client Data Inserted', 200, 'SCI200'), 
('Success: Client Found', 200, 'SF200'), 
('Success: Client Updated', 200, 'SU200'), 
('Success: Client Deleted', 200, 'SD200'), 
('Success: All Clients Obtained', 200, 'AC200'), 
('Error: Clients Not Obtained', 500, 'AC500'),
('Error: Client Not Inserted', 500, 'EC500'), 
('Error: Client Not Found', 404, 'EC404'),
('Error: Client Not Updated', 500, 'EU500'),
('Error: Client Not Deleted', 500, 'ED500'),
('Success: All Contact Type Obtained', 200, 'CT200'),
('Error: Contact Type Not Obtained', 500, 'CT500'),
('Success: All Roll Type Obtained', 200, 'RT200'),
('Error: Roll Type Not Obtained', 500, 'RT500'),
('Error: Contact Value Not Valid', 500, 'CV500')


GO
CREATE OR ALTER PROCEDURE sp_Insert_ClientInfo -- sp_Insert_ClientInfo 'Alonso', 'Castillo', 1
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @RolTypeID INT
AS
BEGIN
    SET NOCOUNT ON
    INSERT INTO log_spUse (SpName, Parameters)
    VALUES('sp_Insert_ClientInfo', CONCAT('@FirstName = ',@FirstName,', @LastName = ',@LastName,', @RolTypeID = ',@RolTypeID))

    BEGIN TRANSACTION
    BEGIN TRY

        INSERT INTO client_info(FirstName, LastName, RolTypeID)
        VALUES(@FirstName, @LastName, @RolTypeID)

        DECLARE @ClientID INT = SCOPE_IDENTITY()
        DECLARE @Data NVARCHAR(MAX) = (SELECT * FROM client_info WHERE ID = @ClientID FOR JSON AUTO)

        SELECT *, @Data [Data]
        FROM vw_spLogMessage
        WHERE InternalCode = 'SCI200'
        
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION

        INSERT INTO log_spUse (SpName, Parameters, Detail)
        VALUES('sp_Insert_ClientInfo', CONCAT('@FirstName = ' , @FirstName , ', @LastName = ' , @LastName , ', @RolTypeID = ' , @RolTypeID), ERROR_MESSAGE())

        SELECT *, NULL [Data], ERROR_MESSAGE() [Detail]
        FROM vw_spLogMessage
        WHERE InternalCode = 'EC500'

    END CATCH
END
GO
CREATE OR ALTER PROCEDURE sp_Insert_ClientContact -- sp_Insert_ClientContact 4, 3, 'Cartago La Basilica'
    @ClientID INT,
    @ContactTypeID INT,
    @ContactValue NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON
    INSERT INTO log_spUse (SpName, Parameters)
    VALUES('sp_Insert_ClientContact', CONCAT('@ClientID = ' , @ClientID , ', @ContactTypeID = ' , @ContactTypeID , ', @ContactValue = ', @ContactValue))

    BEGIN TRANSACTION
    BEGIN TRY
        IF @ContactTypeID IN (SELECT ID FROM contact_type WHERE IsActive = 1)
        BEGIN
            -- Validate the contact value with the regex
            DECLARE @Regex NVARCHAR(100) = (SELECT Regex FROM contact_type WHERE ID = @ContactTypeID)
            IF @ContactValue NOT LIKE @Regex
            BEGIN
                RAISERROR ('Contact Value Not Valid', 16, 1)
            END
        END
        ELSE
        BEGIN
            RAISERROR ('Contact Type Not Found', 16, 1)
        END

        INSERT INTO client_contact(ClientID, ContactTypeID, ContactValue)
        VALUES(@ClientID, @ContactTypeID, @ContactValue)

        DECLARE @Data NVARCHAR(MAX) = (SELECT * FROM client_contact WHERE ID = SCOPE_IDENTITY() FOR JSON AUTO)

        SELECT *, @Data [Data]
        FROM spLogMessage
        WHERE InternalCode = 'SCI200'
        AND IsActive = 1

        COMMIT TRANSACTION
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION

        INSERT INTO log_spUse (SpName, Parameters, Detail)
        VALUES('sp_Insert_ClientContact', CONCAT('@ClientID = ' , @ClientID , ', @ContactTypeID = ' , @ContactTypeID , ', @ContactValue = ' , @ContactValue), ERROR_MESSAGE())

        SELECT *, NULL [Data], ERROR_MESSAGE() [Detail]
        FROM vw_spLogMessage
        WHERE InternalCode = 'EC500'
        

    END CATCH
END
GO
CREATE OR ALTER PROCEDURE sp_Update_ClientInfo -- sp_Update_ClientInfo 4, 'Alonso', 'Castillo', 3
    @ClientID INT,
    @FirstName NVARCHAR(100) = NULL,
    @LastName NVARCHAR(100) = NULL,
    @RolTypeID INT = NULL
AS
BEGIN
    SET NOCOUNT ON

    INSERT INTO log_spUse (SpName, Parameters)
    VALUES('sp_Update_ClientInfo', CONCAT('@ClientID = ' , @ClientID , ', @FirstName = ' , @FirstName , ', @LastName = ' , @LastName , ', @RolTypeID = ', @RolTypeID))
        
    BEGIN TRANSACTION
    BEGIN TRY
        IF @ClientID NOT IN (SELECT ID FROM client_info WHERE IsActive = 1)
        BEGIN
            RAISERROR ('Client Not Found', 16, 1)
        END

        IF @RolTypeID IS NOT NULL AND @RolTypeID NOT IN (SELECT ID FROM rol_type WHERE IsActive = 1)
        BEGIN
            RAISERROR ('Rol Type Not Found', 16, 1)
        END

        UPDATE client_info
        SET FirstName = ISNULL(@FirstName, FirstName),
            LastName = ISNULL(@LastName, LastName),
            RolTypeID = ISNULL(@RolTypeID, RolTypeID),
            UpdateDate = GETDATE()
        WHERE ID = @ClientID

        DECLARE @Data NVARCHAR(MAX) = (SELECT * FROM client_info WHERE ID = @ClientID FOR JSON AUTO)

        SELECT *, @Data [Data]
        FROM vw_spLogMessage
        WHERE InternalCode = 'SU200' 
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION

        INSERT INTO log_spUse (SpName, Parameters, Detail)
        VALUES('sp_Update_ClientInfo', CONCAT('@ClientID = ' , @ClientID , ', @FirstName = ' , @FirstName , ', @LastName = ' , @LastName , ', @RolTypeID = ' , @RolTypeID), ERROR_MESSAGE())

        SELECT *, NULL [Data], ERROR_MESSAGE() [Detail]
        FROM vw_spLogMessage
        WHERE InternalCode = 'EU500'

    END CATCH
END
GO
CREATE OR ALTER PROCEDURE sp_Update_ClientContact -- sp_Update_ClientContact 4, 3, 'Cartago La Basilica 2'
    @ClientContactID INT,
    @ContactTypeID INT = NULL,
    @ContactValue NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON
    INSERT INTO log_spUse (SpName, Parameters)
    VALUES('sp_Update_ClientContact', CONCAT('@ClientContactID = ' , @ClientContactID , ', @ContactTypeID = ' , @ContactTypeID , ', @ContactValue = ', @ContactValue))
        
    BEGIN TRANSACTION
    BEGIN TRY
        IF @ClientContactID NOT IN (SELECT ID FROM client_contact WHERE IsActive = 1)
        BEGIN
            RAISERROR ('Client Contact Not Found', 16, 1)
        END

        IF @ContactTypeID IS NOT NULL AND @ContactTypeID NOT IN (SELECT ID FROM contact_type WHERE IsActive = 1)
        BEGIN
            RAISERROR ('Contact Type Not Found', 16, 1)
        END

        IF @ContactValue IS NOT NULL
        BEGIN
            -- Validate the contact value with the regex
            DECLARE @Regex NVARCHAR(100) = (SELECT Regex FROM contact_type WHERE ID = @ContactTypeID)
            IF @ContactValue NOT LIKE @Regex
            BEGIN
                RAISERROR ('Contact Value Not Valid', 16, 1)
            END
        END

        UPDATE client_contact
        SET ContactTypeID = ISNULL(@ContactTypeID, ContactTypeID),
            ContactValue = ISNULL(@ContactValue, ContactValue),
            UpdateDate = GETDATE()
        WHERE ID = @ClientContactID

        DECLARE @Data NVARCHAR(MAX) = (SELECT * FROM client_contact WHERE ID = @ClientContactID FOR JSON AUTO)

        SELECT *, @Data [Data]
        FROM vw_spLogMessage
        WHERE InternalCode = 'SU200'

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION

        INSERT INTO log_spUse (SpName, Parameters, Detail)
        VALUES('sp_Update_ClientContact',CONCAT('@ClientContactID = ' , @ClientContactID , ', @ContactTypeID = ' , @ContactTypeID , ', @ContactValue = ' , @ContactValue), ERROR_MESSAGE())

        SELECT *, NULL [Data], ERROR_MESSAGE() [Detail]
        FROM vw_spLogMessage
        WHERE InternalCode = 'EU500'

    END CATCH
END
GO
CREATE OR ALTER PROCEDURE sp_Delete_ClientInfo -- sp_Delete_ClientInfo 4
    @ClientID INT
AS
BEGIN
    SET NOCOUNT ON
    INSERT INTO log_spUse (SpName, Parameters)
    VALUES('sp_Delete_ClientInfo', CONCAT('@ClientID = ' , @ClientID))

    BEGIN TRANSACTION
    BEGIN TRY
        IF @ClientID NOT IN (SELECT ID FROM client_info WHERE IsActive = 1)
        BEGIN
            RAISERROR ('Client Not Found', 16, 1)
        END

        UPDATE client_info
        SET IsActive = 0, 
            UpdateDate = GETDATE()
        WHERE ID = @ClientID

        DECLARE @Data NVARCHAR(MAX) = (SELECT * FROM client_info WHERE ID = @ClientID FOR JSON AUTO)

        SELECT *, @Data [Data]
        FROM vw_spLogMessage
        WHERE InternalCode = 'SD200'
        
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION

        INSERT INTO log_spUse (SpName, Parameters, Detail)
        VALUES('sp_Delete_ClientInfo', CONCAT('@ClientID = ' , @ClientID), ERROR_MESSAGE())

        SELECT *, NULL [Data], ERROR_MESSAGE() [Detail]
        FROM vw_spLogMessage
        WHERE InternalCode = 'ED500'

    END CATCH
END
GO
CREATE OR ALTER PROCEDURE sp_Delete_ClientContact -- sp_Delete_ClientContact 4
    @ClientContactID INT
AS
BEGIN
    SET NOCOUNT ON

    INSERT INTO log_spUse (SpName, Parameters)
    VALUES('sp_Delete_ClientContact', CONCAT('@ClientContactID = ' , @ClientContactID))

    BEGIN TRANSACTION
    BEGIN TRY
        IF NOT EXISTS (SELECT ID FROM client_contact WHERE IsActive = 1 AND ID = @ClientContactID)
        BEGIN
            RAISERROR ('Client Contact Not Found', 16, 1)
        END

        UPDATE client_contact
        SET IsActive = 0,
            UpdateDate = GETDATE()
        WHERE ID = @ClientContactID

        DECLARE @Data NVARCHAR(MAX) = (SELECT * FROM client_contact WHERE ID = @ClientContactID FOR JSON AUTO)

        SELECT *, @Data [Data]
        FROM vw_spLogMessage
        WHERE InternalCode = 'SD200'
        
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION

        INSERT INTO log_spUse (SpName, Parameters, Detail)
        VALUES('sp_Delete_ClientContact', CONCAT('@ClientContactID = ' , @ClientContactID), ERROR_MESSAGE())

        SELECT *, NULL [Data], ERROR_MESSAGE() [Detail]
        FROM vw_spLogMessage
        WHERE InternalCode = 'ED500'

    END CATCH
END
GO
CREATE OR ALTER PROCEDURE sp_Get_ClientInfo -- sp_Get_ClientInfo 2
    @ClientID INT
AS
BEGIN
    SET NOCOUNT ON
    INSERT INTO log_spUse (SpName, Parameters)
    VALUES('sp_Get_ClientInfo', CONCAT('@ClientID = ' , @ClientID))

    BEGIN TRANSACTION
    BEGIN TRY
        IF NOT EXISTS (SELECT ID FROM client_info WHERE IsActive = 1 AND ID = @ClientID)
        BEGIN
            RAISERROR ('Client Not Found', 16, 1)
        END

        DECLARE @Data NVARCHAR(MAX) = (
            SELECT client_info.Id, client_info.FirstName, client_info.LastName, client_info.UpdateDate
            FROM client_info
            WHERE ID = @ClientID
            AND IsActive = 1
            FOR JSON AUTO
 
        )

        SELECT *, @Data [Data]
        FROM vw_spLogMessage
        WHERE InternalCode = 'SF200'

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION

        INSERT INTO log_spUse (SpName, Parameters, Detail)
        VALUES('sp_Get_ClientInfo', CONCAT('@ClientID = ' , @ClientID), ERROR_MESSAGE())

        SELECT *, NULL [Data], ERROR_MESSAGE() [Detail]
        FROM vw_spLogMessage
        WHERE InternalCode = 'EC404'

    END CATCH
END
GO
CREATE OR ALTER PROCEDURE sp_Get_ClientContact -- sp_Get_ClientContact 4
    @ClientContactID INT
AS
BEGIN
    SET NOCOUNT ON
    INSERT INTO log_spUse (SpName, Parameters)
    VALUES('sp_Get_ClientContact', CONCAT('@ClientContactID = ' , @ClientContactID))
    BEGIN TRANSACTION
    BEGIN TRY
        IF NOT EXISTS (SELECT ID FROM client_contact WHERE IsActive = 1 AND ID = @ClientContactID)
        BEGIN
            RAISERROR ('Client Contact Not Found', 16, 1)
        END

        DECLARE @Data NVARCHAR(MAX) = (
            SELECT 
                client_contact.ID, 
                client_contact.ClientID, 
                client_contact.ContactValue, 
                client_contact.UpdateDate, 
                (
                    SELECT contact_type.[Type]
                    FROM contact_type
                    WHERE contact_type.ID = client_contact.ContactTypeID
                ) AS ContactType
            FROM client_contact
            WHERE client_contact.ID = @ClientContactID
            AND client_contact.IsActive = 1
            FOR JSON AUTO
        )

        SELECT *, @Data [Data]
        FROM vw_spLogMessage
        WHERE InternalCode = 'SF200'
        
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION

        INSERT INTO log_spUse (SpName, Parameters, Detail)
        VALUES('sp_Get_ClientContact', CONCAT('@ClientContactID = ' , @ClientContactID), ERROR_MESSAGE())

        SELECT *, NULL [Data], ERROR_MESSAGE() [Detail]
        FROM vw_spLogMessage
        WHERE InternalCode = 'EC404'

    END CATCH
END
GO
CREATE OR ALTER PROCEDURE sp_Get_ClientList
AS
BEGIN
    SET NOCOUNT ON
    INSERT INTO log_spUse (SpName)
    VALUES('sp_Get_ClientInfoList')

    BEGIN TRANSACTION
    BEGIN TRY
        IF NOT EXISTS (SELECT ID FROM client_info WHERE IsActive = 1)
        BEGIN
            RAISERROR ('Client Not Found', 16, 1)
        END
        DECLARE @Data NVARCHAR(MAX) = (
            SELECT 
                ci.ID [ClientID], 
                ci.FirstName, 
                ci.LastName, 
                (
                    SELECT rol_type.[Type]
                    FROM rol_type
                    WHERE rol_type.ID = ci.RolTypeID
                ) AS RolType
            FROM client_info ci
            WHERE ci.IsActive = 1
            FOR JSON AUTO
            )

        SELECT *, JSON_QUERY(@Data) [Data]
        FROM vw_spLogMessage
        WHERE InternalCode = 'SF200'

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION

        INSERT INTO log_spUse (SpName, Detail)
        VALUES('sp_Get_ClientInfoList', ERROR_MESSAGE())

        SELECT *, NULL [Data], ERROR_MESSAGE() [Detail]
        FROM vw_spLogMessage
        WHERE InternalCode = 'EC404'

    END CATCH
END
GO
CREATE OR ALTER PROCEDURE sp_Get_ClientInfoAndContact -- sp_Get_ClientInfoAndContact 2
    @ClientID INT
AS
BEGIN
    SET NOCOUNT ON
    INSERT INTO log_spUse (SpName, Parameters)
    VALUES('sp_Get_ClientInfo', CONCAT('@ClientID = ' , @ClientID))
    BEGIN TRANSACTION
    BEGIN TRY
        IF NOT EXISTS (SELECT ID FROM client_info WHERE IsActive = 1 AND ID = @ClientID)
        BEGIN
            RAISERROR ('Client Not Found', 16, 1)
        END

        DECLARE @Data NVARCHAR(MAX) = (
            SELECT 
                client_info.ID [ClientID], 
                client_info.FirstName, 
                client_info.LastName, 
                (
                    SELECT [Type]
                    FROM rol_type
                    WHERE rol_type.ID = client_info.RolTypeID
                ) AS [RolType],
                (
                    SELECT [ID]
                    FROM rol_type
                    WHERE rol_type.ID = client_info.RolTypeID
                ) AS [RolTypeID],
                (
                    SELECT
                        client_contact.ID [ContactID],
                        contact_type.Type [ContactType], 
                        client_contact.ContactValue
                    FROM 
                        client_contact
                        JOIN contact_type ON client_contact.ContactTypeID = contact_type.ID
                    WHERE 
                        client_contact.ClientID = client_info.ID
                        AND client_contact.IsActive = 1
                    FOR JSON PATH
                ) [contact]
            FROM 
                client_info 
            WHERE 
                client_info.IsActive = 1 AND client_info.ID = @ClientID
            FOR JSON AUTO
        )

        SELECT *, @Data [Data]
        FROM vw_spLogMessage
        WHERE InternalCode = 'SF200'

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION

        INSERT INTO log_spUse (SpName, Parameters, Detail)
        VALUES('sp_Get_ClientInfo', CONCAT('@ClientID = ' , @ClientID), ERROR_MESSAGE())

        SELECT *, NULL [Data], ERROR_MESSAGE() [Detail]
        FROM vw_spLogMessage
        WHERE InternalCode = 'EC404'

    END CATCH
END
GO
CREATE OR ALTER PROCEDURE sp_Get_ClientContactList -- sp_Get_ClientContactList 2
    @ClientID INT
AS
BEGIN
    SET NOCOUNT ON
    INSERT INTO log_spUse (SpName, Parameters)
    VALUES('sp_Get_ClientContactList', CONCAT('@ClientID = ' , @ClientID))
    BEGIN TRANSACTION
    BEGIN TRY
        IF NOT EXISTS (SELECT ID FROM client_info WHERE IsActive = 1 AND ID = @ClientID)
        BEGIN
            RAISERROR ('Client Not Found', 16, 1)
        END

        DECLARE @Data NVARCHAR(MAX) = (
            SELECT client_contact.*
            FROM client_contact
            WHERE client_contact.ClientID = @ClientID 
            FOR JSON AUTO
            )

        SELECT *, @Data [Data]
        FROM vw_spLogMessage
        WHERE InternalCode = 'SF200'

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION

        INSERT INTO log_spUse (SpName, Parameters, Detail)
        VALUES('sp_Get_ClientContactList', CONCAT('@ClientID = ' , @ClientID), ERROR_MESSAGE())

        SELECT *, NULL [Data], ERROR_MESSAGE() [Detail]
        FROM vw_spLogMessage
        WHERE InternalCode = 'EC404'

    END CATCH
END
GO
CREATE OR ALTER PROCEDURE sp_Get_AllRoles
AS
BEGIN
    SET NOCOUNT ON

    INSERT INTO log_spUse (SpName)
    VALUES('sp_Get_AllRoles')

    BEGIN TRANSACTION
    BEGIN TRY
        DECLARE @Data NVARCHAR(MAX) = (
            SELECT *
            FROM rol_type
            WHERE IsActive = 1 
            FOR JSON AUTO
            )

        SELECT *, @Data [Data]
        FROM vw_spLogMessage
        WHERE InternalCode = 'RT200'

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION

        INSERT INTO log_spUse (SpName, Detail)
        VALUES('sp_Get_AllRoles', ERROR_MESSAGE())

        SELECT *, NULL [Data], ERROR_MESSAGE() [Detail]
        FROM vw_spLogMessage
        WHERE InternalCode = 'RT500'
    END CATCH
END
GO
CREATE OR ALTER PROCEDURE sp_Get_AllContactTypes
AS
BEGIN
    SET NOCOUNT ON
    INSERT INTO log_spUse (SpName)
    VALUES('sp_Get_AllContactTypes')
    BEGIN TRANSACTION
    BEGIN TRY
        DECLARE @Data NVARCHAR(MAX) = (
            SELECT *
            FROM contact_type
            WHERE IsActive = 1 
            FOR JSON AUTO
            )

        SELECT *, @Data [Data]
        FROM vw_spLogMessage
        WHERE InternalCode = 'CT200'

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION

        INSERT INTO log_spUse (SpName, Detail)
        VALUES('sp_Get_AllContactTypes', ERROR_MESSAGE())

        SELECT *, NULL [Data], ERROR_MESSAGE() [Detail]
        FROM vw_spLogMessage
        WHERE InternalCode = 'CT500'

    END CATCH
END