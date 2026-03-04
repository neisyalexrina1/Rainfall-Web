/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */


document.addEventListener("DOMContentLoaded", function () {
    const passwordInput = document.getElementById("passwordInput");
    const toggle = document.getElementById("togglePassword");

    if (!passwordInput || !toggle) return;

    toggle.addEventListener("click", function () {
        if (passwordInput.type === "password") {
            passwordInput.type = "text";
            toggle.textContent = "✖";
        } else {
            passwordInput.type = "password";
            toggle.textContent = "👁";
        }
    });
});
