<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%-- Access gate: Free users cannot access chatbot --%>
            <% model.User currentUser=(model.User) session.getAttribute("user"); if (currentUser==null) {
                response.sendRedirect("login.jsp"); return; } if (!"Pro".equals(currentUser.getTier()) &&
                !"Admin".equals(currentUser.getRole())) {
                response.sendRedirect("DashboardServlet?upgradeRequired=true"); return; } %>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>AI Chatbot Assistant - Rainfall Analytics</title>
                    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"
                        rel="stylesheet">
                    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
                        rel="stylesheet">
                    <link rel="stylesheet" href="css/style.css?v=3">
                    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

                    <style>
                        /* Bouncing Dots Typing Indicator */
                        .typing-indicator {
                            display: flex;
                            align-items: center;
                            gap: 4px;
                            padding: 8px 12px;
                            background: rgba(11, 108, 179, 0.08);
                            border-radius: 12px;
                            width: fit-content;
                            margin-bottom: 1rem;
                            animation: fadeIn 0.3s ease;
                        }

                        .typing-dot {
                            width: 6px;
                            height: 6px;
                            background-color: var(--primary-color);
                            border-radius: 50%;
                            animation: typing 1.4s infinite ease-in-out both;
                        }

                        .typing-dot:nth-child(1) {
                            animation-delay: -0.32s;
                        }

                        .typing-dot:nth-child(2) {
                            animation-delay: -0.16s;
                        }

                        @keyframes typing {

                            0%,
                            80%,
                            100% {
                                transform: scale(0);
                                opacity: 0.5;
                            }

                            40% {
                                transform: scale(1);
                                opacity: 1;
                            }
                        }

                        /* Quick Prompts */
                        .quick-prompts {
                            display: flex;
                            gap: 0.5rem;
                            margin-bottom: 1rem;
                            flex-wrap: wrap;
                        }

                        .prompt-chip {
                            background: var(--bg-white);
                            border: 1px solid var(--border-color);
                            border-radius: 16px;
                            padding: 0.4rem 0.8rem;
                            font-size: 0.85rem;
                            color: var(--text-muted);
                            cursor: pointer;
                            transition: var(--transition);
                            box-shadow: var(--shadow-sm);
                        }

                        .prompt-chip:hover {
                            background: var(--primary-color);
                            color: var(--text-light);
                            border-color: var(--primary-color);
                            transform: translateY(-2px);
                        }
                    </style>
                </head>

                <body>

                    <div class="dashboard-container">
                        <!-- Sidebar -->
                        <aside class="sidebar">
                            <div class="sidebar-header">
                                <a href="index.jsp" class="logo">
                                    <i class="fa-solid fa-cloud-rain"></i> Analytics Pro
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
                                        <li><a href="chatbot.jsp" class="active"><i class="fa-solid fa-robot"></i> AI
                                                Chatbot</a></li>
                                    </c:when>
                                    <c:otherwise>
                                        <li><a href="#" onclick="openUpgradeModal(); return false;"
                                                style="opacity:0.55;" title="Pro feature"><i class="fa-solid fa-lock"
                                                    style="font-size:0.8em;"></i> AI Forecast</a></li>
                                        <li><a href="#" onclick="openUpgradeModal(); return false;"
                                                style="opacity:0.55;" title="Pro feature"><i class="fa-solid fa-lock"
                                                    style="font-size:0.8em;"></i> AI Chatbot</a></li>
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
                                    <h1>AI Weather Assistant</h1>
                                    <p class="text-muted">Ask me about the rainfall forecasts in any region!</p>
                                </div>
                            </header>

                            <div class="chat-container">
                                <div class="chat-messages" id="chatMessages">
                                    <div class="msg-wrapper">
                                        <div class="msg-avatar bot-avatar"><i class="fa-solid fa-robot"></i></div>
                                        <div class="msg-bubble">
                                            <div class="message bot">
                                                Xin chào! Tôi là trợ lý thời tiết AI. Hãy hỏi tôi về dự báo lượng mưa,
                                                ví dụ: <strong>"Đà Nẵng tháng sau có mưa to không?"</strong> hoặc
                                                <strong>"So sánh lượng mưa TP.HCM và Hà Nội"</strong>
                                            </div>
                                            <div class="msg-time" id="welcomeTime"></div>
                                        </div>
                                    </div>
                                </div>

                                <div class="quick-prompts">
                                    <div class="prompt-chip" data-prompt="Dự báo lượng mưa Hà Nội tháng tới thế nào?"><i
                                            class="fa-solid fa-cloud-sun"
                                            style="font-size:0.75rem;margin-right:4px;"></i>Dự báo Hà Nội</div>
                                    <div class="prompt-chip" data-prompt="Đà Nẵng có nguy cơ ngập lụt không?"><i
                                            class="fa-solid fa-water"
                                            style="font-size:0.75rem;margin-right:4px;"></i>Ngập lụt Đà Nẵng?</div>
                                    <div class="prompt-chip" data-prompt="So sánh lượng mưa TP.HCM và Hà Nội"><i
                                            class="fa-solid fa-chart-column"
                                            style="font-size:0.75rem;margin-right:4px;"></i>So sánh TP.HCM & Hà Nội
                                    </div>
                                    <div class="prompt-chip" data-prompt="Thời tiết Hà Nội tháng này thế nào?"><i
                                            class="fa-solid fa-temperature-half"
                                            style="font-size:0.75rem;margin-right:4px;"></i>Thời tiết Hà Nội</div>
                                </div>

                                <form id="chatForm" class="chat-input" onsubmit="return false;">
                                    <input type="text" id="userInput" class="form-control"
                                        placeholder="Nhập câu hỏi về thời tiết..." style="flex: 1;" autocomplete="off">
                                    <button type="button" id="sendBtn" class="btn btn-primary"
                                        style="border-radius:12px; padding: 0.5rem 1rem;"><i
                                            class="fa-solid fa-paper-plane"></i></button>
                                </form>
                            </div>
                        </main>
                    </div>

                    <script>
                        $(document).ready(function () {
                            const chatMessages = $('#chatMessages');
                            const userInput = $('#userInput');

                            // Set welcome timestamp
                            document.getElementById('welcomeTime').textContent = getTimeStr();

                            function getTimeStr() {
                                const now = new Date();
                                return now.getHours().toString().padStart(2, '0') + ':' + now.getMinutes().toString().padStart(2, '0');
                            }

                            function formatBotResponse(text) {
                                // Clean up excessive whitespace but preserve HTML structure
                                let html = text;
                                // Convert newlines to <br> if response is plain text (no HTML tags)
                                if (!/<[a-z][\s\S]*>/i.test(html)) {
                                    html = html.replace(/\n/g, '<br>');
                                }
                                return html;
                            }

                            function appendMessage(sender, text) {
                                const time = getTimeStr();
                                const isUser = sender === 'user';
                                const avatarClass = isUser ? 'user-avatar' : 'bot-avatar';
                                const userProfileImg = '${sessionScope.user.profileImage}';
                                const avatarIcon = isUser
                                    ? (userProfileImg ? '<img src="' + userProfileImg + '" style="width:32px;height:32px;max-width:32px;max-height:32px;min-width:32px;min-height:32px;border-radius:50%;object-fit:cover;display:block;" onerror="this.outerHTML=\'<i class=\\\'fa-solid fa-user\\\'></i>\'">' : '<i class="fa-solid fa-user"></i>')
                                    : '<i class="fa-solid fa-robot"></i>';
                                const wrapperClass = isUser ? 'msg-wrapper user-side' : 'msg-wrapper';
                                const msgClass = isUser ? 'message user' : 'message bot';
                                const content = isUser ? $('<div/>').text(text).html() : formatBotResponse(text);

                                const html = '<div class="' + wrapperClass + '">' +
                                    '<div class="msg-avatar ' + avatarClass + '">' + avatarIcon + '</div>' +
                                    '<div class="msg-bubble">' +
                                    '<div class="' + msgClass + '">' + content + '</div>' +
                                    '<div class="msg-time">' + time + '</div>' +
                                    '</div></div>';
                                chatMessages.append(html);
                                chatMessages.scrollTop(chatMessages[0].scrollHeight);
                            }

                            function sendMessage(text) {
                                const message = text || userInput.val().trim();
                                if (message === '') return;

                                appendMessage('user', message);
                                userInput.val('');

                                // Show premium bouncing dots typing indicator
                                const typingHtml = '<div class="msg-wrapper typing-msg">' +
                                    '<div class="msg-avatar bot-avatar"><i class="fa-solid fa-robot"></i></div>' +
                                    '<div class="msg-bubble"><div class="message bot">' +
                                    '<div class="typing-indicator">' +
                                    '<div class="typing-dot"></div><div class="typing-dot"></div><div class="typing-dot"></div>' +
                                    '</div></div></div></div>';
                                chatMessages.append(typingHtml);
                                chatMessages.scrollTop(chatMessages[0].scrollHeight);
                                const lastMsg = chatMessages.find('.typing-msg').last();

                                $.ajax({
                                    url: 'ChatbotServlet',
                                    type: 'POST',
                                    data: { message: message },
                                    success: function (response) {
                                        lastMsg.remove();
                                        appendMessage('bot', response);
                                    },
                                    error: function () {
                                        lastMsg.remove();
                                        appendMessage('bot', '<span class="text-danger"><i class="fa-solid fa-circle-exclamation"></i> Xin lỗi, có lỗi xảy ra. Vui lòng thử lại.</span>');
                                    }
                                });
                            }

                            $('#sendBtn').click(function () { sendMessage(); });

                            $('.prompt-chip').click(function () {
                                const promptText = $(this).data('prompt');
                                sendMessage(promptText);
                            });

                            userInput.keypress(function (e) {
                                if (e.which == 13) {
                                    sendMessage();
                                    return false;
                                }
                            });
                        });
                    </script>

                    <!-- ── Upgrade Modal ─────────────────────────────── -->
                    <div id="upgradeModal" style="display:none;position:fixed;inset:0;z-index:9999;
            background:rgba(15,23,42,0.55);backdrop-filter:blur(4px);
            align-items:center;justify-content:center;">
                        <div style="background:#fff;border-radius:18px;padding:2.5rem 2rem;max-width:780px;width:94%;
                box-shadow:0 25px 60px rgba(0,0,0,0.2);position:relative;max-height:90vh;overflow-y:auto;">
                            <button onclick="closeUpgradeModal()" style="position:absolute;top:1rem;right:1.2rem;
                    background:none;border:none;font-size:1.5rem;cursor:pointer;color:#94a3b8;">×</button>
                            <div style="text-align:center;margin-bottom:1.5rem;">
                                <i class="fa-solid fa-crown"
                                    style="font-size:2rem;color:#f59e0b;margin-bottom:0.5rem;"></i>
                                <h2 style="margin:0;font-size:1.6rem;">Upgrade to Pro</h2>
                                <p style="color:#64748b;font-size:0.9rem;margin-top:0.4rem;">Unlock AI Forecasting &amp;
                                    Chatbot</p>
                            </div>
                            <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:1rem;">
                                <div style="border:1.5px solid #e2e8f0;border-radius:12px;padding:1.25rem;">
                                    <h3 style="font-size:1rem;margin:0 0 0.5rem;">Free Tier</h3>
                                    <div style="font-size:1.8rem;font-weight:800;margin-bottom:1rem;">0đ<span
                                            style="font-size:0.9rem;font-weight:400;color:#94a3b8;">/month</span></div>
                                    <ul
                                        style="list-style:none;padding:0;margin:0 0 1.2rem;font-size:0.87rem;display:flex;flex-direction:column;gap:5px;">
                                        <li><i class="fa-solid fa-check" style="color:#10b981;"></i> Historical Data
                                        </li>
                                        <li><i class="fa-solid fa-check" style="color:#10b981;"></i> Basic Charts</li>
                                        <li style="color:#94a3b8;"><i class="fa-solid fa-xmark"
                                                style="color:#ef4444;"></i> AI Forecasting</li>
                                        <li style="color:#94a3b8;"><i class="fa-solid fa-xmark"
                                                style="color:#ef4444;"></i> AI Chatbot</li>
                                    </ul>
                                    <span
                                        style="display:block;text-align:center;padding:0.5rem;border:1.5px solid #e2e8f0;border-radius:8px;color:#94a3b8;font-size:0.85rem;">Current
                                        Plan</span>
                                </div>
                                <div
                                    style="border:2px solid #0b6cb3;border-radius:12px;padding:1.25rem;position:relative;background:rgba(11,108,179,0.03);">
                                    <span
                                        style="position:absolute;top:-11px;left:50%;transform:translateX(-50%);
                            background:#0b6cb3;color:#fff;font-size:0.72rem;font-weight:700;padding:2px 10px;border-radius:999px;">POPULAR</span>
                                    <h3 style="font-size:1rem;margin:0 0 0.5rem;color:#0b6cb3;">Pro Monthly</h3>
                                    <div style="font-size:1.8rem;font-weight:800;margin-bottom:1rem;color:#0b6cb3;">
                                        50k<span style="font-size:0.9rem;font-weight:400;color:#94a3b8;">/month</span>
                                    </div>
                                    <ul
                                        style="list-style:none;padding:0;margin:0 0 1.2rem;font-size:0.87rem;display:flex;flex-direction:column;gap:5px;">
                                        <li><i class="fa-solid fa-check" style="color:#10b981;"></i> All Free features
                                        </li>
                                        <li><i class="fa-solid fa-check" style="color:#10b981;"></i> AI Forecasting</li>
                                        <li><i class="fa-solid fa-check" style="color:#10b981;"></i> AI Chatbot</li>
                                        <li><i class="fa-solid fa-check" style="color:#10b981;"></i> Risk Warnings</li>
                                    </ul>
                                    <form action="PaymentServlet" method="GET">
                                        <input type="hidden" name="packageId" value="2">
                                        <button type="submit"
                                            style="width:100%;background:#0b6cb3;color:#fff;border:none;border-radius:8px;padding:0.55rem;font-weight:600;font-size:0.9rem;cursor:pointer;">Upgrade
                                            Now</button>
                                    </form>
                                </div>
                                <div style="border:1.5px solid #e2e8f0;border-radius:12px;padding:1.25rem;">
                                    <h3 style="font-size:1rem;margin:0 0 0.5rem;">Pro Yearly</h3>
                                    <div style="font-size:1.8rem;font-weight:800;margin-bottom:1rem;">500k<span
                                            style="font-size:0.9rem;font-weight:400;color:#94a3b8;">/year</span></div>
                                    <ul
                                        style="list-style:none;padding:0;margin:0 0 1.2rem;font-size:0.87rem;display:flex;flex-direction:column;gap:5px;">
                                        <li><i class="fa-solid fa-check" style="color:#10b981;"></i> All Pro features
                                        </li>
                                        <li><i class="fa-solid fa-check" style="color:#10b981;"></i> Save 100k/year</li>
                                        <li><i class="fa-solid fa-check" style="color:#10b981;"></i> Priority Support
                                        </li>
                                    </ul>
                                    <form action="PaymentServlet" method="GET">
                                        <input type="hidden" name="packageId" value="3">
                                        <button type="submit"
                                            style="width:100%;background:#fff;color:#374151;border:1.5px solid #e2e8f0;border-radius:8px;padding:0.55rem;font-weight:600;font-size:0.9rem;cursor:pointer;">Upgrade
                                            Yearly</button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                    <script>
                        function openUpgradeModal() { var m = document.getElementById('upgradeModal'); m.style.display = 'flex'; document.body.style.overflow = 'hidden'; }
                        function closeUpgradeModal() { var m = document.getElementById('upgradeModal'); m.style.display = 'none'; document.body.style.overflow = ''; }
                        document.getElementById('upgradeModal').addEventListener('click', function (e) { if (e.target === this) closeUpgradeModal(); });
                    </script>

                </body>

                </html>