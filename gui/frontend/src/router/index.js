import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    name: 'Dashboard',
    component: () => import('@/views/Dashboard.vue'),
    meta: { title: 'Dashboard' }
  },
  {
    path: '/installer',
    name: 'Installer',
    component: () => import('@/views/Installer.vue'),
    meta: { title: 'Installation Wizard' }
  },
  {
    path: '/tool-sets',
    name: 'ToolSets',
    component: () => import('@/views/ToolSets.vue'),
    meta: { title: 'Tool Sets' }
  },
  {
    path: '/monitoring',
    name: 'Monitoring',
    component: () => import('@/views/Monitoring.vue'),
    meta: { title: 'System Monitoring' }
  },
  {
    path: '/services',
    name: 'Services',
    component: () => import('@/views/Services.vue'),
    meta: { title: 'Service Management' }
  },
  {
    path: '/ports',
    name: 'Ports',
    component: () => import('@/views/Ports.vue'),
    meta: { title: 'Port Monitor' }
  },
  {
    path: '/settings',
    name: 'Settings',
    component: () => import('@/views/Settings.vue'),
    meta: { title: 'Settings' }
  },
  {
    path: '/activity',
    name: 'Activity',
    component: () => import('@/views/Activity.vue'),
    meta: { title: 'Activity Log' }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// Update page title
router.beforeEach((to, from, next) => {
  document.title = `${to.meta.title || 'Kubuntu Setup'} - GUI Installer`
  next()
})

export default router