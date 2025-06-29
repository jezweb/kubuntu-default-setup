<template>
  <v-app>
    <!-- Navigation Drawer -->
    <v-navigation-drawer
      v-model="drawer"
      app
      color="grey-darken-4"
      dark
    >
      <v-list>
        <v-list-item
          prepend-avatar="/kubuntu-logo.png"
          title="Kubuntu Setup"
          subtitle="GUI Installer"
          class="mb-2"
        ></v-list-item>
      </v-list>
      
      <v-divider></v-divider>
      
      <v-list density="compact" nav>
        <v-list-item
          v-for="item in navigationItems"
          :key="item.title"
          :to="item.to"
          :prepend-icon="item.icon"
          :title="item.title"
          color="primary"
        ></v-list-item>
      </v-list>
      
      <template v-slot:append>
        <v-divider></v-divider>
        <v-list-item
          prepend-icon="mdi-cog"
          title="Settings"
          to="/settings"
        ></v-list-item>
      </template>
    </v-navigation-drawer>
    
    <!-- App Bar -->
    <v-app-bar
      app
      color="primary"
      dark
      flat
    >
      <v-app-bar-nav-icon @click="drawer = !drawer"></v-app-bar-nav-icon>
      
      <v-toolbar-title>{{ pageTitle }}</v-toolbar-title>
      
      <v-spacer></v-spacer>
      
      <!-- Connection Status -->
      <v-chip
        :color="connected ? 'success' : 'error'"
        variant="flat"
        size="small"
        class="mr-2"
      >
        <v-icon start size="small">
          {{ connected ? 'mdi-wifi' : 'mdi-wifi-off' }}
        </v-icon>
        {{ connected ? 'Connected' : 'Disconnected' }}
      </v-chip>
      
      <!-- Active Installations Badge -->
      <v-badge
        v-if="activeInstallations > 0"
        :content="activeInstallations"
        color="error"
        inline
      >
        <v-btn icon="mdi-download" variant="text"></v-btn>
      </v-badge>
      
      <!-- Theme Toggle -->
      <v-btn
        icon
        @click="toggleTheme"
      >
        <v-icon>{{ theme.global.current.value.dark ? 'mdi-weather-sunny' : 'mdi-weather-night' }}</v-icon>
      </v-btn>
    </v-app-bar>
    
    <!-- Main Content -->
    <v-main>
      <v-container fluid>
        <!-- Alert for errors -->
        <v-alert
          v-if="globalError"
          type="error"
          closable
          class="mb-4"
          @click:close="globalError = null"
        >
          {{ globalError }}
        </v-alert>
        
        <!-- Router View -->
        <router-view v-slot="{ Component }">
          <transition name="fade" mode="out-in">
            <component :is="Component" />
          </transition>
        </router-view>
      </v-container>
    </v-main>
    
    <!-- Installation Progress Snackbar -->
    <v-snackbar
      v-model="showInstallProgress"
      :timeout="-1"
      location="bottom right"
      width="400"
    >
      <div>
        <div class="text-subtitle-2 mb-1">Installing: {{ currentInstallation?.currentTool }}</div>
        <v-progress-linear
          :model-value="currentInstallation?.progress || 0"
          color="primary"
          height="6"
          striped
        ></v-progress-linear>
      </div>
      <template v-slot:actions>
        <v-btn
          variant="text"
          @click="showInstallProgress = false"
        >
          Hide
        </v-btn>
      </template>
    </v-snackbar>
  </v-app>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import { useTheme } from 'vuetify'
import { useInstallationStore } from '@/stores/installation'
import { useMonitoringStore } from '@/stores/monitoring'

const route = useRoute()
const theme = useTheme()
const installationStore = useInstallationStore()
const monitoringStore = useMonitoringStore()

// State
const drawer = ref(true)
const globalError = ref(null)
const showInstallProgress = ref(false)

// Navigation items
const navigationItems = [
  { title: 'Dashboard', icon: 'mdi-view-dashboard', to: '/' },
  { title: 'Installation Wizard', icon: 'mdi-package-variant', to: '/installer' },
  { title: 'Tool Sets', icon: 'mdi-folder-multiple', to: '/tool-sets' },
  { title: 'System Monitoring', icon: 'mdi-monitor', to: '/monitoring' },
  { title: 'Services', icon: 'mdi-server', to: '/services' },
  { title: 'Port Monitor', icon: 'mdi-ethernet-cable', to: '/ports' },
  { title: 'Activity Log', icon: 'mdi-history', to: '/activity' }
]

// Computed
const pageTitle = computed(() => route.meta.title || 'Kubuntu Setup')
const connected = computed(() => installationStore.connected)
const activeInstallations = computed(() => installationStore.activeInstallations.length)
const currentInstallation = computed(() => installationStore.currentInstallation)

// Watch for active installations
watch(activeInstallations, (newVal) => {
  showInstallProgress.value = newVal > 0
})

// Methods
const toggleTheme = () => {
  theme.global.name.value = theme.global.current.value.dark ? 'light' : 'dark'
}

// Lifecycle
onMounted(() => {
  // Initialize WebSocket connection
  installationStore.initSocket()
  
  // Start monitoring
  monitoringStore.startMonitoring()
  
  // Handle global errors
  window.addEventListener('unhandledrejection', (event) => {
    globalError.value = event.reason?.message || 'An unexpected error occurred'
  })
})

onUnmounted(() => {
  // Cleanup
  installationStore.disconnectSocket()
  monitoringStore.stopMonitoring()
})
</script>

<style>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>