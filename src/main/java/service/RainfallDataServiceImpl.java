package service;

import dao.RainfallDataDAO;
import model.RainfallData;
import java.sql.Date;
import java.util.List;

public class RainfallDataServiceImpl implements RainfallDataService {

    private final RainfallDataDAO rainfallDataDAO;

    public RainfallDataServiceImpl() {
        this.rainfallDataDAO = new RainfallDataDAO();
    }

    @Override
    public List<RainfallData> getRainfallByStationId(int stationId) {
        return rainfallDataDAO.getRainfallByStationId(stationId);
    }

    @Override
    public List<RainfallData> getAllRainfallData() {
        return rainfallDataDAO.getAllRainfallData();
    }

    @Override
    public boolean insertRainfallData(int stationId, Date measureDate, double rainfallMM) {
        if (measureDate == null) {
            throw new ValidationException("Measure date cannot be null");
        }
        if (rainfallMM < 0) {
            throw new ValidationException("Rainfall value cannot be negative");
        }
        return rainfallDataDAO.insertRainfallData(stationId, measureDate, rainfallMM);
    }
}
