-- ==========================================
-- 5D CRM для адвоката Полины Зисман
-- SQL Schema for PostgreSQL 14+
-- ==========================================

-- Включаем расширение для UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==========================================
-- 1. ТАБЛИЦА ПОЛЬЗОВАТЕЛЕЙ (users)
-- ==========================================
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  name TEXT NOT NULL,
  role TEXT DEFAULT 'lawyer', -- lawyer, admin
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Создаем индекс для email
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- ==========================================
-- 2. ТАБЛИЦА СПРАВОЧНИК КАТЕГОРИЙ ДЕЛ
-- ==========================================
CREATE TABLE IF NOT EXISTS case_subcategories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  dimension TEXT NOT NULL, -- 1D, 2D, 3D, 4D, 5D
  name_ru TEXT NOT NULL,
  name_he TEXT,
  icon TEXT, -- Emoji или имя иконки
  color TEXT, -- HEX цвет
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Индексы
CREATE INDEX IF NOT EXISTS idx_subcategories_user ON case_subcategories(user_id);
CREATE INDEX IF NOT EXISTS idx_subcategories_dimension ON case_subcategories(dimension);

-- ==========================================
-- 3. ТАБЛИЦА КЛИЕНТОК (clients)
-- ==========================================
CREATE TABLE IF NOT EXISTS clients (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,

  -- Основная информация
  name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  id_number TEXT, -- תעודת זהות

  -- Демография
  age INTEGER,
  marital_status TEXT, -- single, married, divorced, widowed
  children_count INTEGER DEFAULT 0,

  -- Адрес
  address TEXT,
  city TEXT,

  -- Безопасность
  safety_level TEXT DEFAULT 'normal', -- safe, at_risk, critical
  has_protection_order BOOLEAN DEFAULT FALSE,

  -- Источник обращения
  referral_source TEXT, -- website, social, efrat, friend, lawyer, other
  referral_details TEXT,

  -- Волонтерство
  is_volunteer_client BOOLEAN DEFAULT FALSE,
  volunteer_program TEXT, -- efrat, other

  -- Финансы
  total_amount DECIMAL(10,2) DEFAULT 0,
  paid_amount DECIMAL(10,2) DEFAULT 0,
  remaining_amount DECIMAL(10,2) DEFAULT 0,

  -- Pro bono
  is_pro_bono BOOLEAN DEFAULT FALSE,

  -- Метаданные
  status TEXT DEFAULT 'active', -- active, archived
  notes TEXT,
  sensitive_notes TEXT, -- Конфиденциальные заметки

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Индексы
CREATE INDEX IF NOT EXISTS idx_clients_user ON clients(user_id);
CREATE INDEX IF NOT EXISTS idx_clients_status ON clients(status);
CREATE INDEX IF NOT EXISTS idx_clients_volunteer ON clients(is_volunteer_client);

-- ==========================================
-- 4. ТАБЛИЦА ДЕЛ (cases)
-- ==========================================
CREATE TABLE IF NOT EXISTS cases (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  client_id UUID REFERENCES clients(id) ON DELETE CASCADE,

  -- Основная информация
  case_number TEXT,
  title TEXT NOT NULL,
  description TEXT,

  -- 5D-категоризация
  dimension TEXT NOT NULL, -- 1D, 2D, 3D, 4D, 5D
  subcategory_id UUID REFERENCES case_subcategories(id) ON DELETE SET NULL,

  -- Категория (для совместимости)
  category TEXT, -- protection, family, property, business, mediation
  case_type TEXT,

  -- Суд (может быть NULL для медиации)
  court_name TEXT,
  court_city TEXT,
  judge_name TEXT,

  -- Противная сторона
  opposing_party_name TEXT,
  opposing_party_type TEXT, -- person, company, institution
  opposing_lawyer_name TEXT,
  opposing_lawyer_phone TEXT,

  -- Медиация (для 5D)
  is_mediation BOOLEAN DEFAULT FALSE,
  mediation_stage TEXT, -- initial, negotiation, agreement, failed
  agreement_reached BOOLEAN DEFAULT FALSE,

  -- Уровень срочности (для 1D)
  urgency_level TEXT DEFAULT 'normal', -- low, normal, high, critical
  protection_order_active BOOLEAN DEFAULT FALSE,

  -- Финансы
  total_fee DECIMAL(10,2),
  fee_type TEXT, -- fixed, percentage, hourly, pro_bono
  fee_percentage DECIMAL(5,2),
  hourly_rate DECIMAL(10,2),
  claim_amount DECIMAL(10,2),

  paid_amount DECIMAL(10,2) DEFAULT 0,
  advance_paid DECIMAL(10,2) DEFAULT 0,

  -- Статусы
  status TEXT DEFAULT 'active', -- active, won, lost, settled, appeal, closed, mediation_success
  priority TEXT DEFAULT 'medium', -- low, medium, high, urgent

  -- Даты
  opened_at DATE DEFAULT CURRENT_DATE,
  closed_at DATE,
  next_hearing_date TIMESTAMPTZ,

  -- Метаданные
  notes TEXT,
  sensitive_info TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Индексы
CREATE INDEX IF NOT EXISTS idx_cases_user ON cases(user_id);
CREATE INDEX IF NOT EXISTS idx_cases_client ON cases(client_id);
CREATE INDEX IF NOT EXISTS idx_cases_dimension ON cases(dimension);
CREATE INDEX IF NOT EXISTS idx_cases_status ON cases(status);
CREATE INDEX IF NOT EXISTS idx_cases_next_hearing ON cases(next_hearing_date);

-- ==========================================
-- 5. ТАБЛИЦА СУДЕБНЫХ ЗАСЕДАНИЙ (case_hearings)
-- ==========================================
CREATE TABLE IF NOT EXISTS case_hearings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  case_id UUID REFERENCES cases(id) ON DELETE CASCADE,

  -- Информация о заседании
  hearing_date TIMESTAMPTZ NOT NULL,
  hearing_type TEXT, -- דיון, הוכחות, גמר דין
  location TEXT,

  -- Результат
  outcome TEXT,
  notes TEXT,
  next_hearing_date TIMESTAMPTZ,

  -- Напоминания
  reminder_sent BOOLEAN DEFAULT FALSE,

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Индексы
CREATE INDEX IF NOT EXISTS idx_hearings_case ON case_hearings(case_id);
CREATE INDEX IF NOT EXISTS idx_hearings_date ON case_hearings(hearing_date);

-- ==========================================
-- 6. ТАБЛИЦА ДОКУМЕНТОВ ПО ДЕЛАМ (case_documents)
-- ==========================================
CREATE TABLE IF NOT EXISTS case_documents (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  case_id UUID REFERENCES cases(id) ON DELETE CASCADE,

  -- Информация о документе
  title TEXT NOT NULL,
  document_type TEXT, -- כתב תביעה, כתב הגנה, ראיות, פסק דין
  file_url TEXT,
  file_name TEXT,
  file_size INTEGER,

  -- Дедлайн
  deadline DATE,
  submitted BOOLEAN DEFAULT FALSE,
  submitted_at TIMESTAMPTZ,

  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Индексы
CREATE INDEX IF NOT EXISTS idx_documents_case ON case_documents(case_id);
CREATE INDEX IF NOT EXISTS idx_documents_deadline ON case_documents(deadline);

-- ==========================================
-- 7. ТАБЛИЦА ДЕДЛАЙНОВ (deadlines)
-- ==========================================
CREATE TABLE IF NOT EXISTS deadlines (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  case_id UUID REFERENCES cases(id) ON DELETE CASCADE,

  -- Информация о дедлайне
  title TEXT NOT NULL,
  description TEXT,
  deadline_date TIMESTAMPTZ NOT NULL,

  -- Тип
  deadline_type TEXT, -- court_hearing, document_submission, payment, other

  -- Статус
  status TEXT DEFAULT 'pending', -- pending, completed, missed
  completed_at TIMESTAMPTZ,

  -- Напоминания
  reminder_days_before INTEGER DEFAULT 3,
  reminder_sent BOOLEAN DEFAULT FALSE,

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Индексы
CREATE INDEX IF NOT EXISTS idx_deadlines_case ON deadlines(case_id);
CREATE INDEX IF NOT EXISTS idx_deadlines_date ON deadlines(deadline_date);
CREATE INDEX IF NOT EXISTS idx_deadlines_status ON deadlines(status);

-- ==========================================
-- 8. ТАБЛИЦА ОХРАННЫХ ОРДЕРОВ (protection_orders)
-- ==========================================
CREATE TABLE IF NOT EXISTS protection_orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  case_id UUID REFERENCES cases(id) ON DELETE CASCADE,
  client_id UUID REFERENCES clients(id) ON DELETE CASCADE,

  -- Информация об ордере
  order_number TEXT,
  order_type TEXT, -- temporary, permanent, restraining

  -- Против кого
  against_person_name TEXT,
  relationship TEXT, -- spouse, ex_spouse, partner, family_member, other

  -- Даты
  issued_date DATE,
  expiry_date DATE,

  -- Условия
  conditions TEXT,
  distance_meters INTEGER,

  -- Статус
  status TEXT DEFAULT 'active', -- active, expired, violated, cancelled

  -- Нарушения
  violations_count INTEGER DEFAULT 0,
  last_violation_date DATE,

  -- Метаданные
  notes TEXT,
  document_url TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Индексы
CREATE INDEX IF NOT EXISTS idx_protection_orders_case ON protection_orders(case_id);
CREATE INDEX IF NOT EXISTS idx_protection_orders_client ON protection_orders(client_id);
CREATE INDEX IF NOT EXISTS idx_protection_orders_expiry ON protection_orders(expiry_date);
CREATE INDEX IF NOT EXISTS idx_protection_orders_status ON protection_orders(status);

-- ==========================================
-- 9. ТАБЛИЦА СЕССИЙ МЕДИАЦИИ (mediation_sessions)
-- ==========================================
CREATE TABLE IF NOT EXISTS mediation_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  case_id UUID REFERENCES cases(id) ON DELETE CASCADE,

  -- Информация о сессии
  session_number INTEGER,
  session_date TIMESTAMPTZ NOT NULL,
  duration_minutes INTEGER DEFAULT 90,

  -- Участники
  participants TEXT[],

  -- Результаты
  progress_level TEXT, -- low, medium, high
  agreements_reached TEXT[],
  next_steps TEXT,

  -- Статус
  outcome TEXT, -- productive, neutral, difficult, breakthrough

  -- Метаданные
  notes TEXT,
  next_session_date TIMESTAMPTZ,

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Индексы
CREATE INDEX IF NOT EXISTS idx_mediation_sessions_case ON mediation_sessions(case_id);
CREATE INDEX IF NOT EXISTS idx_mediation_sessions_date ON mediation_sessions(session_date);

-- ==========================================
-- 10. ТАБЛИЦА ПЛАТЕЖЕЙ (payments)
-- ==========================================
CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
  case_id UUID REFERENCES cases(id) ON DELETE SET NULL,

  -- Информация о платеже
  amount DECIMAL(10,2) NOT NULL,
  currency TEXT DEFAULT 'ILS', -- ILS, USD, EUR

  -- Тип платежа
  payment_type TEXT, -- advance, partial, full, court_fee
  payment_method TEXT, -- cash, bank_transfer, card, check

  -- Даты
  payment_date DATE DEFAULT CURRENT_DATE,

  -- Метаданные
  notes TEXT,
  receipt_url TEXT,
  invoice_id TEXT, -- ID счета из Green Invoice

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Индексы
CREATE INDEX IF NOT EXISTS idx_payments_user ON payments(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_client ON payments(client_id);
CREATE INDEX IF NOT EXISTS idx_payments_case ON payments(case_id);
CREATE INDEX IF NOT EXISTS idx_payments_date ON payments(payment_date);

-- ==========================================
-- 11. ТАБЛИЦА РАСХОДОВ (expenses)
-- ==========================================
CREATE TABLE IF NOT EXISTS expenses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  case_id UUID REFERENCES cases(id) ON DELETE SET NULL,

  -- Информация о расходе
  amount DECIMAL(10,2) NOT NULL,
  currency TEXT DEFAULT 'ILS',

  -- Категория
  category TEXT, -- court_fees, expert_witness, travel, office, marketing, other

  -- Описание
  description TEXT,

  -- Дата
  expense_date DATE DEFAULT CURRENT_DATE,

  -- Метаданные
  receipt_url TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Индексы
CREATE INDEX IF NOT EXISTS idx_expenses_user ON expenses(user_id);
CREATE INDEX IF NOT EXISTS idx_expenses_case ON expenses(case_id);
CREATE INDEX IF NOT EXISTS idx_expenses_date ON expenses(expense_date);
CREATE INDEX IF NOT EXISTS idx_expenses_category ON expenses(category);

-- ==========================================
-- 12. ТАБЛИЦА ЛИДОВ (leads)
-- ==========================================
CREATE TABLE IF NOT EXISTS leads (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,

  -- Основная информация
  name TEXT NOT NULL,
  email TEXT,
  phone TEXT,

  -- Информация о деле
  case_description TEXT,
  case_category TEXT, -- 1D, 2D, 3D, 4D, 5D

  -- Воронка
  stage TEXT DEFAULT 'new', -- new, contacted, consultation, proposal, won, lost

  -- Финансы
  expected_fee DECIMAL(10,2),
  probability INTEGER DEFAULT 50, -- 0-100%

  -- Источник
  source TEXT, -- website, referral, ads, social, walk_in

  -- Статус
  status TEXT DEFAULT 'active', -- active, converted, lost
  converted_to_client_id UUID REFERENCES clients(id),
  lost_reason TEXT,

  -- Даты
  consultation_date TIMESTAMPTZ,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Индексы
CREATE INDEX IF NOT EXISTS idx_leads_user ON leads(user_id);
CREATE INDEX IF NOT EXISTS idx_leads_stage ON leads(stage);
CREATE INDEX IF NOT EXISTS idx_leads_status ON leads(status);

-- ==========================================
-- 13. ТАБЛИЦА ЗАДАЧ (tasks)
-- ==========================================
CREATE TABLE IF NOT EXISTS tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  case_id UUID REFERENCES cases(id) ON DELETE CASCADE,
  client_id UUID REFERENCES clients(id) ON DELETE CASCADE,

  -- Информация о задаче
  title TEXT NOT NULL,
  description TEXT,

  -- Статус
  status TEXT DEFAULT 'todo', -- todo, in_progress, done
  priority TEXT DEFAULT 'medium', -- low, medium, high, urgent

  -- Дедлайн
  due_date DATE,

  -- Метаданные
  position INTEGER DEFAULT 0,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Индексы
CREATE INDEX IF NOT EXISTS idx_tasks_user ON tasks(user_id);
CREATE INDEX IF NOT EXISTS idx_tasks_case ON tasks(case_id);
CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status);
CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON tasks(due_date);

-- ==========================================
-- 14. ТАБЛИЦА СОБЫТИЙ (events)
-- ==========================================
CREATE TABLE IF NOT EXISTS events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  case_id UUID REFERENCES cases(id) ON DELETE SET NULL,
  client_id UUID REFERENCES clients(id) ON DELETE SET NULL,

  -- Информация о событии
  title TEXT NOT NULL,
  description TEXT,

  -- Тип
  event_type TEXT, -- meeting, call, consultation, other

  -- Дата и время
  event_date TIMESTAMPTZ NOT NULL,
  duration_minutes INTEGER DEFAULT 60,

  -- Место
  location TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Индексы
CREATE INDEX IF NOT EXISTS idx_events_user ON events(user_id);
CREATE INDEX IF NOT EXISTS idx_events_case ON events(case_id);
CREATE INDEX IF NOT EXISTS idx_events_client ON events(client_id);
CREATE INDEX IF NOT EXISTS idx_events_date ON events(event_date);

-- ==========================================
-- 15. ТАБЛИЦА НАСТРОЕК (settings)
-- ==========================================
CREATE TABLE IF NOT EXISTS settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,

  -- Настройки языка
  language TEXT DEFAULT 'ru', -- ru, he

  -- Настройки валюты
  default_currency TEXT DEFAULT 'ILS',

  -- Настройки налогов
  tax_type TEXT DEFAULT 'osek_murshe', -- osek_murshe, osek_patur
  vat_registered BOOLEAN DEFAULT TRUE,

  -- Настройки уведомлений
  notification_email BOOLEAN DEFAULT TRUE,
  notification_push BOOLEAN DEFAULT TRUE,
  notification_sms BOOLEAN DEFAULT FALSE,

  -- Прочее
  logo_url TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Индексы
CREATE INDEX IF NOT EXISTS idx_settings_user ON settings(user_id);

-- ==========================================
-- 16. ТАБЛИЦА КУРСОВ ВАЛЮТ (currency_rates)
-- ==========================================
CREATE TABLE IF NOT EXISTS currency_rates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Курсы
  usd_to_ils DECIMAL(10,4) DEFAULT 3.65,
  eur_to_ils DECIMAL(10,4) DEFAULT 4.00,

  -- Дата обновления
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Вставляем начальные курсы
INSERT INTO currency_rates (usd_to_ils, eur_to_ils, updated_at)
VALUES (3.65, 4.00, NOW())
ON CONFLICT DO NOTHING;

-- ==========================================
-- ТРИГГЕРЫ ДЛЯ АВТООБНОВЛЕНИЯ updated_at
-- ==========================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Применяем триггер к нужным таблицам
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_clients_updated_at BEFORE UPDATE ON clients
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cases_updated_at BEFORE UPDATE ON cases
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_leads_updated_at BEFORE UPDATE ON leads
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON tasks
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_settings_updated_at BEFORE UPDATE ON settings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subcategories_updated_at BEFORE UPDATE ON case_subcategories
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_protection_orders_updated_at BEFORE UPDATE ON protection_orders
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ==========================================
-- ТРИГГЕР ДЛЯ АВТОМАТИЧЕСКОГО ПЕРЕСЧЕТА remaining_amount У КЛИЕНТОВ
-- ==========================================

CREATE OR REPLACE FUNCTION update_client_remaining_amount()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE clients
  SET remaining_amount = total_amount - paid_amount
  WHERE id = NEW.client_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_client_remaining_on_payment AFTER INSERT OR UPDATE ON payments
  FOR EACH ROW EXECUTE FUNCTION update_client_remaining_amount();

-- ==========================================
-- ГОТОВО!
-- ==========================================
