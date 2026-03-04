package dao;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;
import model.RainfallData;

public class RainfallDataDAO extends BaseDAO {

    public List<RainfallData> getRainfallByStationId(int stationId) {
        EntityManager em = getEntityManager();
        try {
            TypedQuery<RainfallData> q = em.createQuery(
                    "SELECT r FROM RainfallData r WHERE r.stationID = :stationId",
                    RainfallData.class);
            q.setParameter("stationId", stationId);
            return q.getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        } finally {
            em.close();
        }
    }

    public List<RainfallData> getAllRainfallData() {
        EntityManager em = getEntityManager();
        try {
            return em.createQuery("SELECT r FROM RainfallData r", RainfallData.class)
                    .getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        } finally {
            em.close();
        }
    }

    public boolean insertRainfallData(int stationId, Date measureDate, double rainfallMM) {
        EntityManager em = getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            RainfallData data = new RainfallData();
            data.setStationID(stationId);
            data.setMeasureDate(measureDate);
            data.setRainfallMM(rainfallMM);
            em.persist(data);
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
}
