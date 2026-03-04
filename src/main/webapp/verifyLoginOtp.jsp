<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Xác nhận Đăng nhập - Rainfall Analytics</title>
            <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
                rel="stylesheet">
            <link rel="stylesheet" href="css/style.css">
            <style>
                .otp-input-group {
                    display: flex;
                    gap: 10px;
                    justify-content: center;
                    margin: 1.5rem 0;
                }

                .otp-digit {
                    width: 52px;
                    height: 60px;
                    border: 2px solid var(--border-color);
                    border-radius: 10px;
                    font-size: 1.5rem;
                    font-weight: 700;
                    text-align: center;
                    outline: none;
                    transition: border-color 0.2s;
                    background: var(--bg-light);
                    color: var(--text-primary);
                }

                .otp-digit:focus {
                    border-color: #7c3aed;
                    background: #fff;
                    box-shadow: 0 0 0 3px rgba(124, 58, 237, 0.15);
                }

                .otp-digit.filled {
                    border-color: #7c3aed;
                    background: #f5f3ff;
                }

                .email-badge {
                    display: inline-flex;
                    align-items: center;
                    gap: 0.5rem;
                    background: #f5f3ff;
                    border: 1px solid #c4b5fd;
                    color: #6d28d9;
                    padding: 0.5rem 1rem;
                    border-radius: 999px;
                    font-size: 0.875rem;
                    font-weight: 500;
                    margin-bottom: 1.5rem;
                }

                .resend-btn {
                    background: none;
                    border: none;
                    color: #7c3aed;
                    font-size: 0.875rem;
                    cursor: pointer;
                    padding: 0;
                    text-decoration: underline;
                    font-family: inherit;
                }

                .resend-btn:disabled {
                    color: var(--text-muted);
                    cursor: not-allowed;
                    text-decoration: none;
                }

                .btn-purple {
                    background: linear-gradient(135deg, #4f46e5, #7c3aed);
                    color: #fff;
                    border: none;
                }

                .btn-purple:hover {
                    background: linear-gradient(135deg, #4338ca, #6d28d9);
                    color: #fff;
                }

                #otpHidden {
                    display: none;
                }

                .security-note {
                    background: #fef3c7;
                    border-left: 4px solid #f59e0b;
                    border-radius: 6px;
                    padding: 0.75rem 1rem;
                    font-size: 0.8rem;
                    color: #92400e;
                    text-align: left;
                    margin-bottom: 1rem;
                }
            </style>
        </head>

        <body>
            <nav class="navbar">
                <div class="container d-flex justify-between align-center">
                    <a href="index.jsp" class="logo" style="padding-bottom: 0; border: none; text-decoration: none;">
                        <i class="fa-solid fa-cloud-rain"></i> Rainfall Analytics
                    </a>
                    <div class="nav-links d-flex align-center gap-3">
                        <a href="index.jsp">Home</a>
                        <a href="about.jsp">About</a>
                    </div>
                </div>
            </nav>

            <div class="container min-vh-100 d-flex flex-column" style="flex: 1;">
                <div class="auth-container" style="flex:1;">
                    <div class="auth-card text-center" style="margin: auto; max-width: 460px;">

                        <%-- Icon header with purple theme --%>
                        <div style="width:64px;height:64px;border-radius:50%;background:linear-gradient(135deg,#4f46e5,#7c3aed);
                            display:flex;align-items:center;justify-content:center;margin:0 auto 1.25rem;
                            box-shadow:0 8px 20px rgba(79,70,229,0.35);">
                            <i class="fa-solid fa-shield-halved" style="font-size:1.6rem;color:#fff;"></i>
                        </div>

                        <h2 class="mb-2">Xác nhận Đăng nhập</h2>
                        <p class="text-muted" style="font-size:0.9rem;margin-bottom:0.75rem;">
                            Phiên đăng nhập của bạn đã hết hạn.<br>
                            Mã xác nhận 6 chữ số vừa được gửi đến
                        </p>

                        <div class="email-badge">
                            <i class="fa-solid fa-envelope"></i>
                            ${not empty maskedEmail ? maskedEmail : 'email của bạn'}
                        </div>

                        <%-- Error / Success messages --%>
                        <c:if test="${not empty errorMessage}">
                            <div style="background:rgba(239,68,68,0.1);border-left:4px solid #ef4444;padding:0.875rem 1rem;
                                border-radius:6px;text-align:left;color:#b91c1c;font-size:0.875rem;margin-bottom:1rem;">
                                <i class="fa-solid fa-circle-exclamation me-2"></i> ${errorMessage}
                            </div>
                        </c:if>
                        <c:if test="${not empty successMessage}">
                            <div style="background:rgba(16,185,129,0.1);border-left:4px solid #10b981;padding:0.875rem 1rem;
                                border-radius:6px;text-align:left;color:#065f46;font-size:0.875rem;margin-bottom:1rem;">
                                <i class="fa-solid fa-check-circle me-2"></i> ${successMessage}
                            </div>
                        </c:if>

                        <%-- Security note --%>
                        <div class="security-note">
                            <i class="fa-solid fa-triangle-exclamation me-1"></i>
                            Nếu bạn không thực hiện đăng nhập này, hãy đổi mật khẩu ngay lập tức.
                        </div>

                        <c:if test="${empty otpExpired}">
                            <form action="AuthServlet" method="POST" onsubmit="collectOtp()">
                                <input type="hidden" name="action" value="verify_login_otp">
                                <input type="hidden" name="otp" id="otpHidden">

                                <%-- 6 digit boxes --%>
                                <div class="otp-input-group">
                                    <input class="otp-digit" type="text" maxlength="1" inputmode="numeric"
                                        id="d0" autocomplete="off">
                                    <input class="otp-digit" type="text" maxlength="1" inputmode="numeric"
                                        id="d1" autocomplete="off">
                                    <input class="otp-digit" type="text" maxlength="1" inputmode="numeric"
                                        id="d2" autocomplete="off">
                                    <input class="otp-digit" type="text" maxlength="1" inputmode="numeric"
                                        id="d3" autocomplete="off">
                                    <input class="otp-digit" type="text" maxlength="1" inputmode="numeric"
                                        id="d4" autocomplete="off">
                                    <input class="otp-digit" type="text" maxlength="1" inputmode="numeric"
                                        id="d5" autocomplete="off">
                                </div>

                                <button type="submit" class="btn btn-block btn-purple" id="verifyBtn" disabled>
                                    <i class="fa-solid fa-shield-halved me-1"></i> Xác nhận & Đăng nhập
                                </button>
                            </form>
                        </c:if>
                        <c:if test="${not empty otpExpired}">
                            <p class="text-muted" style="font-size:0.875rem;margin-top:1rem;">
                                Mã đã hết hạn. <a href="login.jsp">Đăng nhập lại</a>
                            </p>
                        </c:if>

                        <div style="margin-top:1.5rem;font-size:0.875rem;color:var(--text-muted);">
                            Không nhận được mã?
                            <form action="AuthServlet" method="POST" style="display:inline;">
                                <input type="hidden" name="action" value="resend_login_otp">
                                <button type="submit" class="resend-btn" id="resendBtn">Gửi lại</button>
                            </form>
                            <span id="resendCountdown" style="display:none; color:var(--text-muted);"></span>
                        </div>

                        <p style="margin-top:1.5rem;font-size:0.875rem;color:var(--text-muted);">
                            <a href="login.jsp"><i class="fa-solid fa-arrow-left me-1"></i>Quay lại đăng nhập</a>
                        </p>
                    </div>
                </div>
            </div>

            <footer style="background-color:var(--bg-white);border-top:1px solid var(--border-color);
                color:var(--text-muted);padding:2rem 0;text-align:center;">
                <p>&copy; 2026 Rainfall Analytics System. Academic Assignment Showcase.</p>
            </footer>

            <script>
                // Auto-advance between digit boxes
                const digits = [0, 1, 2, 3, 4, 5].map(i => document.getElementById('d' + i));
                const verifyBtn = document.getElementById('verifyBtn');

                if (digits[0]) {
                    digits.forEach(function (el, idx) {
                        el.addEventListener('input', function () {
                            el.value = el.value.replace(/[^0-9]/g, '');
                            el.classList.toggle('filled', el.value !== '');
                            if (el.value && idx < 5) digits[idx + 1].focus();
                            checkFull();
                        });
                        el.addEventListener('keydown', function (e) {
                            if (e.key === 'Backspace' && !el.value && idx > 0) {
                                digits[idx - 1].focus();
                                digits[idx - 1].value = '';
                                digits[idx - 1].classList.remove('filled');
                                checkFull();
                            }
                        });
                        el.addEventListener('paste', function (e) {
                            e.preventDefault();
                            var pasted = (e.clipboardData || window.clipboardData).getData('text').replace(/[^0-9]/g, '');
                            for (var i = 0; i < 6 && i < pasted.length; i++) {
                                digits[i].value = pasted[i];
                                digits[i].classList.add('filled');
                            }
                            if (pasted.length > 0) digits[Math.min(pasted.length, 5)].focus();
                            checkFull();
                        });
                    });

                    function checkFull() {
                        var full = digits.every(function (d) { return d.value.length === 1; });
                        verifyBtn.disabled = !full;
                    }

                    function collectOtp() {
                        document.getElementById('otpHidden').value = digits.map(function (d) { return d.value; }).join('');
                    }

                    // Auto-focus first digit on load
                    digits[0].focus();
                }

                // Resend cooldown: 60s after page load
                (function () {
                    var btn = document.getElementById('resendBtn');
                    var countdown = document.getElementById('resendCountdown');
                    if (!btn) return;
                    var seconds = 60;
                    btn.disabled = true;
                    btn.style.display = 'none';
                    countdown.style.display = 'inline';
                    countdown.textContent = '(gửi lại sau ' + seconds + 's)';
                    var timer = setInterval(function () {
                        seconds--;
                        if (seconds <= 0) {
                            clearInterval(timer);
                            countdown.style.display = 'none';
                            btn.style.display = 'inline';
                            btn.disabled = false;
                        } else {
                            countdown.textContent = '(gửi lại sau ' + seconds + 's)';
                        }
                    }, 1000);
                })();
            </script>
        </body>

        </html>
