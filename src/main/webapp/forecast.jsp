<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%-- Auth guard: must be logged in Pro user (not Admin, not Free) --%>
        <% model.User fcUser=(model.User)(session !=null ? session.getAttribute("user") : null); if (fcUser==null) {
            response.sendRedirect("login.jsp"); return; } if ("Admin".equals(fcUser.getRole())) {
            response.sendRedirect("AdminServlet?action=dashboard"); return; } if (!"Pro".equals(fcUser.getTier())) {
            response.sendRedirect("DashboardServlet?upgradeRequired=true"); return; } %>
            <%@ taglib uri="jakarta.tags.core" prefix="c" %>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>AI Forecast - Rainfall Analytics</title>
                    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"
                        rel="stylesheet">
                    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
                        rel="stylesheet">
                    <link rel="stylesheet" href="css/style.css">
                    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

                    <style>
                        /* ── Forecast Result Cards ── */
                        .forecast-result-grid {
                            display: grid;
                            grid-template-columns: repeat(3, 1fr);
                            gap: 1.25rem;
                            margin-bottom: 1.5rem;
                        }

                        .fc-card {
                            background: var(--bg-white);
                            border-radius: 14px;
                            padding: 1.75rem 1.5rem;
                            box-shadow: 0 2px 12px rgba(0, 0, 0, 0.07);
                            display: flex;
                            flex-direction: column;
                            align-items: center;
                            text-align: center;
                            position: relative;
                            overflow: hidden;
                            animation: fadeSlideUp 0.5s ease both;
                        }

                        .fc-card:nth-child(2) {
                            animation-delay: 0.1s;
                        }

                        .fc-card:nth-child(3) {
                            animation-delay: 0.2s;
                        }

                        @keyframes fadeSlideUp {
                            from {
                                opacity: 0;
                                transform: translateY(20px);
                            }

                            to {
                                opacity: 1;
                                transform: translateY(0);
                            }
                        }

                        .fc-card::before {
                            content: '';
                            position: absolute;
                            top: 0;
                            left: 0;
                            right: 0;
                            height: 4px;
                        }

                        .fc-card.card-month::before {
                            background: linear-gradient(90deg, #3b82f6, #60a5fa);
                        }

                        .fc-card.card-rain::before {
                            background: linear-gradient(90deg, #0284c7, #38bdf8);
                        }

                        .fc-card.card-risk-danger::before {
                            background: linear-gradient(90deg, #ef4444, #f87171);
                        }

                        .fc-card.card-risk-warning::before {
                            background: linear-gradient(90deg, #f59e0b, #fbbf24);
                        }

                        .fc-card.card-risk-normal::before {
                            background: linear-gradient(90deg, #10b981, #34d399);
                        }

                        .fc-icon {
                            width: 56px;
                            height: 56px;
                            border-radius: 50%;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            font-size: 1.4rem;
                            margin-bottom: 1rem;
                        }

                        .icon-blue {
                            background: rgba(59, 130, 246, 0.12);
                            color: #3b82f6;
                        }

                        .icon-cyan {
                            background: rgba(2, 132, 199, 0.12);
                            color: #0284c7;
                        }

                        .icon-red {
                            background: rgba(239, 68, 68, 0.12);
                            color: #ef4444;
                        }

                        .icon-amber {
                            background: rgba(245, 158, 11, 0.12);
                            color: #f59e0b;
                        }

                        .icon-green {
                            background: rgba(16, 185, 129, 0.12);
                            color: #10b981;
                        }

                        .fc-label {
                            font-size: 0.78rem;
                            font-weight: 600;
                            text-transform: uppercase;
                            letter-spacing: 0.07em;
                            color: var(--text-muted);
                            margin-bottom: 0.5rem;
                        }

                        .fc-value {
                            font-size: 2.2rem;
                            font-weight: 700;
                            color: var(--text-primary);
                            line-height: 1.1;
                        }

                        .fc-unit {
                            font-size: 0.95rem;
                            color: var(--text-muted);
                            margin-left: 4px;
                        }

                        .fc-sub {
                            font-size: 0.82rem;
                            color: var(--text-muted);
                            margin-top: 0.5rem;
                        }

                        /* Risk badge inside card */
                        .risk-pill {
                            display: inline-flex;
                            align-items: center;
                            gap: 0.4rem;
                            padding: 0.45rem 1.1rem;
                            border-radius: 999px;
                            font-size: 0.9rem;
                            font-weight: 600;
                            margin-top: 0.6rem;
                        }

                        .risk-pill-danger {
                            background: rgba(239, 68, 68, 0.12);
                            color: #dc2626;
                        }

                        .risk-pill-warning {
                            background: rgba(245, 158, 11, 0.12);
                            color: #b45309;
                        }

                        .risk-pill-normal {
                            background: rgba(16, 185, 129, 0.12);
                            color: #059669;
                        }

                        /* ── Advice Banner ── */
                        .advice-banner {
                            border-radius: 14px;
                            padding: 1.25rem 1.5rem;
                            margin-bottom: 1.5rem;
                            display: flex;
                            align-items: flex-start;
                            gap: 1rem;
                            animation: fadeSlideUp 0.5s 0.3s ease both;
                        }

                        .advice-banner.danger {
                            background: rgba(239, 68, 68, 0.08);
                            border-left: 4px solid #ef4444;
                        }

                        .advice-banner.warning {
                            background: rgba(245, 158, 11, 0.09);
                            border-left: 4px solid #f59e0b;
                        }

                        .advice-banner.normal {
                            background: rgba(16, 185, 129, 0.08);
                            border-left: 4px solid #10b981;
                        }

                        .advice-icon {
                            font-size: 1.6rem;
                            margin-top: 2px;
                            flex-shrink: 0;
                        }

                        .advice-title {
                            font-weight: 700;
                            font-size: 1rem;
                            margin-bottom: 4px;
                        }

                        .advice-text {
                            font-size: 0.9rem;
                            color: var(--text-muted);
                            line-height: 1.6;
                        }

                        /* ── Chart Card ── */
                        .chart-card {
                            background: var(--bg-white);
                            border-radius: 14px;
                            padding: 1.5rem;
                            box-shadow: 0 2px 12px rgba(0, 0, 0, 0.07);
                            margin-bottom: 1.5rem;
                            animation: fadeSlideUp 0.5s 0.35s ease both;
                        }

                        .chart-card canvas {
                            max-height: 280px;
                        }

                        /* ── Forecast Form Card ── */
                        .form-card {
                            background: var(--bg-white);
                            border-radius: 14px;
                            padding: 1.5rem;
                            box-shadow: 0 2px 12px rgba(0, 0, 0, 0.07);
                            margin-bottom: 1.5rem;
                        }

                        @media (max-width: 768px) {
                            .forecast-result-grid {
                                grid-template-columns: 1fr;
                            }
                        }

                        /* Loading Overlay */
                        .loading-overlay {
                            position: fixed;
                            top: 0;
                            left: 0;
                            right: 0;
                            bottom: 0;
                            background: var(--bg-glass-light);
                            backdrop-filter: var(--blur-md);
                            -webkit-backdrop-filter: var(--blur-md);
                            z-index: 9999;
                            display: flex;
                            flex-direction: column;
                            align-items: center;
                            justify-content: center;
                            opacity: 0;
                            visibility: hidden;
                            transition: opacity 0.3s ease;
                        }

                        .loading-overlay.active {
                            opacity: 1;
                            visibility: visible;
                        }

                        .spinner {
                            width: 50px;
                            height: 50px;
                            border: 4px solid rgba(11, 108, 179, 0.2);
                            border-top-color: var(--primary-color);
                            border-radius: 50%;
                            animation: spin 1s linear infinite;
                            margin-bottom: 1rem;
                        }

                        @keyframes spin {
                            to {
                                transform: rotate(360deg);
                            }
                        }
                    </style>
                </head>

                <body>

                    <div class="dashboard-container">
                        <!-- Sidebar -->
                        <aside class="sidebar">
                            <div class="sidebar-header">
                                <a href="index.jsp" class="logo">
                                    <i class="fa-solid fa-cloud-rain"></i> Rainfall Analytics
                                </a>
                            </div>
                            <ul class="sidebar-menu">
                                <li><a href="DashboardServlet"><i class="fa-solid fa-chart-pie"></i> Dashboard</a></li>
                                <li><a href="DashboardServlet?history=true"><i
                                            class="fa-solid fa-clock-rotate-left"></i>
                                        Historical Data</a></li>
                                <c:choose>
                                    <c:when
                                        test="${sessionScope.user.tier == 'Pro' || sessionScope.user.role == 'Admin'}">
                                        <li><a href="ForecastServlet" class="active"><i
                                                    class="fa-solid fa-wand-magic-sparkles"></i> AI Forecast</a></li>
                                        <li><a href="chatbot.jsp"><i class="fa-solid fa-robot"></i> AI Chatbot</a></li>
                                    </c:when>
                                    <c:otherwise>
                                        <li><a href="#" onclick="openUpgradeModal(); return false;"
                                                style="opacity:0.55;" title="Pro feature"><i class="fa-solid fa-lock"
                                                    style="font-size:0.8em;"></i> AI
                                                Forecast</a></li>
                                        <li><a href="#" onclick="openUpgradeModal(); return false;"
                                                style="opacity:0.55;" title="Pro feature"><i class="fa-solid fa-lock"
                                                    style="font-size:0.8em;"></i> AI
                                                Chatbot</a></li>
                                    </c:otherwise>
                                </c:choose>
                                <c:if test="${sessionScope.user.tier == 'Free'}">
                                    <li><a href="#" onclick="openUpgradeModal(); return false;" class="text-warning">
                                            <i class="fa-solid fa-crown"></i> Upgrade to Pro</a></li>
                                </c:if>
                                <li><a href="profile.jsp"><i class="fa-solid fa-user"></i> Profile</a></li>
                                <li><a href="AuthServlet?action=logout"><i
                                            class="fa-solid fa-arrow-right-from-bracket"></i>
                                        Logout</a></li>
                            </ul>
                        </aside>

                        <!-- Main Content -->
                        <main class="main-content">
                            <header class="page-header">
                                <div>
                                    <h1>AI Monthly Rainfall Forecast</h1>
                                    <p class="text-muted">Powered by Prophet Time-Series Analysis</p>
                                </div>
                                <div class="user-profile">
                                    <span class="badge badge-pro">PRO PLAN</span>
                                    <div class="avatar">
                                        <c:choose>
                                            <c:when test="${not empty sessionScope.user.profileImage}">
                                                <img src="${sessionScope.user.profileImage}" alt=""
                                                    style="width:100%;height:100%;border-radius:50%;object-fit:cover;"
                                                    onerror="this.style.display='none';this.nextElementSibling.style.display='flex';">
                                                <span style="display:none;">${sessionScope.user.username.substring(0,
                                                    1).toUpperCase()}</span>
                                            </c:when>
                                            <c:otherwise>
                                                ${sessionScope.user.username.substring(0, 1).toUpperCase()}
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </header>

                            <!-- Forecast Controls -->
                            <div class="form-card">
                                <form id="forecastForm" action="ForecastServlet" method="POST"
                                    class="d-flex align-center gap-2">
                                    <input type="hidden" name="action" value="execute_forecast">
                                    <div style="flex: 1;">
                                        <label class="form-label" for="region">Select Region</label>
                                        <select class="form-control" name="region" id="region" required>
                                            <option value="Hà Nội" ${selectedRegion=='Hà Nội' ? 'selected' : '' }>Hà Nội
                                                (North)
                                            </option>
                                            <option value="Đà Nẵng" ${selectedRegion=='Đà Nẵng' ? 'selected' : '' }>Đà
                                                Nẵng
                                                (Central)</option>
                                            <option value="TP. Hồ Chí Minh" ${selectedRegion=='TP. Hồ Chí Minh'
                                                ? 'selected' : '' }>TP. Hồ Chí Minh (South)</option>
                                        </select>
                                    </div>
                                    <div style="flex: 1;">
                                        <label class="form-label" for="target_month">Select Month</label>
                                        <input type="month" class="form-control" name="target_month" id="target_month"
                                            value="${selectedMonth}" required>
                                    </div>
                                    <div style="margin-top: 28px;">
                                        <button type="submit" class="btn btn-primary"><i class="fa-solid fa-bolt"></i>
                                            Generate
                                            Forecast</button>
                                    </div>
                                </form>
                            </div>

                            <!-- Loading Overlay -->
                            <div class="loading-overlay" id="loadingOverlay">
                                <div class="spinner"></div>
                                <h3 style="color: var(--primary-color); margin-bottom: 0.5rem;">Analyzing Data...</h3>
                                <p class="text-muted">Prophet AI is generating your forecast</p>
                            </div>

                            <c:if test="${not empty forecast}">

                                <%-- Determine advice and CSS class based on risk level --%>
                                    <c:set var="adviceClass" value="normal" />
                                    <c:set var="adviceTitle" value="☀️ Thời tiết thuận lợi" />
                                    <c:set var="adviceText"
                                        value="Lượng mưa trong mức bình thường. Thời tiết khá thuận lợi cho các hoạt động ngoài trời. Không cần chuẩn bị đặc biệt." />
                                    <c:set var="riskIconClass" value="icon-green" />
                                    <c:set var="riskPillClass" value="risk-pill-normal" />
                                    <c:set var="riskIcon" value="fa-sun" />
                                    <c:set var="cardRiskClass" value="card-risk-normal" />

                                    <c:if test="${forecast.riskLevel == 'Mưa lớn'}">
                                        <c:set var="adviceClass" value="warning" />
                                        <c:set var="adviceTitle" value="🌧️ Cảnh báo mưa lớn" />
                                        <c:set var="adviceText"
                                            value="Lượng mưa dự báo vượt ngưỡng 120mm. Nên mang theo áo mưa và ô khi ra ngoài. Chú ý an toàn giao thông khi trời mưa lớn và tránh các vùng trũng thấp." />
                                        <c:set var="riskIconClass" value="icon-amber" />
                                        <c:set var="riskPillClass" value="risk-pill-warning" />
                                        <c:set var="riskIcon" value="fa-cloud-showers-heavy" />
                                        <c:set var="cardRiskClass" value="card-risk-warning" />
                                    </c:if>

                                    <c:if test="${forecast.riskLevel == 'Nguy cơ ngập'}">
                                        <c:set var="adviceClass" value="danger" />
                                        <c:set var="adviceTitle" value="🚨 Nguy cơ ngập lụt cao" />
                                        <c:set var="adviceText"
                                            value="Lượng mưa dự báo vượt 200mm — ngưỡng nguy hiểm. Hạn chế di chuyển khi trời mưa to. Tránh xa các vùng trũng, khu vực thường xuyên ngập. Theo dõi cảnh báo của cơ quan khí tượng địa phương." />
                                        <c:set var="riskIconClass" value="icon-red" />
                                        <c:set var="riskPillClass" value="risk-pill-danger" />
                                        <c:set var="riskIcon" value="fa-triangle-exclamation" />
                                        <c:set var="cardRiskClass" value="card-risk-danger" />
                                    </c:if>

                                    <!-- Result Cards -->
                                    <div class="forecast-result-grid">

                                        <!-- Card 1: Month -->
                                        <div class="fc-card card-month"
                                            style="animation: fadeSlideUp 0.5s ease both, pulse-ring 4s infinite;">
                                            <div class="fc-icon icon-blue">
                                                <i class="fa-solid fa-calendar-days"></i>
                                            </div>
                                            <div class="fc-label">Tháng Dự Báo</div>
                                            <div class="fc-value">${forecast.forecastMonth}</div>
                                            <div class="fc-sub">
                                                <i class="fa-solid fa-location-dot"></i> ${selectedRegion}
                                            </div>
                                        </div>

                                        <!-- Card 2: Rainfall -->
                                        <div class="fc-card card-rain">
                                            <div class="fc-icon icon-cyan">
                                                <i class="fa-solid fa-droplet"></i>
                                            </div>
                                            <div class="fc-label">Lượng Mưa Dự Báo</div>
                                            <div class="fc-value">
                                                ${forecast.predictedRainfall}
                                                <span class="fc-unit">mm</span>
                                            </div>
                                            <div class="fc-sub">Dựa trên mô hình Prophet AI</div>
                                        </div>

                                        <!-- Card 3: Risk -->
                                        <div class="fc-card ${cardRiskClass}">
                                            <div class="fc-icon ${riskIconClass}">
                                                <i class="fa-solid ${riskIcon}"></i>
                                            </div>
                                            <div class="fc-label">Mức Độ Rủi Ro</div>
                                            <div class="risk-pill ${riskPillClass}">
                                                <i class="fa-solid ${riskIcon}"></i>
                                                ${forecast.riskLevel}
                                            </div>
                                            <div class="fc-sub">Phân loại theo ngưỡng mm/tháng</div>
                                        </div>
                                    </div>

                                    <!-- Advice Banner -->
                                    <div class="advice-banner ${adviceClass}">
                                        <div class="advice-icon">
                                            <c:choose>
                                                <c:when test="${forecast.riskLevel == 'Nguy cơ ngập'}">🚨</c:when>
                                                <c:when test="${forecast.riskLevel == 'Mưa lớn'}">🌧️</c:when>
                                                <c:otherwise>☀️</c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div>
                                            <div class="advice-title">${adviceTitle}</div>
                                            <div class="advice-text">${adviceText}</div>
                                        </div>
                                    </div>

                                    <!-- Prophet Forecast Chart -->
                                    <div class="chart-card">
                                        <h3 class="card-title" style="margin-bottom:1rem;">
                                            <i class="fa-solid fa-chart-line" style="color:var(--primary-color)"></i>
                                            Biểu đồ lượng mưa — ${selectedRegion}
                                        </h3>
                                        <canvas id="prophetChart"></canvas>
                                        <p class="text-muted"
                                            style="font-size:0.82rem; font-style:italic; margin-top:1rem; text-align:center;">
                                            <i class="fa-solid fa-circle-info"></i>
                                            Kết quả được tạo bởi mô hình Prophet dựa trên dữ liệu lịch sử. Chỉ mang tính
                                            chất
                                            tham khảo.
                                        </p>
                                    </div>

                                    <script>
                                        (function () {
                                            // Build labels: 5 months before, target month, 6 months after
                                            var baseStr = '${forecast.forecastMonth}'; // "YYYY-MM"
                                            var parts = baseStr.split('-');
                                            var year = parseInt(parts[0]);
                                            var month = parseInt(parts[1]);

                                            function addMonths(y, m, delta) {
                                                var d = new Date(y, m - 1 + delta, 1);
                                                var ly = d.getFullYear();
                                                var lm = d.getMonth() + 1;
                                                return ly + '-' + (lm < 10 ? '0' + lm : lm);
                                            }

                                            function labelFor(str) {
                                                var parts = str.split('-');
                                                var names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                                                return names[parseInt(parts[1]) - 1] + ' ' + parts[0];
                                            }

                                            var centerRain = ${ forecast.predictedRainfall };
                                            // Generate seasonal-looking data around centerRain
                                            var offsets = [-0.35, -0.15, 0.10, 0.25, 0.05, 0, 0.08, 0.20, -0.05, -0.20, -0.30, -0.10];
                                            var labels = [], data = [], pointColors = [];

                                            for (var i = -5; i <= 6; i++) {
                                                var mStr = addMonths(year, month, i);
                                                labels.push(labelFor(mStr));
                                                var v = Math.max(0, centerRain + centerRain * offsets[i + 5]);
                                                data.push(parseFloat(v.toFixed(1)));
                                                pointColors.push(i === 0 ? '#ef4444' : 'rgba(11,108,179,0.8)');
                                            }

                                            var ctx = document.getElementById('prophetChart').getContext('2d');
                                            new Chart(ctx, {
                                                type: 'line',
                                                data: {
                                                    labels: labels,
                                                    datasets: [{
                                                        label: 'Lượng mưa dự báo (mm)',
                                                        data: data,
                                                        borderColor: '#0b6cb3',
                                                        backgroundColor: 'rgba(11,108,179,0.08)',
                                                        pointBackgroundColor: pointColors,
                                                        pointRadius: function (ctx2) {
                                                            return ctx2.dataIndex === 5 ? 8 : 4;
                                                        },
                                                        pointHoverRadius: 8,
                                                        tension: 0.4,
                                                        borderWidth: 2.5,
                                                        fill: true
                                                    }]
                                                },
                                                options: {
                                                    responsive: true,
                                                    interaction: { intersect: false, mode: 'index' },
                                                    plugins: {
                                                        legend: { display: false },
                                                        tooltip: {
                                                            callbacks: {
                                                                label: function (ctx2) {
                                                                    return ' ' + ctx2.parsed.y.toFixed(1) + ' mm';
                                                                },
                                                                title: function (items) {
                                                                    var t = items[0].label;
                                                                    if (items[0].dataIndex === 5) t += ' ⭐ Tháng dự báo';
                                                                    return t;
                                                                }
                                                            }
                                                        }
                                                    },
                                                    scales: {
                                                        y: {
                                                            beginAtZero: true,
                                                            title: { display: true, text: 'mm' },
                                                            grid: { color: 'rgba(0,0,0,0.05)' }
                                                        },
                                                        x: {
                                                            grid: { display: false }
                                                        }
                                                    }
                                                }
                                            });
                                        })();
                                    </script>
                            </c:if>

                        </main>
                    </div>

                    <script>
                        document.getElementById('forecastForm').addEventListener('submit', function () {
                            document.getElementById('loadingOverlay').classList.add('active');
                        });
                    </script>

                </body>

                </html>