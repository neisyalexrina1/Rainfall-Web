<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Multi-Region Rainfall Analysis & Forecasting System</title>
            <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
                rel="stylesheet">
            <link rel="stylesheet" href="css/style.css">
        </head>

        <body class="d-flex flex-column min-vh-100">

            <nav class="navbar">
                <div class="container d-flex justify-between align-center">
                    <a href="index.jsp" class="logo">
                        <i class="fa-solid fa-cloud-rain"></i> Rainfall Analytics
                    </a>
                    <div class="nav-links d-flex align-center gap-3">
                        <a href="index.jsp">Home</a>
                        <a href="about.jsp">About</a>
                        <c:if test="${sessionScope.user == null || sessionScope.user.role != 'Admin'}">
                            <a href="pricing.jsp">Pricing</a>
                        </c:if>
                    </div>

                    <div class="auth-box d-flex align-center gap-2">
                        <c:choose>
                            <c:when test="${sessionScope.user != null}">
                                <c:choose>
                                    <c:when test="${sessionScope.user.role == 'Admin'}">
                                        <a href="AdminServlet?action=dashboard" class="btn btn-primary"
                                            style="padding-bottom: 0.375rem; border-bottom: none;"><i
                                                class="fa-solid fa-lock me-1"></i> Admin Panel</a>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="DashboardServlet" class="btn btn-primary"
                                            style="padding-bottom: 0.375rem; border-bottom: none;"><i
                                                class="fa-solid fa-chart-pie me-1"></i> Dashboard</a>
                                    </c:otherwise>
                                </c:choose>
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

            <section class="hero" style="flex: 1; display: flex; align-items: center; justify-content: center;">
                <div class="container">
                    <h1
                        style="font-size: 3.5rem; margin-bottom: 1.5rem; letter-spacing: -1.5px; color: var(--text-main);">
                        Rainfall Analysis & Forecasting</h1>
                    <p style="font-size: 1.25rem; margin-bottom: 2.5rem; line-height: 1.6; max-width: 800px;">Advanced
                        statistical monthly rainfall forecasting powered by AI. Gain insights into accurate climate
                        patterns across Vietnam regions.</p>
                    <div class="d-flex justify-center gap-3 mt-4">
                        <a href="DashboardServlet" class="btn btn-primary btn-lg"><i class="fa-solid fa-chart-line"></i>
                            View Historical Data</a>
                        <a href="pricing.jsp" class="btn btn-outline btn-lg" style="background: white;"><i
                                class="fa-solid fa-crown"></i> Upgrade to Pro</a>
                    </div>
                </div>
            </section>

            <footer
                style="background-color: var(--bg-white); border-top: 1px solid var(--border-color); color: var(--text-muted); padding: 2rem 0; text-align: center;">
                <p>&copy; 2026 Rainfall Analytics System. Academic Assignment Showcase.</p>
            </footer>

        </body>

        </html>