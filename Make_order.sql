CREATE OR ALTER PROCEDURE dbo.sp_CreateOrder
    @client_id INT,
    @article_id INT,
    @quantity INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
	BEGIN TRY
        BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM dbo.Clients WHERE client_id = @client_id)
    BEGIN
        THROW 50001, 'Client ID does not exist.', 1;
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.Articles WHERE article_id = @article_id)
    BEGIN
        THROW 50002, 'Article ID does not exist.', 1;
    END

    -- Generate next order_id since IDENTITY was removed
    DECLARE @next_order_id INT;
    SELECT @next_order_id = ISNULL(MAX(order_id), 1000) + 1 FROM dbo.Orders WITH (UPDLOCK, HOLDLOCK);  ;

    -- Insert the new order
    INSERT INTO dbo.Orders (order_id, client_id, article_id, quantity, order_date)
    VALUES (@next_order_id, @client_id, @article_id, @quantity, GETDATE());

    SELECT @next_order_id AS CreatedOrderID;
	COMMIT TRANSACTION;
	END TRY
	 
	 BEGIN CATCH
        -- Roll back any open transaction if an error occurred
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        -- Return structured error details
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_PROCEDURE() AS ErrorProcedure,
            ERROR_LINE() AS ErrorLine,
            ERROR_MESSAGE() AS ErrorMessage;

        -- Re-throw the error so calling applications (C#, Python, SSMS) know it failed
        THROW;
    END CATCH
	
END;
GO
