package service;

import dao.OrderDAO;
import model.Order;
import java.util.List;

public class OrderServiceImpl implements OrderService {

    private final OrderDAO orderDAO;

    public OrderServiceImpl() {
        this.orderDAO = new OrderDAO();
    }

    @Override
    public boolean createOrder(int userId, double amount, String status, String transactionCode) {
        if (amount <= 0)
            throw new ValidationException("Order amount must be greater than zero");
        if (transactionCode == null || transactionCode.trim().isEmpty())
            throw new ValidationException("Transaction code cannot be empty");
        return orderDAO.createOrder(userId, amount, status, transactionCode);
    }

    @Override
    public boolean updateOrderStatusByTransactionCode(String transactionCode, String status) {
        if (transactionCode == null || transactionCode.trim().isEmpty())
            throw new ValidationException("Transaction code cannot be empty");
        if (status == null || status.trim().isEmpty())
            throw new ValidationException("Status cannot be empty");
        return orderDAO.updateOrderStatusByTransactionCode(transactionCode, status);
    }

    @Override
    public List<Order> getAllOrders() {
        return orderDAO.getAllOrders();
    }

    @Override
    public boolean createPendingOrder(int userId, double amount, int packageId, String paymentReference) {
        if (amount <= 0)
            throw new ValidationException("Order amount must be greater than zero");
        if (paymentReference == null || paymentReference.trim().isEmpty())
            throw new ValidationException("Payment reference cannot be empty");
        return orderDAO.createPendingOrder(userId, amount, packageId, paymentReference);
    }

    @Override
    public Order getOrderByReference(String reference) {
        if (reference == null || reference.trim().isEmpty())
            return null;
        return orderDAO.getOrderByReference(reference);
    }

    @Override
    public String confirmOrderByReference(String reference) {
        if (reference == null || reference.trim().isEmpty())
            return "error";
        return orderDAO.confirmOrderByReference(reference);
    }
}
