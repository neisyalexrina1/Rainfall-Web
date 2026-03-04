package model;

import jakarta.persistence.*;
import java.sql.Date;

@Entity
@Table(name = "RainfallData")
public class RainfallData {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "LogID")
    private int logID;

    @Column(name = "StationID", nullable = false)
    private int stationID;

    @Column(name = "MeasureDate", nullable = false)
    private Date measureDate;

    @Column(name = "RainfallMM", nullable = false)
    private double rainfallMM;

    public RainfallData() {
    }

    public RainfallData(int logID, int stationID, Date measureDate, double rainfallMM) {
        this.logID = logID;
        this.stationID = stationID;
        this.measureDate = measureDate;
        this.rainfallMM = rainfallMM;
    }

    public int getLogID() {
        return logID;
    }

    public void setLogID(int logID) {
        this.logID = logID;
    }

    public int getStationID() {
        return stationID;
    }

    public void setStationID(int stationID) {
        this.stationID = stationID;
    }

    public Date getMeasureDate() {
        return measureDate;
    }

    public void setMeasureDate(Date measureDate) {
        this.measureDate = measureDate;
    }

    public double getRainfallMM() {
        return rainfallMM;
    }

    public void setRainfallMM(double rainfallMM) {
        this.rainfallMM = rainfallMM;
    }
}
