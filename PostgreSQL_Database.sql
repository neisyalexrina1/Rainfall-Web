-- ============================================================
-- SQL SCRIPT FOR MULTI-REGION RAINFALL ANALYSIS AND FORECASTING
-- Run this script in Supabase SQL Editor
-- ============================================================

CREATE TABLE Stations (
    StationID INT PRIMARY KEY,
    StationName VARCHAR(100) NOT NULL,
    Region VARCHAR(50) NOT NULL
);

INSERT INTO Stations (StationID, StationName, Region) VALUES 
(1, 'Hà Nội', 'North'), 
(2, 'Đà Nẵng', 'Central'), 
(3, 'TP. Hồ Chí Minh', 'South');

CREATE TABLE Users (
    UserID SERIAL PRIMARY KEY,
    Username VARCHAR(50) UNIQUE NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    Email VARCHAR(100),
    Role VARCHAR(20) CHECK (Role IN ('Admin', 'Customer')),
    Tier VARCHAR(20) CHECK (Tier IN ('Free', 'Pro')),
    ExpiryDate DATE NULL,
    ProfileImage VARCHAR(500) NULL
);

INSERT INTO Users (Username, PasswordHash, Email, Role, Tier) VALUES 
('admin', 'admin123', 'admin@mail.com', 'Admin', 'Pro'), 
('user_free', '123', 'free@mail.com', 'Customer', 'Free'), 
('user_pro', '123', 'pro@mail.com', 'Customer', 'Pro');

CREATE TABLE RainfallData (
    LogID SERIAL PRIMARY KEY,
    StationID INT NOT NULL,
    MeasureDate DATE NOT NULL,
    RainfallMM FLOAT NOT NULL,
    CONSTRAINT UQ_Station_Date UNIQUE (StationID, MeasureDate),
    CONSTRAINT FK_Rainfall_Station FOREIGN KEY (StationID) REFERENCES Stations(StationID) ON DELETE CASCADE
);

INSERT INTO RainfallData (StationID, MeasureDate, RainfallMM) VALUES 
-- Hà Nội
(1, '2024-01-01', 5), (1, '2024-01-02', 0), (1, '2024-02-01', 12),
-- Đà Nẵng 
(2, '2024-01-01', 30), (2, '2024-02-01', 55), (2, '2024-03-01', 80),
-- TP.HCM 
(3, '2024-01-01', 0), (3, '2024-02-01', 3), (3, '2024-03-01', 10);

CREATE TABLE ServicePackages (
    PackageID SERIAL PRIMARY KEY,
    PackageName VARCHAR(50),
    DurationMonths INT,
    Price DECIMAL(10,2)
);

INSERT INTO ServicePackages (PackageName, DurationMonths, Price) VALUES 
('Free', 0, 0), 
('Pro Monthly', 1, 50000), 
('Pro Yearly', 12, 500000);

CREATE TABLE Orders (
    OrderID SERIAL PRIMARY KEY,
    UserID INT,
    OrderDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Amount DECIMAL(10,2),
    Status VARCHAR(20),
    TransactionCode VARCHAR(50) UNIQUE,
    PackageID INT DEFAULT 2,
    PaymentReference VARCHAR(50) UNIQUE,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);

INSERT INTO Orders (UserID, Amount, Status, TransactionCode) VALUES 
(2, 50000, 'Completed', 'TXN_2025_A9X');

CREATE TABLE ForecastLogs (
    ForecastID SERIAL PRIMARY KEY,
    StationID INT,
    ForecastMonth VARCHAR(7), -- yyyy-MM
    PredictedRainfall FLOAT,
    RiskLevel VARCHAR(50),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (StationID) REFERENCES Stations(StationID) ON DELETE CASCADE
);

INSERT INTO ForecastLogs (StationID, ForecastMonth, PredictedRainfall, RiskLevel) VALUES 
(3, '2025-03', 180, 'Mưa lớn'), 
(2, '2025-03', 250, 'Nguy cơ ngập');

-- ============================================================
-- TRANSLATED STORED PROCEDURES
-- ============================================================
-- Stored Procedures for fetching Reports translated to Postgres Function
CREATE OR REPLACE FUNCTION GetRainfallReport()
RETURNS TABLE (
    StationName VARCHAR, 
    Month TEXT, 
    TotalRainfall FLOAT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.StationName::VARCHAR, 
        TO_CHAR(r.MeasureDate, 'YYYY-MM') AS Month, 
        SUM(r.RainfallMM)::FLOAT AS TotalRainfall 
    FROM RainfallData r 
    JOIN Stations s ON r.StationID = s.StationID 
    GROUP BY s.StationName, TO_CHAR(r.MeasureDate, 'YYYY-MM') 
    ORDER BY Month;
END;
$$ LANGUAGE plpgsql;
