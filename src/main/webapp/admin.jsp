<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Admin Panel - Rainfall Analytics</title>
            <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
                rel="stylesheet">
            <link rel="stylesheet" href="css/style.css">
            <style>
                .admin-table {
                    width: 100%;
                    text-align: left;
                }

                .admin-table th,
                .admin-table td {
                    text-align: left !important;
                    vertical-align: middle !important;
                    padding: 1rem 0.75rem;
                }
            </style>
        </head>

        <body class="admin-theme">

            <div class="dashboard-container">
                <!-- Admin Sidebar -->
                <aside class="sidebar">
                    <div class="sidebar-header">
                        <a href="index.jsp" class="logo">
                            <i class="fa-solid fa-lock"></i> Admin Panel
                        </a>
                    </div>
                    <ul class="sidebar-menu">
                        <li><a href="AdminServlet?action=dashboard"
                                class="${adminPage == 'dashboard' || empty adminPage ? 'active' : ''}">
                                <i class="fa-solid fa-chart-line"></i> Dashboard</a></li>
                        <li><a href="AdminServlet?action=manageStations"
                                class="${adminPage == 'manageStations' ? 'active' : ''}">
                                <i class="fa-solid fa-map-location-dot"></i> Manage Stations</a></li>
                        <li><a href="AdminServlet?action=rainfallData"
                                class="${adminPage == 'rainfallData' ? 'active' : ''}">
                                <i class="fa-solid fa-database"></i> Rainfall Data</a></li>
                        <li><a href="AdminServlet?action=forecastLogs"
                                class="${adminPage == 'forecastLogs' ? 'active' : ''}">
                                <i class="fa-solid fa-list"></i> Forecast Logs</a></li>
                        <li><a href="AdminServlet?action=manageUsers"
                                class="${adminPage == 'manageUsers' ? 'active' : ''}">
                                <i class="fa-solid fa-users"></i> User Management</a></li>
                        <li><a href="AdminServlet?action=manageOrders"
                                class="${adminPage == 'manageOrders' ? 'active' : ''}">
                                <i class="fa-solid fa-receipt"></i> Orders</a></li>
                        <li><a href="AuthServlet?action=logout">
                                <i class="fa-solid fa-arrow-right-from-bracket"></i> Logout</a></li>
                    </ul>
                </aside>

                <!-- Main Content -->
                <main class="main-content">
                    <header class="page-header">
                        <div>
                            <c:choose>
                                <c:when test="${adminPage == 'manageUsers'}">
                                    <h1>User Management</h1>
                                    <p class="text-muted">Quản lý tài khoản người dùng</p>
                                </c:when>
                                <c:when test="${adminPage == 'manageOrders'}">
                                    <h1>Order Management</h1>
                                    <p class="text-muted">Quản lý đơn hàng thanh toán</p>
                                </c:when>
                                <c:when test="${adminPage == 'manageStations'}">
                                    <h1>Station Management</h1>
                                    <p class="text-muted">Quản lý trạm quan trắc</p>
                                </c:when>
                                <c:when test="${adminPage == 'rainfallData'}">
                                    <h1>Rainfall Data</h1>
                                    <p class="text-muted">Dữ liệu lượng mưa thực tế</p>
                                </c:when>
                                <c:when test="${adminPage == 'forecastLogs'}">
                                    <h1>Forecast Logs</h1>
                                    <p class="text-muted">Nhật ký dự báo AI</p>
                                </c:when>
                                <c:otherwise>
                                    <h1>Admin Dashboard</h1>
                                    <p class="text-muted">System Management & Analytics</p>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="user-profile">
                            <span class="badge"
                                style="background-color: var(--danger-color); color: white;">ADMIN</span>
                            <div class="avatar" style="background-color: var(--danger-color);">A</div>
                        </div>
                    </header>

                    <!-- Success/Error Message -->
                    <c:if test="${not empty message}">
                        <div class="card mb-4" style="border-left: 4px solid var(--success-color);">
                            <p class="text-success" style="margin: 0;">${message}</p>
                        </div>
                    </c:if>

                    <!-- ═══════════════════════════════════════════════════
                 DASHBOARD
                 ═══════════════════════════════════════════════════ -->
                    <c:if test="${adminPage == 'dashboard' || empty adminPage}">

                        <div class="grid-3 mb-4">
                            <div class="card">
                                <h3 class="card-title text-muted">Total Users</h3>
                                <div class="card-value">${totalUsers}</div>
                            </div>
                            <div class="card">
                                <h3 class="card-title text-muted">Pro Subscriptions</h3>
                                <div class="card-value">${proUsers}</div>
                            </div>
                            <div class="card">
                                <h3 class="card-title text-muted">Data Records</h3>
                                <div class="card-value">${dataCount}</div>
                            </div>
                        </div>

                        <!-- System Controls -->
                        <div class="grid-2 mb-4">
                            <!-- Train AI Card -->
                            <div class="card text-center" style="border-top: 4px solid var(--primary-color);">
                                <h3><i class="fa-solid fa-brain"></i> AI Engine Control</h3>
                                <p class="text-muted mt-2 mb-4">Retrain the Prophet model with the latest historical
                                    data.</p>
                                <form action="AdminServlet" method="POST">
                                    <input type="hidden" name="action" value="trainAI">
                                    <button class="btn btn-primary"><i class="fa-solid fa-play"></i> Train Forecast
                                        Model</button>
                                </form>
                            </div>

                            <!-- Import Data Card -->
                            <div class="card text-center" style="border-top: 4px solid var(--success-color);">
                                <h3><i class="fa-solid fa-file-csv"></i> Data Import</h3>
                                <p class="text-muted mt-2 mb-4">Upload new daily rainfall data via CSV.</p>
                                <form action="AdminServlet" method="POST" enctype="multipart/form-data">
                                    <input type="hidden" name="action" value="importCSV">
                                    <div style="margin-bottom: 1rem;">
                                        <input type="file" name="file" class="form-control" required
                                            style="background: var(--bg-dark); color: white; border: 1px solid var(--border-color);">
                                    </div>
                                    <button class="btn btn-primary" style="background-color: var(--success-color);"><i
                                            class="fa-solid fa-upload"></i> Upload CSV</button>
                                </form>
                            </div>
                        </div>

                        <!-- Recent Logs Table -->
                        <div class="card">
                            <div class="d-flex justify-between align-center mb-4">
                                <h3 class="card-title" style="margin: 0;">Recent Forecast Logs</h3>
                                <a href="AdminServlet?action=forecastLogs" class="btn btn-outline"
                                    style="padding: 0.25rem 0.75rem; font-size: 0.8rem;">View All</a>
                            </div>
                            <div class="table-responsive">
                                <table class="admin-table">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Station</th>
                                            <th>Target Month</th>
                                            <th>Prediction</th>
                                            <th>Risk Level</th>
                                            <th>Generated At</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${empty recentLogs}">
                                                <tr>
                                                    <td colspan="6"
                                                        style="text-align:center; color: var(--text-muted);">Chưa có dữ
                                                        liệu forecast</td>
                                                </tr>
                                            </c:when>
                                            <c:otherwise>
                                                <c:forEach var="log" items="${recentLogs}">
                                                    <tr>
                                                        <td>${log.forecastID}</td>
                                                        <td>Station ${log.stationID}</td>
                                                        <td>${log.forecastMonth}</td>
                                                        <td>${log.predictedRainfall}mm</td>
                                                        <td>${log.riskLevel}</td>
                                                        <td>${log.createdAt}</td>
                                                    </tr>
                                                </c:forEach>
                                            </c:otherwise>
                                        </c:choose>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                    </c:if>

                    <!-- ═══════════════════════════════════════════════════
                 MANAGE USERS
                 ═══════════════════════════════════════════════════ -->
                    <c:if test="${adminPage == 'manageUsers'}">

                        <!-- Create User Form -->
                        <div class="card mb-4"
                            style="background:var(--bg-white); padding:1.5rem; border-radius:12px; border:1px solid var(--border-color);">
                            <h3 class="card-title mb-3">Tạo User mới</h3>
                            <form action="AdminServlet" method="POST"
                                style="display:flex; gap:1rem; align-items:flex-end; flex-wrap:wrap;">
                                <input type="hidden" name="action" value="createUser">
                                <div>
                                    <label
                                        style="font-size:0.8rem; font-weight:600; color:var(--text-muted); display:block; margin-bottom:0.3rem;">Username</label>
                                    <input type="text" name="username" class="form-control" required
                                        style="padding:0.4rem 0.8rem; border-radius:6px; border:1px solid var(--border-color);">
                                </div>
                                <div>
                                    <label
                                        style="font-size:0.8rem; font-weight:600; color:var(--text-muted); display:block; margin-bottom:0.3rem;">Email</label>
                                    <input type="email" name="email" class="form-control" required
                                        style="padding:0.4rem 0.8rem; border-radius:6px; border:1px solid var(--border-color);">
                                </div>
                                <div>
                                    <label
                                        style="font-size:0.8rem; font-weight:600; color:var(--text-muted); display:block; margin-bottom:0.3rem;">Password</label>
                                    <input type="text" name="password" class="form-control" required
                                        style="padding:0.4rem 0.8rem; border-radius:6px; border:1px solid var(--border-color);">
                                </div>
                                <div>
                                    <label
                                        style="font-size:0.8rem; font-weight:600; color:var(--text-muted); display:block; margin-bottom:0.3rem;">Role</label>
                                    <select name="role" class="form-control"
                                        style="padding:0.4rem 0.8rem; border-radius:6px; border:1px solid var(--border-color);">
                                        <option value="Customer">Customer</option>
                                        <option value="Admin">Admin</option>
                                    </select>
                                </div>
                                <div>
                                    <label
                                        style="font-size:0.8rem; font-weight:600; color:var(--text-muted); display:block; margin-bottom:0.3rem;">Tier</label>
                                    <select name="tier" class="form-control"
                                        style="padding:0.4rem 0.8rem; border-radius:6px; border:1px solid var(--border-color);">
                                        <option value="Free">Free</option>
                                        <option value="Pro">Pro</option>
                                    </select>
                                </div>
                                <button type="submit" class="btn btn-success"
                                    style="padding:0.4rem 1.2rem; background:var(--success-color, #10b981); color:white; border:none; border-radius:6px; margin-bottom:1px;">
                                    <i class="fa-solid fa-plus"></i> Add User
                                </button>
                            </form>
                        </div>

                        <div class="card">
                            <h3 class="card-title mb-4">Danh sách Users (${userList.size()} tài khoản)</h3>
                            <div class="table-responsive">
                                <!-- Define forms outside the table -->
                                <c:forEach var="u" items="${userList}">
                                    <form id="form_user_${u.userID}" action="AdminServlet" method="POST">
                                        <input type="hidden" name="action" value="updateUser">
                                        <input type="hidden" name="userId" value="${u.userID}">
                                    </form>
                                </c:forEach>

                                <table class="admin-table">
                                    <thead>
                                        <tr>
                                            <th style="width:5%;">ID</th>
                                            <th style="width:20%;">Username</th>
                                            <th style="width:25%;">Email</th>
                                            <th style="width:15%;">Role</th>
                                            <th style="width:15%;">Tier</th>
                                            <th style="width:10%;">Expiry</th>
                                            <th style="width:10%;">Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="u" items="${userList}">
                                            <tr>
                                                <td>${u.userID}</td>
                                                <td>
                                                    <input form="form_user_${u.userID}" type="text" name="username"
                                                        value="${u.username}" class="form-control"
                                                        style="padding:0.3rem; background:var(--bg-white); color:var(--text-main); border:1px solid var(--border-color); border-radius:4px; font-weight:600; width:100%;"
                                                        required>
                                                </td>
                                                <td>
                                                    <input form="form_user_${u.userID}" type="email" name="email"
                                                        value="${u.email}" class="form-control"
                                                        style="padding:0.3rem; background:var(--bg-white); color:var(--text-main); border:1px solid var(--border-color); border-radius:4px; width:100%;"
                                                        required>
                                                </td>
                                                <td>
                                                    <select form="form_user_${u.userID}" name="role"
                                                        class="form-control"
                                                        style="padding:0.3rem; background:var(--bg-white); color:var(--text-main); border:1px solid var(--border-color); border-radius:4px;">
                                                        <option value="Customer" ${u.role=='Customer' ? 'selected' : ''
                                                            }>Customer</option>
                                                        <option value="Admin" ${u.role=='Admin' ? 'selected' : '' }>
                                                            Admin</option>
                                                    </select>
                                                </td>
                                                <td>
                                                    <select form="form_user_${u.userID}" name="tier"
                                                        class="form-control"
                                                        style="padding:0.3rem; background:var(--bg-white); color:var(--text-main); border:1px solid var(--border-color); border-radius:4px;">
                                                        <option value="Free" ${u.tier=='Free' ? 'selected' : '' }>Free
                                                        </option>
                                                        <option value="Pro" ${u.tier=='Pro' ? 'selected' : '' }>Pro
                                                        </option>
                                                    </select>
                                                </td>
                                                <td>
                                                    <input form="form_user_${u.userID}" type="date" name="expiryDate"
                                                        value="${u.expiryDate}" class="form-control"
                                                        style="padding:0.3rem; background:var(--bg-white); color:var(--text-main); border:1px solid var(--border-color); border-radius:4px;">
                                                </td>
                                                <td style="display:flex; gap:0.5rem; align-items:center;">
                                                    <button form="form_user_${u.userID}" type="submit"
                                                        class="btn btn-primary"
                                                        style="padding:0.3rem 0.6rem; font-size:0.8rem;">
                                                        <i class="fa-solid fa-save"></i> Save
                                                    </button>
                                                    <form action="AdminServlet" method="POST" style="margin:0;"
                                                        onsubmit="return confirm('Bạn có chắc chắn muốn xoá user này?');">
                                                        <input type="hidden" name="action" value="deleteUser">
                                                        <input type="hidden" name="userId" value="${u.userID}">
                                                        <button type="submit" class="btn btn-danger"
                                                            style="padding:0.3rem 0.6rem; font-size:0.8rem; background:var(--danger-color, #ef4444); color:white; border:none; border-radius:4px;">
                                                            <i class="fa-solid fa-trash"></i> Del
                                                        </button>
                                                    </form>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </c:if>

                    <!-- ═══════════════════════════════════════════════════
                 MANAGE ORDERS
                 ═══════════════════════════════════════════════════ -->
                    <c:if test="${adminPage == 'manageOrders'}">
                        <div class="card">
                            <h3 class="card-title mb-4">Danh sách Orders (${orderList.size()} đơn)</h3>
                            <div class="table-responsive">
                                <table class="admin-table">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>UserID</th>
                                            <th>Amount</th>
                                            <th>Status</th>
                                            <th>Transaction</th>
                                            <th>Payment Ref</th>
                                            <th>Order Date</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${empty orderList}">
                                                <tr>
                                                    <td colspan="7"
                                                        style="text-align:center; color: var(--text-muted);">Chưa có đơn
                                                        hàng</td>
                                                </tr>
                                            </c:when>
                                            <c:otherwise>
                                                <c:forEach var="o" items="${orderList}">
                                                    <tr>
                                                        <td>${o.orderID}</td>
                                                        <td>${o.userID}</td>
                                                        <td style="font-weight:600;">${o.amount} ₫</td>
                                                        <td>
                                                            <span class="badge"
                                                                style="background-color: ${o.status == 'Completed' ? 'var(--success-color)' : o.status == 'Pending' ? '#f59e0b' : 'var(--danger-color)'}; color:white; padding:0.2rem 0.5rem; border-radius:4px; font-size:0.75rem;">
                                                                ${o.status}
                                                            </span>
                                                        </td>
                                                        <td style="font-size:0.85rem;">${o.transactionCode}</td>
                                                        <td style="font-size:0.85rem;">${o.paymentReference}</td>
                                                        <td>${o.orderDate}</td>
                                                    </tr>
                                                </c:forEach>
                                            </c:otherwise>
                                        </c:choose>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </c:if>

                    <!-- ═══════════════════════════════════════════════════
                 MANAGE STATIONS
                 ═══════════════════════════════════════════════════ -->
                    <c:if test="${adminPage == 'manageStations'}">

                        <!-- Create Station Form -->
                        <div class="card mb-4"
                            style="background:var(--bg-white); padding:1.5rem; border-radius:12px; border:1px solid var(--border-color);">
                            <h3 class="card-title mb-3">Tạo Trạm mới</h3>
                            <form action="AdminServlet" method="POST"
                                style="display:flex; gap:1rem; align-items:flex-end; flex-wrap:wrap;">
                                <input type="hidden" name="action" value="createStation">
                                <div>
                                    <label
                                        style="font-size:0.8rem; font-weight:600; color:var(--text-muted); display:block; margin-bottom:0.3rem;">Station
                                        ID</label>
                                    <input type="number" name="stationId" class="form-control" required
                                        style="padding:0.4rem 0.8rem; border-radius:6px; border:1px solid var(--border-color); width:100px;">
                                </div>
                                <div style="flex-grow:1;">
                                    <label
                                        style="font-size:0.8rem; font-weight:600; color:var(--text-muted); display:block; margin-bottom:0.3rem;">Station
                                        Name</label>
                                    <input type="text" name="stationName" class="form-control" required
                                        style="padding:0.4rem 0.8rem; border-radius:6px; border:1px solid var(--border-color); width:100%;">
                                </div>
                                <div>
                                    <label
                                        style="font-size:0.8rem; font-weight:600; color:var(--text-muted); display:block; margin-bottom:0.3rem;">Region</label>
                                    <select name="region" class="form-control"
                                        style="padding:0.4rem 0.8rem; border-radius:6px; border:1px solid var(--border-color);">
                                        <option value="North">North</option>
                                        <option value="Central">Central</option>
                                        <option value="South">South</option>
                                    </select>
                                </div>
                                <button type="submit" class="btn btn-success"
                                    style="padding:0.4rem 1.2rem; background:var(--success-color, #10b981); color:white; border:none; border-radius:6px; margin-bottom:1px;">
                                    <i class="fa-solid fa-plus"></i> Add Station
                                </button>
                            </form>
                        </div>

                        <div class="card">
                            <h3 class="card-title mb-4">Danh sách Stations (${stationList.size()} trạm)</h3>
                            <div class="table-responsive">
                                <!-- Define forms outside the table -->
                                <c:forEach var="s" items="${stationList}">
                                    <form id="form_station_${s.stationID}" action="AdminServlet" method="POST">
                                        <input type="hidden" name="action" value="updateStation">
                                        <input type="hidden" name="stationId" value="${s.stationID}">
                                    </form>
                                </c:forEach>

                                <table class="admin-table">
                                    <thead>
                                        <tr>
                                            <th style="width:10%;">ID</th>
                                            <th style="width:40%;">Station Name</th>
                                            <th style="width:30%;">Region</th>
                                            <th style="width:20%;">Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="s" items="${stationList}">
                                            <tr>
                                                <td>${s.stationID}</td>
                                                <td>
                                                    <input form="form_station_${s.stationID}" type="text"
                                                        name="stationName" value="${s.stationName}" class="form-control"
                                                        style="padding:0.3rem; background:var(--bg-white); color:var(--text-main); border:1px solid var(--border-color); border-radius:4px; width:100%;">
                                                </td>
                                                <td>
                                                    <select form="form_station_${s.stationID}" name="region"
                                                        class="form-control"
                                                        style="padding:0.3rem; background:var(--bg-white); color:var(--text-main); border:1px solid var(--border-color); border-radius:4px; width:100%;">
                                                        <option value="North" ${s.region=='North' ? 'selected' : '' }>
                                                            North</option>
                                                        <option value="Central" ${s.region=='Central' ? 'selected' : ''
                                                            }>Central</option>
                                                        <option value="South" ${s.region=='South' ? 'selected' : '' }>
                                                            South</option>
                                                    </select>
                                                </td>
                                                <td style="display:flex; gap:0.5rem; align-items:center;">
                                                    <button form="form_station_${s.stationID}" type="submit"
                                                        class="btn btn-primary"
                                                        style="padding:0.3rem 0.6rem; font-size:0.8rem;">
                                                        <i class="fa-solid fa-save"></i> Save
                                                    </button>
                                                    <form action="AdminServlet" method="POST" style="margin:0;"
                                                        onsubmit="return confirm('Bạn có chắc chắn muốn xoá trạm này? Nếu Database có trigger, RainfallData và ForecastLogs của trạm sẽ tự bị xoá.');">
                                                        <input type="hidden" name="action" value="deleteStation">
                                                        <input type="hidden" name="stationId" value="${s.stationID}">
                                                        <button type="submit" class="btn btn-danger"
                                                            style="padding:0.3rem 0.6rem; font-size:0.8rem; background:var(--danger-color, #ef4444); color:white; border:none; border-radius:4px;">
                                                            <i class="fa-solid fa-trash"></i> Del
                                                        </button>
                                                    </form>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </c:if>

                    <!-- ═══════════════════════════════════════════════════
                 RAINFALL DATA
                 ═══════════════════════════════════════════════════ -->
                    <c:if test="${adminPage == 'rainfallData'}">
                        <!-- Filter by Station -->
                        <div class="card mb-4">
                            <h3 class="card-title mb-4">Lọc theo trạm</h3>
                            <form action="AdminServlet" method="GET"
                                style="display:flex; gap:1rem; align-items:center; flex-wrap:wrap;">
                                <input type="hidden" name="action" value="rainfallData">
                                <select name="stationId" class="form-control"
                                    style="padding:0.4rem; background:var(--bg-white); color:var(--text-main); border:1px solid var(--border-color); border-radius:4px; width:200px;">
                                    <option value="">-- Tất cả --</option>
                                    <c:forEach var="s" items="${stationList}">
                                        <option value="${s.stationID}" ${selectedStationId==s.stationID ? 'selected'
                                            : '' }>${s.stationName} (${s.region})</option>
                                    </c:forEach>
                                </select>
                                <button type="submit" class="btn btn-primary" style="padding:0.4rem 1rem;"><i
                                        class="fa-solid fa-filter"></i> Lọc</button>
                            </form>
                        </div>

                        <div class="card">
                            <h3 class="card-title mb-4">Dữ liệu lượng mưa (${rainfallList.size()} bản ghi)</h3>
                            <div class="table-responsive">
                                <table class="admin-table">
                                    <thead>
                                        <tr>
                                            <th>LogID</th>
                                            <th>StationID</th>
                                            <th>Measure Date</th>
                                            <th>Rainfall (mm)</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${empty rainfallList}">
                                                <tr>
                                                    <td colspan="4"
                                                        style="text-align:center; color: var(--text-muted);">Không có dữ
                                                        liệu</td>
                                                </tr>
                                            </c:when>
                                            <c:otherwise>
                                                <c:forEach var="r" items="${rainfallList}">
                                                    <tr>
                                                        <td>${r.logID}</td>
                                                        <td>${r.stationID}</td>
                                                        <td>${r.measureDate}</td>
                                                        <td style="font-weight:600;">${r.rainfallMM} mm</td>
                                                    </tr>
                                                </c:forEach>
                                            </c:otherwise>
                                        </c:choose>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </c:if>

                    <!-- ═══════════════════════════════════════════════════
                 FORECAST LOGS
                 ═══════════════════════════════════════════════════ -->
                    <c:if test="${adminPage == 'forecastLogs'}">
                        <div class="card">
                            <h3 class="card-title mb-4">Tất cả Forecast Logs (${forecastLogList.size()} bản ghi)</h3>
                            <div class="table-responsive">
                                <table class="admin-table">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Station</th>
                                            <th>Forecast Month</th>
                                            <th>Predicted Rainfall</th>
                                            <th>Risk Level</th>
                                            <th>Created At</th>
                                            <th style="width:10%;">Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${empty forecastLogList}">
                                                <tr>
                                                    <td colspan="6"
                                                        style="text-align:center; color: var(--text-muted);">Chưa có log
                                                        dự báo</td>
                                                </tr>
                                            </c:when>
                                            <c:otherwise>
                                                <c:forEach var="log" items="${forecastLogList}">
                                                    <tr>
                                                        <td>${log.forecastID}</td>
                                                        <td>
                                                            <c:forEach var="s" items="${stationList}">
                                                                <c:if test="${s.stationID == log.stationID}">
                                                                    ${s.stationName}</c:if>
                                                            </c:forEach>
                                                        </td>
                                                        <td>${log.forecastMonth}</td>
                                                        <td style="font-weight:600;">${log.predictedRainfall} mm</td>
                                                        <td>
                                                            <span class="badge"
                                                                style="padding:0.2rem 0.5rem; border-radius:4px; font-size:0.75rem;
                                                        background-color: ${log.riskLevel.contains('ngập') || log.riskLevel.contains('Nguy') ? 'var(--danger-color)' :
                                                        log.riskLevel.contains('lớn') || log.riskLevel.contains('Mưa') ? '#f59e0b' : 'var(--success-color)'}; color:white;">
                                                                ${log.riskLevel}
                                                            </span>
                                                        </td>
                                                        <td>${log.createdAt}</td>
                                                        <td style="text-align:center;">
                                                            <form action="AdminServlet" method="POST" style="margin:0;"
                                                                onsubmit="return confirm('Xoá bản ghi dự báo này?');">
                                                                <input type="hidden" name="action"
                                                                    value="deleteForecastLog">
                                                                <input type="hidden" name="forecastId"
                                                                    value="${log.forecastID}">
                                                                <button type="submit" class="btn btn-danger"
                                                                    style="padding:0.25rem 0.5rem; font-size:0.75rem; background:var(--danger-color, #ef4444); color:white; border:none; border-radius:4px;">
                                                                    <i class="fa-solid fa-trash"></i>
                                                                </button>
                                                            </form>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </c:otherwise>
                                        </c:choose>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </c:if>

                </main>
            </div>

        </body>

        </html>