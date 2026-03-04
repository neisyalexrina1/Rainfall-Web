package model;

import jakarta.persistence.*;
import java.sql.Timestamp;

@Entity
@Table(name = "ForecastLogs")
public class ForecastLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ForecastID")
    private int forecastID;

    @Column(name = "StationID")
    private int stationID;

    @Column(name = "ForecastMonth", length = 7)
    private String forecastMonth;

    @Column(name = "PredictedRainfall")
    private double predictedRainfall;

    @Column(name = "RiskLevel", length = 50)
    private String riskLevel;

    @Column(name = "CreatedAt", insertable = false, updatable = false)
    private Timestamp createdAt;

    @Transient
    private String dataSource; // "historical" or "forecast" — not in DB

    public ForecastLog() {
    }

    public ForecastLog(int forecastID, int stationID, String forecastMonth, double predictedRainfall, String riskLevel,
            Timestamp createdAt) {
        this(forecastID, stationID, forecastMonth, predictedRainfall, riskLevel, createdAt, "forecast");
    }

    public ForecastLog(int forecastID, int stationID, String forecastMonth, double predictedRainfall, String riskLevel,
            Timestamp createdAt, String dataSource) {
        this.forecastID = forecastID;
        this.stationID = stationID;
        this.forecastMonth = forecastMonth;
        this.predictedRainfall = predictedRainfall;
        this.riskLevel = riskLevel;
        this.createdAt = createdAt;
        this.dataSource = dataSource;
    }

    public int getForecastID() {
        return forecastID;
    }

    public void setForecastID(int forecastID) {
        this.forecastID = forecastID;
    }

    public int getStationID() {
        return stationID;
    }

    public void setStationID(int stationID) {
        this.stationID = stationID;
    }

    public String getForecastMonth() {
        return forecastMonth;
    }

    public void setForecastMonth(String forecastMonth) {
        this.forecastMonth = forecastMonth;
    }

    public double getPredictedRainfall() {
        return predictedRainfall;
    }

    public void setPredictedRainfall(double predictedRainfall) {
        this.predictedRainfall = predictedRainfall;
    }

    public String getRiskLevel() {
        return riskLevel;
    }

    public void setRiskLevel(String riskLevel) {
        this.riskLevel = riskLevel;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getDataSource() {
        return dataSource != null ? dataSource : "forecast";
    }

    public void setDataSource(String dataSource) {
        this.dataSource = dataSource;
    }
}
