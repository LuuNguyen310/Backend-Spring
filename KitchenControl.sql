-- ============================================
-- FRANCHISE CENTRAL KITCHEN MANAGEMENT SYSTEM
-- SQL Server Database Schema with Test Data
-- ============================================

USE master;
GO

-- Drop database if exists
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'KitchenControl_SWP391')
BEGIN
    ALTER DATABASE KitchenControl_SWP391 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE KitchenControl_SWP391;
END
GO

-- Create database
CREATE DATABASE KitchenControl_SWP391;
GO

USE KitchenControl_SWP391;
GO



-- 1. Bảng Roles
CREATE TABLE [roles] (
  [role_id] int PRIMARY KEY IDENTITY(1, 1),
  [role_name] nvarchar(255)
)
GO

-- 2. Bảng Stores
CREATE TABLE [stores] (
  [store_id] int PRIMARY KEY IDENTITY(1, 1),
  [store_name] nvarchar(255),
  [address] nvarchar(255),
  [phone] nvarchar(255)
)
GO

-- 3. Bảng Users (Phụ thuộc Roles, Stores)
CREATE TABLE [users] (
  [user_id] int PRIMARY KEY IDENTITY(1, 1),
  [username] nvarchar(255),
  [password] nvarchar(255),
  [full_name] nvarchar(255),
  [role_id] int,
  [store_id] int
)
GO

-- 4. Bảng Products
CREATE TABLE [products] (
  [product_id] int PRIMARY KEY IDENTITY(1, 1),
  [product_name] nvarchar(255),
  [product_type] nvarchar(255) NOT NULL CHECK ([product_type] IN ('RAW_MATERIAL', 'SEMI_FINISHED', 'FINISHED_PRODUCT')),
  [unit] nvarchar(255),
  [shelf_life_days] int
)
GO

-- 5. Bảng Recipes
CREATE TABLE [recipes] (
  [recipe_id] int PRIMARY KEY IDENTITY(1, 1),
  [product_id] int,
  [recipe_name] nvarchar(255), -- Đã sửa: thêm độ dài 255
  [yield_quantity] float,
  [description] text
)
GO

-- 6. Bảng Recipe Details
CREATE TABLE [recipe_details] (
  [recipe_detail_id] int PRIMARY KEY IDENTITY(1, 1),
  [recipe_id] int,
  [raw_material_id] int,
  [quantity] float
)
GO

-- 7. Bảng Production Plans
CREATE TABLE [production_plans] (
  [plan_id] int PRIMARY KEY IDENTITY(1, 1),
  [kitchen_id] int,
  [created_by] int,
  [plan_date] date,
  [start_date] date,
  [end_date] date,
  [status] nvarchar(255),
  [note] text
)
GO

-- 8. Bảng Deliveries (Tạo trước Orders để tham chiếu)
CREATE TABLE [deliveries] (
  [delivery_id] int PRIMARY KEY IDENTITY(1, 1),
  [delivery_date] date,
  [status] nvarchar(255) NOT NULL CHECK ([status] IN ('WAITTING', 'PROCESSING', 'DONE')),
  [shipper_id] int,
  [created_at] datetime
)
GO

-- 9. Bảng Orders
CREATE TABLE [orders] (
  [order_id] int PRIMARY KEY IDENTITY(1, 1),
  [delivery_id] int,
  [store_id] int,
  [plan_id] int,
  [order_date] datetime,
  [status] nvarchar(255) NOT NULL CHECK ([status] IN ('WAITTING', 'PROCESSING', 'DONE', 'DAMAGED'))
)
GO

-- 10. Bảng Order Details
CREATE TABLE [order_details] (
  [order_detail_id] int PRIMARY KEY IDENTITY(1, 1),
  [order_id] int,
  [product_id] int,
  [quantity] float
)
GO

-- 11. Bảng Log Batches
CREATE TABLE [log_batches] (
  [batch_id] int PRIMARY KEY IDENTITY(1, 1),
  [plan_id] int,
  [product_id] int,
  [quantity] float,
  [production_date] date,
  [expiry_date] date,
  [status] nvarchar(255) NOT NULL CHECK ([status] IN ('PROCESSING', 'DONE', 'EXPIRED', 'DAMAGED')),
  [type] nvarchar(255) NOT NULL CHECK ([type] IN ('PRODUCTION', 'PURCHASE')),
  [created_at] datetime
)
GO

-- 12. Bảng Inventories
CREATE TABLE [inventories] (
  [inventory_id] int PRIMARY KEY IDENTITY(1, 1),
  [product_id] int,
  [batch_id] int,
  [quantity] float,
  [expiry_date] date
)
GO

-- 13. Bảng Inventory Transactions
CREATE TABLE [inventory_transactions] (
  [transaction_id] int PRIMARY KEY IDENTITY(1, 1),
  [product_id] int,
  [created_by] int,
  [batch_id] int,
  [type] nvarchar(255) NOT NULL CHECK ([type] IN ('IMPORT', 'EXPORT')),
  [quantity] float,
  [created_at] datetime,
  [note] text
)
GO

-- 14. Bảng Quality Feedbacks
CREATE TABLE [quality_feedbacks] (
  [feedback_id] int PRIMARY KEY IDENTITY(1, 1),
  [order_id] int,
  [store_id] int,
  [rating] int,
  [comment] text,
  [created_at] datetime
)
GO

-- 15. Bảng Reports
CREATE TABLE [reports] (
  [report_id] int PRIMARY KEY IDENTITY(1, 1),
  [report_type] nvarchar(255),
  [user_id] int,
  [created_date] datetime
)
GO

-- =============================================
-- TẠO CÁC KHÓA NGOẠI (FOREIGN KEYS)
-- =============================================

ALTER TABLE [users] ADD FOREIGN KEY ([role_id]) REFERENCES [roles] ([role_id])
GO
ALTER TABLE [users] ADD FOREIGN KEY ([store_id]) REFERENCES [stores] ([store_id])
GO
ALTER TABLE [recipes] ADD FOREIGN KEY ([product_id]) REFERENCES [products] ([product_id])
GO
ALTER TABLE [recipe_details] ADD FOREIGN KEY ([recipe_id]) REFERENCES [recipes] ([recipe_id])
GO
ALTER TABLE [recipe_details] ADD FOREIGN KEY ([raw_material_id]) REFERENCES [products] ([product_id])
GO
ALTER TABLE [production_plans] ADD FOREIGN KEY ([created_by]) REFERENCES [users] ([user_id])
GO
ALTER TABLE [orders] ADD FOREIGN KEY ([plan_id]) REFERENCES [production_plans] ([plan_id])
GO
ALTER TABLE [orders] ADD FOREIGN KEY ([store_id]) REFERENCES [stores] ([store_id])
GO
ALTER TABLE [order_details] ADD FOREIGN KEY ([order_id]) REFERENCES [orders] ([order_id])
GO
ALTER TABLE [order_details] ADD FOREIGN KEY ([product_id]) REFERENCES [products] ([product_id])
GO
ALTER TABLE [log_batches] ADD FOREIGN KEY ([plan_id]) REFERENCES [production_plans] ([plan_id])
GO
ALTER TABLE [log_batches] ADD FOREIGN KEY ([product_id]) REFERENCES [products] ([product_id])
GO
ALTER TABLE [inventories] ADD FOREIGN KEY ([product_id]) REFERENCES [products] ([product_id])
GO
ALTER TABLE [inventories] ADD FOREIGN KEY ([batch_id]) REFERENCES [log_batches] ([batch_id])
GO
ALTER TABLE [inventory_transactions] ADD FOREIGN KEY ([product_id]) REFERENCES [products] ([product_id])
GO
ALTER TABLE [inventory_transactions] ADD FOREIGN KEY ([batch_id]) REFERENCES [log_batches] ([batch_id])
GO
-- [ĐÃ SỬA LỖI 1]: Trỏ đúng vào delivery_id (Primary Key của bảng deliveries)
ALTER TABLE [orders] ADD FOREIGN KEY ([delivery_id]) REFERENCES [deliveries] ([delivery_id])
GO
ALTER TABLE [quality_feedbacks] ADD FOREIGN KEY ([order_id]) REFERENCES [orders] ([order_id])
GO
ALTER TABLE [quality_feedbacks] ADD FOREIGN KEY ([store_id]) REFERENCES [stores] ([store_id])
GO
ALTER TABLE [reports] ADD FOREIGN KEY ([user_id]) REFERENCES [users] ([user_id])
GO
-- [ĐÃ SỬA LỖI 2]: Đảo chiều quan hệ. Shipper (trong bảng Deliveries) là một User.
ALTER TABLE [deliveries] ADD FOREIGN KEY ([shipper_id]) REFERENCES [users] ([user_id])
GO
ALTER TABLE [inventory_transactions] ADD FOREIGN KEY ([created_by]) REFERENCES [users] ([user_id])
GO

/*======================================================================================================*/

-- 1. INSERT ROLES
INSERT INTO [roles] ([role_name]) VALUES 
('Admin'),                -- ID: 1
('Supply Coordinator'),   -- ID: 2
('Kitchen Manager'),      -- ID: 3
('Store Manager');        -- ID: 4
GO

-- 2. INSERT STORES (5 Cửa hàng theo yêu cầu)
INSERT INTO [stores] ([store_name], [address], [phone]) VALUES 
(N'Bakery South', N'789 Nguyen Trai, District 5', '0903333333'),      -- ID: 1 (Gia su Bep dat o day)
(N'Bakery East', N'101 Vo Van Ngan, Thu Duc City', '0904444444'),     -- ID: 2
(N'Bakery West', N'Store West Name, Thu Duc City', '123456789'),      -- ID: 3
(N'Bakery North', N'Store North Name, Thu Duc City', '987654321'),    -- ID: 4
(N'Bakery 1', N'Store 1 Name, Thu Duc City', '080811111111');         -- ID: 5
GO

-- 3. INSERT USERS (Theo đúng Scope: 1 Admin, 1 Supply, 1 Kitchen, 5 Store Mgr)
-- ID: 1 - Admin
INSERT INTO [users] ([username], [password], [full_name], [role_id], [store_id]) 
VALUES ('admin', 'pass123', N'System Administrator', 1, NULL); 

-- ID: 2 - Supply Coordinator (Phu trach Deliveries & Kho)
INSERT INTO [users] ([username], [password], [full_name], [role_id], [store_id]) 
VALUES ('supply_coor', 'pass123', N'Tran Van Supply', 2, NULL); 

-- ID: 3 - Kitchen Manager (Phu trach Production Plan)
INSERT INTO [users] ([username], [password], [full_name], [role_id], [store_id]) 
VALUES ('kitchen_mgr', 'pass123', N'Nguyen Chef Manager', 3, 1); 

-- ID: 4 -> 8: Store Managers (Moi nguoi 1 Store)
INSERT INTO [users] ([username], [password], [full_name], [role_id], [store_id]) VALUES 
('mgr_south', 'pass123', N'Manager South', 4, 1),  -- ID 4
('mgr_east', 'pass123', N'Manager East', 4, 2),    -- ID 5
('mgr_west', 'pass123', N'Manager West', 4, 3),    -- ID 6
('mgr_north', 'pass123', N'Manager North', 4, 4),  -- ID 7
('mgr_one', 'pass123', N'Manager One', 4, 5);      -- ID 8
GO

-- 4. INSERT PRODUCTS
-- Nguyen lieu (Raw)
INSERT INTO [products] ([product_name], [product_type], [unit], [shelf_life_days]) VALUES 
(N'Bot mi (Flour)', 'RAW_MATERIAL', 'kg', 180),           -- ID 1
(N'Duong (Sugar)', 'RAW_MATERIAL', 'kg', 365),            -- ID 2
(N'Trung ga (Eggs)', 'RAW_MATERIAL', 'qua', 10),          -- ID 3
(N'Sua tuoi (Milk)', 'RAW_MATERIAL', 'lit', 7),           -- ID 4
(N'Socola (Chocolate)', 'RAW_MATERIAL', 'kg', 180);       -- ID 5

-- Ban thanh pham (Semi)
INSERT INTO [products] ([product_name], [product_type], [unit], [shelf_life_days]) VALUES 
(N'Bot banh ngot (Dough)', 'SEMI_FINISHED', 'kg', 2),     -- ID 6
(N'Kem trung (Custard)', 'SEMI_FINISHED', 'lit', 3);      -- ID 7

-- Thanh pham (Finished)
INSERT INTO [products] ([product_name], [product_type], [unit], [shelf_life_days]) VALUES 
(N'Banh Croissant', 'FINISHED_PRODUCT', 'cai', 1),        -- ID 8
(N'Banh Mousse', 'FINISHED_PRODUCT', 'cai', 3),           -- ID 9
(N'Banh Donut', 'FINISHED_PRODUCT', 'cai', 2);            -- ID 10
GO

-- 5. INSERT RECIPES
-- CT 1: Bot banh ngot (tu Bot mi, Duong, Trung, Sua)
INSERT INTO [recipes] ([product_id], [recipe_name], [yield_quantity], [description]) 
VALUES (6, N'Cong thuc Bot co ban', 10, N'Tron nguyen lieu'); -- ID 1

INSERT INTO [recipe_details] ([recipe_id], [raw_material_id], [quantity]) VALUES 
(1, 1, 5), (1, 2, 2), (1, 3, 20), (1, 4, 2);

-- CT 2: Banh Croissant (tu Bot banh ngot, Socola)
INSERT INTO [recipes] ([product_id], [recipe_name], [yield_quantity], [description]) 
VALUES (8, N'Croissant Socola', 50, N'Nuong 180 do'); -- ID 2

INSERT INTO [recipe_details] ([recipe_id], [raw_material_id], [quantity]) VALUES 
(2, 6, 8), (2, 5, 2);
GO

/*=======================================================================================================*/
-- 6. INSERT PRODUCTION PLANS
-- Plan cu (da xong) - Tao boi Kitchen Manager (ID 3)
INSERT INTO [production_plans] ([kitchen_id], [created_by], [plan_date], [start_date], [end_date], [status], [note]) 
VALUES (1, 3, '2023-10-01', '2023-10-01', '2023-10-03', 'DONE', N'Plan tuan 1 thang 10'); -- ID 1

-- Plan moi (dang chay) - Tao boi Kitchen Manager (ID 3)
INSERT INTO [production_plans] ([kitchen_id], [created_by], [plan_date], [start_date], [end_date], [status], [note]) 
VALUES (1, 3, GETDATE(), GETDATE(), DATEADD(day, 2, GETDATE()), 'PROCESSING', N'Plan tuan nay'); -- ID 2
GO

-- 7. INSERT LOG BATCHES (Nhap hang & San xuat)
-- Nhap nguyen lieu (PURCHASE)
INSERT INTO [log_batches] ([plan_id], [product_id], [quantity], [production_date], [expiry_date], [status], [type], [created_at]) VALUES 
(NULL, 1, 500, '2023-10-01', '2024-04-01', 'DONE', 'PURCHASE', '2023-10-01'), -- Batch 1: Bot mi
(NULL, 5, 200, '2023-10-01', '2024-04-01', 'DONE', 'PURCHASE', '2023-10-01'); -- Batch 2: Socola

-- San xuat thanh pham (PRODUCTION) - Tu Plan ID 1
INSERT INTO [log_batches] ([plan_id], [product_id], [quantity], [production_date], [expiry_date], [status], [type], [created_at]) VALUES 
(1, 8, 200, '2023-10-03', '2023-10-04', 'DONE', 'PRODUCTION', '2023-10-03'), -- Batch 3: Croissant (Da xong)
(2, 10, 100, GETDATE(), DATEADD(day, 2, GETDATE()), 'PROCESSING', 'PRODUCTION', GETDATE()); -- Batch 4: Donut (Dang lam)
GO

-- 8. INSERT INVENTORIES & TRANSACTIONS
-- Ton kho tu Batch 1, 3
INSERT INTO [inventories] ([product_id], [batch_id], [quantity], [expiry_date]) VALUES 
(1, 1, 400, '2024-04-01'), -- Bot mi con 400
(8, 3, 50, '2023-10-04');  -- Croissant con 50

-- Lich su giao dich (Tao boi Supply ID 2 hoac Kitchen ID 3)
INSERT INTO [inventory_transactions] ([product_id], [created_by], [batch_id], [type], [quantity], [created_at], [note]) VALUES 
(1, 2, 1, 'IMPORT', 500, '2023-10-01', N'Nhap kho bot mi'),
(1, 3, 1, 'EXPORT', 100, '2023-10-02', N'Xuat bot mi lam banh');
GO

-- 9. INSERT DELIVERIES (Tao boi Supply Coordinator - ID 2)
-- Chuyen 1: Da giao xong
INSERT INTO [deliveries] ([delivery_date], [status], [shipper_id], [created_at]) 
VALUES ('2023-10-04', 'DONE', 2, '2023-10-04'); -- ID 1

-- Chuyen 2: Dang di
INSERT INTO [deliveries] ([delivery_date], [status], [shipper_id], [created_at]) 
VALUES (GETDATE(), 'PROCESSING', 2, GETDATE()); -- ID 2
GO

-- 10. INSERT ORDERS (Tao boi cac Store Manager ID 4,5,6,7,8)

-- Order 1: Cua Bakery East (Store 2 - Mgr ID 5), thuoc Delivery 1 (Da xong)
INSERT INTO [orders] ([delivery_id], [store_id], [plan_id], [order_date], [status]) 
VALUES (1, 2, 1, '2023-10-04', 'DONE'); -- ID 1

INSERT INTO [order_details] ([order_id], [product_id], [quantity]) VALUES (1, 8, 100); -- 100 Croissant

-- Order 2: Cua Bakery West (Store 3 - Mgr ID 6), thuoc Delivery 2 (Dang giao)
INSERT INTO [orders] ([delivery_id], [store_id], [plan_id], [order_date], [status]) 
VALUES (2, 3, 1, GETDATE(), 'PROCESSING'); -- ID 2

INSERT INTO [order_details] ([order_id], [product_id], [quantity]) VALUES (2, 8, 50); -- 50 Croissant

-- Order 3: Cua Bakery 1 (Store 5 - Mgr ID 8), chua co xe giao (Waitting)
INSERT INTO [orders] ([delivery_id], [store_id], [plan_id], [order_date], [status]) 
VALUES (NULL, 5, 2, GETDATE(), 'WAITTING'); -- ID 3

INSERT INTO [order_details] ([order_id], [product_id], [quantity]) VALUES (3, 10, 20); -- 20 Donut
GO

-- 11. INSERT FEEDBACKS
INSERT INTO [quality_feedbacks] ([order_id], [store_id], [rating], [comment], [created_at]) 
VALUES (1, 2, 5, N'Hang ve dung gio, banh ngon', GETDATE());
GO