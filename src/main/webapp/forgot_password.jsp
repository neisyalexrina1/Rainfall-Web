<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Forgot Password - Rainfall Analytics</title>
            <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
                rel="stylesheet">
            <link rel="stylesheet" href="css/style.css">
            <style>
                .otp-input {
                    letter-spacing: 0.3em;
                    font-size: 1.6rem;
                    font-weight: 700;
                    text-align: center;
                }

                .step-indicator {
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    gap: 0.5rem;
                    margin-bottom: 1.5rem;
                }

                .step-dot {
                    width: 10px;
                    height: 10px;
                    border-radius: 50%;
                    background: var(--border-color);
                    transition: background 0.3s;
                }

                .step-dot.active {
                    background: var(--primary-color);
                }

                .step-dot.done {
                    background: #10b981;
                }
            </style>
        </head>

        <body>
            <nav class="navbar">
                <div class="container d-flex justify-between align-center">
                    <a href="index.jsp" class="logo" style="padding-bottom:0;border:none;text-decoration:none;">
                        <i class="fa-solid fa-cloud-rain"></i> Rainfall Analytics
                    </a>
                    <div class="nav-links d-flex align-center gap-3">
                        <a href="index.jsp">Home</a>
                        <a href="login.jsp">Login</a>
                    </div>
                </div>
            </nav>

            <div class="container min-vh-100 d-flex flex-column" style="flex:1;">
                <div class="auth-container" style="flex:1;">
                    <div class="auth-card" style="margin:auto; max-width:420px;">

                        <!-- Step indicator -->
                        <div class="step-indicator">
                            <div class="step-dot ${not empty otpSent ? 'done' : 'active'}"></div>
                            <div style="width:40px;height:2px;background:var(--border-color);border-radius:2px;"></div>
                            <div class="step-dot ${empty otpSent ? '' : 'active'}"></div>
                        </div>

                        <c:choose>

                            <%-- ── Step 1: Enter Email ── --%>
                                <c:when test="${empty otpSent}">
                                    <div class="text-center mb-4">
                                        <i class="fa-solid fa-envelope-open-text fa-3x mb-2"
                                            style="color:var(--primary-color)"></i>
                                        <h2 class="mb-1">Forgot Password?</h2>
                                        <p style="font-size:0.9rem;color:var(--text-muted);">
                                            Enter your registered email address. We'll send you a verification code.
                                        </p>
                                    </div>

                                    <c:if test="${not empty errorMessage}">
                                        <div class="alert alert-danger mb-4">
                                            <i class="fa-solid fa-circle-exclamation"></i> ${errorMessage}
                                        </div>
                                    </c:if>

                                    <form action="PasswordResetServlet" method="POST" id="emailForm" novalidate>
                                        <input type="hidden" name="action" value="send_otp">
                                        <div class="form-group">
                                            <label class="form-label" for="email">Email Address</label>
                                            <input type="email" id="email" name="email" class="form-control" required
                                                placeholder="Enter your email" autocomplete="email">
                                            <div class="invalid-feedback">Please enter a valid email address.</div>
                                        </div>
                                        <button type="submit" class="btn btn-primary btn-block mt-3">
                                            <i class="fa-solid fa-paper-plane"></i> Send Verification Code
                                        </button>
                                    </form>

                                    <p class="mt-4 text-center" style="font-size:0.9rem;color:var(--text-muted);">
                                        Remember your password? <a href="login.jsp">Back to Login</a>
                                    </p>
                                </c:when>

                                <%-- ── Step 2: Enter OTP ── --%>
                                    <c:otherwise>
                                        <div class="text-center mb-4">
                                            <i class="fa-solid fa-shield-halved fa-3x mb-2"
                                                style="color:var(--primary-color)"></i>
                                            <h2 class="mb-1">Enter Verification Code</h2>
                                            <p style="font-size:0.9rem;color:var(--text-muted);">
                                                We sent a 6-digit code to <strong>${maskedEmail}</strong>.
                                                Check your inbox (and spam folder).
                                            </p>
                                        </div>

                                        <c:if test="${not empty errorMessage}">
                                            <div class="alert alert-danger mb-4">
                                                <i class="fa-solid fa-circle-exclamation"></i> ${errorMessage}
                                            </div>
                                        </c:if>

                                        <form action="PasswordResetServlet" method="POST" id="otpForm" novalidate>
                                            <input type="hidden" name="action" value="verify_otp">
                                            <div class="form-group">
                                                <label class="form-label" for="otp">Verification Code</label>
                                                <input type="text" id="otp" name="otp" class="form-control otp-input"
                                                    maxlength="6" placeholder="_ _ _ _ _ _" autocomplete="one-time-code"
                                                    required>
                                                <div class="invalid-feedback">Please enter the 6-digit code.</div>
                                            </div>
                                            <button type="submit" class="btn btn-primary btn-block mt-3">
                                                <i class="fa-solid fa-check-circle"></i> Verify Code
                                            </button>
                                        </form>

                                        <p class="mt-3 text-center" style="font-size:0.85rem;color:var(--text-muted);">
                                            Didn't get it? <a href="PasswordResetServlet">Request a new code</a>
                                        </p>
                                    </c:otherwise>
                        </c:choose>

                    </div>
                </div>
            </div>

            <footer
                style="background-color:var(--bg-white);border-top:1px solid var(--border-color);color:var(--text-muted);padding:1.5rem 0;text-align:center;">
                <p>&copy; 2026 Rainfall Analytics System. Academic Assignment Showcase.</p>
            </footer>

            <script>
                // Basic client-side validation
                ['emailForm', 'otpForm'].forEach(function (id) {
                    var form = document.getElementById(id);
                    if (!form) return;
                    form.addEventListener('submit', function (e) {
                        var valid = true;
                        form.querySelectorAll('input[required]').forEach(function (input) {
                            input.classList.remove('is-invalid');
                            if (!input.value.trim()) {
                                input.classList.add('is-invalid');
                                valid = false;
                            }
                        });
                        if (!valid) { e.preventDefault(); }
                    });
                });

                // Auto-format OTP input: digits only
                var otpInput = document.getElementById('otp');
                if (otpInput) {
                    otpInput.addEventListener('input', function () {
                        this.value = this.value.replace(/\D/g, '').substring(0, 6);
                    });
                }
            </script>
        </body>

        </html>