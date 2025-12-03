import { createRouter, createWebHistory } from 'vue-router'

// Admin pages
import BookManagement from '../components/admin/BookManagement.vue'
import LabelManagement from '../components/admin/LabelManagement.vue'
import Reservation from '../components/admin/Reservation.vue'
import Comments from '../components/admin/Comments.vue'
import Users from '../components/admin/Users.vue'

const routes = [
  // ===== User side =====
  { path: '/', redirect: '/login' },
  { path: '/login', name: 'login', meta: { layout: 'auth', public: true } },
  { path: '/register', name: 'register', meta: { layout: 'auth', public: true } },
  { path: '/user', name: 'user', meta: { layout: 'auth' } },

  // ===== Admin side =====
  {
    path: '/admin',
    meta: { layout: 'admin',requiresAdmin: true},
    children: [
      { path: 'books',        name: 'admin-books',        component: BookManagement },
      { path: 'labels',       name: 'admin-labels',       component: LabelManagement },
      { path: 'reservations', name: 'admin-reservations', component: Reservation },
      { path: 'comments',     name: 'admin-comments',     component: Comments },
      { path: 'users',        name: 'admin-users',        component: Users },
      // Default to book management (relative redirect is more stable)
      { path: '', redirect: { name: 'admin-books' } }
    ]
  },

  // Fallback
  { path: '/:pathMatch(.*)*', redirect: { name: 'login' } }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router