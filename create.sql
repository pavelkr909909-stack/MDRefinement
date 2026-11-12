 
CREATE TABLE dbo.Articles (
    article_id INT IDENTITY(1,1) PRIMARY KEY,
    article_name NVARCHAR(100) NOT NULL,
    description NVARCHAR(255) NULL
);


CREATE TABLE dbo.Prices (
    price_id INT IDENTITY(1,1) PRIMARY KEY,
    article_id INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    effective_date DATE NOT NULL   
      
);

 
CREATE TABLE dbo.Orders (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    client_id INT NOT NULL,
    article_id INT NOT NULL,
    quantity INT NOT NULL CONSTRAINT CK_Orders_Quantity CHECK (quantity > 0),
    order_date DATETIME2 NOT NULL  
    
);

CREATE TABLE dbo.Clients (
    client_id INT IDENTITY(1,1) PRIMARY KEY,
    client_name NVARCHAR(100) NOT NULL,
    email NVARCHAR(100) NULL,
    loyalty_level INT NOT NULL 
);