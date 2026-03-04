<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Pricing - Rainfall Analytics</title>
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
                        <a href="pricing.jsp" class="active">Pricing</a>
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

            <div class="container min-vh-100 d-flex flex-column" style="flex: 1;">
                <section id="pricing" class="pricing-section" style="padding: 4rem 0;">
                    <div class="text-center mb-4">
                        <h1 style="font-size: 2.5rem; margin-bottom: 1rem;">Select Your Plan</h1>
                        <p class="text-muted" style="font-size: 1.1rem;">Choose the level of access you need for your
                            operations.</p>

                        <c:if test="${param.error == 'true'}">
                            <div class="alert alert-danger mx-auto mt-4" style="max-width: 500px; text-align: left;">
                                <i class="fa-solid fa-circle-exclamation"></i> Transaction failed. Please try again.
                            </div>
                        </c:if>
                    </div>

                    <div class="grid-3 mt-4">
                        <!-- Free Plan -->
                        <div class="card pricing-card">
                            <h3 style="font-size: 1.25rem;">Free Tier</h3>
                            <div class="price">0đ<span>/month</span></div>
                            <ul class="features-list">
                                <li><i class="fa-solid fa-check"></i> View Historical Data</li>
                                <li><i class="fa-solid fa-check"></i> Basic Charts & Analytics</li>
                                <li><i class="fa-solid fa-check"></i> 5-year Trends</li>
                                <li class="text-muted"><i class="fa-solid fa-xmark"
                                        style="color: var(--danger-color)"></i> AI Prophet Forecasting</li>
                                <li class="text-muted"><i class="fa-solid fa-xmark"
                                        style="color: var(--danger-color)"></i> Smart Chatbot Assistant</li>
                                <li class="text-muted"><i class="fa-solid fa-xmark"
                                        style="color: var(--danger-color)"></i> Risk Level Warnings</li>
                            </ul>
                            <a href="register.jsp" class="btn btn-outline btn-block">Get Started</a>
                        </div>

                        <!-- Pro Monthly Plan -->
                        <div class="card pricing-card featured">
                            <h3>Pro Monthly</h3>
                            <div class="price">50k<span>/month</span></div>
                            <ul class="features-list">
                                <li><i class="fa-solid fa-check"></i> All Free Features</li>
                                <li><i class="fa-solid fa-check"></i> AI Prophet Forecasting</li>
                                <li><i class="fa-solid fa-check"></i> Smart Chatbot Assistant</li>
                                <li><i class="fa-solid fa-check"></i> Risk Level Warnings</li>
                                <li><i class="fa-solid fa-check"></i> Data Export (CSV)</li>
                            </ul>
                            <c:choose>
                                <c:when test="${sessionScope.user != null && sessionScope.user.role == 'Admin'}">
                                    <a href="AdminServlet?action=dashboard" class="btn btn-primary btn-block"
                                        style="display:block; text-align:center; padding: 0.75rem; border-bottom: none; text-decoration:none;">
                                        <i class="fa-solid fa-lock"></i> Go to Admin Panel
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <a href="PaymentServlet?packageId=2" class="btn btn-primary btn-block"
                                        style="display:block; text-align:center; padding: 0.75rem; border-bottom: none; text-decoration:none;">
                                        <i class="fa-solid fa-bolt"></i> Nâng cấp ngay
                                    </a>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <!-- Pro Yearly Plan -->
                        <div class="card pricing-card">
                            <h3 style="font-size: 1.25rem;">Pro Yearly</h3>
                            <div class="price">500k<span>/year</span></div>
                            <ul class="features-list">
                                <li><i class="fa-solid fa-check"></i> All Pro Features</li>
                                <li><i class="fa-solid fa-check"></i> Save 100k annually</li>
                                <li><i class="fa-solid fa-check"></i> Priority Support</li>
                                <li><i class="fa-solid fa-check"></i> Custom Region Tracking</li>
                            </ul>
                            <c:choose>
                                <c:when test="${sessionScope.user != null && sessionScope.user.role == 'Admin'}">
                                    <a href="AdminServlet?action=dashboard" class="btn btn-outline btn-block"
                                        style="display:block; text-align:center; padding: 0.75rem; border-bottom: 1px solid var(--border-color); color: var(--text-main); text-decoration:none;">
                                        <i class="fa-solid fa-lock"></i> Go to Admin Panel
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <a href="PaymentServlet?packageId=3" class="btn btn-outline btn-block"
                                        style="display:block; text-align:center; padding: 0.75rem; border-bottom: 1px solid var(--border-color); color: var(--text-main); text-decoration:none;">
                                        <i class="fa-solid fa-calendar-check"></i> Nâng cấp năm
                                    </a>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </section>
            </div>

            <footer
                style="background-color: var(--bg-white); border-top: 1px solid var(--border-color); color: var(--text-muted); padding: 2rem 0; text-align: center;">
                <p>&copy; 2026 Rainfall Analytics System. Academic Assignment Showcase.</p>
            </footer>

        </body>

        </html>