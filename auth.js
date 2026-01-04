// ==========================================
// Authentication Logic
// ==========================================

document.addEventListener('DOMContentLoaded', () => {
  // Check if already logged in
  const user = localStorage.getItem('user');
  if (user) {
    window.location.href = 'index.html';
    return;
  }

  // Handle login form submission
  const loginForm = document.getElementById('loginForm');
  loginForm.addEventListener('submit', handleLogin);

  // Handle language switcher
  const langButtons = document.querySelectorAll('.lang-btn');
  langButtons.forEach(btn => {
    btn.addEventListener('click', () => switchLanguage(btn.dataset.lang));
  });

  // Load saved language
  const savedLang = localStorage.getItem('language') || 'ru';
  switchLanguage(savedLang, false);
});

// Handle Login
async function handleLogin(e) {
  e.preventDefault();

  const email = document.getElementById('email').value;
  const password = document.getElementById('password').value;
  const errorMessage = document.getElementById('errorMessage');
  const loginButton = document.getElementById('loginButton');
  const loginButtonText = document.getElementById('loginButtonText');
  const loginButtonSpinner = document.getElementById('loginButtonSpinner');

  // Show loading state
  loginButton.disabled = true;
  loginButtonText.style.display = 'none';
  loginButtonSpinner.style.display = 'inline-block';
  errorMessage.style.display = 'none';

  try {
    // Call login API
    const response = await fetch(`${CONFIG.API_BASE_URL}/auth/login.php`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ email, password })
    });

    const data = await response.json();

    if (data.success) {
      // Save user data
      localStorage.setItem('user', JSON.stringify(data.user));
      localStorage.setItem('userId', data.user.id);

      // Redirect to dashboard
      window.location.href = 'dashboard.html';
    } else {
      // Show error
      errorMessage.textContent = data.error || 'Неверный email или пароль';
      errorMessage.style.display = 'block';
    }
  } catch (error) {
    console.error('Login error:', error);
    errorMessage.textContent = 'Ошибка соединения с сервером';
    errorMessage.style.display = 'block';
  } finally {
    // Reset button state
    loginButton.disabled = false;
    loginButtonText.style.display = 'inline';
    loginButtonSpinner.style.display = 'none';
  }
}

// Language Switcher
function switchLanguage(lang, save = true) {
  const currentLang = lang;

  // Update active button
  document.querySelectorAll('.lang-btn').forEach(btn => {
    btn.classList.toggle('active', btn.dataset.lang === currentLang);
  });

  // Update HTML lang and dir
  document.documentElement.lang = currentLang;
  document.documentElement.dir = currentLang === 'he' ? 'rtl' : 'ltr';

  // Update text content
  if (currentLang === 'he') {
    document.querySelector('.auth-title').textContent = '5D CRM של עו"ד פולינה זיסמן';
    document.querySelector('.auth-subtitle').textContent = 'משפט 5D לנשים';
    document.querySelector('.auth-card-title').textContent = 'כניסה למערכת';
    document.querySelector('label[for="email"]').textContent = 'אימייל';
    document.querySelector('label[for="password"]').textContent = 'סיסמה';
    document.getElementById('loginButtonText').textContent = 'כניסה';
    document.querySelector('.auth-footer p').textContent = '© 2026 פולינה זיסמן. כל הזכויות שמורות.';
  } else {
    document.querySelector('.auth-title').textContent = '5D CRM адвоката Полины Зисман';
    document.querySelector('.auth-subtitle').textContent = '5D-юриспруденция для женщин';
    document.querySelector('.auth-card-title').textContent = 'Вход в систему';
    document.querySelector('label[for="email"]').textContent = 'Email';
    document.querySelector('label[for="password"]').textContent = 'Пароль';
    document.getElementById('loginButtonText').textContent = 'Войти';
    document.querySelector('.auth-footer p').textContent = '© 2026 Полина Зисман. Все права защищены.';
  }

  // Save language preference
  if (save) {
    localStorage.setItem('language', currentLang);
  }
}
