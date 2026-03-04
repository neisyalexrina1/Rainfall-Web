<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%-- Auth guard --%>
        <% model.User currentUser=(model.User) session.getAttribute("user"); if (currentUser==null) {
            response.sendRedirect("login.jsp"); return; } if ("Admin".equals(currentUser.getRole())) {
            response.sendRedirect("AdminServlet?action=dashboard"); return; } %>
            <%@ taglib uri="jakarta.tags.core" prefix="c" %>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Profile - Rainfall Analytics</title>
                    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"
                        rel="stylesheet">
                    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
                        rel="stylesheet">
                    <link rel="stylesheet" href="css/style.css">

                    <style>
                        .profile-header {
                            background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-dark) 100%);
                            color: white;
                            padding: 3rem 2rem;
                            border-radius: var(--border-radius);
                            margin-bottom: 2rem;
                            display: flex;
                            align-items: center;
                            gap: 2rem;
                        }

                        .profile-avatar-large {
                            width: 100px;
                            height: 100px;
                            background-color: rgba(255, 255, 255, 0.2);
                            color: white;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            font-size: 3rem;
                            font-weight: 700;
                            border-radius: 50%;
                            border: 4px solid rgba(255, 255, 255, 0.5);
                            position: relative;
                            overflow: visible;
                        }

                        .profile-avatar-large img {
                            width: 100%;
                            height: 100%;
                            border-radius: 50%;
                            object-fit: cover;
                        }

                        .avatar-camera-btn {
                            position: absolute;
                            bottom: -2px;
                            right: -2px;
                            width: 32px;
                            height: 32px;
                            background: #fff;
                            border: 2px solid var(--primary-color);
                            border-radius: 50%;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            cursor: pointer;
                            color: var(--primary-color);
                            font-size: 0.85rem;
                            transition: all 0.2s;
                            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
                        }

                        .avatar-camera-btn:hover {
                            background: var(--primary-color);
                            color: #fff;
                            transform: scale(1.1);
                        }

                        .profile-info h2 {
                            color: white;
                            margin-bottom: 0.25rem;
                            font-size: 2rem;
                        }

                        .profile-detail-row {
                            display: flex;
                            padding: 1rem 0;
                            border-bottom: 1px solid var(--border-color);
                        }

                        .profile-detail-row:last-child {
                            border-bottom: none;
                        }

                        .profile-detail-label {
                            width: 150px;
                            font-weight: 600;
                            color: var(--text-muted);
                        }

                        .profile-detail-value {
                            font-weight: 500;
                            color: var(--text-main);
                        }

                        /* Avatar Modal */
                        .avatar-modal-overlay {
                            display: none;
                            position: fixed;
                            inset: 0;
                            z-index: 9999;
                            background: rgba(15, 23, 42, 0.55);
                            backdrop-filter: blur(4px);
                            align-items: center;
                            justify-content: center;
                        }

                        .avatar-modal-overlay.show {
                            display: flex;
                        }

                        .avatar-modal {
                            background: #fff;
                            border-radius: 16px;
                            padding: 2rem;
                            max-width: 440px;
                            width: 92%;
                            box-shadow: 0 25px 60px rgba(0, 0, 0, 0.2);
                            animation: popIn 0.3s ease;
                        }

                        @keyframes popIn {
                            from {
                                transform: scale(0.85);
                                opacity: 0;
                            }

                            to {
                                transform: scale(1);
                                opacity: 1;
                            }
                        }

                        .avatar-preview {
                            width: 100px;
                            height: 100px;
                            border-radius: 50%;
                            background: #f1f5f9;
                            margin: 0 auto 1.2rem;
                            overflow: hidden;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            border: 3px solid var(--primary-color);
                        }

                        .avatar-preview img {
                            width: 100%;
                            height: 100%;
                            object-fit: cover;
                        }

                        .avatar-preview .placeholder-icon {
                            font-size: 2.5rem;
                            color: #cbd5e1;
                        }

                        .avatar-url-input {
                            width: 100%;
                            padding: 0.7rem 1rem;
                            border: 1.5px solid #e2e8f0;
                            border-radius: 10px;
                            font-size: 0.9rem;
                            outline: none;
                            transition: border-color 0.2s;
                            box-sizing: border-box;
                        }

                        .avatar-url-input:focus {
                            border-color: var(--primary-color);
                        }

                        .avatar-modal-actions {
                            display: flex;
                            gap: 0.75rem;
                            margin-top: 1.2rem;
                        }

                        .avatar-modal-actions button {
                            flex: 1;
                            padding: 0.6rem;
                            border-radius: 10px;
                            font-weight: 600;
                            font-size: 0.9rem;
                            cursor: pointer;
                            border: none;
                            transition: all 0.2s;
                        }

                        .btn-avatar-save {
                            background: var(--primary-color);
                            color: #fff;
                        }

                        .btn-avatar-save:hover {
                            opacity: 0.9;
                        }

                        .btn-avatar-cancel {
                            background: #f1f5f9;
                            color: #64748b;
                        }

                        .btn-avatar-cancel:hover {
                            background: #e2e8f0;
                        }

                        .btn-avatar-remove {
                            background: none;
                            color: #ef4444;
                            font-size: 0.82rem;
                            padding: 0.4rem;
                        }

                        .btn-avatar-remove:hover {
                            text-decoration: underline;
                        }

                        /* Toast */
                        .profile-toast {
                            position: fixed;
                            top: 1.5rem;
                            right: 1.5rem;
                            z-index: 99999;
                            padding: 0.8rem 1.2rem;
                            border-radius: 10px;
                            color: #fff;
                            font-weight: 600;
                            font-size: 0.88rem;
                            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
                            animation: slideIn 0.3s;
                            display: flex;
                            align-items: center;
                            gap: 0.5rem;
                        }

                        .profile-toast.success {
                            background: #059669;
                        }

                        .profile-toast.error {
                            background: #ef4444;
                        }

                        @keyframes slideIn {
                            from {
                                transform: translateX(100%);
                                opacity: 0;
                            }

                            to {
                                transform: translateX(0);
                                opacity: 1;
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
                                        <li><a href="ForecastServlet"><i class="fa-solid fa-wand-magic-sparkles"></i> AI
                                                Forecast</a></li>
                                        <li><a href="chatbot.jsp"><i class="fa-solid fa-robot"></i> AI Chatbot</a></li>
                                    </c:when>
                                    <c:otherwise>
                                        <li><a href="pricing.jsp" style="opacity:0.55;" title="Pro feature"><i
                                                    class="fa-solid fa-lock" style="font-size:0.8em;"></i> AI
                                                Forecast</a></li>
                                        <li><a href="pricing.jsp" style="opacity:0.55;" title="Pro feature"><i
                                                    class="fa-solid fa-lock" style="font-size:0.8em;"></i> AI
                                                Chatbot</a></li>
                                    </c:otherwise>
                                </c:choose>
                                <c:if test="${sessionScope.user.tier == 'Free'}">
                                    <li><a href="pricing.jsp" class="text-warning">
                                            <i class="fa-solid fa-crown"></i> Upgrade to Pro</a></li>
                                </c:if>
                                <li><a href="profile.jsp" class="active"><i class="fa-solid fa-user"></i> Profile</a>
                                </li>
                                <li><a href="AuthServlet?action=logout"><i
                                            class="fa-solid fa-arrow-right-from-bracket"></i>
                                        Logout</a></li>
                            </ul>
                        </aside>

                        <!-- Main Content -->
                        <main class="main-content">
                            <header class="page-header">
                                <div>
                                    <h1>Account Profile</h1>
                                    <p class="text-muted">Manage your personal information and subscription</p>
                                </div>
                                <div class="user-profile">
                                    <span class="badge ${sessionScope.user.tier == 'Pro' ? 'badge-pro' : 'badge-free'}">
                                        ${sessionScope.user.tier} Plan
                                    </span>
                                </div>
                            </header>

                            <c:choose>
                                <c:when test="${not empty sessionScope.user}">
                                    <div class="container" style="max-width: 800px; margin: 0 auto; padding-top: 1rem;">

                                        <div class="profile-header">
                                            <div class="profile-avatar-large" id="profileAvatar">
                                                <c:choose>
                                                    <c:when test="${not empty sessionScope.user.profileImage}">
                                                        <img src="${sessionScope.user.profileImage}" alt="Avatar"
                                                            id="avatarImg"
                                                            onerror="this.style.display='none';this.nextElementSibling.style.display='flex';">
                                                        <span id="avatarLetter" style="display:none;">
                                                            ${sessionScope.user.username.substring(0, 1).toUpperCase()}
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span id="avatarLetter">
                                                            ${sessionScope.user.username.substring(0, 1).toUpperCase()}
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                                <button class="avatar-camera-btn" onclick="openAvatarModal()"
                                                    title="Đổi ảnh đại diện">
                                                    <i class="fa-solid fa-camera"></i>
                                                </button>
                                            </div>
                                            <div class="profile-info">
                                                <h2>${sessionScope.user.username}</h2>
                                                <p style="color: rgba(255,255,255,0.8); font-size: 1.1rem;">
                                                    <i class="fa-solid fa-envelope"></i> ${sessionScope.user.email}
                                                </p>
                                            </div>
                                        </div>

                                        <div class="card mb-4" style="padding: 2rem;">
                                            <h3 class="card-title text-muted mb-4"
                                                style="border-bottom: 2px solid var(--border-color); padding-bottom: 0.5rem;">
                                                Subscription Details</h3>

                                            <div class="profile-detail-row">
                                                <div class="profile-detail-label">Current Plan</div>
                                                <div class="profile-detail-value">
                                                    <span
                                                        class="badge ${sessionScope.user.tier == 'Pro' ? 'badge-pro' : 'badge-free'}"
                                                        style="font-size: 0.9rem; padding: 0.4rem 0.6rem;">
                                                        ${sessionScope.user.tier}
                                                    </span>
                                                </div>
                                            </div>

                                            <div class="profile-detail-row">
                                                <div class="profile-detail-label">Account Status</div>
                                                <div class="profile-detail-value text-success"><i
                                                        class="fa-solid fa-circle-check"></i> Active</div>
                                            </div>

                                            <div class="profile-detail-row">
                                                <div class="profile-detail-label">Expiration Date</div>
                                                <div class="profile-detail-value">
                                                    <c:choose>
                                                        <c:when test="${not empty sessionScope.user.expiryDate}">
                                                            ${sessionScope.user.expiryDate}
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted">Lifetime (Free Tier)</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                        </div>

                                        <c:if test="${sessionScope.user.tier == 'Free'}">
                                            <div class="card text-center"
                                                style="background: linear-gradient(135deg, rgba(21,101,192,0.1) 0%, rgba(21,101,192,0.05) 100%);">
                                                <p class="mb-3">You are currently using the Free Tier. Upgrade to access
                                                    AI
                                                    Prophet forecasting, CSV data exports, and the Smart Chatbot
                                                    assistant.</p>
                                                <a href="pricing.jsp" class="btn btn-primary"><i
                                                        class="fa-solid fa-crown"></i>
                                                    View Upgrade Options</a>
                                            </div>
                                        </c:if>

                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="alert alert-danger">
                                        <i class="fa-solid fa-circle-xmark"></i> You are not logged in. Please <a
                                            href="login.jsp" style="text-decoration: underline;">log in</a> to view this
                                        page.
                                    </div>
                                </c:otherwise>
                            </c:choose>

                        </main>
                    </div>

                    <!-- Avatar URL Modal -->
                    <div class="avatar-modal-overlay" id="avatarModal">
                        <div class="avatar-modal">
                            <h3 style="margin:0 0 1rem;font-size:1.2rem;text-align:center;">
                                <i class="fa-solid fa-camera" style="color:var(--primary-color);"></i> Đổi ảnh đại diện
                            </h3>
                            <div class="avatar-preview" id="avatarPreview">
                                <i class="fa-solid fa-user placeholder-icon" id="previewPlaceholder"></i>
                                <img id="previewImg" src="" alt="Preview" style="display:none;"
                                    onerror="this.style.display='none';document.getElementById('previewPlaceholder').style.display='block';">
                            </div>
                            <label
                                style="font-size:0.82rem;font-weight:600;color:#64748b;margin-bottom:0.3rem;display:block;">
                                URL ảnh đại diện
                            </label>
                            <input type="text" class="avatar-url-input" id="avatarUrlInput"
                                placeholder="https://example.com/avatar.jpg" oninput="previewAvatar(this.value)">
                            <div class="avatar-modal-actions">
                                <button class="btn-avatar-cancel" onclick="closeAvatarModal()">Huỷ</button>
                                <button class="btn-avatar-save" id="saveAvatarBtn" onclick="saveAvatar()">
                                    <i class="fa-solid fa-check"></i> Lưu
                                </button>
                            </div>
                            <div style="text-align:center;margin-top:0.5rem;">
                                <button class="btn-avatar-remove" onclick="removeAvatar()">
                                    <i class="fa-solid fa-trash-can"></i> Xoá ảnh đại diện
                                </button>
                            </div>
                        </div>
                    </div>

                    <script>
                        function openAvatarModal() {
                            document.getElementById('avatarModal').classList.add('show');
                            var currentImg = document.getElementById('avatarImg');
                            if (currentImg && currentImg.src && currentImg.style.display !== 'none') {
                                document.getElementById('avatarUrlInput').value = currentImg.src;
                                previewAvatar(currentImg.src);
                            }
                        }

                        function closeAvatarModal() {
                            document.getElementById('avatarModal').classList.remove('show');
                        }

                        // Close on backdrop click
                        document.getElementById('avatarModal').addEventListener('click', function (e) {
                            if (e.target === this) closeAvatarModal();
                        });

                        function previewAvatar(url) {
                            var img = document.getElementById('previewImg');
                            var placeholder = document.getElementById('previewPlaceholder');
                            if (url && url.trim()) {
                                img.src = url.trim();
                                img.style.display = 'block';
                                placeholder.style.display = 'none';
                                img.onerror = function () {
                                    img.style.display = 'none';
                                    placeholder.style.display = 'block';
                                };
                            } else {
                                img.style.display = 'none';
                                placeholder.style.display = 'block';
                            }
                        }

                        async function saveAvatar() {
                            var url = document.getElementById('avatarUrlInput').value.trim();
                            if (!url) {
                                showProfileToast('error', 'Vui lòng nhập URL ảnh');
                                return;
                            }
                            var btn = document.getElementById('saveAvatarBtn');
                            btn.disabled = true;
                            btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang lưu...';

                            try {
                                var params = new URLSearchParams();
                                params.append('action', 'updateAvatar');
                                params.append('imageUrl', url);

                                var res = await fetch('ProfileServlet', {
                                    method: 'POST',
                                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                                    body: params.toString()
                                });
                                var data = await res.json();

                                if (data.result === 'success') {
                                    showProfileToast('success', 'Cập nhật ảnh đại diện thành công!');
                                    closeAvatarModal();
                                    // Reload to reflect changes
                                    setTimeout(function () { location.reload(); }, 800);
                                } else {
                                    showProfileToast('error', data.msg || 'Lỗi cập nhật');
                                    btn.disabled = false;
                                    btn.innerHTML = '<i class="fa-solid fa-check"></i> Lưu';
                                }
                            } catch (err) {
                                showProfileToast('error', 'Lỗi kết nối server');
                                btn.disabled = false;
                                btn.innerHTML = '<i class="fa-solid fa-check"></i> Lưu';
                            }
                        }

                        async function removeAvatar() {
                            try {
                                var params = new URLSearchParams();
                                params.append('action', 'updateAvatar');
                                params.append('imageUrl', '');

                                var res = await fetch('ProfileServlet', {
                                    method: 'POST',
                                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                                    body: params.toString()
                                });
                                var data = await res.json();

                                if (data.result === 'success') {
                                    showProfileToast('success', 'Đã xoá ảnh đại diện');
                                    closeAvatarModal();
                                    setTimeout(function () { location.reload(); }, 800);
                                } else {
                                    showProfileToast('error', data.msg || 'Lỗi xoá ảnh');
                                }
                            } catch (err) {
                                showProfileToast('error', 'Lỗi kết nối server');
                            }
                        }

                        function showProfileToast(type, msg) {
                            var toast = document.createElement('div');
                            toast.className = 'profile-toast ' + type;
                            toast.innerHTML = '<i class="fa-solid ' + (type === 'success' ? 'fa-circle-check' : 'fa-circle-xmark') + '"></i> ' + msg;
                            document.body.appendChild(toast);
                            setTimeout(function () {
                                toast.style.animation = 'slideIn 0.3s reverse';
                                setTimeout(function () { toast.remove(); }, 300);
                            }, 3000);
                        }
                    </script>

                </body>

                </html>