/*
  tSQLt tests for dbo.sp_CreateOrder
  Run with:  EXEC tSQLt.Run 'CreateOrderTests';

  NOTE: two tests are EXPECTED TO FAIL against the current procedure,
  because they expose real problems in it:
    - [test stored order_id equals returned CreatedOrderID]
    - [test non-positive quantity is rejected]
  See the explanation in the chat.
*/

EXEC tSQLt.NewTestClass 'CreateOrderTests';
GO
 
CREATE PROCEDURE CreateOrderTests.[SetUp]
AS
BEGIN
    EXEC tSQLt.FakeTable 'dbo.Clients';
    EXEC tSQLt.FakeTable 'dbo.Articles';
    EXEC tSQLt.FakeTable 'dbo.Orders';

    INSERT INTO dbo.Clients  (client_id)  VALUES (1), (2);
    INSERT INTO dbo.Articles (article_id) VALUES (10), (20);
END;
GO
 // SUNNY DAY 
CREATE PROCEDURE CreateOrderTests.[test returns 1001 when Orders is empty]
AS
BEGIN
    CREATE TABLE #actual   (CreatedOrderID INT);
    CREATE TABLE #expected (CreatedOrderID INT);
    INSERT INTO #expected VALUES (1001);

    INSERT INTO #actual
    EXEC dbo.sp_CreateOrder @client_id = 1, @article_id = 10, @quantity = 5;

    EXEC tSQLt.AssertEqualsTable '#expected', '#actual';
END;
GO

CREATE PROCEDURE CreateOrderTests.[test returns MAX(order_id) + 1 when orders exist]
AS
BEGIN
    INSERT INTO dbo.Orders (order_id, client_id, article_id, quantity, order_date)
    VALUES (1003, 1, 10, 1, GETDATE()),
           (1005, 2, 20, 2, GETDATE());

    CREATE TABLE #actual   (CreatedOrderID INT);
    CREATE TABLE #expected (CreatedOrderID INT);
    INSERT INTO #expected VALUES (1006);

    INSERT INTO #actual
    EXEC dbo.sp_CreateOrder @client_id = 1, @article_id = 10, @quantity = 5;

    EXEC tSQLt.AssertEqualsTable '#expected', '#actual';
END;
GO

CREATE PROCEDURE CreateOrderTests.[test inserts one row with correct client, article and quantity]
AS
BEGIN
    EXEC dbo.sp_CreateOrder @client_id = 2, @article_id = 20, @quantity = 7;

    SELECT client_id, article_id, quantity
    INTO #actual
    FROM dbo.Orders;

    CREATE TABLE #expected (client_id INT, article_id INT, quantity INT);
    INSERT INTO #expected VALUES (2, 20, 7);

    EXEC tSQLt.AssertEqualsTable '#expected', '#actual';
END;
GO

CREATE PROCEDURE CreateOrderTests.[test order_date is set to current time]
AS
BEGIN
    EXEC dbo.sp_CreateOrder @client_id = 1, @article_id = 10, @quantity = 1;

    DECLARE @order_date DATETIME = (SELECT order_date FROM dbo.Orders);

    IF @order_date IS NULL OR ABS(DATEDIFF(SECOND, @order_date, GETDATE())) > 5
        EXEC tSQLt.Fail 'order_date was not set to (approximately) the current time.';
END;
GO

 //// RAINY DAY 
CREATE PROCEDURE CreateOrderTests.[test stored order_id equals returned CreatedOrderID]
AS
BEGIN
    CREATE TABLE #result (CreatedOrderID INT);

    INSERT INTO #result
    EXEC dbo.sp_CreateOrder @client_id = 1, @article_id = 10, @quantity = 3;

    DECLARE @returned INT = (SELECT CreatedOrderID FROM #result);
    DECLARE @stored   INT = (SELECT order_id FROM dbo.Orders);

    EXEC tSQLt.AssertEquals @Expected = @returned,
                            @Actual   = @stored,
                            @Message  = 'order_id stored in dbo.Orders differs from the returned CreatedOrderID.';
END;
GO
 
CREATE PROCEDURE CreateOrderTests.[test throws 50001 when client does not exist]
AS
BEGIN
    EXEC tSQLt.ExpectException @ExpectedMessage     = 'Client ID does not exist.',
                               @ExpectedErrorNumber = 50001;

    EXEC dbo.sp_CreateOrder @client_id = 999, @article_id = 10, @quantity = 1;
END;
GO

CREATE PROCEDURE CreateOrderTests.[test throws 50002 when article does not exist]
AS
BEGIN
    EXEC tSQLt.ExpectException @ExpectedMessage     = 'Article ID does not exist.',
                               @ExpectedErrorNumber = 50002;

    EXEC dbo.sp_CreateOrder @client_id = 1, @article_id = 999, @quantity = 1;
END;
GO

CREATE PROCEDURE CreateOrderTests.[test client is validated before article]
AS
BEGIN
    EXEC tSQLt.ExpectException @ExpectedErrorNumber = 50001;

    EXEC dbo.sp_CreateOrder @client_id = 999, @article_id = 999, @quantity = 1;
END;
GO

CREATE PROCEDURE CreateOrderTests.[test NULL client_id is rejected]
AS
BEGIN
    EXEC tSQLt.ExpectException @ExpectedErrorNumber = 50001;

    EXEC dbo.sp_CreateOrder @client_id = NULL, @article_id = 10, @quantity = 1;
END;
GO

 // EXPECTED TO FAIL with current proc: quantity is never validated.
CREATE PROCEDURE CreateOrderTests.[test non-positive quantity is rejected]
AS
BEGIN
    EXEC tSQLt.ExpectAnyException;

    EXEC dbo.sp_CreateOrder @client_id = 1, @article_id = 10, @quantity = 0;
END;
GO

EXEC tSQLt.Run 'CreateOrderTests';
