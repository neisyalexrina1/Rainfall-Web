package model;

import jakarta.persistence.*;
import java.sql.Timestamp;

@Entity
@Table(name = "Orders")
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "OrderID")
    private int orderID;

    @Column(name = "UserID")
    private int userID;

    @Column(name = "OrderDate", insertable = false, updatable = false)
    private Timestamp orderDate;

    @Column(name = "Amount")
    private double amount;

    @Column(name = "Status", length = 20)
    private String status;

    @Column(name = "TransactionCode", unique = true, length = 50)
    private String transactionCode;

    @Column(name = "PackageID")
    private Integer packageId;

    @Transient
    private String packageName; // not in DB

    @Column(name = "PaymentReference", length = 50)
    private String paymentReference;

    public Order() {
    }

    public Order(int orderID, int userID, Timestamp orderDate, double amount, String status, String transactionCode) {
        this.orderID = orderID;
        this.userID = userID;
        this.orderDate = orderDate;
        this.amount = amount;
        this.status = status;
        this.transactionCode = transactionCode;
    }

    public int getOrderID() {
        return orderID;
    }

    public void setOrderID(int orderID) {
        this.orderID = orderID;
    }

    public int getUserID() {
        return userID;
    }

    public void setUserID(int userID) {
        this.userID = userID;
    }

    public Timestamp getOrderDate() {
        return orderDate;
    }

    public void setOrderDate(Timestamp orderDate) {
        this.orderDate = orderDate;
    }

    public double getAmount() {
        return amount;
    }

    public void setAmount(double amount) {
        this.amount = amount;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getTransactionCode() {
        return transactionCode;
    }

    public void setTransactionCode(String transactionCode) {
        this.transactionCode = transactionCode;
    }

    public int getPackageId() {
        return packageId != null ? packageId : 0;
    }

    public void setPackageId(int packageId) {
        this.packageId = packageId;
    }

    public String getPackageName() {
        return packageName;
    }

    public void setPackageName(String packageName) {
        this.packageName = packageName;
    }

    public String getPaymentReference() {
        return paymentReference;
    }

    public void setPaymentReference(String paymentReference) {
        this.paymentReference = paymentReference;
    }
}
