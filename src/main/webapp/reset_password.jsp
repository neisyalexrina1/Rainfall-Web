<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Reset Password - Rainfall Analytics</title>
            <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
                rel="stylesheet">
            <link rel="stylesheet" href="css/style.css">
            <style>
                .username-locked {
                    background: #f1f5f9;
                    border: 1.5px solid #94a3b8;
                    color: #64748b;
                    cursor: not-allowed;
                    font-weight: 600;
                }

                .locked-label-note {
                    font-size: 0.78rem;
                    color: var(--text-muted);
                    display: flex;
                    align-items: center;
                    gap: 4px;
                    margin-top: 4px;
                }

                .pw-toggle {
                    position: relative;
                }

                .pw-toggle .form-control {
                    padding-right: 2.8rem;
                }

                .pw-eye-btn {
                    position: absolute;
                    right: 0.7rem;
                    top: 50%;
                    transform: translateY(-50%);
                    background: none;
                    border: none;
                    cursor: pointer;
                    color: var(--text-muted);
                    font-size: 1rem;
                }

                .strength-bar {
                    height: 4px;
                    border-radius: 2px;
                    background: #e2e8f0;
                    margin-top: 6px;
                    overflow: hidden;
                }

                .strength-fill {
                    height: 100%;
                    border-radius: 2px;
                    width: 0;
                    transition: width 0.3s, background 0.3s;
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

            <%-- Guard: if OTP not verified, redirect back --%>
                <% Boolean verified=(Boolean) session.getAttribute("otpVerified"); if (verified==null || !verified) {
                    response.sendRedirect("PasswordResetServlet"); return; } %>

                    <div class="container min-vh-100 d-flex flex-column" style="flex:1;">
                        <div class="auth-container" style="flex:1;">
                            <div class="auth-card" style="margin:auto; max-width:420px;">

                                <div class="text-center mb-4">
                                    <i class="fa-solid fa-key fa-3x mb-2" style="color:var(--primary-color)"></i>
                                    <h2 class="mb-1">Set New Password</h2>
                                    <p style="font-size:0.9rem;color:var(--text-muted);">
                                        Create a new secure password for your account.
                                    </p>
                                </div>

                                <c:if test="${not empty errorMessage}">
                                    <div class="alert alert-danger mb-4">
                                        <i class="fa-solid fa-circle-exclamation"></i> ${errorMessage}
                                    </div>
                                </c:if>

                                <form action="PasswordResetServlet" method="POST" id="resetForm" novalidate>
                                    <input type="hidden" name="action" value="reset_password">

                                    <!-- Username: locked/readonly -->
                                    <div class="form-group">
                                        <label class="form-label" for="username">Username</label>
                                        <input type="text" id="username" class="form-control username-locked"
                                            value="${sessionScope.resetUsername}" readonly tabindex="-1">
                                        <div class="locked-label-note">
                                            <i class="fa-solid fa-lock" style="font-size:0.7rem;"></i>
                                            Account linked to this username (cannot be changed)
                                        </div>
                                    </div>

                                    <!-- New Password -->
                                    <div class="form-group">
                                        <label class="form-label" for="newPassword">New Password</label>
                                        <div class="pw-toggle">
                                            <input type="password" id="newPassword" name="newPassword"
                                                class="form-control" required minlength="4"
                                                placeholder="Enter new password" oninput="checkStrength(this.value)">
                                            <button type="button" class="pw-eye-btn"
                                                onclick="togglePw('newPassword',this)" tabindex="-1">
                                                <i class="fa-solid fa-eye"></i>
                                            </button>
                                        </div>
                                        <div class="strength-bar">
                                            <div class="strength-fill" id="strengthFill"></div>
                                        </div>
                                        <div id="strengthLabel"
                                            style="font-size:0.78rem;color:var(--text-muted);margin-top:3px;"></div>
                                        <div class="invalid-feedback">Password must be at least 4 characters.</div>
                                    </div>

                                    <!-- Confirm Password -->
                                    <div class="form-group">
                                        <label class="form-label" for="confirmPassword">Confirm New Password</label>
                                        <div class="pw-toggle">
                                            <input type="password" id="confirmPassword" name="confirmPassword"
                                                class="form-control" required minlength="4"
                                                placeholder="Repeat new password">
                                            <button type="button" class="pw-eye-btn"
                                                onclick="togglePw('confirmPassword',this)" tabindex="-1">
                                                <i class="fa-solid fa-eye"></i>
                                            </button>
                                        </div>
                                        <div class="invalid-feedback">Passwords do not match.</div>
                                    </div>

                                    <button type="submit" class="btn btn-primary btn-block mt-3">
                                        <i class="fa-solid fa-check-circle"></i> Reset Password
                                    </button>
                                </form>

                            </div>
                        </div>
                    </div>

                    <footer
                        style="background-color:var(--bg-white);border-top:1px solid var(--border-color);color:var(--text-muted);padding:1.5rem 0;text-align:center;">
                        <p>&copy; 2026 Rainfall Analytics System. Academic Assignment Showcase.</p>
                    </footer>

                    <script>
                        function togglePw(id, btn) {
                            var input = document.getElementById(id);
                            var icon = btn.querySelector('i');
                            if (input.type === 'password') {
                                input.type = 'text';
                                icon.className = 'fa-solid fa-eye-slash';
                            } else {
                                input.type = 'password';
                                icon.className = 'fa-solid fa-eye';
                            }
                        }

                        function checkStrength(val) {
                            var fill = document.getElementById('strengthFill');
                            var label = document.getElementById('strengthLabel');
                            var score = 0;
                            if (val.length >= 4) score++;
                            if (val.length >= 8) score++;
                            if (/[A-Z]/.test(val)) score++;
                            if (/[0-9]/.test(val)) score++;
                            if (/[^A-Za-z0-9]/.test(val)) score++;

                            var pct = (score / 5) * 100;
                            var color = score <= 1 ? '#ef4444' : score <= 3 ? '#f59e0b' : '#10b981';
                            var text = score <= 1 ? 'Weak' : score <= 3 ? 'Moderate' : 'Strong';

                            fill.style.width = pct + '%';
                            fill.style.background = color;
                            label.textContent = val ? text : '';
                            label.style.color = color;
                        }

                        document.getElementById('resetForm').addEventListener('submit', function (e) {
                            var valid = true;
                            var pw = document.getElementById('newPassword');
                            var cpw = document.getElementById('confirmPassword');
                            pw.classList.remove('is-invalid');
                            cpw.classList.remove('is-invalid');

                            if (pw.value.trim().length < 4) {
                                pw.classList.add('is-invalid');
                                valid = false;
                            }
                            if (pw.value !== cpw.value) {
                                cpw.classList.add('is-invalid');
                                valid = false;
                            }
                            if (!valid) e.preventDefault();
                        });
                    </script>
        </body>

        </html>