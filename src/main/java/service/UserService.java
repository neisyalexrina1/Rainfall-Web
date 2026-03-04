package service;

import model.User;
import java.sql.Date;
import java.util.List;

public interface UserService {
    User login(String username, String password);

    boolean register(String username, String password, String email);

    User getUserById(int userId);

    List<User> getAllUsers();

    User findByUsername(String username);

    User findByEmail(String email);

    boolean updatePassword(int userId, String newPassword);

    boolean updateUserRoleAndTier(int userId, String role, String tier, Date expiryDate);

    boolean updateUserTier(int userId, String tier, Date expiryDate);

    boolean updateProfileImage(int userId, String imageUrl);

    boolean createUserAdmin(String username, String password, String email, String role, String tier);

    boolean updateUserFull(int userId, String username, String email, String role, String tier, Date expiryDate);

    boolean deleteUser(int userId);
}
