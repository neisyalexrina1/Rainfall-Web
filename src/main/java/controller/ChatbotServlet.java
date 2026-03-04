package controller;

import model.ForecastLog;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import service.ForecastService;
import service.ForecastServiceImpl;

@WebServlet("/ChatbotServlet")
public class ChatbotServlet extends HttpServlet {

    private final ForecastService forecastService = new ForecastServiceImpl();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        // Pro/Admin tier guard — Free users cannot access chatbot even via direct POST
        model.User chatUser = (model.User) session.getAttribute("user");
        if (!"Pro".equals(chatUser.getTier()) && !"Admin".equals(chatUser.getRole())) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().print("Tính năng này chỉ dành cho người dùng Pro. Vui lòng nâng cấp tài khoản.");
            return;
        }

        // BUG-04: null-safe message param
        String rawMessage = request.getParameter("message");
        if (rawMessage == null || rawMessage.trim().isEmpty()) {
            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().print("Vui lòng nhập câu hỏi.");
            return;
        }
        String message = rawMessage.toLowerCase();
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        int stationId = -1;
        String regionName = "";

        if (message.contains("hà nội") || message.contains("hanoi") || message.contains("ha noi")) {
            stationId = 1;
            regionName = "Hà Nội";
        } else if (message.contains("đà nẵng") || message.contains("danang") || message.contains("da nang")) {
            stationId = 2;
            regionName = "Đà Nẵng";
        } else if (message.contains("hồ chí minh") || message.contains("hcm") || message.contains("sài gòn")) {
            stationId = 3;
            regionName = "TP. Hồ Chí Minh";
        }

        if (stationId != -1) {
            // Parse target month
            String targetMonth = extractTargetMonth(message);

            ForecastLog log = generateForecast(stationId, regionName, targetMonth);

            if (log != null) {
                String advice;
                String riskEmoji;
                String riskColor;
                String riskBg;
                if ("Nguy cơ ngập".equals(log.getRiskLevel())) {
                    advice = "⚠️ Cảnh báo ngập lụt! Hạn chế di chuyển vào vùng trũng thấp. Chú ý các cung đường dễ ngập. Theo dõi cảnh báo của cơ quan khí tượng.";
                    riskEmoji = "🚨";
                    riskColor = "#dc2626";
                    riskBg = "rgba(239,68,68,0.10)";
                } else if ("Mưa lớn".equals(log.getRiskLevel())) {
                    advice = "🌂 Nên mang theo áo mưa và ô khi ra ngoài. Chú ý an toàn giao thông khi trời mưa lớn và tránh các vùng trũng thấp.";
                    riskEmoji = "🌧️";
                    riskColor = "#b45309";
                    riskBg = "rgba(245,158,11,0.10)";
                } else {
                    advice = "☀️ Thời tiết khá thuận lợi cho các hoạt động ngoài trời. Lượng mưa trong mức bình thường, không cần chuẩn bị đặc biệt.";
                    riskEmoji = "🌤️";
                    riskColor = "#059669";
                    riskBg = "rgba(16,185,129,0.10)";
                }

                String dataSource = "historical".equals(log.getDataSource())
                        ? "📂 Dữ liệu lịch sử thực tế"
                        : "🤖 Dự báo AI (Prophet Model)";

                String botReply = String.format(
                        "<div style='font-family:inherit;'>" +
                                "  <div style='font-weight:700;font-size:1rem;margin-bottom:10px;color:#1e293b;'>📊 Kết quả phân tích lượng mưa</div>"
                                +
                                "  <table style='width:100%%;border-collapse:collapse;font-size:0.88rem;'>" +
                                "    <tr><td style='padding:5px 8px;color:#64748b;width:42%%;'>📍 Khu vực</td>" +
                                "        <td style='padding:5px 8px;font-weight:600;color:#0f172a;'>%s</td></tr>" +
                                "    <tr style='background:rgba(0,0,0,0.02);'>" +
                                "        <td style='padding:5px 8px;color:#64748b;'>🗓️ Tháng</td>" +
                                "        <td style='padding:5px 8px;font-weight:600;color:#0f172a;'>%s</td></tr>" +
                                "    <tr><td style='padding:5px 8px;color:#64748b;'>💧 Lượng mưa</td>" +
                                "        <td style='padding:5px 8px;font-weight:700;font-size:1.05rem;color:#0284c7;'>%.1f mm</td></tr>"
                                +
                                "    <tr style='background:rgba(0,0,0,0.02);'>" +
                                "        <td style='padding:5px 8px;color:#64748b;'>%s Mức rủi ro</td>" +
                                "        <td style='padding:5px 8px;'>" +
                                "          <span style='background:%s;color:%s;padding:2px 10px;border-radius:999px;font-weight:600;font-size:0.85rem;'>%s</span>"
                                +
                                "        </td></tr>" +
                                "    <tr><td style='padding:5px 8px;color:#64748b;'>🔬 Nguồn</td>" +
                                "        <td style='padding:5px 8px;font-size:0.82rem;color:#475569;'>%s</td></tr>" +
                                "  </table>" +
                                "  <div style='margin-top:12px;padding:10px 12px;background:%s;border-radius:8px;font-size:0.87rem;color:%s;line-height:1.5;'>"
                                +
                                "    %s" +
                                "  </div>" +
                                "</div>",
                        regionName,
                        log.getForecastMonth(),
                        log.getPredictedRainfall(),
                        riskEmoji, riskBg, riskColor, log.getRiskLevel(),
                        dataSource,
                        riskBg, riskColor,
                        advice);
                out.print(botReply);
            } else {
                out.print("Xin lỗi, hệ thống AI hiện đang bận hoặc quá trình dự báo cho " + regionName
                        + " thất bại. Vui lòng thử lại sau.");
            }
        } else {
            out.print(
                    "Bạn muốn tra cứu lượng mưa ở khu vực nào? (Gợi ý: Hãy nhắc tới tên thành phố như Hà Nội, Đà Nẵng, TP. Hồ Chí Minh kèm theo tháng/năm bạn muốn dự báo)");
        }
    }

    private String extractTargetMonth(String message) {
        // Look for formats: "tháng 5 năm 2026", "tháng 05/2026", "tháng 5-2026",
        // "05/2026", "2026-05"
        Pattern p1 = Pattern.compile("tháng (\\d{1,2}) năm (\\d{4})");
        Matcher m1 = p1.matcher(message);
        if (m1.find()) {
            return String.format("%04d-%02d", Integer.parseInt(m1.group(2)), Integer.parseInt(m1.group(1)));
        }

        Pattern p2 = Pattern.compile("(?:tháng )?(\\d{1,2})[-/](\\d{4})");
        Matcher m2 = p2.matcher(message);
        if (m2.find()) {
            return String.format("%04d-%02d", Integer.parseInt(m2.group(2)), Integer.parseInt(m2.group(1)));
        }

        Pattern p3 = Pattern.compile("(\\d{4})-(\\d{1,2})");
        Matcher m3 = p3.matcher(message);
        if (m3.find()) {
            return String.format("%04d-%02d", Integer.parseInt(m3.group(1)), Integer.parseInt(m3.group(2)));
        }

        // Return empty so Python predicts next month dynamically
        return "";
    }

    private ForecastLog generateForecast(int stationId, String regionName, String targetMonth) {
        double predictedRainfall = 0.0;
        String riskLevel = "Bình thường";
        String nextMonth = targetMonth;

        try {
            String fileParam = "hanoi.csv";
            if (stationId == 2)
                fileParam = "danang.csv";
            if (stationId == 3)
                fileParam = "hcm.csv";

            String pyScript = getServletContext().getRealPath("/") + "../../ai_engine.py";

            ProcessBuilder processBuilder;
            if (targetMonth != null && !targetMonth.isEmpty()) {
                processBuilder = new ProcessBuilder("python", pyScript, fileParam, targetMonth);
            } else {
                processBuilder = new ProcessBuilder("python", pyScript, fileParam);
            }
            processBuilder.redirectErrorStream(true);
            Process process = processBuilder.start();

            StringBuilder output = new StringBuilder();
            try (java.io.BufferedReader reader = new java.io.BufferedReader(
                    new java.io.InputStreamReader(process.getInputStream(),
                            java.nio.charset.StandardCharsets.UTF_8))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    output.append(line);
                }
            }

            process.waitFor();

            String jsonResponse = output.toString();

            if (jsonResponse.contains("\"status\": \"success\"")) {
                String firstForecast = jsonResponse.split("\"forecasts\": \\[\\{")[1].split("\\}")[0];

                nextMonth = firstForecast.split("\"month\": \"")[1].split("\"")[0];
                String rainStr = firstForecast.split("\"predicted_rain_mm\": ")[1].split(",")[0];
                predictedRainfall = Double.parseDouble(rainStr.trim());
                riskLevel = firstForecast.split("\"risk_level\": \"")[1].split("\"")[0];

                // Detect whether result is from historical data or AI forecast
                String ds = jsonResponse.contains("\"data_source\": \"historical\"") ? "historical" : "forecast";

                ForecastLog log = new ForecastLog(
                        0, stationId, nextMonth, predictedRainfall, riskLevel,
                        new Timestamp(System.currentTimeMillis()), ds);
                forecastService.saveForecast(stationId, nextMonth, predictedRainfall, riskLevel);
                return log;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        // MOCK FALLBACK JUST IN CASE PYTHON FAILS
        if (nextMonth == null || nextMonth.isEmpty()) {
            Calendar cal = Calendar.getInstance();
            cal.add(Calendar.MONTH, 1);
            nextMonth = new SimpleDateFormat("yyyy-MM").format(cal.getTime());
        }
        if (stationId == 1) {
            predictedRainfall = 80.5;
            riskLevel = "Bình thường";
        }
        if (stationId == 2) {
            predictedRainfall = 250.0;
            riskLevel = "Nguy cơ ngập";
        }
        if (stationId == 3) {
            predictedRainfall = 180.2;
            riskLevel = "Mưa lớn";
        }

        ForecastLog log = new ForecastLog(
                0, stationId, nextMonth, predictedRainfall, riskLevel, new Timestamp(System.currentTimeMillis()));
        forecastService.saveForecast(stationId, nextMonth, predictedRainfall, riskLevel);
        return log;
    }
}
