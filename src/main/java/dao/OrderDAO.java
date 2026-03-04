package dao;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;
import java.util.ArrayList;
import java.util.List;
import model.Order;

public class OrderDAO extends BaseDAO {

    /** Tạo đơn hàng cũ (backward compat) */
    public boolean createOrder(int userId, double amount, String status, String transactionCode) {
        EntityManager em = getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Order order = new Order();
            order.setUserID(userId);
            order.setAmount(amount);
            order.setStatus(status);
            order.setTransactionCode(transactionCode);
            em.persist(order);
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

    /**
     * Tạo đơn hàng Pending cho luồng VNPay.
     */
    public boolean createPendingOrder(int userId, double amount, int packageId, String paymentReference) {
        EntityManager em = getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Order order = new Order();
            order.setUserID(userId);
            order.setAmount(amount);
            order.setStatus("Pending");
            order.setTransactionCode(paymentReference);
            order.setPackageId(packageId);
            order.setPaymentReference(paymentReference);
            em.persist(order);
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

    /**
     * Tìm đơn hàng theo PaymentReference hoặc TransactionCode.
     */
    public Order getOrderByReference(String reference) {
        EntityManager em = getEntityManager();
        try {
            // Tìm theo PaymentReference trước
            TypedQuery<Order> q = em.createQuery(
                    "SELECT o FROM Order o WHERE o.paymentReference = :ref", Order.class);
            q.setParameter("ref", reference);
            List<Order> results = q.getResultList();
            if (!results.isEmpty())
                return results.get(0);

            // Fallback: tìm theo TransactionCode
            q = em.createQuery(
                    "SELECT o FROM Order o WHERE o.transactionCode = :ref AND o.status = 'Pending'", Order.class);
            q.setParameter("ref", reference);
            results = q.getResultList();
            return results.isEmpty() ? null : results.get(0);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        } finally {
            em.close();
        }
    }

    /**
     * Xác nhận đơn hàng: chỉ Pending mới được mark Completed.
     * Trả về: "success", "already_completed", "not_found", "error"
     */
    public String confirmOrderByReference(String reference) {
        Order order = getOrderByReference(reference);
        if (order == null)
            return "not_found";
        if ("Completed".equalsIgnoreCase(order.getStatus()))
            return "already_completed";
        if (!"Pending".equalsIgnoreCase(order.getStatus()))
            return "error";

        EntityManager em = getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Order managed = em.find(Order.class, order.getOrderID());
            if (managed == null)
                return "not_found";
            managed.setStatus("Completed");
            em.merge(managed);
            tx.commit();
            return "success";
        } catch (Exception e) {
            if (tx.isActive())
                tx.rollback();
            e.printStackTrace();
            return "error";
        } finally {
            em.close();
        }
    }

    public boolean updateOrderStatusByTransactionCode(String transactionCode, String status) {
        EntityManager em = getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            TypedQuery<Order> q = em.createQuery(
                    "SELECT o FROM Order o WHERE o.transactionCode = :tc", Order.class);
            q.setParameter("tc", transactionCode);
            List<Order> results = q.getResultList();
            if (results.isEmpty())
                return false;
            Order order = results.get(0);
            order.setStatus(status);
            em.merge(order);
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

    public List<Order> getAllOrders() {
        EntityManager em = getEntityManager();
        try {
            return em.createQuery("SELECT o FROM Order o ORDER BY o.orderDate DESC", Order.class)
                    .getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        } finally {
            em.close();
        }
    }
}
