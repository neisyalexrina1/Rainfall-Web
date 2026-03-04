package service;

import dao.ForecastDAO;
import model.ForecastLog;
import java.util.List;

public class ForecastServiceImpl implements ForecastService {

    private final ForecastDAO forecastDAO;

    public ForecastServiceImpl() {
        this.forecastDAO = new ForecastDAO();
    }

    @Override
    public boolean saveForecast(int stationId, String forecastMonth, double predictedRainfall, String riskLevel) {
        if (predictedRainfall < 0) {
            throw new ValidationException("Predicted rainfall cannot be negative");
        }
        return forecastDAO.saveForecast(stationId, forecastMonth, predictedRainfall, riskLevel);
    }

    @Override
    public List<ForecastLog> getForecastLogs() {
        return forecastDAO.getForecastLogs();
    }

    @Override
    public ForecastLog getLatestForecast(int stationId) {
        return forecastDAO.getLatestForecast(stationId);
    }

    @Override
    public boolean deleteForecastLog(int forecastId) {
        return forecastDAO.deleteForecastLog(forecastId);
    }
}
