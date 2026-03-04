package model;

import jakarta.persistence.*;

@Entity
@Table(name = "Stations")
public class Station {

    @Id
    @Column(name = "StationID")
    private int stationID;

    @Column(name = "StationName", nullable = false, length = 100)
    private String stationName;

    @Column(name = "Region", nullable = false, length = 50)
    private String region;

    public Station() {
    }

    public Station(int stationID, String stationName, String region) {
        this.stationID = stationID;
        this.stationName = stationName;
        this.region = region;
    }

    public int getStationID() {
        return stationID;
    }

    public void setStationID(int stationID) {
        this.stationID = stationID;
    }

    public String getStationName() {
        return stationName;
    }

    public void setStationName(String stationName) {
        this.stationName = stationName;
    }

    public String getRegion() {
        return region;
    }

    public void setRegion(String region) {
        this.region = region;
    }
}
