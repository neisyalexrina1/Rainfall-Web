package controller;

import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import service.UserService;
import service.UserServiceImpl;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/ProfileServlet")
public class ProfileServlet extends HttpServlet {

    private final UserService userService = new UserServiceImpl();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            out.print("{\"result\":\"not_logged_in\"}");
            return;
        }

        String action = request.getParameter("action");
        User user = (User) session.getAttribute("user");

        if ("updateAvatar".equals(action)) {
            String imageUrl = request.getParameter("imageUrl");

            if (imageUrl == null || imageUrl.trim().isEmpty()) {
                // Xoá ảnh profile (đặt lại về mặc định chữ cái đầu)
                imageUrl = null;
            } else {
                imageUrl = imageUrl.trim();
                // Validate URL basic
                if (imageUrl.length() > 500) {
                    out.print("{\"result\":\"error\",\"msg\":\"URL quá dài (max 500 ký tự)\"}");
                    return;
                }
            }

            try {
                boolean updated = userService.updateProfileImage(user.getUserID(), imageUrl);
                if (updated) {
                    user.setProfileImage(imageUrl);
                    session.setAttribute("user", user);
                    out.print("{\"result\":\"success\",\"imageUrl\":\"" + (imageUrl != null ? imageUrl : "") + "\"}");
                } else {
                    out.print("{\"result\":\"error\",\"msg\":\"Không thể cập nhật DB\"}");
                }
            } catch (Exception e) {
                e.printStackTrace();
                out.print("{\"result\":\"error\",\"msg\":\"" + e.getMessage() + "\"}");
            }
        } else {
            out.print("{\"result\":\"error\",\"msg\":\"Unknown action\"}");
        }
    }
}
