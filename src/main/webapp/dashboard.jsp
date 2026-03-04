<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Customer Dashboard - Rainfall Analytics</title>
            <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
                rel="stylesheet">
            <link rel="stylesheet" href="css/style.css">
            <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
                        <li><a href="DashboardServlet" class="${empty param.history ? 'active' : ''}"><i
                                    class="fa-solid fa-chart-pie"></i> Dashboard</a></li>
                        <li><a href="DashboardServlet?history=true"
                                class="${not empty param.history ? 'active' : ''}"><i
                                    class="fa-solid fa-clock-rotate-left"></i> Historical Data</a></li>
                        <c:choose>
                            <c:when test="${sessionScope.user.tier == 'Pro' || sessionScope.user.role == 'Admin'}">
                                <li><a href="ForecastServlet"><i class="fa-solid fa-wand-magic-sparkles"></i> AI
                                        Forecast</a></li>
                                <li><a href="chatbot.jsp"><i class="fa-solid fa-robot"></i> AI Chatbot</a></li>
                            </c:when>
                            <c:otherwise>
                                <li><a href="#" onclick="openUpgradeModal(); return false;" style="opacity:0.55;"
                                        title="Pro feature"><i class="fa-solid fa-lock" style="font-size:0.8em;"></i> AI
                                        Forecast</a></li>
                                <li><a href="#" onclick="openUpgradeModal(); return false;" style="opacity:0.55;"
                                        title="Pro feature"><i class="fa-solid fa-lock" style="font-size:0.8em;"></i> AI
                                        Chatbot</a></li>
                            </c:otherwise>
                        </c:choose>
                        <c:if test="${sessionScope.user.tier == 'Free'}">
                            <li><a href="#" onclick="openUpgradeModal(); return false;" class="text-warning">
                                    <i class="fa-solid fa-crown"></i> Upgrade to Pro</a></li>
                        </c:if>
                        <li><a href="profile.jsp"><i class="fa-solid fa-user"></i> Profile</a></li>
                        <li><a href="AuthServlet?action=logout"><i class="fa-solid fa-arrow-right-from-bracket"></i>
                                Logout</a></li>
                    </ul>
                </aside>

                <!-- Main Content -->
                <main class="main-content">
                    <header class="page-header">
                        <div>
                            <h1>Overview Dashboard</h1>
                            <p class="text-muted"><span id="dynamicGreeting">Welcome back</span>,
                                ${sessionScope.user.username}</p>

                            <script>
                                document.addEventListener('DOMContentLoaded', function () {
                                    const hour = new Date().getHours();
                                    let greeting = 'Good evening';
                                    if (hour >= 5 && hour < 12) greeting = 'Good morning';
                                    else if (hour >= 12 && hour < 18) greeting = 'Good afternoon';
                                    document.getElementById('dynamicGreeting').textContent = greeting;
                                });
                            </script>
                        </div>
                        <div class="user-profile">
                            <span class="badge ${sessionScope.user.tier == 'Pro' ? 'badge-pro' : 'badge-free'}">
                                ${sessionScope.user.tier} Plan
                                <c:if test="${not empty sessionScope.user.expiryDate}">
                                    (Exp: ${sessionScope.user.expiryDate})
                                </c:if>
                            </span>
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

                    <!-- Conditional View Logic -->
                    <c:choose>
                        <c:when test="${empty param.history}">
                            <!-- KPI Cards -->
                            <div class="grid-3 mb-4">
                                <div class="card">
                                    <h3 class="card-title text-muted">Total Rainfall (Current Year)</h3>
                                    <div class="card-value">${totalRainfall} <span
                                            style="font-size: 1rem; color: var(--text-muted)">mm</span></div>
                                    <p class="mt-2 text-success"><i class="fa-solid fa-arrow-up"></i> +5.2% from last
                                        year</p>
                                </div>
                                <div class="card">
                                    <h3 class="card-title text-muted">Wettest Region</h3>
                                    <div class="card-value">Đà Nẵng</div>
                                    <p class="mt-2 text-warning"><i class="fa-solid fa-triangle-exclamation"></i> Heavy
                                        rain
                                        season incoming</p>
                                </div>
                                <div class="card">
                                    <h3 class="card-title text-muted">Active Stations</h3>
                                    <div class="card-value">3</div>
                                    <p class="mt-2 text-muted">Hà Nội, Đà Nẵng, TP.HCM</p>
                                </div>
                            </div>

                            <!-- Charts Grid -->
                            <div class="grid-2 mb-4">
                                <div class="card" style="min-width: 0;">
                                    <h3 class="card-title">5-Year Historical Trend</h3>
                                    <div style="position: relative; height: 300px; width: 100%;">
                                        <canvas id="lineChart"></canvas>
                                    </div>
                                </div>
                                <div class="card" style="min-width: 0;">
                                    <h3 class="card-title">Monthly Regional Comparison</h3>
                                    <div style="position: relative; height: 300px; width: 100%;">
                                        <canvas id="barChart"></canvas>
                                    </div>
                                </div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <!-- Historical Data Log View -->

                            <form action="DashboardServlet" method="GET" class="mb-4">
                                <input type="hidden" name="history" value="true">
                                <div class="card"
                                    style="display: flex; gap: 1rem; align-items: flex-end; padding: 1.5rem;">
                                    <div>
                                        <label class="form-label"
                                            style="font-size: 0.85rem; color: var(--text-muted); margin-bottom: 0.4rem;">Start
                                            Date</label>
                                        <input type="date" name="startDate" value="${startDate}" class="form-control"
                                            required style="width: 180px;">
                                    </div>
                                    <div>
                                        <label class="form-label"
                                            style="font-size: 0.85rem; color: var(--text-muted); margin-bottom: 0.4rem;">End
                                            Date</label>
                                        <input type="date" name="endDate" value="${endDate}" class="form-control"
                                            required style="width: 180px;">
                                    </div>
                                    <div>
                                        <button type="submit" class="btn btn-primary"><i class="fa-solid fa-filter"></i>
                                            View Records</button>
                                    </div>
                                </div>
                            </form>

                            <div class="card mb-4" style="overflow-x: auto;">
                                <h3 class="card-title mb-4">Daily Regional Database</h3>
                                <table style="width: 100%; border-collapse: collapse;">
                                    <thead>
                                        <tr>
                                            <th
                                                style="text-align: left; padding: 1rem; border-bottom: 2px solid var(--border-color);">
                                                Date</th>
                                            <th style="padding: 1rem; border-bottom: 2px solid var(--border-color);">Hà
                                                Nội (mm)</th>
                                            <th style="padding: 1rem; border-bottom: 2px solid var(--border-color);">Đà
                                                Nẵng (mm)</th>
                                            <th style="padding: 1rem; border-bottom: 2px solid var(--border-color);">TP.
                                                Hồ Chí Minh (mm)</th>
                                        </tr>
                                    </thead>
                                    <tbody id="historyTableBody">
                                        <!-- Javascript will inject data here -->
                                    </tbody>
                                </table>
                                <!-- Pagination Controls -->
                                <div id="paginationControls"
                                    style="display:none; align-items:center; justify-content:space-between; padding:1rem 0.5rem 0; border-top:1px solid var(--border-color); margin-top:0.5rem;">
                                    <span id="pageInfo"
                                        style="font-size:0.85rem; color:var(--text-muted); font-weight:500;"></span>
                                    <div style="display:flex; gap:0.5rem; align-items:center;">
                                        <button id="prevPageBtn" class="btn btn-outline"
                                            style="padding:0.35rem 0.75rem; font-size:0.85rem;"
                                            onclick="changePage(-1)">
                                            <i class="fa-solid fa-chevron-left"></i> Trước
                                        </button>
                                        <span id="pageNumbers" style="display:flex; gap:0.25rem;"></span>
                                        <button id="nextPageBtn" class="btn btn-outline"
                                            style="padding:0.35rem 0.75rem; font-size:0.85rem;" onclick="changePage(1)">
                                            Sau <i class="fa-solid fa-chevron-right"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>

                    <!-- Call to Action for Free Users -->
                    <c:if test="${sessionScope.user.tier == 'Free'}">
                        <div class="card text-center"
                            style="background: linear-gradient(135deg, rgba(21,101,192,0.1) 0%, rgba(21,101,192,0.05) 100%);">
                            <h3>Unlock AI Predictions</h3>
                            <p class="mb-4">Want to see what next month's rainfall looks like? Upgrade to Pro to access
                                our Prophet AI Forecasting Engine.</p>
                            <a href="#" onclick="openUpgradeModal(); return false;" class="btn btn-primary">
                                <i class="fa-solid fa-crown"></i> Upgrade to Pro</a>
                        </div>
                    </c:if>

                </main>
            </div>

            <script>
                // Read injected JSON strings into JS arrays safely with fallback
                const yearlyLabels = ${ not empty yearlyLabels ?yearlyLabels: '[]'};
                const hnYearly = ${ not empty hnYearly ?hnYearly: '[]'};
                const dnYearly = ${ not empty dnYearly ?dnYearly: '[]'};
                const hcmYearly = ${ not empty hcmYearly ?hcmYearly: '[]'};

                const monthlyLabels = ${ not empty monthlyLabels ?monthlyLabels: '[]'};
                const hnMonthly = ${ not empty hnMonthly ?hnMonthly: '[]'};
                const dnMonthly = ${ not empty dnMonthly ?dnMonthly: '[]'};
                const hcmMonthly = ${ not empty hcmMonthly ?hcmMonthly: '[]'};

                // Init Charts if on Dashboard
                if (document.getElementById('lineChart')) {
                    const ctxLine = document.getElementById('lineChart').getContext('2d');
                    const ctxBar = document.getElementById('barChart').getContext('2d');

                    // Create Gradients
                    const hnGrad = ctxLine.createLinearGradient(0, 0, 0, 300);
                    hnGrad.addColorStop(0, 'rgba(11, 108, 179, 0.4)');
                    hnGrad.addColorStop(1, 'rgba(11, 108, 179, 0.0)');

                    const dnGrad = ctxLine.createLinearGradient(0, 0, 0, 300);
                    dnGrad.addColorStop(0, 'rgba(40, 167, 69, 0.4)');
                    dnGrad.addColorStop(1, 'rgba(40, 167, 69, 0.0)');

                    const hcmGrad = ctxLine.createLinearGradient(0, 0, 0, 300);
                    hcmGrad.addColorStop(0, 'rgba(255, 193, 7, 0.4)');
                    hcmGrad.addColorStop(1, 'rgba(255, 193, 7, 0.0)');

                    const commonOptions = {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            tooltip: {
                                backgroundColor: 'rgba(15, 23, 42, 0.9)',
                                titleFont: { size: 13, family: 'Inter' },
                                bodyFont: { size: 13, family: 'Inter' },
                                padding: 10,
                                cornerRadius: 8,
                                displayColors: true
                            }
                        }
                    };

                    new Chart(ctxLine, {
                        type: 'line',
                        data: {
                            labels: yearlyLabels,
                            datasets: [
                                { label: 'Hà Nội', data: hnYearly, borderColor: '#0b6cb3', backgroundColor: hnGrad, fill: true, tension: 0.4, borderWidth: 2, pointRadius: 4, pointHoverRadius: 6 },
                                { label: 'Đà Nẵng', data: dnYearly, borderColor: '#28a745', backgroundColor: dnGrad, fill: true, tension: 0.4, borderWidth: 2, pointRadius: 4, pointHoverRadius: 6 },
                                { label: 'TP.HCM', data: hcmYearly, borderColor: '#ffc107', backgroundColor: hcmGrad, fill: true, tension: 0.4, borderWidth: 2, pointRadius: 4, pointHoverRadius: 6 }
                            ]
                        },
                        options: {
                            ...commonOptions,
                            interaction: { intersect: false, mode: 'index' },
                            scales: {
                                y: { grid: { color: 'rgba(0,0,0,0.04)', drawBorder: false } },
                                x: { grid: { display: false, drawBorder: false } }
                            }
                        }
                    });

                    // Bar Chart Gradients
                    const hnBarGrad = ctxBar.createLinearGradient(0, 0, 0, 300);
                    hnBarGrad.addColorStop(0, '#4490d1'); hnBarGrad.addColorStop(1, '#0b6cb3');
                    const dnBarGrad = ctxBar.createLinearGradient(0, 0, 0, 300);
                    dnBarGrad.addColorStop(0, '#34d399'); dnBarGrad.addColorStop(1, '#10b981');
                    const hcmBarGrad = ctxBar.createLinearGradient(0, 0, 0, 300);
                    hcmBarGrad.addColorStop(0, '#fcd34d'); hcmBarGrad.addColorStop(1, '#f59e0b');

                    new Chart(ctxBar, {
                        type: 'bar',
                        data: {
                            labels: monthlyLabels,
                            datasets: [
                                { label: 'Hà Nội', data: hnMonthly, backgroundColor: hnBarGrad, borderRadius: 4 },
                                { label: 'Đà Nẵng', data: dnMonthly, backgroundColor: dnBarGrad, borderRadius: 4 },
                                { label: 'TP.HCM', data: hcmMonthly, backgroundColor: hcmBarGrad, borderRadius: 4 }
                            ]
                        },
                        options: {
                            ...commonOptions,
                            scales: {
                                x: { stacked: true, grid: { display: false } },
                                y: { stacked: true, grid: { color: 'rgba(0,0,0,0.04)' } }
                            }
                        }
                    });
                }

                // Render Table with Pagination if on History view
                if (document.getElementById('historyTableBody')) {
                    const tbody = document.getElementById('historyTableBody');
                    const dailyDataInfo = ${ not empty dailyJson ?dailyJson: '[]'};
                    const ROWS_PER_PAGE = 20;
                    let currentPage = 1;
                    let totalPages = Math.max(1, Math.ceil(dailyDataInfo.length / ROWS_PER_PAGE));

                    function renderPage(page) {
                        currentPage = page;
                        const start = (page - 1) * ROWS_PER_PAGE;
                        const end = Math.min(start + ROWS_PER_PAGE, dailyDataInfo.length);
                        const pageData = dailyDataInfo.slice(start, end);

                        if (pageData.length > 0) {
                            let html = '';
                            pageData.forEach(row => {
                                let displayDate = row.date.split(' ')[0];
                                html += `<tr>
                                    <td style="padding: 1rem; border-bottom: 1px solid var(--border-color);"><strong>\${displayDate}</strong></td>
                                    <td style="text-align: center; padding: 1rem; border-bottom: 1px solid var(--border-color);">\${row.hn}</td>
                                    <td style="text-align: center; padding: 1rem; border-bottom: 1px solid var(--border-color);">\${row.dn}</td>
                                    <td style="text-align: center; padding: 1rem; border-bottom: 1px solid var(--border-color);">\${row.hcm}</td>
                                </tr>`;
                            });
                            tbody.innerHTML = html;
                        } else {
                            tbody.innerHTML = '<tr><td colspan="4" class="text-center text-muted" style="padding: 2rem;">No data available for this range. Please adjust the filters.</td></tr>';
                        }

                        // Update pagination controls
                        const controls = document.getElementById('paginationControls');
                        if (dailyDataInfo.length > ROWS_PER_PAGE) {
                            controls.style.display = 'flex';
                            document.getElementById('pageInfo').textContent =
                                'Hiển thị ' + (start + 1) + '–' + end + ' / ' + dailyDataInfo.length + ' bản ghi';
                            document.getElementById('prevPageBtn').disabled = (page <= 1);
                            document.getElementById('nextPageBtn').disabled = (page >= totalPages);
                            document.getElementById('prevPageBtn').style.opacity = (page <= 1) ? '0.5' : '1';
                            document.getElementById('nextPageBtn').style.opacity = (page >= totalPages) ? '0.5' : '1';

                            // Page number buttons
                            let numHtml = '';
                            const maxVisible = 5;
                            let startPage = Math.max(1, page - Math.floor(maxVisible / 2));
                            let endPage = Math.min(totalPages, startPage + maxVisible - 1);
                            if (endPage - startPage < maxVisible - 1) startPage = Math.max(1, endPage - maxVisible + 1);

                            for (let i = startPage; i <= endPage; i++) {
                                const isActive = i === page;
                                numHtml += '<button onclick="renderPage(' + i + ')" style="width:32px;height:32px;border-radius:8px;border:' +
                                    (isActive ? '1.5px solid var(--primary-color)' : '1px solid var(--border-color)') +
                                    ';background:' + (isActive ? 'var(--primary-color)' : '#fff') +
                                    ';color:' + (isActive ? '#fff' : 'var(--text-muted)') +
                                    ';font-size:0.82rem;font-weight:600;cursor:pointer;transition:all 0.2s;">' + i + '</button>';
                            }
                            document.getElementById('pageNumbers').innerHTML = numHtml;
                        } else {
                            controls.style.display = 'none';
                        }
                    }

                    function changePage(delta) {
                        const newPage = currentPage + delta;
                        if (newPage >= 1 && newPage <= totalPages) renderPage(newPage);
                    }

                    // Initial render
                    if (dailyDataInfo.length > 0) {
                        renderPage(1);
                    } else {
                        tbody.innerHTML = '<tr><td colspan="4" class="text-center text-muted" style="padding: 2rem;">No data available for this range. Please adjust the filters.</td></tr>';
                    }
                }
            </script>

            </div> <!-- close .layout -->

            <!-- ── Upgrade Modal (outside .layout for proper fixed positioning) ── -->
            <div id="upgradeModal" style="display:none;position:fixed;inset:0;z-index:9999;
        background:rgba(15,23,42,0.55);backdrop-filter:blur(4px);
        align-items:center;justify-content:center;">
                <div style="background:#fff;border-radius:18px;padding:2.5rem 2rem;max-width:780px;width:94%;
            box-shadow:0 25px 60px rgba(0,0,0,0.2);position:relative;max-height:90vh;overflow-y:auto;">
                    <!-- Close -->
                    <button onclick="closeUpgradeModal()" style="position:absolute;top:1rem;right:1.2rem;
                background:none;border:none;font-size:1.5rem;cursor:pointer;color:#94a3b8;">×</button>

                    <div style="text-align:center;margin-bottom:1.5rem;">
                        <i class="fa-solid fa-crown" style="font-size:2rem;color:#f59e0b;margin-bottom:0.5rem;"></i>
                        <h2 style="margin:0;font-size:1.6rem;">Upgrade to Pro</h2>
                        <p style="color:#64748b;font-size:0.9rem;margin-top:0.4rem;">Unlock AI Forecasting &amp; Chatbot
                        </p>
                    </div>

                    <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:1rem;">
                        <!-- Free -->
                        <div style="border:1.5px solid #e2e8f0;border-radius:12px;padding:1.25rem;">
                            <h3 style="font-size:1rem;margin:0 0 0.5rem;">Free Tier</h3>
                            <div style="font-size:1.8rem;font-weight:800;margin-bottom:1rem;">0đ<span
                                    style="font-size:0.9rem;font-weight:400;color:#94a3b8;">/month</span></div>
                            <ul
                                style="list-style:none;padding:0;margin:0 0 1.2rem;font-size:0.87rem;display:flex;flex-direction:column;gap:5px;">
                                <li><i class="fa-solid fa-check" style="color:#10b981;"></i> Historical Data</li>
                                <li><i class="fa-solid fa-check" style="color:#10b981;"></i> Basic Charts</li>
                                <li style="color:#94a3b8;"><i class="fa-solid fa-xmark" style="color:#ef4444;"></i> AI
                                    Forecasting</li>
                                <li style="color:#94a3b8;"><i class="fa-solid fa-xmark" style="color:#ef4444;"></i> AI
                                    Chatbot</li>
                            </ul>
                            <span
                                style="display:block;text-align:center;padding:0.5rem;border:1.5px solid #e2e8f0;border-radius:8px;color:#94a3b8;font-size:0.85rem;">Current
                                Plan</span>
                        </div>
                        <!-- Pro Monthly -->
                        <div
                            style="border:2px solid #0b6cb3;border-radius:12px;padding:1.25rem;position:relative;background:rgba(11,108,179,0.03); box-shadow: 0 0 20px rgba(11,108,179,0.15); transform: scale(1.02);">
                            <span
                                style="position:absolute;top:-11px;left:50%;transform:translateX(-50%);
                        background: linear-gradient(135deg, #0b6cb3 0%, #4490d1 100%);color:#fff;font-size:0.72rem;font-weight:700;
                        padding:3px 12px;border-radius:999px; box-shadow: 0 4px 10px rgba(11,108,179,0.3);">POPULAR</span>
                            <h3 style="font-size:1rem;margin:0 0 0.5rem;color:#0b6cb3;">Pro Monthly</h3>
                            <div style="font-size:1.8rem;font-weight:800;margin-bottom:1rem;color:#0b6cb3;">50k<span
                                    style="font-size:0.9rem;font-weight:400;color:#94a3b8;">/month</span></div>
                            <ul
                                style="list-style:none;padding:0;margin:0 0 1.2rem;font-size:0.87rem;display:flex;flex-direction:column;gap:5px;">
                                <li><i class="fa-solid fa-check" style="color:#10b981;"></i> All Free features</li>
                                <li><i class="fa-solid fa-check" style="color:#10b981;"></i> AI Prophet Forecasting</li>
                                <li><i class="fa-solid fa-check" style="color:#10b981;"></i> AI Chatbot Assistant</li>
                                <li><i class="fa-solid fa-check" style="color:#10b981;"></i> Risk Warnings</li>
                            </ul>
                            <form action="PaymentServlet" method="GET">
                                <input type="hidden" name="packageId" value="2">
                                <button type="submit" style="width:100%;background:#0b6cb3;color:#fff;
                            border:none;border-radius:8px;padding:0.55rem;font-weight:600;
                            font-size:0.9rem;cursor:pointer;">
                                    Upgrade Now
                                </button>
                            </form>
                        </div>
                        <!-- Pro Yearly -->
                        <div style="border:1.5px solid #e2e8f0;border-radius:12px;padding:1.25rem;">
                            <h3 style="font-size:1rem;margin:0 0 0.5rem;">Pro Yearly</h3>
                            <div style="font-size:1.8rem;font-weight:800;margin-bottom:1rem;">500k<span
                                    style="font-size:0.9rem;font-weight:400;color:#94a3b8;">/year</span></div>
                            <ul
                                style="list-style:none;padding:0;margin:0 0 1.2rem;font-size:0.87rem;display:flex;flex-direction:column;gap:5px;">
                                <li><i class="fa-solid fa-check" style="color:#10b981;"></i> All Pro features</li>
                                <li><i class="fa-solid fa-check" style="color:#10b981;"></i> Save 100k/year</li>
                                <li><i class="fa-solid fa-check" style="color:#10b981;"></i> Priority Support</li>
                            </ul>
                            <form action="PaymentServlet" method="GET">
                                <input type="hidden" name="packageId" value="3">
                                <button type="submit" style="width:100%;background:#fff;color:#374151;
                            border:1.5px solid #e2e8f0;border-radius:8px;padding:0.55rem;font-weight:600;
                            font-size:0.9rem;cursor:pointer;">
                                    Upgrade Yearly
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>

            <script>
                function openUpgradeModal() {
                    var m = document.getElementById('upgradeModal');
                    m.style.display = 'flex';
                    document.body.style.overflow = 'hidden';
                }
                function closeUpgradeModal() {
                    var m = document.getElementById('upgradeModal');
                    m.style.display = 'none';
                    document.body.style.overflow = '';
                }
                // Close on backdrop click
                document.getElementById('upgradeModal').addEventListener('click', function (e) {
                    if (e.target === this) closeUpgradeModal();
                });
                // Auto-open if redirected from a gated feature
                if (window.location.search.indexOf('upgradeRequired=true') !== -1) {
                    openUpgradeModal();
                }
            </script>

        </body>

        </html>