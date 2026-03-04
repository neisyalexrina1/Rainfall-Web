package service;

import jakarta.mail.*;
import jakarta.mail.internet.*;

import java.util.Properties;

/**
 * Sends emails via Gmail SMTP.
 * Used for: registration OTP, order receipt, password reset OTP.
 */
public class EmailService {

    private final String fromEmail = "dominhgiabaobmg@gmail.com";
    private final String password = "rqwvnhbhrlzgcpjm"; // Gmail App Password

    /** Sends an HTML email. */
    public void sendHtml(String toEmail, String subject, String htmlBody) throws Exception {
        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");

        Session session = Session.getInstance(props,
                new Authenticator() {
                    @Override
                    protected PasswordAuthentication getPasswordAuthentication() {
                        return new PasswordAuthentication(fromEmail, password);
                    }
                });

        MimeMessage message = new MimeMessage(session);
        message.setFrom(new InternetAddress(fromEmail));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject(subject);
        message.setContent(htmlBody, "text/html; charset=UTF-8");
        Transport.send(message);
    }

    /** Sends a password reset OTP email. */
    public void sendPasswordResetOtp(String toEmail, String username, String otp) throws Exception {
        String html = "<!DOCTYPE html><html><head><meta charset='UTF-8'></head>"
                + "<body style='margin:0;padding:0;background:#f1f4f8;font-family:Inter,Segoe UI,sans-serif;'>"
                + "<table width='100%' cellpadding='0' cellspacing='0' style='background:#f1f4f8;padding:40px 0;'><tr><td align='center'>"
                + "<table width='520' cellpadding='0' cellspacing='0' style='background:#fff;border-radius:14px;box-shadow:0 4px 20px rgba(0,0,0,0.08);overflow:hidden;'>"
                + "<tr><td style='background:linear-gradient(135deg,#1e293b,#0f172a);padding:28px 40px;text-align:center;'>"
                + "<h1 style='margin:0;color:#fff;font-size:22px;font-weight:700;'>🔐 Password Reset</h1>"
                + "<p style='margin:6px 0 0;color:#94a3b8;font-size:13px;'>Rainfall Analytics System</p></td></tr>"
                + "<tr><td style='padding:32px 40px;'>"
                + "<p style='color:#374151;font-size:15px;line-height:1.6;margin:0 0 20px;'>Hi <strong>" + username
                + "</strong>,<br>We received a request to reset your password. Use the code below:</p>"
                + "<div style='background:#f0f7ff;border:2px dashed #0284c7;border-radius:10px;padding:20px;text-align:center;margin:0 0 20px;'>"
                + "<div style='font-size:2.4rem;font-weight:800;letter-spacing:0.25em;color:#0b6cb3;'>" + otp + "</div>"
                + "<p style='margin:8px 0 0;font-size:12px;color:#64748b;'>Valid for <strong>10 minutes</strong></p></div>"
                + "<p style='color:#6b7280;font-size:13px;line-height:1.6;'>If you did not request a password reset, please ignore this email.<br>Your account remains secure.</p>"
                + "</td></tr>"
                + "<tr><td style='padding:16px 40px 28px;text-align:center;border-top:1px solid #f1f4f8;'>"
                + "<p style='margin:0;color:#94a3b8;font-size:12px;'>© 2026 Rainfall Analytics System</p></td></tr>"
                + "</table></td></tr></table></body></html>";
        sendHtml(toEmail, "🔐 Password Reset — Verification Code", html);
    }

    /** Sends a login verification OTP email when session has expired. */
    public void sendLoginOtp(String toEmail, String username, String otp) throws Exception {
        String html = "<!DOCTYPE html><html><head><meta charset='UTF-8'></head>"
                + "<body style='margin:0;padding:0;background:#f1f4f8;font-family:Inter,Segoe UI,sans-serif;'>"
                + "<table width='100%' cellpadding='0' cellspacing='0' style='background:#f1f4f8;padding:40px 0;'><tr><td align='center'>"
                + "<table width='520' cellpadding='0' cellspacing='0' style='background:#fff;border-radius:14px;box-shadow:0 4px 20px rgba(0,0,0,0.08);overflow:hidden;'>"
                + "<tr><td style='background:linear-gradient(135deg,#4f46e5,#7c3aed);padding:28px 40px;text-align:center;'>"
                + "<h1 style='margin:0;color:#fff;font-size:22px;font-weight:700;'>🔒 Xác nhận đăng nhập</h1>"
                + "<p style='margin:6px 0 0;color:#c4b5fd;font-size:13px;'>Rainfall Analytics System</p></td></tr>"
                + "<tr><td style='padding:32px 40px;'>"
                + "<p style='color:#374151;font-size:15px;line-height:1.6;margin:0 0 20px;'>Chào <strong>" + username
                + "</strong>,<br>Phiên đăng nhập của bạn đã hết hạn. Vui lòng nhập mã bên dưới để xác nhận danh tính:</p>"
                + "<div style='background:#f5f3ff;border:2px dashed #7c3aed;border-radius:10px;padding:20px;text-align:center;margin:0 0 20px;'>"
                + "<div style='font-size:2.4rem;font-weight:800;letter-spacing:0.25em;color:#4f46e5;'>" + otp + "</div>"
                + "<p style='margin:8px 0 0;font-size:12px;color:#64748b;'>Mã có hiệu lực trong <strong>10 phút</strong></p></div>"
                + "<div style='background:#fef3c7;border-left:4px solid #f59e0b;border-radius:6px;padding:12px 16px;margin-bottom:16px;'>"
                + "<p style='margin:0;color:#92400e;font-size:13px;'>⚠️ Nếu bạn không thực hiện đăng nhập này, hãy đổi mật khẩu ngay lập tức.</p></div>"
                + "<p style='color:#6b7280;font-size:13px;line-height:1.6;'>Vì lý do bảo mật, mã này chỉ dùng một lần và hết hạn sau 10 phút.</p>"
                + "</td></tr>"
                + "<tr><td style='padding:16px 40px 28px;text-align:center;border-top:1px solid #f1f4f8;'>"
                + "<p style='margin:0;color:#94a3b8;font-size:12px;'>© 2026 Rainfall Analytics System</p></td></tr>"
                + "</table></td></tr></table></body></html>";
        sendHtml(toEmail, "🔒 Xác nhận đăng nhập — Rainfall Analytics", html);
    }

    /** Sends a registration OTP email to verify the user's email address. */
    public void sendRegistrationOtp(String toEmail, String username, String otp) throws Exception {
        String html = "<!DOCTYPE html><html><head><meta charset='UTF-8'></head>"
                + "<body style='margin:0;padding:0;background:#f1f4f8;font-family:Inter,Segoe UI,sans-serif;'>"
                + "<table width='100%' cellpadding='0' cellspacing='0' style='background:#f1f4f8;padding:40px 0;'><tr><td align='center'>"
                + "<table width='520' cellpadding='0' cellspacing='0' style='background:#fff;border-radius:14px;box-shadow:0 4px 20px rgba(0,0,0,0.08);overflow:hidden;'>"
                + "<tr><td style='background:linear-gradient(135deg,#0b6cb3,#0284c7);padding:28px 40px;text-align:center;'>"
                + "<h1 style='margin:0;color:#fff;font-size:22px;font-weight:700;'>✅ Xác nhận tài khoản</h1>"
                + "<p style='margin:6px 0 0;color:#bae6fd;font-size:13px;'>Rainfall Analytics System</p></td></tr>"
                + "<tr><td style='padding:32px 40px;'>"
                + "<p style='color:#374151;font-size:15px;line-height:1.6;margin:0 0 20px;'>Chào <strong>" + username
                + "</strong>,<br>Cảm ơn bạn đã đăng ký! Vui lòng nhập mã xác nhận bên dưới để kích hoạt tài khoản của bạn:</p>"
                + "<div style='background:#f0fdf4;border:2px dashed #16a34a;border-radius:10px;padding:20px;text-align:center;margin:0 0 20px;'>"
                + "<div style='font-size:2.4rem;font-weight:800;letter-spacing:0.25em;color:#15803d;'>" + otp + "</div>"
                + "<p style='margin:8px 0 0;font-size:12px;color:#64748b;'>Mã có hiệu lực trong <strong>10 phút</strong></p></div>"
                + "<p style='color:#6b7280;font-size:13px;line-height:1.6;'>Nếu bạn không đăng ký tài khoản, vui lòng bỏ qua email này.</p>"
                + "</td></tr>"
                + "<tr><td style='padding:16px 40px 28px;text-align:center;border-top:1px solid #f1f4f8;'>"
                + "<p style='margin:0;color:#94a3b8;font-size:12px;'>© 2026 Rainfall Analytics System</p></td></tr>"
                + "</table></td></tr></table></body></html>";
        sendHtml(toEmail, "✅ Xác nhận đăng ký tài khoản — Rainfall Analytics", html);
    }

    /** Sends a payment receipt email after successful Pro upgrade. */
    public void sendPaymentReceipt(String toEmail, String username, String packageName,
            double amount, String ref, String expiry) throws Exception {
        String amountStr = String.format("%,.0f", amount) + " VND";
        String html = "<!DOCTYPE html><html><head><meta charset='UTF-8'></head>"
                + "<body style='margin:0;padding:0;background:#f1f4f8;font-family:Inter,Segoe UI,sans-serif;'>"
                + "<table width='100%' cellpadding='0' cellspacing='0' style='background:#f1f4f8;padding:40px 0;'><tr><td align='center'>"
                + "<table width='560' cellpadding='0' cellspacing='0' style='background:#fff;border-radius:14px;box-shadow:0 4px 20px rgba(0,0,0,0.08);overflow:hidden;'>"
                + "<tr><td style='background:linear-gradient(135deg,#0f172a,#1e3a5f);padding:28px 40px;text-align:center;'>"
                + "<h1 style='margin:0;color:#fff;font-size:22px;font-weight:700;'>🎉 Nâng cấp Pro thành công!</h1>"
                + "<p style='margin:6px 0 0;color:#94a3b8;font-size:13px;'>Rainfall Analytics System</p></td></tr>"
                + "<tr><td style='padding:32px 40px;'>"
                + "<p style='color:#374151;font-size:15px;line-height:1.6;margin:0 0 24px;'>Chào <strong>" + username
                + "</strong>,<br>Thanh toán của bạn đã được xác nhận. Dưới đây là chi tiết đơn hàng:</p>"
                + "<table width='100%' cellpadding='0' cellspacing='0' style='border-radius:10px;overflow:hidden;border:1px solid #e2e8f0;margin-bottom:24px;'>"
                + "<tr style='background:#f8fafc;'><td style='padding:12px 20px;font-size:13px;color:#64748b;font-weight:600;border-bottom:1px solid #e2e8f0;'>GÓI DỊCH VỤ</td>"
                + "<td style='padding:12px 20px;font-size:14px;color:#0f172a;font-weight:700;border-bottom:1px solid #e2e8f0;text-align:right;'>"
                + packageName + "</td></tr>"
                + "<tr><td style='padding:12px 20px;font-size:13px;color:#64748b;font-weight:600;border-bottom:1px solid #e2e8f0;'>SỐ TIỀN</td>"
                + "<td style='padding:12px 20px;font-size:14px;color:#0b6cb3;font-weight:700;border-bottom:1px solid #e2e8f0;text-align:right;'>"
                + amountStr + "</td></tr>"
                + "<tr style='background:#f8fafc;'><td style='padding:12px 20px;font-size:13px;color:#64748b;font-weight:600;border-bottom:1px solid #e2e8f0;'>MÃ GIAO DỊCH</td>"
                + "<td style='padding:12px 20px;font-size:13px;color:#374151;font-family:monospace;border-bottom:1px solid #e2e8f0;text-align:right;'>"
                + ref + "</td></tr>"
                + "<tr><td style='padding:12px 20px;font-size:13px;color:#64748b;font-weight:600;'>HẠN SỬ DỤNG</td>"
                + "<td style='padding:12px 20px;font-size:14px;color:#16a34a;font-weight:700;text-align:right;'>"
                + expiry + "</td></tr>"
                + "</table>"
                + "<div style='background:#f0fdf4;border-left:4px solid #16a34a;border-radius:6px;padding:16px 20px;margin-bottom:20px;'>"
                + "<p style='margin:0;color:#15803d;font-size:14px;font-weight:600;'>🚀 Tài khoản của bạn đã được nâng cấp lên Pro!</p>"
                + "<p style='margin:6px 0 0;color:#166534;font-size:13px;'>Bạn có thể sử dụng AI Forecast và AI Chatbot ngay bây giờ.</p></div>"
                + "<p style='color:#6b7280;font-size:13px;line-height:1.6;'>Cảm ơn bạn đã tin tưởng sử dụng dịch vụ của chúng tôi!</p>"
                + "</td></tr>"
                + "<tr><td style='padding:16px 40px 28px;text-align:center;border-top:1px solid #f1f4f8;'>"
                + "<p style='margin:0;color:#94a3b8;font-size:12px;'>© 2026 Rainfall Analytics System · Academic Assignment</p></td></tr>"
                + "</table></td></tr></table></body></html>";
        sendHtml(toEmail, "🎉 Xác nhận thanh toán Pro — Rainfall Analytics", html);
    }
}
