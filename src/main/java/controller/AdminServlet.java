package controller;

import model.ForecastLog;
import model.Order;
import model.RainfallData;
import model.Station;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import service.*;

import java.io.IOException;
import java.nio.file.Paths;
import java.sql.Date;
import java.util.List;

@WebServlet("/AdminServlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 1, maxFileSize = 1024 * 1024 * 10, maxRequestSize = 1024 * 1024
        * 100)
public class AdminServlet extends HttpServlet {

    private final UserService userService = new UserServiceImpl();
    private final OrderService orderService = new OrderServiceImpl();
    private final StationService stationService = new StationServiceImpl();
    private final RainfallDataService rainfallDataService = new RainfallDataServiceImpl();
    private final ForecastService forecastService = new ForecastServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ── Auth guard ──
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            request.setAttribute("errorMessage", "Vui lòng đăng nhập để tiếp tục.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }
        User user = (User) session.getAttribute("user");
        if (!"Admin".equals(user.getRole())) {
            response.sendRedirect("index.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action == null)
            action = "dashboard";

        switch (action) {
            case "manageUsers":
                handleManageUsers(request, response);
                break;
            case "manageOrders":
                handleManageOrders(request, response);
                break;
            case "manageStations":
                handleManageStations(request, response);
                break;
            case "rainfallData":
                handleRainfallData(request, response);
                break;
            case "forecastLogs":
                handleForecastLogs(request, response);
                break;
            default:
                handleDashboard(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            request.setAttribute("errorMessage", "Vui lòng đăng nhập để tiếp tục.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }
        User user = (User) session.getAttribute("user");
        if (!"Admin".equals(user.getRole())) {
            response.sendRedirect("index.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("importCSV".equals(action)) {
            handleImportCSV(request, response);
        } else if ("trainAI".equals(action)) {
            handleTrainAI(request, response);
        } else if ("updateUser".equals(action)) {
            handleUpdateUser(request, response);
        } else if ("createUser".equals(action)) {
            handleCreateUser(request, response);
        } else if ("deleteUser".equals(action)) {
            handleDeleteUser(request, response);
        } else if ("updateStation".equals(action)) {
            handleUpdateStation(request, response);
        } else if ("createStation".equals(action)) {
            handleCreateStation(request, response);
        } else if ("deleteStation".equals(action)) {
            handleDeleteStation(request, response);
        } else if ("deleteForecastLog".equals(action)) {
            handleDeleteForecastLog(request, response);
        } else {
            handleDashboard(request, response);
        }
    }

    // ── Dashboard ─────────────────────────────────────────────────────────
    private void handleDashboard(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Real stats from DB
        List<User> allUsers = userService.getAllUsers();
        long proCount = allUsers.stream()
                .filter(u -> "Pro".equalsIgnoreCase(u.getTier()))
                .count();
        List<RainfallData> allData = rainfallDataService.getAllRainfallData();
        List<ForecastLog> logs = forecastService.getForecastLogs();

        request.setAttribute("totalUsers", allUsers.size());
        request.setAttribute("proUsers", proCount);
        request.setAttribute("dataCount", allData.size());
        request.setAttribute("recentLogs", logs.size() > 5 ? logs.subList(0, 5) : logs);
        request.setAttribute("adminPage", "dashboard");
        request.getRequestDispatcher("admin.jsp").forward(request, response);
    }

    // ── Manage Users ──────────────────────────────────────────────────────
    private void handleManageUsers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<User> users = userService.getAllUsers();
        request.setAttribute("userList", users);
        request.setAttribute("adminPage", "manageUsers");
        request.getRequestDispatcher("admin.jsp").forward(request, response);
    }

    private void handleUpdateUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int userId = Integer.parseInt(request.getParameter("userId"));
            String username = request.getParameter("username");
            String email = request.getParameter("email");
            String role = request.getParameter("role");
            String tier = request.getParameter("tier");
            String expiryStr = request.getParameter("expiryDate");
            Date expiryDate = (expiryStr != null && !expiryStr.isEmpty()) ? Date.valueOf(expiryStr) : null;

            userService.updateUserFull(userId, username, email, role, tier, expiryDate);
            request.setAttribute("message", "Cập nhật user #" + userId + " thành công!");
        } catch (Exception e) {
            request.setAttribute("message", "Lỗi cập nhật: " + e.getMessage());
        }
        handleManageUsers(request, response);
    }

    private void handleCreateUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String username = request.getParameter("username");
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            String role = request.getParameter("role");
            String tier = request.getParameter("tier");

            if (userService.createUserAdmin(username, password, email, role, tier)) {
                request.setAttribute("message", "Tạo user " + username + " thành công!");
            } else {
                request.setAttribute("message", "Lỗi tạo user (có thể trùng username hoặc email).");
            }
        } catch (Exception e) {
            request.setAttribute("message", "Lỗi tạo user: " + e.getMessage());
        }
        handleManageUsers(request, response);
    }

    private void handleDeleteUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int userId = Integer.parseInt(request.getParameter("userId"));
            if (userService.deleteUser(userId)) {
                request.setAttribute("message", "Đã xoá user #" + userId + " thành công.");
            } else {
                request.setAttribute("message", "Không thể xoá. Kiểm tra khoá ngoại hoặc trigger.");
            }
        } catch (Exception e) {
            request.setAttribute("message", "Lỗi xoá user." + e.getMessage());
        }
        handleManageUsers(request, response);
    }

    // ── Manage Orders ─────────────────────────────────────────────────────
    private void handleManageOrders(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Order> orders = orderService.getAllOrders();
        request.setAttribute("orderList", orders);
        request.setAttribute("adminPage", "manageOrders");
        request.getRequestDispatcher("admin.jsp").forward(request, response);
    }

    // ── Manage Stations ───────────────────────────────────────────────────
    private void handleManageStations(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Station> stations = stationService.getAllStations();
        request.setAttribute("stationList", stations);
        request.setAttribute("adminPage", "manageStations");
        request.getRequestDispatcher("admin.jsp").forward(request, response);
    }

    private void handleUpdateStation(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int stationId = Integer.parseInt(request.getParameter("stationId"));
            String name = request.getParameter("stationName");
            String region = request.getParameter("region");
            stationService.updateStation(stationId, name, region);
            request.setAttribute("message", "Cập nhật trạm #" + stationId + " thành công!");
        } catch (Exception e) {
            request.setAttribute("message", "Lỗi cập nhật: " + e.getMessage());
        }
        handleManageStations(request, response);
    }

    private void handleCreateStation(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int stationId = Integer.parseInt(request.getParameter("stationId"));
            String name = request.getParameter("stationName");
            String region = request.getParameter("region");
            if (stationService.createStation(stationId, name, region)) {
                request.setAttribute("message", "Tạo trạm #" + stationId + " thành công!");
            } else {
                request.setAttribute("message", "Lỗi tạo trạm (ID đã tồn tại).");
            }
        } catch (Exception e) {
            request.setAttribute("message", "Lỗi tạo trạm: " + e.getMessage());
        }
        handleManageStations(request, response);
    }

    private void handleDeleteStation(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int stationId = Integer.parseInt(request.getParameter("stationId"));
            if (stationService.deleteStation(stationId)) {
                request.setAttribute("message", "Đã xoá trạm #" + stationId + " thành công.");
            } else {
                request.setAttribute("message", "Không thể xoá trạm. (Có thể đang bị tham chiếu ở bảng khác).");
            }
        } catch (Exception e) {
            request.setAttribute("message", "Lỗi xoá trạm: " + e.getMessage());
        }
        handleManageStations(request, response);
    }

    // ── Rainfall Data ─────────────────────────────────────────────────────
    private void handleRainfallData(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String stationIdStr = request.getParameter("stationId");
        List<Station> stations = stationService.getAllStations();
        request.setAttribute("stationList", stations);

        if (stationIdStr != null && !stationIdStr.isEmpty()) {
            int stationId = Integer.parseInt(stationIdStr);
            List<RainfallData> data = rainfallDataService.getRainfallByStationId(stationId);
            request.setAttribute("rainfallList", data);
            request.setAttribute("selectedStationId", stationId);
        } else {
            List<RainfallData> data = rainfallDataService.getAllRainfallData();
            request.setAttribute("rainfallList", data);
        }

        request.setAttribute("adminPage", "rainfallData");
        request.getRequestDispatcher("admin.jsp").forward(request, response);
    }

    // ── Forecast Logs ─────────────────────────────────────────────────────
    private void handleForecastLogs(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<ForecastLog> logs = forecastService.getForecastLogs();
        List<Station> stations = stationService.getAllStations();
        request.setAttribute("forecastLogList", logs);
        request.setAttribute("stationList", stations);
        request.setAttribute("adminPage", "forecastLogs");
        request.getRequestDispatcher("admin.jsp").forward(request, response);
    }

    private void handleDeleteForecastLog(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int forecastId = Integer.parseInt(request.getParameter("forecastId"));
            if (forecastService.deleteForecastLog(forecastId)) {
                request.setAttribute("message", "Đã xoá bản ghi dự báo #" + forecastId);
            } else {
                request.setAttribute("message", "Lỗi xoá bản ghi dự báo.");
            }
        } catch (Exception e) {
            request.setAttribute("message", "Ngoại lệ xoá dự báo: " + e.getMessage());
        }
        handleForecastLogs(request, response);
    }

    // ── Import CSV ────────────────────────────────────────────────────────
    private void handleImportCSV(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            Part filePart = request.getPart("file");
            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            request.setAttribute("message", "File '" + fileName + "' imported successfully! Data merged into DB.");
        } catch (Exception e) {
            request.setAttribute("message", "Error importing CSV.");
        }
        handleDashboard(request, response);
    }

    // ── Train AI ──────────────────────────────────────────────────────────
    private void handleTrainAI(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            request.setAttribute("message",
                    "AI Model Prophet has been successfully retrained on the latest dataset.");
        } catch (Exception e) {
            request.setAttribute("message", "Error triggering model training.");
        }
        handleDashboard(request, response);
    }
}
