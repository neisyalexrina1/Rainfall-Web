package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import service.EmailService;
import service.UserService;
import service.UserServiceImpl;

import java.io.IOException;
import java.security.SecureRandom;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Handles the forgot-password / OTP verification / password reset flow.
 *
 * Actions (POST):
 * send_otp – look up email, generate OTP, e-mail it, store in session
 * verify_otp – compare OTP, advance to reset form
 * reset_password – validate & update password in DB
 */
@WebServlet("/PasswordResetServlet")
public class PasswordResetServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(PasswordResetServlet.class.getName());
    private static final int OTP_EXPIRY_MS = 10 * 60 * 1000; // 10 minutes

    private UserService userService;
    private EmailService emailService;

    @Override
    public void init() {
        userService = new UserServiceImpl();
        emailService = new EmailService();
    }

    /** GET – shows the forgot-password page */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("forgot_password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        HttpSession session = request.getSession();

        // ── Step 1: User submits email ────────────────────────────────────
        if ("send_otp".equals(action)) {
            String email = request.getParameter("email");
            if (email == null || email.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Please enter your email address.");
                request.getRequestDispatcher("forgot_password.jsp").forward(request, response);
                return;
            }

            User user = userService.findByEmail(email.trim());
            if (user == null) {
                request.setAttribute("errorMessage", "No account found with that email address.");
                request.getRequestDispatcher("forgot_password.jsp").forward(request, response);
                return;
            }

            // Generate 6-digit OTP
            String otp = String.format("%06d", new SecureRandom().nextInt(1_000_000));

            // Store OTP + metadata in session
            session.setAttribute("resetOtp", otp);
            session.setAttribute("resetOtpExpiry", System.currentTimeMillis() + OTP_EXPIRY_MS);
            session.setAttribute("resetUserId", user.getUserID());
            session.setAttribute("resetUsername", user.getUsername());
            session.setAttribute("resetEmail", user.getEmail());

            // Send OTP email
            try {
                emailService.sendPasswordResetOtp(user.getEmail(), user.getUsername(), otp);
            } catch (Exception ex) {
                LOG.log(Level.WARNING, "Failed to send OTP email", ex);
                request.setAttribute("errorMessage",
                        "Could not send email. Please check your address or try again later.");
                request.getRequestDispatcher("forgot_password.jsp").forward(request, response);
                return;
            }

            // Advance to OTP entry page
            request.setAttribute("otpSent", true);
            request.setAttribute("maskedEmail", maskEmail(user.getEmail()));
            request.getRequestDispatcher("forgot_password.jsp").forward(request, response);
            return;
        }

        // ── Step 2: User submits OTP ──────────────────────────────────────
        if ("verify_otp".equals(action)) {
            String enteredOtp = request.getParameter("otp");
            String storedOtp = (String) session.getAttribute("resetOtp");
            Long expiry = (Long) session.getAttribute("resetOtpExpiry");

            if (storedOtp == null || expiry == null) {
                request.setAttribute("errorMessage", "Session expired. Please request a new code.");
                request.getRequestDispatcher("forgot_password.jsp").forward(request, response);
                return;
            }
            if (System.currentTimeMillis() > expiry) {
                session.removeAttribute("resetOtp");
                request.setAttribute("errorMessage", "Your code has expired. Please request a new one.");
                request.getRequestDispatcher("forgot_password.jsp").forward(request, response);
                return;
            }
            if (!storedOtp.equals(enteredOtp)) {
                request.setAttribute("errorMessage", "Invalid code. Please try again.");
                request.setAttribute("otpSent", true);
                request.setAttribute("maskedEmail", maskEmail((String) session.getAttribute("resetEmail")));
                request.getRequestDispatcher("forgot_password.jsp").forward(request, response);
                return;
            }

            // OTP verified — clear OTP from session (prevent reuse)
            session.removeAttribute("resetOtp");
            session.removeAttribute("resetOtpExpiry");
            session.setAttribute("otpVerified", true);
            request.getRequestDispatcher("reset_password.jsp").forward(request, response);
            return;
        }

        // ── Step 3: User submits new password ─────────────────────────────
        if ("reset_password".equals(action)) {
            Boolean verified = (Boolean) session.getAttribute("otpVerified");
            if (verified == null || !verified) {
                response.sendRedirect("PasswordResetServlet");
                return;
            }

            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");
            Integer userId = (Integer) session.getAttribute("resetUserId");

            if (newPassword == null || newPassword.trim().length() < 4) {
                request.setAttribute("errorMessage", "Password must be at least 4 characters.");
                request.getRequestDispatcher("reset_password.jsp").forward(request, response);
                return;
            }
            if (!newPassword.equals(confirmPassword)) {
                request.setAttribute("errorMessage", "Passwords do not match.");
                request.getRequestDispatcher("reset_password.jsp").forward(request, response);
                return;
            }

            boolean updated = userService.updatePassword(userId, newPassword);
            if (!updated) {
                request.setAttribute("errorMessage", "Failed to update password. Please try again.");
                request.getRequestDispatcher("reset_password.jsp").forward(request, response);
                return;
            }

            // Cleanup session reset state
            session.removeAttribute("resetOtp");
            session.removeAttribute("resetOtpExpiry");
            session.removeAttribute("resetUserId");
            session.removeAttribute("resetUsername");
            session.removeAttribute("resetEmail");
            session.removeAttribute("otpVerified");

            request.setAttribute("successMessage", "Your password has been reset successfully!");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }

    /** Masks email for display: e.g. go***@gmail.com */
    private String maskEmail(String email) {
        if (email == null)
            return "";
        int at = email.indexOf('@');
        if (at <= 2)
            return email;
        return email.substring(0, 2) + "***" + email.substring(at);
    }
}
