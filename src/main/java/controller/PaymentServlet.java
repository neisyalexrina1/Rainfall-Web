package controller;

import model.Order;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import service.EmailService;
import service.OrderService;
import service.OrderServiceImpl;
import service.UserService;
import service.UserServiceImpl;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Date;
import java.util.Calendar;
import java.util.UUID;

/**
 * PaymentServlet – VNPay mock transfer (full DB integration)
 *
 * GET /PaymentServlet?packageId=2 → tạo Pending order trong DB → redirect
 * payment_vnpay.jsp
 * POST /PaymentServlet?action=confirm → xác nhận đơn → cập nhật DB → JSON
 * response
 */
@WebServlet("/PaymentServlet")
public class PaymentServlet extends HttpServlet {

    private final OrderService orderService = new OrderServiceImpl();
    private final UserService userService = new UserServiceImpl();
    private final EmailService emailService = new EmailService();

    // ――― GET: Khởi tạo đơn hàng Pending trong DB ―――――――――――――――――――
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");

        // Admin should never access payment — redirect to admin dashboard
        if ("Admin".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect("AdminServlet?action=dashboard");
            return;
        }

        // Nếu đã là Pro còn hạn thì không cần nạp nữa
        if ("Pro".equalsIgnoreCase(user.getTier())
                && user.getExpiryDate() != null
                && user.getExpiryDate().after(new java.util.Date())) {
            response.sendRedirect("DashboardServlet?info=already_pro");
            return;
        }

        String packageIdStr = request.getParameter("packageId");
        int packageId = 2; // mặc định Pro Monthly
        try {
            packageId = Integer.parseInt(packageIdStr);
        } catch (Exception ignored) {
        }

        double amount = (packageId == 3) ? 500000 : 50000;
        String packageName = (packageId == 3) ? "Pro Yearly" : "Pro Monthly";

        // Sinh mã nội dung chuyển khoản duy nhất
        String ref = "RA" + Calendar.getInstance().get(Calendar.YEAR)
                + UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase();

        // Tạo đơn hàng Pending trong DB
        try {
            boolean created = orderService.createPendingOrder(user.getUserID(), amount, packageId, ref);
            if (!created) {
                System.err.println("[PaymentServlet] Failed to create pending order for ref=" + ref);
            }
        } catch (Exception e) {
            System.err.println("[PaymentServlet] Error creating pending order: " + e.getMessage());
        }

        System.out.println("[PaymentServlet] doGet → ref=" + ref + ", pkg=" + packageId + ", user=" + user.getUserID());

        response.sendRedirect("payment_vnpay.jsp?ref=" + ref
                + "&pkg=" + packageId
                + "&name=" + java.net.URLEncoder.encode(packageName, "UTF-8")
                + "&amount=" + (long) amount);
    }

    // ――― POST: Xác nhận thanh toán ――――――――――――――――――――――――――――――――
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("confirm".equals(action)) {
            handleConfirm(request, response);
        } else {
            // Backward compat: redirect về GET để tạo đơn hàng
            String packageId = request.getParameter("packageId");
            response.sendRedirect("PaymentServlet?packageId=" + (packageId != null ? packageId : "2"));
        }
    }

    /**
     * POST /PaymentServlet?action=confirm&ref=RA2026XXXXXX
     * 
     * 1. Gọi confirmOrderByReference → cập nhật đơn hàng sang Completed trong DB
     * 2. Nâng tier user trong DB
     * 3. Cập nhật session
     * 4. Trả JSON {"result":"success"}
     */
    private void handleConfirm(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            out.print("{\"result\":\"not_logged_in\"}");
            return;
        }

        String ref = request.getParameter("ref");
        if (ref == null || ref.trim().isEmpty()) {
            out.print("{\"result\":\"error\",\"msg\":\"Missing reference\"}");
            return;
        }

        User user = (User) session.getAttribute("user");
        System.out.println("[PaymentServlet] handleConfirm → ref=" + ref + ", user=" + user.getUserID());

        try {
            // 1. Xác nhận đơn hàng trong DB (chuyển status sang Completed)
            String confirmResult = orderService.confirmOrderByReference(ref);
            System.out.println("[PaymentServlet] confirmOrderByReference result: " + confirmResult);

            // 2. Lấy thông tin đơn hàng để biết packageId
            int durationMonths = 1; // mặc định
            try {
                Order order = orderService.getOrderByReference(ref);
                if (order != null) {
                    int packageId = order.getPackageId();
                    if (packageId == 0) {
                        packageId = (order.getAmount() >= 500000) ? 3 : 2;
                    }
                    durationMonths = (packageId == 3) ? 12 : 1;
                }
            } catch (Exception e) {
                System.err.println("[PaymentServlet] Error getting order info: " + e.getMessage());
                // Mặc định 1 tháng nếu không lấy được order
            }

            // 3. Nâng tier user trong DB
            Calendar cal = Calendar.getInstance();
            if (user.getExpiryDate() != null && user.getExpiryDate().after(new java.util.Date())) {
                cal.setTime(user.getExpiryDate());
            }
            cal.add(Calendar.MONTH, durationMonths);
            Date newExpiry = new Date(cal.getTimeInMillis());

            try {
                userService.updateUserTier(user.getUserID(), "Pro", newExpiry);
                System.out.println("[PaymentServlet] Updated user tier in DB → Pro, expiry=" + newExpiry);
            } catch (Exception e) {
                System.err.println("[PaymentServlet] Error updating user tier in DB: " + e.getMessage());
                // Vẫn cập nhật session dù DB tier update fail
            }

            // 4. Cập nhật session
            user.setTier("Pro");
            user.setExpiryDate(newExpiry);
            session.setAttribute("user", user);

            // 5. Gửi email biên lai thanh toán (background thread)
            final String finalRef = ref;
            final Date finalExpiry = newExpiry;
            final int finalDuration = durationMonths;
            final String uname = user.getUsername();
            final String uemail = user.getEmail();
            new Thread(() -> {
                try {
                    String pkgName = (finalDuration == 12) ? "Pro Yearly" : "Pro Monthly";
                    double amt = (finalDuration == 12) ? 500000 : 50000;
                    emailService.sendPaymentReceipt(uemail, uname, pkgName, amt, finalRef, finalExpiry.toString());
                    System.out.println("[PaymentServlet] Receipt email sent to " + uemail);
                } catch (Exception ex) {
                    System.err.println("[PaymentServlet] Failed to send receipt email: " + ex.getMessage());
                }
            }).start();

            out.print("{\"result\":\"success\",\"expiry\":\"" + newExpiry + "\"}");
            System.out.println("[PaymentServlet] Payment success → expiry=" + newExpiry);

        } catch (Exception e) {
            System.err.println("[PaymentServlet] Unexpected error in handleConfirm: " + e.getMessage());
            e.printStackTrace();

            // Dù lỗi gì cũng vẫn nâng cấp Pro trong session (mock)
            Calendar cal = Calendar.getInstance();
            cal.add(Calendar.MONTH, 1);
            Date newExpiry = new Date(cal.getTimeInMillis());
            user.setTier("Pro");
            user.setExpiryDate(newExpiry);
            session.setAttribute("user", user);

            out.print("{\"result\":\"success\",\"expiry\":\"" + newExpiry + "\"}");
        }
    }
}
