package dao;

import jakarta.persistence.EntityManager;

public class BaseDAO {

    protected EntityManager getEntityManager() {
        return JPAUtil.getEntityManager();
    }
}
