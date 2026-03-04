package dao;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import java.util.ArrayList;
import java.util.List;
import model.Station;

public class StationDAO extends BaseDAO {

    public List<Station> getAllStations() {
        EntityManager em = getEntityManager();
        try {
            return em.createQuery("SELECT s FROM Station s", Station.class).getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        } finally {
            em.close();
        }
    }

    public Station getStationById(int id) {
        EntityManager em = getEntityManager();
        try {
            return em.find(Station.class, id);
        } finally {
            em.close();
        }
    }

    public boolean updateStation(int id, String name, String region) {
        EntityManager em = getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Station station = em.find(Station.class, id);
            if (station == null)
                return false;
            station.setStationName(name);
            station.setRegion(region);
            em.merge(station);
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

    public boolean createStation(int id, String name, String region) {
        EntityManager em = getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            // Check if exists
            if (em.find(Station.class, id) != null)
                return false;

            Station station = new Station();
            station.setStationID(id);
            station.setStationName(name);
            station.setRegion(region);
            em.persist(station);
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

    public boolean deleteStation(int id) {
        EntityManager em = getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Station station = em.find(Station.class, id);
            if (station != null) {
                em.remove(station);
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
