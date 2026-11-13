CREATE PROCEDURE dbo.usp_CreateClient
    @client_name NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO dbo.Clients ( loyalty_level,client_name)
        VALUES (@client_name, 1);

        DECLARE @new_id INT = SCOPE_IDENTITY();

        COMMIT TRANSACTION;

        SELECT @new_id AS client_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;  
    END CATCH;
END;
GO