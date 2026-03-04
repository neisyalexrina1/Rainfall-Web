package dao;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;
import java.util.ArrayList;
import java.util.List;
import model.ForecastLog;

public class ForecastDAO extends BaseDAO {

    public boolean saveForecast(int stationId, String forecastMonth, double predictedRainfall, String riskLevel) {
        EntityManager em = getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            ForecastLog log = new ForecastLog();
            log.setStationID(stationId);
            log.setForecastMonth(forecastMonth);
            log.setPredictedRainfall(predictedRainfall);
            log.setRiskLevel(riskLevel);
            em.persist(log);
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx.isActive())
                tx.rollback();
            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }

    public List<ForecastLog> getForecastLogs() {
        EntityManager em = getEntityManager();
        try {
            return em.createQuery("SELECT f FROM ForecastLog f", ForecastLog.class)
                    .getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        } finally {
            em.close();
        }
    }

    public ForecastLog getLatestForecast(int stationId) {
        EntityManager em = getEntityManager();
        try {
            TypedQuery<ForecastLog> q = em.createQuery(
                    "SELECT f FROM ForecastLog f WHERE f.stationID = :stationId ORDER BY f.createdAt DESC",
                    ForecastLog.class);
            q.setParameter("stationId", stationId);
            q.setMaxResults(1);
            List<ForecastLog> results = q.getResultList();
            return results.isEmpty() ? null : results.get(0);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        } finally {
            em.close();
        }
    }

    public boolean deleteForecastLog(int forecastId) {
        EntityManager em = getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            ForecastLog log = em.find(ForecastLog.class, forecastId);
            if (log != null) {
                em.remove(log);
                tx.commit();
                return true;
            }
            tx.rollback();
            return false;
        } catch (Exception e) {
            if (tx.isActive())
                tx.rollback();
            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }
}
