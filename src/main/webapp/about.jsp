<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>About - Rainfall Analytics</title>
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
                        <a href="about.jsp" class="active">About</a>
                        <a href="pricing.jsp">Pricing</a>
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
                <section id="about" style="padding: 4rem 0;">
                    <div class="text-center mb-4">
                        <h1 style="font-size: 2.5rem; margin-bottom: 1rem;">3 Major Climate Regions</h1>
                        <p class="text-muted" style="font-size: 1.1rem; max-width: 600px; margin: 0 auto;">Analyzing the
                            distinct weather patterns across Vietnam to provide the most highly accurate forecasts.</p>
                    </div>
                    <div class="grid-3 mt-4" style="margin-top: 3rem;">
                        <div class="card text-center" style="padding: 0; overflow: hidden;">
                            <img src="images/hanoi_weather.png" alt="Hà Nội weather"
                                style="width:100%; height:180px; object-fit:cover;">
                            <div style="padding: 1.5rem 1.5rem 2rem;">
                                <i class="fa-solid fa-cloud-sun"
                                    style="font-size:1.5rem; color: var(--primary-color); margin-bottom:0.75rem; display:block;"></i>
                                <h3>Hà Nội (North)</h3>
                                <p class="text-muted mt-2">Distinct four seasons with a hot, rainy summer and cold, dry
                                    winter.</p>
                            </div>
                        </div>
                        <div class="card text-center" style="padding: 0; overflow: hidden;">
                            <img src="images/danang_weather.png" alt="Đà Nẵng weather"
                                style="width:100%; height:180px; object-fit:cover;">
                            <div style="padding: 1.5rem 1.5rem 2rem;">
                                <i class="fa-solid fa-cloud-showers-heavy"
                                    style="font-size:1.5rem; color: #0b6cb3; margin-bottom:0.75rem; display:block;"></i>
                                <h3>Đà Nẵng (Central)</h3>
                                <p class="text-muted mt-2">Tropical monsoon climate with a distinct dry season and wet
                                    season peaking in late year.</p>
                            </div>
                        </div>
                        <div class="card text-center" style="padding: 0; overflow: hidden;">
                            <img src="images/hcm_weather.png" alt="TP. Hồ Chí Minh weather"
                                style="width:100%; height:180px; object-fit:cover;">
                            <div style="padding: 1.5rem 1.5rem 2rem;">
                                <i class="fa-solid fa-sun-plant-wilt"
                                    style="font-size:1.5rem; color: #ffc107; margin-bottom:0.75rem; display:block;"></i>
                                <h3>TP. Hồ Chí Minh (South)</h3>
                                <p class="text-muted mt-2">Tropical savanna climate with clearly defined wet and dry
                                    seasons
                                    all year round.</p>
                            </div>
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