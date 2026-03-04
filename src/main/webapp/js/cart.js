/**
 * cart.js — Interactive enhancements for Cart & Shop pages
 */

document.addEventListener('DOMContentLoaded', function () {

    /* ===== 1. Qty input: submit on Enter ===== */
    document.querySelectorAll('input.qty-input').forEach(function (input) {
        input.addEventListener('keydown', function (e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                var form = input.closest('form');
                if (form) form.submit();
            }
        });
    });

    /* ===== 2. Frontend Validation: Alert user instead of auto-clamping ===== */
    document.querySelectorAll('form').forEach(function (form) {
        form.addEventListener('submit', function (e) {
            var input = form.querySelector('input[type="number"]');
            if (!input) return;

            var val = parseInt(input.value);
            var max = parseInt(input.getAttribute('max'));

            // Validate minimum
            if (isNaN(val) || val < 1) {
                e.preventDefault();
                alert("Please enter a valid quantity (1 or more).");
                return;
            }

            // Validate maximum (stock)
            if (!isNaN(max) && val > max) {
                e.preventDefault();
                alert("You can only order up to " + max + " items. Please enter " + max + " or less.");
                return;
            }

            // If valid and it's an add-to-cart form, show visual feedback
            if (form.classList.contains('add-form')) {
                var btn = form.querySelector('.btn-add');
                if (btn) {
                    btn.textContent = '✓ Added!';
                    btn.style.background = 'linear-gradient(135deg, #155724, #0f4218)';
                    // We don't disable the button here because form needs to submit,
                    // but we can prevent double clicking:
                    setTimeout(function () { btn.disabled = true; }, 50);
                }
            }
        });
    });

    /* ===== 3. Highlight row on hover in cart table ===== */
    document.querySelectorAll('.cart-table tbody tr').forEach(function (row) {
        row.addEventListener('mouseenter', function () {
            this.style.backgroundColor = '#f0f7ff';
        });
        row.addEventListener('mouseleave', function () {
            this.style.backgroundColor = '';
        });
    });

    /* ===== 4. Auto-dismiss error alert after 6 seconds ===== */
    var alertEl = document.querySelector('.alert-error');
    if (alertEl) {
        setTimeout(function () {
            alertEl.style.transition = 'opacity 0.5s ease';
            alertEl.style.opacity = '0';
            setTimeout(function () { alertEl.remove(); }, 500);
        }, 6000);
    }
});
