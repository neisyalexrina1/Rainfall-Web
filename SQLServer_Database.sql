-- ============================================================
-- SQL SCRIPT FOR MULTI-REGION RAINFALL ANALYSIS AND FORECASTING
-- Run this script in SSMS to generate the full database.
-- ============================================================

CREATE DATABASE RainfallForecastDB;
GO
USE RainfallForecastDB;
GO

CREATE TABLE Stations (
    StationID INT PRIMARY KEY,
    StationName NVARCHAR(100) NOT NULL,
    Region NVARCHAR(50) NOT NULL
);

INSERT INTO Stations VALUES 
(1, N'Hà Nội', N'North'), 
(2, N'Đà Nẵng', N'Central'), 
(3, N'TP. Hồ Chí Minh', N'South');

CREATE TABLE Users (
    UserID INT IDENTITY PRIMARY KEY,
    Username NVARCHAR(50) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL,
    Email NVARCHAR(100),
    Role NVARCHAR(20) CHECK (Role IN ('Admin', 'Customer')),
    Tier NVARCHAR(20) CHECK (Tier IN ('Free', 'Pro')),
    ExpiryDate DATE NULL
);

INSERT INTO Users (Username, PasswordHash, Email, Role, Tier) VALUES 
('admin', 'admin123', 'admin@mail.com', 'Admin', 'Pro'), 
('user_free', '123', 'free@mail.com', 'Customer', 'Free'), 
('user_pro', '123', 'pro@mail.com', 'Customer', 'Pro');

CREATE TABLE RainfallData (
    LogID INT IDENTITY PRIMARY KEY,
    StationID INT NOT NULL,
    MeasureDate DATE NOT NULL,
    RainfallMM FLOAT NOT NULL,
    CONSTRAINT UQ_Station_Date UNIQUE (StationID, MeasureDate),
    CONSTRAINT FK_Rainfall_Station FOREIGN KEY (StationID) REFERENCES Stations(StationID)
);

INSERT INTO RainfallData (StationID, MeasureDate, RainfallMM) VALUES 
-- Hà Nội
(1, '2024-01-01', 5), (1, '2024-01-02', 0), (1, '2024-02-01', 12),
-- Đà Nẵng 
(2, '2024-01-01', 30), (2, '2024-02-01', 55), (2, '2024-03-01', 80),
-- TP.HCM 
(3, '2024-01-01', 0), (3, '2024-02-01', 3), (3, '2024-03-01', 10);

CREATE TABLE ServicePackages (
    PackageID INT IDENTITY PRIMARY KEY,
    PackageName NVARCHAR(50),
    DurationMonths INT,
    Price DECIMAL(10,2)
);

INSERT INTO ServicePackages VALUES 
('Free', 0, 0), 
('Pro Monthly', 1, 50000), 
('Pro Yearly', 12, 500000);

CREATE TABLE Orders (
    OrderID INT IDENTITY PRIMARY KEY,
    UserID INT,
    OrderDate DATETIME DEFAULT GETDATE(),
    Amount DECIMAL(10,2),
    Status NVARCHAR(20),
    TransactionCode NVARCHAR(50) UNIQUE,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

INSERT INTO Orders (UserID, Amount, Status, TransactionCode) VALUES 
(2, 50000, 'Completed', 'TXN_2025_A9X');

CREATE TABLE ForecastLogs (
    ForecastID INT IDENTITY PRIMARY KEY,
    StationID INT,
    ForecastMonth NVARCHAR(7), -- yyyy-MM
    PredictedRainfall FLOAT,
    RiskLevel NVARCHAR(50),
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (StationID) REFERENCES Stations(StationID)
);

INSERT INTO ForecastLogs (StationID, ForecastMonth, PredictedRainfall, RiskLevel) VALUES 
(3, '2025-03', 180, N'Mưa lớn'), 
(2, '2025-03', 250, N'Nguy cơ ngập');
GO

-- Stored Procedures for fetching Reports
CREATE PROCEDURE GetRainfallReport
AS
BEGIN
    SELECT s.StationName, FORMAT(r.MeasureDate, 'yyyy-MM') AS Month, SUM(r.RainfallMM) AS TotalRainfall 
    FROM RainfallData r 
    JOIN Stations s ON r.StationID = s.StationID 
    GROUP BY s.StationName, FORMAT(r.MeasureDate, 'yyyy-MM') 
    ORDER BY Month;
END;
GO

-- =====================================================
-- Profile Picture Migration
-- Run this in SQL Server Management Studio
-- =====================================================

ALTER TABLE Users ADD ProfileImage NVARCHAR(500) NULL;

-- Verify
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Users' AND COLUMN_NAME = 'ProfileImage';


-- VNPay Payment Migration Script
-- Chạy script này trên SQL Server để thêm các cột cần thiết cho luồng VNPay

-- 1. Thêm cột PackageID (gói Pro Monthly=2, Pro Yearly=3)
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'Orders' AND COLUMN_NAME = 'PackageID'
)
BEGIN
    ALTER TABLE Orders ADD PackageID INT DEFAULT 2;
    PRINT 'Added PackageID column to Orders';
END
ELSE
    PRINT 'PackageID already exists';

-- 2. Thêm cột PaymentReference (mã nội dung chuyển khoản, ví dụ: RA2026ABCD1234)
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'Orders' AND COLUMN_NAME = 'PaymentReference'
)
BEGIN
    ALTER TABLE Orders ADD PaymentReference NVARCHAR(50) NULL;
    PRINT 'Added PaymentReference column to Orders';
END
ELSE
    PRINT 'PaymentReference already exists';

-- 3. Thêm unique index cho PaymentReference để tránh duplicate
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'UX_Orders_PaymentReference' AND object_id = OBJECT_ID('Orders')
)
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UX_Orders_PaymentReference
        ON Orders(PaymentReference)
        WHERE PaymentReference IS NOT NULL;
    PRINT 'Created unique index on PaymentReference';
END
ELSE
    PRINT 'Index UX_Orders_PaymentReference already exists';

PRINT 'Migration completed successfully!';

-- 1. Trigger cho Users
IF OBJECT_ID('trg_DeleteUserRelatedData', 'TR') IS NOT NULL
    DROP TRIGGER trg_DeleteUserRelatedData;
GO

CREATE TRIGGER trg_DeleteUserRelatedData
ON Users
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    -- Xoá Orders liên quan đến Users bị xoá
    DELETE FROM Orders WHERE UserID IN (SELECT UserID FROM deleted);
    -- Xoá Users sau khi đã xoá các dữ liệu tham chiếu
    DELETE FROM Users WHERE UserID IN (SELECT UserID FROM deleted);
END
GO

-- 2. Trigger cho Stations
IF OBJECT_ID('trg_DeleteStationRelatedData', 'TR') IS NOT NULL
    DROP TRIGGER trg_DeleteStationRelatedData;
GO

CREATE TRIGGER trg_DeleteStationRelatedData
ON Stations
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    -- Xoá ForecastLogs và RainfallData liên quan
    DELETE FROM ForecastLogs WHERE StationID IN (SELECT StationID FROM deleted);
    DELETE FROM RainfallData WHERE StationID IN (SELECT StationID FROM deleted);
    -- Xoá Stations
    DELETE FROM Stations WHERE StationID IN (SELECT StationID FROM deleted);
END
GO

