package service;

import model.Order;
import java.util.List;

public interface OrderService {
    boolean createOrder(int userId, double amount, String status, String transactionCode);

    boolean updateOrderStatusByTransactionCode(String transactionCode, String status);

    List<Order> getAllOrders();

    // VNPay payment methods
    boolean createPendingOrder(int userId, double amount, int packageId, String paymentReference);

    Order getOrderByReference(String reference);

    /** Trả về: "success", "already_completed", "not_found", "error" */
    String confirmOrderByReference(String reference);
}
