package service;

import dao.UserDAO;
import model.User;
import java.sql.Date;
import java.util.List;

public class UserServiceImpl implements UserService {

    private final UserDAO userDAO;

    public UserServiceImpl() {
        this.userDAO = new UserDAO();
    }

    private void validateRegistration(String username, String password, String email) {
        if (username == null || username.trim().isEmpty()) {
            throw new ValidationException("Username cannot be empty");
        }
        if (password == null || password.trim().isEmpty() || password.length() < 3) {
            throw new ValidationException("Password must be at least 3 characters");
        }
        if (email == null || email.trim().isEmpty() || !email.contains("@")) {
            throw new ValidationException("Valid email is required");
        }
    }

    @Override
    public User login(String username, String password) {
        if (username == null || password == null)
            return null;
        return userDAO.login(username, password);
    }

    @Override
    public boolean register(String username, String password, String email) {
        validateRegistration(username, password, email);
        return userDAO.register(username, password, email);
    }

    @Override
    public User getUserById(int userId) {
        return userDAO.getUserById(userId);
    }

    @Override
    public List<User> getAllUsers() {
        return userDAO.getAllUsers();
    }

    @Override
    public User findByUsername(String username) {
        return userDAO.findByUsername(username);
    }

    @Override
    public User findByEmail(String email) {
        return userDAO.findByEmail(email);
    }

    @Override
    public boolean updatePassword(int userId, String newPassword) {
        return userDAO.updatePassword(userId, newPassword);
    }

    @Override
    public boolean updateUserRoleAndTier(int userId, String role, String tier, Date expiryDate) {
        return userDAO.updateUserRoleAndTier(userId, role, tier, expiryDate);
    }

    @Override
    public boolean updateUserTier(int userId, String tier, Date expiryDate) {
        return userDAO.updateUserTier(userId, tier, expiryDate);
    }

    @Override
    public boolean updateProfileImage(int userId, String imageUrl) {
        return userDAO.updateProfileImage(userId, imageUrl);
    }

    @Override
    public boolean createUserAdmin(String username, String password, String email, String role, String tier) {
        if (username == null || username.trim().isEmpty())
            throw new ValidationException("Username required");
        if (password == null || password.trim().isEmpty())
            throw new ValidationException("Password required");
        return userDAO.createUserAdmin(username, password, email, role, tier);
    }

    @Override
    public boolean updateUserFull(int userId, String username, String email, String role, String tier,
            Date expiryDate) {
        return userDAO.updateUserFull(userId, username, email, role, tier, expiryDate);
    }

    @Override
    public boolean deleteUser(int userId) {
        return userDAO.deleteUser(userId);
    }
}
