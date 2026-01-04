// ==========================================
// Dashboard Logic
// ==========================================

document.addEventListener('DOMContentLoaded', async () => {
  // Check authentication
  const user = JSON.parse(localStorage.getItem('user'));
  if (!user) {
    window.location.href = 'auth.html';
    return;
  }

  // Display user name
  document.getElementById('userName').textContent = user.name;
  document.getElementById('userNameTitle').textContent = user.name.split(' ')[0];

  // Load dashboard data
  await loadDashboardData(user.id);
});

// Load all dashboard data
async function loadDashboardData(userId) {
  try {
    // Load stats in parallel
    await Promise.all([
      loadGeneralStats(userId),
      loadDimensionStats(userId),
      loadRecentActivity(userId),
      loadUpcomingDeadlines(userId)
    ]);
  } catch (error) {
    console.error('Error loading dashboard data:', error);
  }
}

// Load general statistics
async function loadGeneralStats(userId) {
  try {
    const response = await fetch(`${CONFIG.API_BASE_URL}/dashboard/stats.php?user_id=${userId}`);
    const data = await response.json();

    if (data.success) {
      const stats = data.stats;
      document.getElementById('totalClients').textContent = stats.total_clients || 0;
      document.getElementById('activeCases').textContent = stats.active_cases || 0;
      document.getElementById('monthlyRevenue').textContent = formatCurrency(stats.monthly_revenue || 0);
      document.getElementById('upcomingEvents').textContent = stats.upcoming_events || 0;
    }
  } catch (error) {
    console.error('Error loading general stats:', error);
  }
}

// Load stats by dimension
async function loadDimensionStats(userId) {
  try {
    const response = await fetch(`${CONFIG.API_BASE_URL}/dashboard/dimensions.php?user_id=${userId}`);
    const data = await response.json();

    if (data.success) {
      const dimensions = data.dimensions;

      // Update dimension cards
      Object.keys(dimensions).forEach(dim => {
        const element = document.getElementById(`cases${dim}`);
        if (element) {
          element.textContent = dimensions[dim].cases_count || 0;
        }
      });

      // Update special stats
      if (data.protection_orders !== undefined) {
        const ordersEl = document.getElementById('orders1D');
        if (ordersEl) ordersEl.textContent = data.protection_orders;
      }

      if (data.mediation_sessions !== undefined) {
        const sessionsEl = document.getElementById('sessions5D');
        if (sessionsEl) sessionsEl.textContent = data.mediation_sessions;
      }
    }
  } catch (error) {
    console.error('Error loading dimension stats:', error);
  }
}

// Load recent activity
async function loadRecentActivity(userId) {
  try {
    const response = await fetch(`${CONFIG.API_BASE_URL}/dashboard/activity.php?user_id=${userId}&limit=5`);
    const data = await response.json();

    const container = document.getElementById('recentActivity');

    if (data.success && data.activities && data.activities.length > 0) {
      container.innerHTML = data.activities.map(activity => `
        <div class="activity-item">
          <div class="activity-icon">${getActivityIcon(activity.type)}</div>
          <div class="activity-content">
            <div class="activity-title">${activity.title}</div>
            <div class="activity-time">${formatDate(activity.created_at)}</div>
          </div>
        </div>
      `).join('');
    } else {
      container.innerHTML = '<div class="empty-state"><p>Пока нет активности</p></div>';
    }
  } catch (error) {
    console.error('Error loading recent activity:', error);
  }
}

// Load upcoming deadlines
async function loadUpcomingDeadlines(userId) {
  try {
    const response = await fetch(`${CONFIG.API_BASE_URL}/dashboard/deadlines.php?user_id=${userId}&limit=5`);
    const data = await response.json();

    const container = document.getElementById('upcomingDeadlines');

    if (data.success && data.deadlines && data.deadlines.length > 0) {
      container.innerHTML = data.deadlines.map(deadline => `
        <div class="deadline-item ${isUrgent(deadline.deadline_date) ? 'urgent' : ''}">
          <div class="deadline-icon">${getDimensionIcon(deadline.dimension)}</div>
          <div class="deadline-content">
            <div class="deadline-title">${deadline.title}</div>
            <div class="deadline-date">${formatDate(deadline.deadline_date)}</div>
          </div>
          <div class="deadline-badge ${getPriorityClass(deadline.priority)}">
            ${deadline.priority || 'normal'}
          </div>
        </div>
      `).join('');
    } else {
      container.innerHTML = '<div class="empty-state"><p>Нет дедлайнов</p></div>';
    }
  } catch (error) {
    console.error('Error loading deadlines:', error);
  }
}

// Helper functions
function formatCurrency(amount) {
  return new Intl.NumberFormat('he-IL', {
    style: 'currency',
    currency: 'ILS',
    minimumFractionDigits: 0
  }).format(amount);
}

function formatDate(dateString) {
  if (!dateString) return '';
  const date = new Date(dateString);
  const now = new Date();
  const diffMs = date - now;
  const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));

  if (diffDays === 0) return 'Сегодня';
  if (diffDays === 1) return 'Завтра';
  if (diffDays === -1) return 'Вчера';
  if (diffDays > 0 && diffDays <= 7) return `Через ${diffDays} дн.`;
  if (diffDays < 0 && diffDays >= -7) return `${Math.abs(diffDays)} дн. назад`;

  return date.toLocaleDateString('ru-RU', { day: 'numeric', month: 'short' });
}

function getActivityIcon(type) {
  const icons = {
    'case_created': '📁',
    'client_added': '👤',
    'payment_received': '💰',
    'event_scheduled': '📅',
    'document_uploaded': '📄',
    'default': '•'
  };
  return icons[type] || icons.default;
}

function getDimensionIcon(dimension) {
  const icons = {
    '1D': '🛡️',
    '2D': '👨‍👩‍👧‍👦',
    '3D': '🏡',
    '4D': '💼',
    '5D': '🕊️',
    'OTHER': '📂'
  };
  return icons[dimension] || '📋';
}

function isUrgent(dateString) {
  const date = new Date(dateString);
  const now = new Date();
  const diffDays = Math.floor((date - now) / (1000 * 60 * 60 * 24));
  return diffDays <= 3;
}

function getPriorityClass(priority) {
  const classes = {
    'high': 'badge-danger',
    'medium': 'badge-warning',
    'low': 'badge-info',
    'normal': 'badge-secondary'
  };
  return classes[priority] || classes.normal;
}

function logout() {
  localStorage.removeItem('user');
  localStorage.removeItem('userId');
  window.location.href = 'auth.html';
}
