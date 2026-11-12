 
SET IDENTITY_INSERT dbo.Clients ON

INSERT INTO dbo.Clients (client_id, client_name, email, loyalty_level)
VALUES 
    (1, N'Skoda', N'purchase_germany@skoda.zz', 8),           -- Loyal client (> 5)
    (2, N'Ford', N'acquisition@ford.zz', 4),             
    (3, N'Stellantis', N'achate_brussels@stellantis.zz', 6), -- Loyal client (> 5)
    (4, N'Maserati', N'kyoko@maserati.zz', 2);      

SET IDENTITY_INSERT dbo.Clients OFF 

SET IDENTITY_INSERT dbo.Articles ON

INSERT INTO dbo.Articles (article_id, article_name, description)
VALUES 
    (101, N'Carpet_10923', N'Automotive floor carpet mat'),
    (102, N'Mirror_51', N'Side rear-view mirror assembly'),
    (103, N'Screw_XC11', N'Stainless steel fastening screw'),
    (104, N'Bottle', N'Windshield washer fluid bottle');

SET IDENTITY_INSERT dbo.Articles OFF

SET IDENTITY_INSERT dbo.Prices  ON 

INSERT INTO dbo.Prices (price_id, article_id, unit_price, effective_date)
VALUES 
    (1, 101, 120.00, '2026-01-01'), 
    (2, 102, 350.00, '2026-01-01'),  
    (3, 103, 1.50,   '2026-01-01'),  
    (4, 104, 45.00,  '2026-01-01'); 

SET IDENTITY_INSERT dbo.Prices  OFF
