<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Register - Rainfall Analytics</title>
            <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
                rel="stylesheet">
            <link rel="stylesheet" href="css/style.css">
        </head>

        <body>

            <nav class="navbar">
                <div class="container d-flex justify-between align-center">
                    <a href="index.jsp" class="logo">
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
                                    style="padding-bottom: 0.375rem; border-bottom: none;">Sign up for Free</a>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </nav>

            <div class="container min-vh-100 d-flex flex-column" style="flex: 1;">
                <div class="auth-container" style="flex:1;">
                    <div class="auth-card text-center" style="margin: auto;">
                        <i class="fa-solid fa-user-plus fa-4x mb-2" style="color: var(--primary-color)"></i>
                        <h2 class="mb-4">Create Free Account</h2>

                        <c:if test="${not empty errorMessage}">
                            <div class="alert alert-danger mb-4">
                                <i class="fa-solid fa-circle-exclamation"></i> ${errorMessage}
                            </div>
                        </c:if>

                        <form action="AuthServlet" method="POST" id="registerForm" novalidate>
                            <input type="hidden" name="action" value="register">

                            <div class="form-group">
                                <label class="form-label" for="username">Username</label>
                                <input type="text" id="username" name="username" class="form-control" required
                                    minlength="3" placeholder="Choose a username">
                                <div class="invalid-feedback">Username must be at least 3 characters.</div>
                            </div>

                            <div class="form-group">
                                <label class="form-label" for="email">Email</label>
                                <input type="email" id="email" name="email" class="form-control" required
                                    placeholder="name@example.com">
                                <div class="invalid-feedback">Please enter a valid email address.</div>
                            </div>

                            <div class="form-group">
                                <label class="form-label" for="password">Password</label>
                                <input type="password" id="password" name="password" class="form-control" required
                                    minlength="4" placeholder="Create a password">
                                <div class="invalid-feedback">Password must be at least 4 characters.</div>
                            </div>

                            <button type="submit" class="btn btn-primary btn-block mt-4">Create Account</button>
                        </form>

                        <p class="mt-4" style="font-size: 0.9rem; color: var(--text-muted)">
                            Already have an account? <a href="login.jsp">Log In</a>
                        </p>
                    </div>
                </div>
            </div>

            <footer
                style="background-color: var(--bg-white); border-top: 1px solid var(--border-color); color: var(--text-muted); padding: 2rem 0; text-align: center;">
                <p>&copy; 2026 Rainfall Analytics System. Academic Assignment Showcase.</p>
            </footer>

            <script>
                document.getElementById('registerForm').addEventListener('submit', function (event) {
                    var form = this;
                    var isValid = true;

                    form.querySelectorAll('.form-control').forEach(function (el) {
                        el.classList.remove('is-invalid');
                    });

                    var username = document.getElementById('username');
                    if (username.value.trim().length < 3) {
                        username.classList.add('is-invalid');
                        isValid = false;
                    }

                    var email = document.getElementById('email');
                    var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                    if (!emailRegex.test(email.value.trim())) {
                        email.classList.add('is-invalid');
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
            </script>
        </body>

        </html>