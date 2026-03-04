package service;

import model.Station;
import java.util.List;

public interface StationService {
    List<Station> getAllStations();

    Station getStationById(int id);

    boolean updateStation(int id, String name, String region);

    boolean createStation(int id, String name, String region);

    boolean deleteStation(int id);
}
