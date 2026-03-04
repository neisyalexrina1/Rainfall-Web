package service;

import model.ForecastLog;
import java.util.List;

public interface ForecastService {
    boolean saveForecast(int stationId, String forecastMonth, double predictedRainfall, String riskLevel);

    List<ForecastLog> getForecastLogs();

    ForecastLog getLatestForecast(int stationId);

    boolean deleteForecastLog(int forecastId);
}
