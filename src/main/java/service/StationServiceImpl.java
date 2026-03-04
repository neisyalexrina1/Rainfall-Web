package service;

import dao.StationDAO;
import model.Station;
import java.util.List;

public class StationServiceImpl implements StationService {

    private final StationDAO stationDAO;

    public StationServiceImpl() {
        this.stationDAO = new StationDAO();
    }

    @Override
    public List<Station> getAllStations() {
        return stationDAO.getAllStations();
    }

    @Override
    public Station getStationById(int id) {
        return stationDAO.getStationById(id);
    }

    @Override
    public boolean updateStation(int id, String name, String region) {
        if (name == null || name.trim().isEmpty()) {
            throw new ValidationException("Station name cannot be empty");
        }
        if (region == null || region.trim().isEmpty()) {
            throw new ValidationException("Region cannot be empty");
        }
        return stationDAO.updateStation(id, name, region);
    }

    @Override
    public boolean createStation(int id, String name, String region) {
        if (name == null || name.trim().isEmpty())
            throw new ValidationException("Station name cannot be empty");
        if (region == null || region.trim().isEmpty())
            throw new ValidationException("Region cannot be empty");
        return stationDAO.createStation(id, name, region);
    }

    @Override
    public boolean deleteStation(int id) {
        return stationDAO.deleteStation(id);
    }
}
