package controller;

import service.EmailService;
import service.UserService;
import service.UserServiceImpl;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.security.SecureRandom;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/AuthServlet")
public class AuthServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(AuthServlet.class.getName());
    private static final int OTP_EXPIRY_MS = 10 * 60 * 1000; // 10 minutes

    // ── Session policy ─────────────────────────────────────────────────────────
    // Set to 2 minutes (120 seconds) for DEMO/TESTING.
    // Change to 86400 (1 day) for PRODUCTION.
    private static final int SESSION_VALID_SECONDS = 86400; // 2 minutes for demo

    // Cookie name that tracks the last verified login timestamp (for Remember Me)
    private static final String REMEMBER_COOKIE = "rainfall_rm";
    // Remember Me duration: 30 days
    private static final int REMEMBER_MAX_AGE = 30 * 24 * 3600;

    private final UserService userService = new UserServiceImpl();
    private final EmailService emailService = new EmailService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("logout".equals(action)) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            // On logout, clear the Remember Me cookie too
            Cookie rmCookie = new Cookie(REMEMBER_COOKIE, "");
            rmCookie.setMaxAge(0);
            rmCookie.setPath("/");
            response.addCookie(rmCookie);
            response.sendRedirect("index.jsp");
        } else {
            response.sendRedirect("login.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("login".equals(action)) {
            handleLogin(request, response);
        } else if ("register".equals(action)) {
            handleRegisterStep1(request, response);
        } else if ("verify_register_otp".equals(action)) {
            handleRegisterStep2(request, response);
        } else if ("resend_register_otp".equals(action)) {
            handleResendRegisterOtp(request, response);
        } else if ("verify_login_otp".equals(action)) {
            handleVerifyLoginOtp(request, response);
        } else if ("resend_login_otp".equals(action)) {
            handleResendLoginOtp(request, response);
        }
    }

    // ── Login ─────────────────────────────────────────────────────────────────
    private void handleLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String uname = request.getParameter("username");
        String pass = request.getParameter("password");
        boolean rememberMe = "on".equals(request.getParameter("remember"));

        User user = userService.login(uname, pass);
        if (user == null) {
            request.setAttribute("errorMessage", "Tên đăng nhập hoặc mật khẩu không đúng.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        // ── Check if session is still valid ──────────────────────────────────
        // We trust the session if:
        // (a) The current HTTP session has a fresh "lastLoginTime" within
        // SESSION_VALID_SECONDS, OR
        // (b) The "Remember Me" cookie exists, is not expired, and matches this user
        boolean sessionOk = false;

        // (a) Check server-side session attribute
        HttpSession existingSession = request.getSession(false);
        if (existingSession != null) {
            Long lastLoginTime = (Long) existingSession.getAttribute("lastLoginTime");
            String sessionUser = (String) existingSession.getAttribute("lastLoginUser");
            if (lastLoginTime != null && uname.equals(sessionUser)) {
                long elapsedSeconds = (System.currentTimeMillis() - lastLoginTime) / 1000;
                if (elapsedSeconds <= SESSION_VALID_SECONDS) {
                    sessionOk = true;
                }
            }
        }

        // (b) Check Remember Me cookie
        if (!sessionOk) {
            Cookie[] cookies = request.getCookies();
            if (cookies != null) {
                for (Cookie c : cookies) {
                    if (REMEMBER_COOKIE.equals(c.getName())) {
                        // Cookie value format: "username:timestamp"
                        String val = c.getValue();
                        if (val != null && val.startsWith(uname + ":")) {
                            try {
                                long savedTs = Long.parseLong(val.split(":")[1]);
                                long elapsedSeconds = (System.currentTimeMillis() - savedTs) / 1000;
                                if (elapsedSeconds <= REMEMBER_MAX_AGE) {
                                    sessionOk = true;
                                }
                            } catch (NumberFormatException ignored) {
                            }
                        }
                        break;
                    }
                }
            }
        }

        if (sessionOk) {
            // Session still valid – log in directly without OTP
            completeLogin(request, response, user, rememberMe);
        } else {
            // Session expired or first login – require email OTP
            sendLoginOtpAndAwait(request, response, user, rememberMe);
        }
    }

    /** Sends login OTP and stores pending state in session. */
    private void sendLoginOtpAndAwait(HttpServletRequest request, HttpServletResponse response,
            User user, boolean rememberMe) throws ServletException, IOException {
        String otp = String.format("%06d", new SecureRandom().nextInt(1_000_000));

        HttpSession session = request.getSession();
        session.setAttribute("pendingLoginUser", user);
        session.setAttribute("pendingLoginRememberMe", rememberMe);
        session.setAttribute("loginOtp", otp);
        session.setAttribute("loginOtpExpiry", System.currentTimeMillis() + OTP_EXPIRY_MS);

        try {
            emailService.sendLoginOtp(user.getEmail(), user.getUsername(), otp);
        } catch (Exception ex) {
            LOG.log(Level.WARNING, "Failed to send login OTP email", ex);
            request.setAttribute("errorMessage", "Không thể gửi email xác nhận. Vui lòng thử lại.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        request.setAttribute("maskedEmail", maskEmail(user.getEmail()));
        request.setAttribute("loginUsername", user.getUsername());
        request.getRequestDispatcher("verifyLoginOtp.jsp").forward(request, response);
    }

    /**
     * Called after successful OTP verification – sets full session and optionally
     * Remember Me cookie.
     */
    private void completeLogin(HttpServletRequest request, HttpServletResponse response,
            User user, boolean rememberMe) throws IOException {
        HttpSession session = request.getSession();
        session.setAttribute("user", user);
        session.setAttribute("lastLoginTime", System.currentTimeMillis());
        session.setAttribute("lastLoginUser", user.getUsername());

        // Set Remember Me cookie if requested
        if (rememberMe) {
            String cookieVal = user.getUsername() + ":" + System.currentTimeMillis();
            Cookie rmCookie = new Cookie(REMEMBER_COOKIE, cookieVal);
            rmCookie.setMaxAge(REMEMBER_MAX_AGE);
            rmCookie.setPath("/");
            rmCookie.setHttpOnly(true);
            response.addCookie(rmCookie);
        }

        if ("Admin".equals(user.getRole())) {
            response.sendRedirect("AdminServlet?action=dashboard");
        } else {
            response.sendRedirect("DashboardServlet");
        }
    }

    // ── Verify Login OTP ───────────────────────────────────────────────────────
    private void handleVerifyLoginOtp(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String enteredOtp = request.getParameter("otp");

        if (session == null || session.getAttribute("loginOtp") == null) {
            request.setAttribute("errorMessage", "Phiên đã hết hạn. Vui lòng đăng nhập lại.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        String storedOtp = (String) session.getAttribute("loginOtp");
        Long expiry = (Long) session.getAttribute("loginOtpExpiry");
        User pendingUser = (User) session.getAttribute("pendingLoginUser");
        Boolean rememberMe = (Boolean) session.getAttribute("pendingLoginRememberMe");

        if (pendingUser == null) {
            request.setAttribute("errorMessage", "Phiên đã hết hạn. Vui lòng đăng nhập lại.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        // Check OTP expiry
        if (System.currentTimeMillis() > expiry) {
            session.removeAttribute("loginOtp");
            request.setAttribute("errorMessage", "Mã xác nhận đã hết hạn (10 phút). Vui lòng đăng nhập lại.");
            request.setAttribute("otpExpired", true);
            request.setAttribute("maskedEmail", maskEmail(pendingUser.getEmail()));
            request.setAttribute("loginUsername", pendingUser.getUsername());
            request.getRequestDispatcher("verifyLoginOtp.jsp").forward(request, response);
            return;
        }

        // Check OTP match
        if (!storedOtp.equals(enteredOtp != null ? enteredOtp.trim() : "")) {
            request.setAttribute("errorMessage", "Mã xác nhận không đúng. Vui lòng thử lại.");
            request.setAttribute("maskedEmail", maskEmail(pendingUser.getEmail()));
            request.setAttribute("loginUsername", pendingUser.getUsername());
            request.getRequestDispatcher("verifyLoginOtp.jsp").forward(request, response);
            return;
        }

        // OTP correct – clean up pending attributes
        session.removeAttribute("loginOtp");
        session.removeAttribute("loginOtpExpiry");
        session.removeAttribute("pendingLoginUser");
        session.removeAttribute("pendingLoginRememberMe");

        completeLogin(request, response, pendingUser, rememberMe != null && rememberMe);
    }

    // ── Resend Login OTP ───────────────────────────────────────────────────────
    private void handleResendLoginOtp(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("pendingLoginUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User pendingUser = (User) session.getAttribute("pendingLoginUser");
        String otp = String.format("%06d", new SecureRandom().nextInt(1_000_000));
        session.setAttribute("loginOtp", otp);
        session.setAttribute("loginOtpExpiry", System.currentTimeMillis() + OTP_EXPIRY_MS);

        try {
            emailService.sendLoginOtp(pendingUser.getEmail(), pendingUser.getUsername(), otp);
            request.setAttribute("successMessage", "Đã gửi lại mã xác nhận đến " + maskEmail(pendingUser.getEmail()));
        } catch (Exception ex) {
            LOG.log(Level.WARNING, "Failed to resend login OTP", ex);
            request.setAttribute("errorMessage", "Không thể gửi lại email. Vui lòng thử lại.");
        }

        request.setAttribute("maskedEmail", maskEmail(pendingUser.getEmail()));
        request.setAttribute("loginUsername", pendingUser.getUsername());
        request.getRequestDispatcher("verifyLoginOtp.jsp").forward(request, response);
    }

    // ── Register Step 1: Validate form, send OTP email ────────────────────────
    private void handleRegisterStep1(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String uname = request.getParameter("username");
        String pass = request.getParameter("password");
        String email = request.getParameter("email");

        // Basic validation
        if (uname == null || uname.trim().length() < 3) {
            request.setAttribute("errorMessage", "Tên đăng nhập phải có ít nhất 3 ký tự.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }
        if (pass == null || pass.trim().length() < 4) {
            request.setAttribute("errorMessage", "Mật khẩu phải có ít nhất 4 ký tự.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }
        if (email == null || !email.contains("@")) {
            request.setAttribute("errorMessage", "Vui lòng nhập địa chỉ email hợp lệ.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Check if username or email is already used
        if (userService.findByUsername(uname.trim()) != null) {
            request.setAttribute("errorMessage", "Tên đăng nhập đã tồn tại. Vui lòng chọn tên khác.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        if (userService.findByEmail(email.trim()) != null) {
            request.setAttribute("errorMessage", "Email này đã được sử dụng. Vui lòng dùng email khác.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Generate OTP
        String otp = String.format("%06d", new SecureRandom().nextInt(1_000_000));

        // Store pending registration data in session
        HttpSession session = request.getSession();
        session.setAttribute("pendingUsername", uname.trim());
        session.setAttribute("pendingPassword", pass);
        session.setAttribute("pendingEmail", email.trim());
        session.setAttribute("registerOtp", otp);
        session.setAttribute("registerOtpExpiry", System.currentTimeMillis() + OTP_EXPIRY_MS);

        // Send OTP email
        try {
            emailService.sendRegistrationOtp(email.trim(), uname.trim(), otp);
        } catch (Exception ex) {
            LOG.log(Level.WARNING, "Failed to send registration OTP email", ex);
            request.setAttribute("errorMessage", "Không thể gửi email xác nhận. Vui lòng thử lại.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Forward to OTP verification page
        request.setAttribute("maskedEmail", maskEmail(email.trim()));
        request.getRequestDispatcher("verifyEmail.jsp").forward(request, response);
    }

    // ── Register Step 2: Verify OTP and create account ────────────────────────
    private void handleRegisterStep2(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String enteredOtp = request.getParameter("otp");

        if (session == null || session.getAttribute("registerOtp") == null) {
            request.setAttribute("errorMessage", "Phiên đã hết hạn. Vui lòng đăng ký lại.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        String storedOtp = (String) session.getAttribute("registerOtp");
        Long expiry = (Long) session.getAttribute("registerOtpExpiry");
        String uname = (String) session.getAttribute("pendingUsername");
        String pass = (String) session.getAttribute("pendingPassword");
        String email = (String) session.getAttribute("pendingEmail");

        // Check expiry
        if (System.currentTimeMillis() > expiry) {
            session.removeAttribute("registerOtp");
            request.setAttribute("errorMessage", "Mã xác nhận đã hết hạn. Vui lòng đăng ký lại.");
            request.setAttribute("otpExpired", true);
            request.getRequestDispatcher("verifyEmail.jsp").forward(request, response);
            return;
        }

        // Check OTP match
        if (!storedOtp.equals(enteredOtp != null ? enteredOtp.trim() : "")) {
            request.setAttribute("errorMessage", "Mã xác nhận không đúng. Vui lòng thử lại.");
            request.setAttribute("maskedEmail", maskEmail(email));
            request.getRequestDispatcher("verifyEmail.jsp").forward(request, response);
            return;
        }

        // OTP correct → create account
        boolean success = userService.register(uname, pass, email);
        if (!success) {
            request.setAttribute("errorMessage", "Đăng ký thất bại. Tên đăng nhập có thể đã tồn tại.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Clean up session OTP data
        session.removeAttribute("registerOtp");
        session.removeAttribute("registerOtpExpiry");
        session.removeAttribute("pendingUsername");
        session.removeAttribute("pendingPassword");
        session.removeAttribute("pendingEmail");

        // Auto login after registration (new account → set lastLoginTime)
        User user = userService.login(uname, pass);
        if (user != null) {
            session.setAttribute("user", user);
            session.setAttribute("lastLoginTime", System.currentTimeMillis());
            session.setAttribute("lastLoginUser", user.getUsername());
            if ("Admin".equals(user.getRole())) {
                response.sendRedirect("AdminServlet?action=dashboard");
            } else {
                response.sendRedirect("DashboardServlet");
            }
        } else {
            response.sendRedirect("login.jsp");
        }
    }

    // ── Resend Register OTP ────────────────────────────────────────────────────
    private void handleResendRegisterOtp(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("pendingEmail") == null) {
            response.sendRedirect("register.jsp");
            return;
        }

        String uname = (String) session.getAttribute("pendingUsername");
        String email = (String) session.getAttribute("pendingEmail");

        // Generate new OTP
        String otp = String.format("%06d", new SecureRandom().nextInt(1_000_000));
        session.setAttribute("registerOtp", otp);
        session.setAttribute("registerOtpExpiry", System.currentTimeMillis() + OTP_EXPIRY_MS);

        try {
            emailService.sendRegistrationOtp(email, uname, otp);
            request.setAttribute("successMessage", "Đã gửi lại mã xác nhận đến " + maskEmail(email));
        } catch (Exception ex) {
            LOG.log(Level.WARNING, "Failed to resend registration OTP", ex);
            request.setAttribute("errorMessage", "Không thể gửi lại email. Vui lòng thử lại.");
        }

        request.setAttribute("maskedEmail", maskEmail(email));
        request.getRequestDispatcher("verifyEmail.jsp").forward(request, response);
    }

    private String maskEmail(String email) {
        if (email == null)
            return "";
        int at = email.indexOf('@');
        if (at <= 2)
            return email;
        return email.substring(0, 2) + "***" + email.substring(at);
    }
}
