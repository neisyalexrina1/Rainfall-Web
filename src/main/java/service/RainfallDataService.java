package service;

import model.RainfallData;
import java.sql.Date;
import java.util.List;

public interface RainfallDataService {
    List<RainfallData> getRainfallByStationId(int stationId);

    List<RainfallData> getAllRainfallData();

    boolean insertRainfallData(int stationId, Date measureDate, double rainfallMM);
}
