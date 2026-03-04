package model;

import jakarta.persistence.*;
import java.sql.Date;

@Entity
@Table(name = "Users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "UserID")
    private int userID;

    @Column(name = "Username", unique = true, nullable = false, length = 50)
    private String username;

    @Column(name = "PasswordHash", nullable = false, length = 255)
    private String passwordHash;

    @Column(name = "Email", length = 100)
    private String email;

    @Column(name = "Role", length = 20)
    private String role;

    @Column(name = "Tier", length = 20)
    private String tier;

    @Column(name = "ExpiryDate")
    private Date expiryDate;

    @Column(name = "ProfileImage", length = 500)
    private String profileImage;

    public User() {
    }

    public User(int userID, String username, String passwordHash, String email, String role, String tier,
            Date expiryDate) {
        this.userID = userID;
        this.username = username;
        this.passwordHash = passwordHash;
        this.email = email;
        this.role = role;
        this.tier = tier;
        this.expiryDate = expiryDate;
    }

    public int getUserID() {
        return userID;
    }

    public void setUserID(int userID) {
        this.userID = userID;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getTier() {
        return tier;
    }

    public void setTier(String tier) {
        this.tier = tier;
    }

    public Date getExpiryDate() {
        return expiryDate;
    }

    public void setExpiryDate(Date expiryDate) {
        this.expiryDate = expiryDate;
    }

    public String getProfileImage() {
        return profileImage;
    }

    public void setProfileImage(String profileImage) {
        this.profileImage = profileImage;
    }
}
