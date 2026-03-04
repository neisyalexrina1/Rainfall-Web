<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%-- Auth guard: must be logged in, non-admin --%>
        <% model.User pvUser=(model.User)(session !=null ? session.getAttribute("user") : null); if (pvUser==null) {
            response.sendRedirect("login.jsp"); return; } if ("Admin".equals(pvUser.getRole())) {
            response.sendRedirect("AdminServlet?action=dashboard"); return; } %>
            <%@ taglib uri="jakarta.tags.core" prefix="c" %>
                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Thanh Toán – Rainfall Analytics</title>
                    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"
                        rel="stylesheet">
                    <link
                        href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap"
                        rel="stylesheet">
                    <link rel="stylesheet" href="css/style.css">
                    <style>
                        body {
                            background: linear-gradient(135deg, #f0f4f8 0%, #e8eef5 100%);
                            min-height: 100vh;
                        }

                        /* ── Steps Bar ── */
                        .steps-bar {
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            gap: 0;
                            padding: 1.5rem 2rem 0.5rem;
                        }

                        .step {
                            display: flex;
                            align-items: center;
                            gap: 0.5rem;
                            font-size: 0.82rem;
                            font-weight: 600;
                            color: var(--text-muted);
                            transition: all 0.3s ease;
                        }

                        .step.active {
                            color: var(--primary-color);
                        }

                        .step.done {
                            color: var(--success-color);
                        }

                        .step-num {
                            width: 30px;
                            height: 30px;
                            border-radius: 50%;
                            background: var(--border-color);
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            font-size: 0.78rem;
                            font-weight: 700;
                            flex-shrink: 0;
                            transition: all 0.3s ease;
                        }

                        .step.active .step-num {
                            background: var(--primary-gradient);
                            color: #fff;
                            box-shadow: 0 4px 12px rgba(11, 108, 179, 0.3);
                        }

                        .step.done .step-num {
                            background: var(--success-color);
                            color: #fff;
                            box-shadow: 0 4px 12px rgba(40, 167, 69, 0.3);
                        }

                        .step-line {
                            width: 50px;
                            height: 2px;
                            background: var(--border-color);
                            margin: 0 0.75rem;
                            border-radius: 2px;
                            transition: all 0.3s ease;
                        }

                        .step-line.done {
                            background: var(--success-color);
                        }

                        /* ── Main layout ── */
                        .pay-container {
                            max-width: 520px;
                            margin: 0 auto;
                            padding: 1.5rem 1.25rem 3rem;
                            width: 100%;
                        }

                        /* ── Amount header ── */
                        .amount-header {
                            background: var(--primary-gradient);
                            color: #fff;
                            border-radius: 16px;
                            padding: 1.5rem;
                            text-align: center;
                            margin-bottom: 1.25rem;
                            box-shadow: 0 8px 24px rgba(11, 108, 179, 0.25);
                            position: relative;
                            overflow: hidden;
                        }

                        .amount-header::before {
                            content: '';
                            position: absolute;
                            top: -40px;
                            right: -40px;
                            width: 120px;
                            height: 120px;
                            border-radius: 50%;
                            background: rgba(255, 255, 255, 0.08);
                        }

                        .amount-header .pkg-name {
                            font-size: 0.82rem;
                            opacity: 0.9;
                            margin-bottom: 0.3rem;
                            font-weight: 500;
                        }

                        .amount-header .pkg-amount {
                            font-size: 2rem;
                            font-weight: 800;
                            letter-spacing: -0.02em;
                        }

                        /* ── Pay Card ── */
                        .pay-card {
                            background: #fff;
                            border-radius: 16px;
                            padding: 1.5rem;
                            margin-bottom: 1rem;
                            box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
                            border: 1px solid rgba(0, 0, 0, 0.04);
                        }

                        .pay-card:hover {
                            transform: none;
                            box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
                        }

                        .pay-card::before {
                            display: none;
                        }

                        .pay-card-title {
                            font-size: 0.95rem;
                            font-weight: 700;
                            color: var(--text-main);
                            margin-bottom: 1rem;
                            display: flex;
                            align-items: center;
                            gap: 0.5rem;
                        }

                        .pay-card-title i {
                            color: var(--primary-color);
                            font-size: 1rem;
                        }

                        /* ── QR Section ── */
                        .qr-section {
                            text-align: center;
                            padding-bottom: 0.5rem;
                        }

                        .qr-img {
                            width: 180px;
                            height: 180px;
                            object-fit: contain;
                            border-radius: 14px;
                            border: 2px solid var(--border-color);
                            background: #fff;
                            padding: 6px;
                            display: block;
                            margin: 0 auto 0.75rem;
                        }

                        .bank-badges {
                            display: flex;
                            justify-content: center;
                            gap: 0.5rem;
                            margin-bottom: 0.75rem;
                        }

                        .bank-badge {
                            background: #f1f5f9;
                            border: 1px solid #e2e8f0;
                            border-radius: 8px;
                            padding: 3px 10px;
                            font-weight: 600;
                            font-size: 0.72rem;
                            color: var(--text-muted);
                            letter-spacing: 0.02em;
                        }

                        .bank-badge.momo {
                            color: #a0248e;
                            background: #fdf0fb;
                            border-color: #f5d0ef;
                        }

                        .bank-badge.vietqr {
                            color: #e21a1a;
                            background: #fef2f2;
                            border-color: #fecaca;
                        }

                        .bank-badge.napas {
                            color: #0066b3;
                            background: #eff6ff;
                            border-color: #bfdbfe;
                        }

                        /* ── Transfer Info ── */
                        .info-row {
                            display: flex;
                            flex-direction: column;
                            gap: 0.75rem;
                        }

                        .info-item {
                            background: #f8fafc;
                            border-radius: 10px;
                            padding: 0.7rem 0.85rem;
                            border: 1px solid #e2e8f0;
                        }

                        .info-label {
                            font-size: 0.7rem;
                            color: var(--text-muted);
                            font-weight: 600;
                            margin-bottom: 0.2rem;
                            text-transform: uppercase;
                            letter-spacing: 0.06em;
                        }

                        .info-value {
                            font-size: 0.95rem;
                            font-weight: 700;
                            color: var(--text-main);
                            display: flex;
                            align-items: center;
                            justify-content: space-between;
                            gap: 0.5rem;
                        }

                        .info-value.highlight {
                            color: var(--primary-color);
                            font-size: 1.1rem;
                        }

                        .info-value.ref-code {
                            font-family: 'Courier New', monospace;
                            font-size: 0.92rem;
                            color: #7c3aed;
                            word-break: break-all;
                        }

                        .copy-btn {
                            background: none;
                            border: none;
                            cursor: pointer;
                            color: var(--primary-color);
                            padding: 3px 8px;
                            border-radius: 6px;
                            transition: all 0.2s;
                            font-size: 0.8rem;
                            white-space: nowrap;
                            flex-shrink: 0;
                        }

                        .copy-btn:hover {
                            background: rgba(11, 108, 179, 0.08);
                        }

                        .copy-btn.copied {
                            color: var(--success-color);
                        }

                        /* ── Timer ── */
                        .timer-box {
                            background: #fffbeb;
                            border: 1px solid #fde68a;
                            border-radius: 10px;
                            padding: 0.6rem 0.85rem;
                            display: flex;
                            align-items: center;
                            gap: 0.6rem;
                            margin-bottom: 0.75rem;
                            font-size: 0.82rem;
                            color: #92400e;
                        }

                        .timer-box i {
                            color: var(--warning-color);
                            font-size: 1rem;
                        }

                        .timer-box strong {
                            font-variant-numeric: tabular-nums;
                            font-size: 0.95rem;
                        }

                        /* ── Confirm Button ── */
                        .confirm-btn {
                            width: 100%;
                            padding: 0.85rem;
                            background: linear-gradient(135deg, #10b981, #059669);
                            color: #fff;
                            border: none;
                            border-radius: 12px;
                            font-size: 0.95rem;
                            font-weight: 700;
                            cursor: pointer;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            gap: 0.5rem;
                            transition: all 0.3s ease;
                            box-shadow: 0 4px 14px rgba(16, 185, 129, 0.3);
                        }

                        .confirm-btn:hover:not(:disabled) {
                            transform: translateY(-2px);
                            box-shadow: 0 6px 20px rgba(16, 185, 129, 0.4);
                        }

                        .confirm-btn:disabled {
                            opacity: 0.7;
                            cursor: not-allowed;
                        }

                        /* ── Verify progress bar ── */
                        .verify-progress {
                            display: none;
                            margin-top: 0.75rem;
                        }

                        .verify-progress.show {
                            display: block;
                        }

                        .verify-bar-bg {
                            background: #e2e8f0;
                            border-radius: 8px;
                            height: 6px;
                            overflow: hidden;
                            margin-bottom: 0.4rem;
                        }

                        .verify-bar {
                            height: 100%;
                            background: linear-gradient(90deg, #10b981, #34d399);
                            border-radius: 8px;
                            width: 0%;
                            transition: width 0.5s ease;
                        }

                        .verify-text {
                            font-size: 0.78rem;
                            color: var(--text-muted);
                            text-align: center;
                        }

                        .btn-back {
                            width: 100%;
                            padding: 0.6rem;
                            background: transparent;
                            border: 1px solid var(--border-color);
                            border-radius: 10px;
                            font-size: 0.85rem;
                            font-weight: 500;
                            cursor: pointer;
                            color: var(--text-muted);
                            margin-top: 0.6rem;
                            transition: all 0.2s;
                        }

                        .btn-back:hover {
                            background: #f8fafc;
                            color: var(--text-main);
                        }

                        /* ── Instructions ── */
                        .steps-list {
                            list-style: none;
                            display: flex;
                            flex-direction: column;
                            gap: 0.5rem;
                            padding: 0;
                            margin: 0;
                        }

                        .steps-list li {
                            display: flex;
                            align-items: flex-start;
                            gap: 0.6rem;
                            font-size: 0.82rem;
                            color: var(--text-muted);
                            line-height: 1.45;
                        }

                        .step-bullet {
                            width: 20px;
                            height: 20px;
                            min-width: 20px;
                            border-radius: 50%;
                            background: #eef2ff;
                            color: var(--primary-color);
                            font-size: 0.7rem;
                            font-weight: 700;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            margin-top: 1px;
                        }

                        /* ── Toast ── */
                        .toast-container {
                            position: fixed;
                            top: 1.5rem;
                            right: 1.5rem;
                            z-index: 9999;
                            display: flex;
                            flex-direction: column;
                            gap: 0.75rem;
                        }

                        .toast {
                            background: #fff;
                            border-radius: 12px;
                            padding: 0.85rem 1rem;
                            box-shadow: 0 8px 28px rgba(0, 0, 0, 0.12);
                            display: flex;
                            align-items: flex-start;
                            gap: 0.6rem;
                            min-width: 280px;
                            max-width: 360px;
                            animation: slideIn 0.35s cubic-bezier(.34, 1.56, .64, 1);
                            border-left: 4px solid var(--primary-color);
                        }

                        .toast.success {
                            border-color: var(--success-color);
                        }

                        .toast.error {
                            border-color: var(--danger-color);
                        }

                        .toast.warning {
                            border-color: var(--warning-color);
                        }

                        .toast-icon {
                            font-size: 1.1rem;
                            flex-shrink: 0;
                            margin-top: 1px;
                        }

                        .toast.success .toast-icon {
                            color: var(--success-color);
                        }

                        .toast.error .toast-icon {
                            color: var(--danger-color);
                        }

                        .toast.warning .toast-icon {
                            color: var(--warning-color);
                        }

                        .toast-content {
                            flex: 1;
                        }

                        .toast-title {
                            font-weight: 700;
                            font-size: 0.85rem;
                            margin-bottom: 0.15rem;
                        }

                        .toast-msg {
                            font-size: 0.78rem;
                            color: var(--text-muted);
                        }

                        @keyframes slideIn {
                            from {
                                transform: translateX(120%);
                                opacity: 0;
                            }

                            to {
                                transform: translateX(0);
                                opacity: 1;
                            }
                        }

                        /* ── Success overlay ── */
                        .success-overlay {
                            display: none;
                            position: fixed;
                            inset: 0;
                            background: rgba(0, 0, 0, 0.55);
                            backdrop-filter: blur(6px);
                            z-index: 9990;
                            align-items: center;
                            justify-content: center;
                        }

                        .success-overlay.show {
                            display: flex;
                        }

                        .success-card {
                            background: #fff;
                            border-radius: 20px;
                            padding: 2.5rem 2rem;
                            text-align: center;
                            max-width: 380px;
                            width: 90%;
                            animation: popIn 0.45s cubic-bezier(.34, 1.56, .64, 1);
                            box-shadow: 0 20px 50px rgba(0, 0, 0, 0.15);
                        }

                        @keyframes popIn {
                            from {
                                transform: scale(0.7);
                                opacity: 0;
                            }

                            to {
                                transform: scale(1);
                                opacity: 1;
                            }
                        }

                        .success-icon {
                            width: 72px;
                            height: 72px;
                            border-radius: 50%;
                            background: linear-gradient(135deg, #d1fae5, #a7f3d0);
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            margin: 0 auto 1.25rem;
                            font-size: 2rem;
                            color: #059669;
                            animation: pulse 1.5s ease-in-out infinite;
                        }

                        @keyframes pulse {

                            0%,
                            100% {
                                transform: scale(1);
                            }

                            50% {
                                transform: scale(1.08);
                            }
                        }

                        .success-title {
                            font-size: 1.4rem;
                            font-weight: 800;
                            margin-bottom: 0.4rem;
                            color: #059669;
                        }

                        .success-body {
                            color: var(--text-muted);
                            font-size: 0.88rem;
                            margin-bottom: 1.25rem;
                            line-height: 1.6;
                        }

                        .success-timer {
                            font-size: 0.82rem;
                            color: var(--text-muted);
                        }
                    </style>
                </head>

                <body>

                    <!-- ── Navbar ── -->
                    <nav class="navbar">
                        <div
                            style="max-width: 520px; margin: 0 auto; padding: 0 1.25rem; display:flex; justify-content:space-between; align-items:center; width:100%;">
                            <a href="index.jsp" class="logo">
                                <i class="fa-solid fa-cloud-rain"></i> Rainfall Analytics
                            </a>
                            <span
                                style="font-size:0.82rem; color:var(--text-muted); display:flex; align-items:center; gap:0.4rem;">
                                <i class="fa-solid fa-shield-halved" style="color:var(--success-color);"></i> Thanh toán
                                bảo mật
                            </span>
                        </div>
                    </nav>

                    <!-- ── Steps ── -->
                    <div class="steps-bar">
                        <div class="step done">
                            <div class="step-num"><i class="fa-solid fa-check" style="font-size:0.7rem;"></i></div>
                            <span>Chọn gói</span>
                        </div>
                        <div class="step-line done"></div>
                        <div class="step active">
                            <div class="step-num">2</div>
                            <span>Thanh toán</span>
                        </div>
                        <div class="step-line"></div>
                        <div class="step">
                            <div class="step-num">3</div>
                            <span>Hoàn tất</span>
                        </div>
                    </div>

                    <!-- ── Main ── -->
                    <div class="pay-container">

                        <!-- Amount header -->
                        <div class="amount-header">
                            <div class="pkg-name">
                                <i class="fa-solid fa-crown"></i> ${param.name}
                            </div>
                            <div class="pkg-amount">
                                <c:choose>
                                    <c:when test="${param.pkg == '3'}">500,000đ</c:when>
                                    <c:otherwise>50,000đ</c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <!-- QR Code -->
                        <div class="pay-card">
                            <div class="pay-card-title">
                                <i class="fa-solid fa-qrcode"></i> Quét mã QR để thanh toán
                            </div>
                            <div class="qr-section">
                                <div class="bank-badges">
                                    <span class="bank-badge momo">MoMo</span>
                                    <span class="bank-badge vietqr">VietQR</span>
                                    <span class="bank-badge napas">Napas 247</span>
                                </div>
                                <img src="images/qr_vnpay.png" alt="VietQR" class="qr-img"
                                    onerror="this.src='https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=VietQR-Payment'">
                                <p style="font-size:0.78rem; color:var(--text-muted); margin:0;">Quét bằng ứng dụng ngân
                                    hàng
                                    hoặc MoMo</p>
                            </div>
                        </div>

                        <!-- Transfer Info -->
                        <div class="pay-card">
                            <div class="pay-card-title">
                                <i class="fa-solid fa-building-columns"></i> Thông tin chuyển khoản
                            </div>
                            <div class="info-row">
                                <div class="info-item">
                                    <div class="info-label">Chủ tài khoản</div>
                                    <div class="info-value">ĐỖ MINH GIA BẢO</div>
                                </div>
                                <div class="info-item">
                                    <div class="info-label">Số tiền</div>
                                    <div class="info-value highlight">
                                        <span>
                                            <c:choose>
                                                <c:when test="${param.pkg == '3'}">500,000đ</c:when>
                                                <c:otherwise>50,000đ</c:otherwise>
                                            </c:choose>
                                        </span>
                                        <button class="copy-btn"
                                            onclick="copyText('${param.pkg == 3 ? 500000 : 50000}', this)">
                                            <i class="fa-regular fa-copy"></i> Copy
                                        </button>
                                    </div>
                                </div>
                                <div class="info-item">
                                    <div class="info-label">⚠️ Nội dung chuyển khoản (bắt buộc)</div>
                                    <div class="info-value ref-code">
                                        <span>${param.ref}</span>
                                        <button class="copy-btn" onclick="copyText('${param.ref}', this)">
                                            <i class="fa-regular fa-copy"></i> Copy
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Timer -->
                        <div class="timer-box">
                            <i class="fa-solid fa-clock"></i>
                            <span>Đơn hàng hết hạn sau <strong id="countdown">15:00</strong></span>
                        </div>

                        <!-- Confirm button -->
                        <button class="confirm-btn" id="confirmBtn" onclick="confirmPayment()">
                            <i class="fa-solid fa-circle-check"></i> Xác nhận đã chuyển tiền
                        </button>

                        <!-- Verify progress (shows after clicking confirm) -->
                        <div class="verify-progress" id="verifyProgress">
                            <div class="verify-bar-bg">
                                <div class="verify-bar" id="verifyBar"></div>
                            </div>
                            <div class="verify-text" id="verifyText">Đang xác minh thanh toán...</div>
                        </div>

                        <button class="btn-back" onclick="window.location.href='pricing.jsp'">
                            <i class="fa-solid fa-arrow-left"></i> Quay lại chọn gói khác
                        </button>

                        <!-- Instructions (collapsible) -->
                        <details style="margin-top:1rem;">
                            <summary
                                style="cursor:pointer; font-size:0.88rem; font-weight:600; color:var(--text-muted); padding:0.5rem 0; list-style:none; display:flex; align-items:center; gap:0.4rem;">
                                <i class="fa-solid fa-circle-info" style="color:var(--primary-color);"></i> Hướng dẫn
                                thanh toán
                                <i class="fa-solid fa-chevron-down" style="font-size:0.7rem; margin-left:auto;"></i>
                            </summary>
                            <div class="pay-card" style="margin-top:0.5rem;">
                                <ul class="steps-list">
                                    <li>
                                        <div class="step-bullet">1</div>
                                        Mở ứng dụng ngân hàng hoặc MoMo, quét mã QR <em>hoặc</em> chuyển khoản thủ công.
                                    </li>
                                    <li>
                                        <div class="step-bullet">2</div>
                                        Nhập <strong>đúng nội dung chuyển khoản</strong> như hiển thị (copy để tránh
                                        sai).
                                    </li>
                                    <li>
                                        <div class="step-bullet">3</div>
                                        Sau khi chuyển thành công, nhấn <strong>"Xác nhận đã chuyển tiền"</strong>.
                                    </li>
                                    <li>
                                        <div class="step-bullet">4</div>
                                        Hệ thống sẽ tự động xác minh và nâng cấp tài khoản Pro.
                                    </li>
                                </ul>
                            </div>
                        </details>

                    </div>

                    <!-- ── Toast container ── -->
                    <div class="toast-container" id="toastContainer"></div>

                    <!-- ── Success overlay ── -->
                    <div class="success-overlay" id="successOverlay">
                        <div class="success-card">
                            <div class="success-icon"><i class="fa-solid fa-check"></i></div>
                            <div class="success-title">Nâng cấp thành công! 🎉</div>
                            <div class="success-body">
                                Tài khoản của bạn đã được nâng cấp lên <strong>Pro</strong>.<br>
                                Bạn có thể sử dụng đầy đủ tính năng AI Forecast & Chatbot ngay bây giờ.
                            </div>
                            <div class="success-timer">Đang chuyển hướng về Dashboard sau <strong
                                    id="redirectCount">3</strong>
                                giây...</div>
                        </div>
                    </div>

                    <script>
                        const REF = '${param.ref}';
                        let timerExpired = false;
                        let confirmLocked = false;

                        // ── Countdown timer (15 phút) ──
                        (function () {
                            let seconds = 15 * 60;
                            const el = document.getElementById('countdown');
                            const interval = setInterval(() => {
                                seconds--;
                                if (seconds <= 0) {
                                    clearInterval(interval);
                                    el.textContent = '00:00';
                                    el.style.color = '#ef4444';
                                    timerExpired = true;
                                    document.getElementById('confirmBtn').disabled = true;
                                    showToast('warning', 'Hết thời gian', 'Đơn hàng đã hết hạn. Vui lòng tạo đơn mới.');
                                    return;
                                }
                                const m = String(Math.floor(seconds / 60)).padStart(2, '0');
                                const s = String(seconds % 60).padStart(2, '0');
                                el.textContent = m + ':' + s;
                                if (seconds <= 60) el.style.color = '#ef4444';
                            }, 1000);
                        })();

                        // ── Copy helper ──
                        function copyText(text, btn) {
                            navigator.clipboard.writeText(text).then(() => {
                                const orig = btn.innerHTML;
                                btn.innerHTML = '<i class="fa-solid fa-check"></i> Đã copy';
                                btn.classList.add('copied');
                                setTimeout(() => { btn.innerHTML = orig; btn.classList.remove('copied'); }, 2000);
                            }).catch(() => {
                                const ta = document.createElement('textarea');
                                ta.value = text; document.body.appendChild(ta);
                                ta.select(); document.execCommand('copy');
                                document.body.removeChild(ta);
                                btn.innerHTML = '<i class="fa-solid fa-check"></i> Đã copy';
                                btn.classList.add('copied');
                                setTimeout(() => {
                                    btn.innerHTML = '<i class="fa-regular fa-copy"></i> Copy';
                                    btn.classList.remove('copied');
                                }, 2000);
                            });
                        }

                        // ── Toast ──
                        function showToast(type, title, msg, duration = 4000) {
                            const icons = { success: 'fa-circle-check', error: 'fa-circle-xmark', warning: 'fa-triangle-exclamation', info: 'fa-circle-info' };
                            const toast = document.createElement('div');
                            toast.className = 'toast ' + type;
                            toast.innerHTML = '<i class="fa-solid ' + (icons[type] || icons.info) + ' toast-icon"></i>' +
                                '<div class="toast-content"><div class="toast-title">' + title + '</div>' +
                                '<div class="toast-msg">' + msg + '</div></div>';
                            document.getElementById('toastContainer').appendChild(toast);
                            setTimeout(() => {
                                toast.style.animation = 'slideIn 0.3s reverse';
                                setTimeout(() => toast.remove(), 300);
                            }, duration);
                        }

                        // ── Confirm Payment with 10s verification delay ──
                        async function confirmPayment() {
                            if (timerExpired || confirmLocked) return;

                            const btn = document.getElementById('confirmBtn');
                            btn.disabled = true;
                            btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang xử lý...';

                            // Show verification progress bar
                            const progress = document.getElementById('verifyProgress');
                            const bar = document.getElementById('verifyBar');
                            const verifyText = document.getElementById('verifyText');
                            progress.classList.add('show');

                            // Animate progress bar over 10 seconds
                            let elapsed = 0;
                            const totalTime = 10;
                            const messages = [
                                'Đang kết nối ngân hàng...',
                                'Đang xác minh giao dịch...',
                                'Đang kiểm tra nội dung chuyển khoản...',
                                'Đang đối chiếu số tiền...',
                                'Đang xác nhận thanh toán...',
                                'Gần xong rồi...'
                            ];

                            const progressInterval = setInterval(() => {
                                elapsed += 0.5;
                                const pct = Math.min((elapsed / totalTime) * 100, 95);
                                bar.style.width = pct + '%';

                                // Update text at intervals
                                const msgIndex = Math.min(Math.floor(elapsed / 2), messages.length - 1);
                                verifyText.textContent = messages[msgIndex];
                            }, 500);

                            // Wait 10 seconds then call the server
                            await new Promise(resolve => setTimeout(resolve, totalTime * 1000));
                            clearInterval(progressInterval);

                            bar.style.width = '100%';
                            verifyText.textContent = 'Xác minh hoàn tất!';

                            // Gọi server để xác nhận thanh toán và cập nhật DB
                            try {
                                const params = new URLSearchParams();
                                params.append('action', 'confirm');
                                params.append('ref', REF);

                                const res = await fetch('PaymentServlet', {
                                    method: 'POST',
                                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                                    body: params.toString()
                                });

                                if (!res.ok) {
                                    console.error('[Payment] HTTP error:', res.status);
                                    showToast('error', 'Lỗi server', 'Server trả về lỗi ' + res.status + '. Hãy Clean & Build lại project trong NetBeans.', 8000);
                                    resetBtn();
                                    return;
                                }

                                const text = await res.text();
                                console.log('[Payment] Raw response:', text);

                                let data;
                                try {
                                    data = JSON.parse(text);
                                } catch (parseErr) {
                                    console.error('[Payment] JSON parse error. Response was:', text.substring(0, 200));
                                    showToast('error', 'Lỗi server', 'Server không trả về JSON. Hãy Clean & Build lại project trong NetBeans rồi chạy lại.', 8000);
                                    resetBtn();
                                    return;
                                }

                                console.log('[Payment] Parsed response:', data);

                                if (data.result === 'not_logged_in') {
                                    showToast('error', 'Chưa đăng nhập', 'Phiên đăng nhập hết hạn.');
                                    setTimeout(() => window.location.href = 'login.jsp', 2500);
                                    resetBtn();
                                    return;
                                }

                                if (data.result === 'success') {
                                    // Thành công thực sự - DB đã cập nhật
                                    confirmLocked = true;
                                    progress.classList.remove('show');
                                    document.getElementById('successOverlay').classList.add('show');
                                    let count = 3;
                                    const counter = document.getElementById('redirectCount');
                                    const ri = setInterval(() => {
                                        count--;
                                        counter.textContent = count;
                                        if (count <= 0) {
                                            clearInterval(ri);
                                            window.location.href = 'DashboardServlet?success=upgrade';
                                        }
                                    }, 1000);
                                } else {
                                    showToast('error', 'Thanh toán thất bại', data.msg || ('Kết quả: ' + data.result), 6000);
                                    resetBtn();
                                }

                            } catch (err) {
                                console.error('[Payment] Network/fetch error:', err);
                                showToast('error', 'Lỗi kết nối', 'Không thể kết nối server. Hãy Clean & Build lại project trong NetBeans.', 8000);
                                resetBtn();
                            }
                        }

                        function resetBtn() {
                            const btn = document.getElementById('confirmBtn');
                            btn.disabled = false;
                            btn.innerHTML = '<i class="fa-solid fa-circle-check"></i> Xác nhận đã chuyển tiền';
                            document.getElementById('verifyProgress').classList.remove('show');
                            document.getElementById('verifyBar').style.width = '0%';
                        }
                    </script>

                </body>

                </html>