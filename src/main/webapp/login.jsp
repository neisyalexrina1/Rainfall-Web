<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%-- Redirect if already logged in --%>
            <% if (session !=null && session.getAttribute("user") !=null) { model.User lu=(model.User)
                session.getAttribute("user"); if ("Admin".equals(lu.getRole())) {
                response.sendRedirect("AdminServlet?action=dashboard"); } else {
                response.sendRedirect("DashboardServlet"); } return; } %>
                <%@ taglib uri="jakarta.tags.core" prefix="c" %>
                    <!DOCTYPE html>
                    <html lang="en">

                    <head>
                        <meta charset="UTF-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <title>Login - Rainfall Analytics</title>
                        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"
                            rel="stylesheet">
                        <link
                            href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
                            rel="stylesheet">
                        <link rel="stylesheet" href="css/style.css">
                        <style>
                            .login-toast {
                                position: fixed;
                                bottom: 2rem;
                                right: 2rem;
                                background: var(--bg-white);
                                border-left: 4px solid var(--danger-color);
                                padding: 1rem 1.5rem;
                                border-radius: var(--border-radius);
                                box-shadow: var(--shadow-md);
                                display: flex;
                                align-items: center;
                                gap: 0.75rem;
                                transform: translateX(120%);
                                opacity: 0;
                                transition: all 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55);
                                z-index: 1000;
                            }

                            .login-toast.show {
                                transform: translateX(0);
                                opacity: 1;
                            }

                            .login-toast i {
                                color: var(--danger-color);
                                font-size: 1.2rem;
                            }
                        </style>
                    </head>

                    <body>

                        <nav class="navbar">
                            <div class="container d-flex justify-between align-center">
                                <a href="index.jsp" class="logo"
                                    style="padding-bottom: 0; border: none; text-decoration: none;">
                                    <i class="fa-solid fa-cloud-rain"></i> Rainfall Analytics
                                </a>
                                <div class="nav-links d-flex align-center gap-3">
                                    <a href="index.jsp">Home</a>
                                    <a href="about.jsp">About</a>
                                    <a href="pricing.jsp">Pricing</a>
                                </div>

                                <div class="auth-box d-flex align-center gap-2">
                                    <c:choose>
                                        <c:when test="${sessionScope.user != null}">
                                            <a href="DashboardServlet" class="btn btn-primary"
                                                style="padding-bottom: 0.375rem; border-bottom: none;"><i
                                                    class="fa-solid fa-chart-pie me-1"></i> Dashboard</a>
                                            <a href="AuthServlet?action=logout" class="btn btn-outline"
                                                style="padding-bottom: 0.375rem; border-bottom: none;">Logout</a>
                                        </c:when>
                                        <c:otherwise>
                                            <a href="login.jsp" class="btn btn-outline"
                                                style="padding-bottom: 0.375rem; border-bottom: none;">Log in</a>
                                            <a href="register.jsp" class="btn btn-primary"
                                                style="padding-bottom: 0.375rem; border-bottom: none;">Sign up for
                                                Free</a>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </nav>

                        <div class="container min-vh-100 d-flex flex-column" style="flex: 1;">
                            <div class="auth-container" style="flex:1;">
                                <div class="auth-card text-center" style="margin: auto;">
                                    <i class="fa-solid fa-user-circle fa-4x mb-2"
                                        style="background: var(--primary-gradient); -webkit-background-clip: text; -webkit-text-fill-color: transparent;"></i>
                                    <h2 class="mb-4">Welcome Back</h2>

                                    <c:if test="${not empty errorMessage}">
                                        <div class="alert alert-danger"
                                            style="background: rgba(239, 68, 68, 0.1); border-left: 4px solid var(--danger-color); padding: 1rem; margin-bottom: 1.5rem; border-radius: 4px; text-align: left; color: #b91c1c;">
                                            <i class="fa-solid fa-circle-exclamation me-2"></i> ${errorMessage}
                                        </div>
                                    </c:if>

                                    <form action="AuthServlet" method="POST" id="loginForm" novalidate>
                                        <input type="hidden" name="action" value="login">

                                        <div class="form-group">
                                            <label class="form-label" for="username">Username</label>
                                            <input type="text" id="username" name="username" class="form-control"
                                                required minlength="3" placeholder="Enter username">
                                            <div class="invalid-feedback">Please enter a valid username (min 3 chars).
                                            </div>
                                        </div>

                                        <div class="form-group" style="position:relative;">
                                            <label class="form-label" for="password">Password</label>
                                            <input type="password" id="password" name="password" class="form-control"
                                                required minlength="4" placeholder="Enter password"
                                                style="padding-right:2.8rem;">
                                            <button type="button" onclick="togglePwd()" tabindex="-1" style="position:absolute;right:0.75rem;bottom:0.65rem;background:none;border:none;
                                    cursor:pointer;color:var(--text-muted);padding:0;line-height:1;">
                                                <i class="fa-solid fa-eye" id="pwdEyeIcon" style="font-size:1rem;"></i>
                                            </button>
                                            <div class="invalid-feedback">Password must be at least 4 characters long.
                                            </div>
                                        </div>

                                        <div class="d-flex justify-between align-center mt-2 mb-4">
                                            <div
                                                style="font-size: 0.9rem; display:flex; align-items:center; gap: 0.4rem;">
                                                <input type="checkbox" id="remember" name="remember" value="on"
                                                    style="width:15px;height:15px;accent-color:#0b6cb3;cursor:pointer;">
                                                <label for="remember" style="cursor:pointer;margin:0;">Remember me <span
                                                        style="color:var(--text-muted);font-size:0.8rem;">(30
                                                        ngày)</span></label>
                                            </div>
                                            <a href="PasswordResetServlet" style="font-size: 0.9rem;">Forgot
                                                password?</a>
                                        </div>

                                        <button type="submit" class="btn btn-primary btn-block">Log In</button>
                                    </form>

                                    <p class="mt-4" style="font-size: 0.9rem; color: var(--text-muted)">
                                        Don't have an account? <a href="register.jsp">Create for free</a>
                                    </p>
                                </div>
                            </div>
                        </div>

                        <footer
                            style="background-color: var(--bg-white); border-top: 1px solid var(--border-color); color: var(--text-muted); padding: 2rem 0; text-align: center;">
                            <p>&copy; 2026 Rainfall Analytics System. Academic Assignment Showcase.</p>
                        </footer>

                        <script>
                            document.getElementById('loginForm').addEventListener('submit', function (event) {
                                var form = this;
                                var isValid = true;

                                // Clear previous validation
                                form.querySelectorAll('.form-control').forEach(function (el) {
                                    el.classList.remove('is-invalid');
                                });

                                var username = document.getElementById('username');
                                if (username.value.trim().length < 3) {
                                    username.classList.add('is-invalid');
                                    isValid = false;
                                }

                                var password = document.getElementById('password');
                                if (password.value.trim().length < 4) {
                                    password.classList.add('is-invalid');
                                    isValid = false;
                                }

                                if (!isValid) {
                                    event.preventDefault();
                                    event.stopPropagation();
                                }
                            });

                            function togglePwd() {
                                var pwd = document.getElementById('password');
                                var icon = document.getElementById('pwdEyeIcon');
                                if (pwd.type === 'password') {
                                    pwd.type = 'text';
                                    icon.className = 'fa-solid fa-eye-slash';
                                } else {
                                    pwd.type = 'password';
                                    icon.className = 'fa-solid fa-eye';
                                }
                            }
                        </script>
                    </body>

                    </html>