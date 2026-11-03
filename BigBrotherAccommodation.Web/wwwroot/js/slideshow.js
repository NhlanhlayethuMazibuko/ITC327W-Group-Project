// Fades between the photos in the home hero and the sign-in side panel,
// and adds show/hide buttons to password boxes.
(function () {
    function run(slidesSelector, dotsSelector, delay) {
        var slides = document.querySelectorAll(slidesSelector);
        if (slides.length < 2) return;
        var dots = dotsSelector ? document.querySelectorAll(dotsSelector) : [];
        var i = 0;

        setInterval(function () {
            slides[i].classList.remove('on');
            if (dots[i]) dots[i].classList.remove('on');
            i = (i + 1) % slides.length;
            slides[i].classList.add('on');
            if (dots[i]) dots[i].classList.add('on');
        }, delay);
    }

    // Adds an eye button to each password box so people can check what they typed
    function addPasswordToggles() {
        document.querySelectorAll('.auth-input input[type="password"]').forEach(function (input) {
            var button = document.createElement('button');
            button.type = 'button';
            button.className = 'pw-toggle';
            button.setAttribute('aria-label', 'Show password');
            button.innerHTML = '<i class="bi bi-eye"></i>';
            button.addEventListener('click', function () {
                var show = input.type === 'password';
                input.type = show ? 'text' : 'password';
                button.setAttribute('aria-label', show ? 'Hide password' : 'Show password');
                button.innerHTML = show ? '<i class="bi bi-eye-slash"></i>' : '<i class="bi bi-eye"></i>';
            });
            input.classList.add('has-toggle');
            input.parentNode.appendChild(button);
        });
    }

    function start() {
        run('.hero .hero-slide', '.hero .hero-dots span', 6000);
        run('.auth-side .auth-slide', null, 4500);
        addPasswordToggles();
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', start);
    } else {
        start();
    }
})();
