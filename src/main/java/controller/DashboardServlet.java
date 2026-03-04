package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/DashboardServlet")
public class DashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            request.setAttribute("errorMessage", "Vui lòng đăng nhập để tiếp tục.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        // Admin should never see the user dashboard — redirect to admin panel
        model.User currentUser = (model.User) session.getAttribute("user");
        if ("Admin".equalsIgnoreCase(currentUser.getRole())) {
            response.sendRedirect("AdminServlet?action=dashboard");
            return;
        }

        // Process Historical Data if requested or for main dashboard charts
        String basePath = getServletContext().getRealPath("/") + "../../";

        try {
            // Arrays for Line Chart (Yearly - last 5 years: 2020-2024 for demo if full data
            // isn't parsed)
            // To keep it fast and responsive for the UI assignment, we'll parse the last 5
            // years aggregated.
            Map<String, double[]> yearlyData = new HashMap<String, double[]>();
            yearlyData.put("Hà Nội", getYearlyAggregates(basePath + "hanoi.csv"));
            yearlyData.put("Đà Nẵng", getYearlyAggregates(basePath + "danang.csv"));
            yearlyData.put("TP.HCM", getYearlyAggregates(basePath + "hcm.csv"));

            // Monthly for the Bar Chart (Current year mock or average)
            Map<String, double[]> monthlyData = new HashMap<String, double[]>();
            monthlyData.put("Hà Nội", getMonthlyAggregates(basePath + "hanoi.csv"));
            monthlyData.put("Đà Nẵng", getMonthlyAggregates(basePath + "danang.csv"));
            monthlyData.put("TP.HCM", getMonthlyAggregates(basePath + "hcm.csv"));

            request.setAttribute("yearlyLabels", "['2020', '2021', '2022', '2023', '2024']");
            request.setAttribute("monthlyLabels",
                    "['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']");

            request.setAttribute("hnYearly", arrayToString(yearlyData.get("Hà Nội")));
            request.setAttribute("dnYearly", arrayToString(yearlyData.get("Đà Nẵng")));
            request.setAttribute("hcmYearly", arrayToString(yearlyData.get("TP.HCM")));

            request.setAttribute("hnMonthly", arrayToString(monthlyData.get("Hà Nội")));
            request.setAttribute("dnMonthly", arrayToString(monthlyData.get("Đà Nẵng")));
            request.setAttribute("hcmMonthly", arrayToString(monthlyData.get("TP.HCM")));

            // KPI Calculations
            double totalRainfallCurrentYear = monthlyData.get("Đà Nẵng")[0] + monthlyData.get("Hà Nội")[0]
                    + monthlyData.get("TP.HCM")[0]; // Simplified mock sum for KPI
            request.setAttribute("totalRainfall", String.format("%.0f", totalRainfallCurrentYear * 12));

            if ("true".equals(request.getParameter("history"))) {
                String startDate = request.getParameter("startDate");
                String endDate = request.getParameter("endDate");

                // default to 2024 if empty
                if (startDate == null || startDate.trim().isEmpty())
                    startDate = "2024-01-01";
                if (endDate == null || endDate.trim().isEmpty())
                    endDate = "2024-12-31";

                request.setAttribute("startDate", startDate);
                request.setAttribute("endDate", endDate);

                java.util.SortedMap<String, double[]> dailyData = getDailyRainfall(startDate, endDate, basePath);
                StringBuilder json = new StringBuilder("[");
                for (Map.Entry<String, double[]> entry : dailyData.entrySet()) {
                    json.append(String.format(java.util.Locale.US,
                            "{\"date\":\"%s\", \"hn\":%.1f, \"dn\":%.1f, \"hcm\":%.1f},",
                            entry.getKey(), entry.getValue()[0], entry.getValue()[1], entry.getValue()[2]));
                }
                if (json.length() > 1)
                    json.setLength(json.length() - 1);
                json.append("]");

                request.setAttribute("dailyJson", json.toString());
            }

        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("Error reading CSV files: " + e.getMessage());
        }

        request.getRequestDispatcher("dashboard.jsp").forward(request, response);
    }

    private double[] getYearlyAggregates(String filePath) {
        double[] yearly = new double[5]; // 2020-2024
        File f = new File(filePath);
        if (!f.exists())
            return new double[] { 1700, 1650, 1800, 1600, 1900 }; // Fallback mock

        try (BufferedReader br = new BufferedReader(new FileReader(f))) {
            String line;
            boolean isFirst = true;
            while ((line = br.readLine()) != null) {
                if (isFirst) {
                    isFirst = false;
                    continue;
                } // skip header
                String[] cols = line.split(",");
                if (cols.length >= 2) {
                    String date = cols[0];
                    double prcp = 0;
                    try {
                        prcp = Double.parseDouble(cols[1]);
                    } catch (Exception ignored) {
                    }

                    if (date.startsWith("2020"))
                        yearly[0] += prcp;
                    else if (date.startsWith("2021"))
                        yearly[1] += prcp;
                    else if (date.startsWith("2022"))
                        yearly[2] += prcp;
                    else if (date.startsWith("2023"))
                        yearly[3] += prcp;
                    else if (date.startsWith("2024"))
                        yearly[4] += prcp;
                }
            }
        } catch (Exception e) {
        }
        return yearly;
    }

    private double[] getMonthlyAggregates(String filePath) {
        double[] monthly = new double[12]; // Jan-Dec for 2024
        File f = new File(filePath);
        if (!f.exists())
            return new double[] { 30, 40, 50, 90, 150, 200, 250, 300, 200, 100, 50, 20 }; // Fallback mock

        try (BufferedReader br = new BufferedReader(new FileReader(f))) {
            String line;
            boolean isFirst = true;
            while ((line = br.readLine()) != null) {
                if (isFirst) {
                    isFirst = false;
                    continue;
                }
                String[] cols = line.split(",");
                if (cols.length >= 2 && cols[0].startsWith("2024")) {
                    String[] dateParts = cols[0].split("-");
                    if (dateParts.length >= 2) {
                        int month = Integer.parseInt(dateParts[1]) - 1;
                        double prcp = 0;
                        try {
                            prcp = Double.parseDouble(cols[1]);
                        } catch (Exception ignored) {
                        }
                        if (month >= 0 && month < 12) {
                            monthly[month] += prcp;
                        }
                    }
                }
            }
        } catch (Exception e) {
        }
        return monthly;
    }

    private java.util.SortedMap<String, double[]> getDailyRainfall(String startDate, String endDate, String basePath) {
        java.util.TreeMap<String, double[]> dataMap = new java.util.TreeMap<>();

        loadDaily(dataMap, basePath + "hanoi.csv", 0, startDate, endDate);
        loadDaily(dataMap, basePath + "danang.csv", 1, startDate, endDate);
        loadDaily(dataMap, basePath + "hcm.csv", 2, startDate, endDate);

        return dataMap;
    }

    private void loadDaily(java.util.Map<String, double[]> map, String filePath, int regionIndex, String startDate,
            String endDate) {
        File f = new File(filePath);
        if (!f.exists())
            return;
        try (BufferedReader br = new BufferedReader(new FileReader(f))) {
            String line;
            boolean isFirst = true;
            while ((line = br.readLine()) != null) {
                if (isFirst) {
                    isFirst = false;
                    continue;
                }
                String[] cols = line.split(",");
                if (cols.length >= 2) {
                    String date = cols[0];
                    if (date.compareTo(startDate) >= 0 && date.compareTo(endDate) <= 0) {
                        double prcp = 0;
                        try {
                            prcp = Double.parseDouble(cols[1]);
                        } catch (Exception ignored) {
                        }

                        double[] arr = map.computeIfAbsent(date, k -> new double[3]);
                        arr[regionIndex] = prcp;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private String arrayToString(double[] arr) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < arr.length; i++) {
            sb.append(String.format(java.util.Locale.US, "%.1f", arr[i]));
            if (i < arr.length - 1)
                sb.append(",");
        }
        sb.append("]");
        return sb.toString();
    }
}
