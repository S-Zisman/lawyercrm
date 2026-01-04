// ==========================================
// LawyerCRM Configuration
// ==========================================

const CONFIG = {
  // API Base URL
  API_BASE_URL: '/lawyercrm/api',

  // App Info
  APP_NAME: '5D CRM адвоката Полины Зисман',
  APP_VERSION: '1.0.0',

  // Default Settings
  DEFAULT_LANGUAGE: 'ru', // ru или he
  DEFAULT_CURRENCY: 'ILS',

  // Currency Rates (будут загружаться из БД)
  CURRENCY_RATES: {
    ILS: 1,
    USD: 3.65,
    EUR: 4.00
  },

  // Tax Settings (עוסק מורשה)
  TAX_TYPE: 'osek_murshe',
  VAT_RATE: 0.17, // 17%
  BITUACH_LEUMI_RATE: 0.17, // ~17%

  // Income Tax Brackets (2026, Israel)
  TAX_BRACKETS: [
    { limit: 83280, rate: 0.10 },
    { limit: 119760, rate: 0.14 },
    { limit: 187440, rate: 0.20 },
    { limit: 269280, rate: 0.31 },
    { limit: 560280, rate: 0.35 },
    { limit: 721560, rate: 0.47 },
    { limit: Infinity, rate: 0.50 }
  ],

  // 5D Dimensions
  DIMENSIONS: {
    '1D': {
      name_ru: 'Защита и безопасность',
      name_he: 'הגנה ובטיחות',
      icon: '🛡️',
      color: '#EF4444'
    },
    '2D': {
      name_ru: 'Семья и дети',
      name_he: 'משפחה וילדים',
      icon: '👨‍👩‍👧‍👦',
      color: '#F59E0B'
    },
    '3D': {
      name_ru: 'Имущество и наследство',
      name_he: 'רכוש וירושה',
      icon: '🏡',
      color: '#10B981'
    },
    '4D': {
      name_ru: 'Работа и бизнес',
      name_he: 'עבודה ועסקים',
      icon: '💼',
      color: '#3B82F6'
    },
    '5D': {
      name_ru: 'Будущее и согласие',
      name_he: 'עתיד והסכמה',
      icon: '🕊️',
      color: '#8B5CF6'
    }
  },

  // Date Formats
  DATE_FORMAT: 'DD.MM.YYYY',
  DATETIME_FORMAT: 'DD.MM.YYYY HH:mm',

  // Pagination
  ITEMS_PER_PAGE: 20,

  // File Upload
  MAX_FILE_SIZE: 10 * 1024 * 1024, // 10MB
  ALLOWED_FILE_TYPES: [
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'image/jpeg',
    'image/png',
    'image/jpg'
  ]
};

// Translations
const TRANSLATIONS = {
  ru: {
    // Navigation
    dashboard: 'Дашборд',
    cases: 'Дела',
    clients: 'Клиентки',
    leads: 'Лиды',
    calendar: 'Календарь',
    finances: 'Финансы',
    tasks: 'Задачи',
    documents: 'Документы',
    settings: 'Настройки',
    volunteer: 'Волонтерство (Эфрат)',

    // Common
    add: 'Добавить',
    edit: 'Редактировать',
    delete: 'Удалить',
    save: 'Сохранить',
    cancel: 'Отмена',
    search: 'Поиск',
    filter: 'Фильтр',
    all: 'Все',
    active: 'Активные',
    archived: 'Архивные',
    completed: 'Завершенные',

    // Dashboard
    total_income: 'Доходы',
    total_clients: 'Клиенток',
    active_cases: 'Активных дел',
    new_leads: 'Новых лидов',
    urgent_deadlines: 'Срочные дедлайны',
    upcoming_events: 'Предстоящие события',

    // Cases
    case_number: 'Номер дела',
    case_title: 'Название дела',
    dimension: 'Измерение',
    subcategory: 'Подкатегория',
    status: 'Статус',
    priority: 'Приоритет',
    client: 'Клиентка',

    // Statuses
    new: 'Новый',
    in_progress: 'В процессе',
    won: 'Выиграно',
    lost: 'Проиграно',
    settled: 'Урегулировано',
    mediation_success: 'Медиация успешна',

    // Priorities
    low: 'Низкий',
    medium: 'Средний',
    high: 'Высокий',
    urgent: 'Срочно',
    critical: 'Критично',

    // Dimensions
    '1d_protection': 'Защита и безопасность',
    '2d_family': 'Семья и дети',
    '3d_property': 'Имущество и наследство',
    '4d_business': 'Работа и бизнес',
    '5d_future': 'Будущее и согласие'
  },

  he: {
    // Navigation
    dashboard: 'לוח בקרה',
    cases: 'תיקים',
    clients: 'לקוחות',
    leads: 'לידים',
    calendar: 'יומן',
    finances: 'כספים',
    tasks: 'משימות',
    documents: 'מסמכים',
    settings: 'הגדרות',
    volunteer: 'התנדבות (אפרת)',

    // Common
    add: 'הוסף',
    edit: 'ערוך',
    delete: 'מחק',
    save: 'שמור',
    cancel: 'ביטול',
    search: 'חיפוש',
    filter: 'סינון',
    all: 'הכל',
    active: 'פעילים',
    archived: 'בארכיון',
    completed: 'הושלמו',

    // Dashboard
    total_income: 'הכנסות',
    total_clients: 'לקוחות',
    active_cases: 'תיקים פעילים',
    new_leads: 'לידים חדשים',
    urgent_deadlines: 'דדליינים דחופים',
    upcoming_events: 'אירועים קרובים',

    // Cases
    case_number: 'מספר תיק',
    case_title: 'שם התיק',
    dimension: 'מימד',
    subcategory: 'קטגוריה משנית',
    status: 'סטטוס',
    priority: 'עדיפות',
    client: 'לקוחה',

    // Statuses
    new: 'חדש',
    in_progress: 'בתהליך',
    won: 'זכייה',
    lost: 'הפסד',
    settled: 'הוסדר',
    mediation_success: 'גישור מוצלח',

    // Priorities
    low: 'נמוך',
    medium: 'בינוני',
    high: 'גבוה',
    urgent: 'דחוף',
    critical: 'קריטי',

    // Dimensions
    '1d_protection': 'הגנה ובטיחות',
    '2d_family': 'משפחה וילדים',
    '3d_property': 'רכוש וירושה',
    '4d_business': 'עבודה ועסקים',
    '5d_future': 'עתיד והסכמה'
  }
};

// Helper Functions
const Utils = {
  // Get translation
  t(key, lang = null) {
    const currentLang = lang || localStorage.getItem('language') || CONFIG.DEFAULT_LANGUAGE;
    return TRANSLATIONS[currentLang][key] || key;
  },

  // Format currency
  formatCurrency(amount, currency = 'ILS') {
    const symbols = {
      ILS: '₪',
      USD: '$',
      EUR: '€'
    };

    return `${symbols[currency]}${parseFloat(amount).toLocaleString('en-US', {
      minimumFractionDigits: 0,
      maximumFractionDigits: 0
    })}`;
  },

  // Convert currency
  convertCurrency(amount, fromCurrency, toCurrency) {
    if (fromCurrency === toCurrency) return amount;

    // Convert to ILS first
    const amountInILS = fromCurrency === 'ILS'
      ? amount
      : amount * CONFIG.CURRENCY_RATES[fromCurrency];

    // Then convert to target currency
    return toCurrency === 'ILS'
      ? amountInILS
      : amountInILS / CONFIG.CURRENCY_RATES[toCurrency];
  },

  // Format date
  formatDate(date, format = CONFIG.DATE_FORMAT) {
    if (!date) return '';

    const d = new Date(date);
    const day = String(d.getDate()).padStart(2, '0');
    const month = String(d.getMonth() + 1).padStart(2, '0');
    const year = d.getFullYear();
    const hours = String(d.getHours()).padStart(2, '0');
    const minutes = String(d.getMinutes()).padStart(2, '0');

    if (format === CONFIG.DATE_FORMAT) {
      return `${day}.${month}.${year}`;
    } else if (format === CONFIG.DATETIME_FORMAT) {
      return `${day}.${month}.${year} ${hours}:${minutes}`;
    }

    return date;
  },

  // Calculate tax (עוסק מורשה)
  calculateIncomeTax(income) {
    let tax = 0;
    let remaining = income;

    for (let i = 0; i < CONFIG.TAX_BRACKETS.length; i++) {
      const bracket = CONFIG.TAX_BRACKETS[i];
      const prevLimit = i > 0 ? CONFIG.TAX_BRACKETS[i - 1].limit : 0;
      const bracketSize = bracket.limit - prevLimit;

      if (remaining <= 0) break;

      const taxableInBracket = Math.min(remaining, bracketSize);
      tax += taxableInBracket * bracket.rate;
      remaining -= taxableInBracket;
    }

    return tax;
  },

  // Calculate VAT
  calculateVAT(amount) {
    return amount * CONFIG.VAT_RATE;
  },

  // Calculate Bituach Leumi
  calculateBituachLeumi(income) {
    return income * CONFIG.BITUACH_LEUMI_RATE;
  },

  // Get dimension info
  getDimensionInfo(dimension) {
    return CONFIG.DIMENSIONS[dimension] || {};
  }
};

// Export for use in modules
if (typeof module !== 'undefined' && module.exports) {
  module.exports = { CONFIG, TRANSLATIONS, Utils };
}
