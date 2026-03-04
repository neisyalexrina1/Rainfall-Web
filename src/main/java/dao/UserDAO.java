package dao;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;
import model.User;

public class UserDAO extends BaseDAO {

    public User login(String username, String password) {
        EntityManager em = getEntityManager();
        try {
            TypedQuery<User> q = em.createQuery(
                    "SELECT u FROM User u WHERE u.username = :username AND u.passwordHash = :password", User.class);
            q.setParameter("username", username);
            q.setParameter("password", password);
            List<User> results = q.getResultList();
            return results.isEmpty() ? null : results.get(0);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        } finally {
            em.close();
        }
    }

    public boolean register(String username, String password, String email) {
        EntityManager em = getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            User user = new User();
            user.setUsername(username);
            user.setPasswordHash(password);
            user.setEmail(email);
            user.setRole("Customer");
            user.setTier("Free");
            em.persist(user);
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

    public User getUserById(int userId) {
        EntityManager em = getEntityManager();
        try {
            return em.find(User.class, userId);
        } finally {
            em.close();
        }
    }

    public List<User> getAllUsers() {
        EntityManager em = getEntityManager();
        try {
            return em.createQuery("SELECT u FROM User u", User.class).getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        } finally {
            em.close();
        }
    }

    public boolean updateUserRoleAndTier(int userId, String role, String tier, Date expiryDate) {
        EntityManager em = getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            User user = em.find(User.class, userId);
            if (user == null)
                return false;
            user.setRole(role);
            user.setTier(tier);
            user.setExpiryDate(expiryDate);
            em.merge(user);
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

    public boolean updateUserTier(int userId, String tier, Date expiryDate) {
        EntityManager em = getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            User user = em.find(User.class, userId);
            if (user == null)
                return false;
            user.setTier(tier);
            user.setExpiryDate(expiryDate);
            em.merge(user);
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

    public boolean updateProfileImage(int userId, String imageUrl) {
        EntityManager em = getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            User user = em.find(User.class, userId);
            if (user == null)
                return false;
            user.setProfileImage(imageUrl);
            em.merge(user);
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

    public User findByUsername(String username) {
        EntityManager em = getEntityManager();
        try {
            TypedQuery<User> q = em.createQuery(
                    "SELECT u FROM User u WHERE u.username = :username", User.class);
            q.setParameter("username", username);
            List<User> results = q.getResultList();
            return results.isEmpty() ? null : results.get(0);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        } finally {
            em.close();
        }
    }

    public User findByEmail(String email) {
        EntityManager em = getEntityManager();
        try {
            TypedQuery<User> q = em.createQuery(
                    "SELECT u FROM User u WHERE u.email = :email", User.class);
            q.setParameter("email", email);
            List<User> results = q.getResultList();
            return results.isEmpty() ? null : results.get(0);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        } finally {
            em.close();
        }
    }

    public boolean updatePassword(int userId, String newPassword) {
        EntityManager em = getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            User user = em.find(User.class, userId);
            if (user == null)
                return false;
            user.setPasswordHash(newPassword);
            em.merge(user);
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

    public boolean createUserAdmin(String username, String password, String email, String role, String tier) {
        EntityManager em = getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            User user = new User();
            user.setUsername(username);
            user.setPasswordHash(password);
            user.setEmail(email);
            user.setRole(role);
            user.setTier(tier);
            em.persist(user);
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

    public boolean updateUserFull(int userId, String username, String email, String role, String tier,
            Date expiryDate) {
        EntityManager em = getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            User user = em.find(User.class, userId);
            if (user == null)
                return false;
            user.setUsername(username);
            user.setEmail(email);
            user.setRole(role);
            user.setTier(tier);
            user.setExpiryDate(expiryDate);
            em.merge(user);
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

    public boolean deleteUser(int userId) {
        EntityManager em = getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            User user = em.find(User.class, userId);
            if (user != null) {
                em.remove(user);
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
