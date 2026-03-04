package dao;

import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;
import java.util.ArrayList;
import java.util.List;
import model.ServicePackage;

public class ServicePackageDAO extends BaseDAO {

    public List<ServicePackage> getAllPackages() {
        EntityManager em = getEntityManager();
        try {
            return em.createQuery("SELECT sp FROM ServicePackage sp ORDER BY sp.price ASC", ServicePackage.class)
                    .getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        } finally {
            em.close();
        }
    }

    public ServicePackage getPackageById(int id) {
        EntityManager em = getEntityManager();
        try {
            return em.find(ServicePackage.class, id);
        } finally {
            em.close();
        }
    }
}
