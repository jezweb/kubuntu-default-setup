<template>
  <div>
    <v-row>
      <!-- Welcome Card -->
      <v-col cols="12">
        <v-card>
          <v-card-title class="text-h4">
            Welcome to Kubuntu Setup GUI
          </v-card-title>
          <v-card-text>
            <p class="text-body-1">
              Manage your development environment with ease. Install tools, monitor services, and track system resources all in one place.
            </p>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
    
    <!-- Stats Cards -->
    <v-row class="mt-4">
      <v-col cols="12" sm="6" md="3">
        <v-card color="primary" dark>
          <v-card-text>
            <div class="d-flex align-center justify-space-between">
              <div>
                <p class="text-caption mb-0">Installed Tools</p>
                <p class="text-h4 font-weight-bold">{{ installedCount }}</p>
              </div>
              <v-icon size="48">mdi-package-variant-closed</v-icon>
            </div>
          </v-card-text>
          <v-card-actions>
            <v-btn variant="text" to="/installer">Install More</v-btn>
          </v-card-actions>
        </v-card>
      </v-col>
      
      <v-col cols="12" sm="6" md="3">
        <v-card color="success" dark>
          <v-card-text>
            <div class="d-flex align-center justify-space-between">
              <div>
                <p class="text-caption mb-0">Running Services</p>
                <p class="text-h4 font-weight-bold">{{ runningServices }}</p>
              </div>
              <v-icon size="48">mdi-server</v-icon>
            </div>
          </v-card-text>
          <v-card-actions>
            <v-btn variant="text" to="/services">Manage</v-btn>
          </v-card-actions>
        </v-card>
      </v-col>
      
      <v-col cols="12" sm="6" md="3">
        <v-card color="warning" dark>
          <v-card-text>
            <div class="d-flex align-center justify-space-between">
              <div>
                <p class="text-caption mb-0">Active Ports</p>
                <p class="text-h4 font-weight-bold">{{ activePorts }}</p>
              </div>
              <v-icon size="48">mdi-ethernet-cable</v-icon>
            </div>
          </v-card-text>
          <v-card-actions>
            <v-btn variant="text" to="/ports">View All</v-btn>
          </v-card-actions>
        </v-card>
      </v-col>
      
      <v-col cols="12" sm="6" md="3">
        <v-card :color="systemHealthy ? 'info' : 'error'" dark>
          <v-card-text>
            <div class="d-flex align-center justify-space-between">
              <div>
                <p class="text-caption mb-0">System Health</p>
                <p class="text-h4 font-weight-bold">{{ systemHealthy ? 'Good' : 'Issues' }}</p>
              </div>
              <v-icon size="48">{{ systemHealthy ? 'mdi-check-circle' : 'mdi-alert-circle' }}</v-icon>
            </div>
          </v-card-text>
          <v-card-actions>
            <v-btn variant="text" to="/monitoring">Details</v-btn>
          </v-card-actions>
        </v-card>
      </v-col>
    </v-row>
    
    <!-- System Resources -->
    <v-row class="mt-4">
      <v-col cols="12" md="6">
        <v-card>
          <v-card-title>System Resources</v-card-title>
          <v-card-text>
            <v-list>
              <v-list-item>
                <template v-slot:prepend>
                  <v-icon>mdi-cpu-64-bit</v-icon>
                </template>
                <v-list-item-title>CPU Usage</v-list-item-title>
                <v-list-item-subtitle>{{ systemStats.cpu.cores }} cores</v-list-item-subtitle>
                <template v-slot:append>
                  <span class="text-h6">{{ systemStats.cpu.usage }}%</span>
                </template>
                <v-progress-linear
                  :model-value="systemStats.cpu.usage"
                  :color="getProgressColor(systemStats.cpu.usage)"
                  height="6"
                  class="mt-2"
                ></v-progress-linear>
              </v-list-item>
              
              <v-list-item>
                <template v-slot:prepend>
                  <v-icon>mdi-memory</v-icon>
                </template>
                <v-list-item-title>Memory</v-list-item-title>
                <v-list-item-subtitle>
                  {{ formatBytes(systemStats.memory.used) }} / {{ formatBytes(systemStats.memory.total) }}
                </v-list-item-subtitle>
                <template v-slot:append>
                  <span class="text-h6">{{ systemStats.memory.percent }}%</span>
                </template>
                <v-progress-linear
                  :model-value="systemStats.memory.percent"
                  :color="getProgressColor(systemStats.memory.percent)"
                  height="6"
                  class="mt-2"
                ></v-progress-linear>
              </v-list-item>
              
              <v-list-item>
                <template v-slot:prepend>
                  <v-icon>mdi-harddisk</v-icon>
                </template>
                <v-list-item-title>Disk Space</v-list-item-title>
                <v-list-item-subtitle>
                  {{ formatBytes(systemStats.disk.used) }} / {{ formatBytes(systemStats.disk.total) }}
                </v-list-item-subtitle>
                <template v-slot:append>
                  <span class="text-h6">{{ systemStats.disk.percent }}%</span>
                </template>
                <v-progress-linear
                  :model-value="systemStats.disk.percent"
                  :color="getProgressColor(systemStats.disk.percent)"
                  height="6"
                  class="mt-2"
                ></v-progress-linear>
              </v-list-item>
            </v-list>
          </v-card-text>
        </v-card>
      </v-col>
      
      <!-- Quick Actions -->
      <v-col cols="12" md="6">
        <v-card>
          <v-card-title>Quick Actions</v-card-title>
          <v-card-text>
            <v-list>
              <v-list-item
                v-for="action in quickActions"
                :key="action.title"
                :to="action.to"
                :prepend-icon="action.icon"
                :title="action.title"
                :subtitle="action.subtitle"
                link
              ></v-list-item>
            </v-list>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
    
    <!-- Recent Activity -->
    <v-row class="mt-4">
      <v-col cols="12">
        <v-card>
          <v-card-title>
            Recent Activity
            <v-spacer></v-spacer>
            <v-btn
              variant="text"
              size="small"
              to="/activity"
            >
              View All
            </v-btn>
          </v-card-title>
          <v-card-text>
            <v-timeline density="compact" align="start">
              <v-timeline-item
                v-for="(activity, i) in recentActivity"
                :key="i"
                :dot-color="getActivityColor(activity.type)"
                size="small"
              >
                <div class="text-body-2">
                  {{ activity.message }}
                </div>
                <div class="text-caption text-grey">
                  {{ formatTime(activity.timestamp) }}
                </div>
              </v-timeline-item>
            </v-timeline>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </div>
</template>

<script setup>
import { computed, onMounted } from 'vue'
import { useToolsStore } from '@/stores/tools'
import { useMonitoringStore } from '@/stores/monitoring'
import dayjs from 'dayjs'
import relativeTime from 'dayjs/plugin/relativeTime'

dayjs.extend(relativeTime)

const toolsStore = useToolsStore()
const monitoringStore = useMonitoringStore()

// Mock recent activity - in real app, this would come from the API
const recentActivity = [
  { type: 'install', message: 'Installed Docker successfully', timestamp: new Date() },
  { type: 'service', message: 'Started PostgreSQL container', timestamp: new Date(Date.now() - 3600000) },
  { type: 'update', message: 'Updated Node.js to v22.0.0', timestamp: new Date(Date.now() - 7200000) },
  { type: 'error', message: 'Failed to install MySQL', timestamp: new Date(Date.now() - 10800000) }
]

// Quick actions
const quickActions = [
  {
    icon: 'mdi-package-variant',
    title: 'Install New Tools',
    subtitle: 'Browse and install development tools',
    to: '/installer'
  },
  {
    icon: 'mdi-folder-star',
    title: 'Quick Setup with Tool Sets',
    subtitle: 'Pre-configured tool collections',
    to: '/tool-sets'
  },
  {
    icon: 'mdi-update',
    title: 'Check for Updates',
    subtitle: 'Update installed tools',
    to: '/installer'
  },
  {
    icon: 'mdi-cog',
    title: 'Configure Settings',
    subtitle: 'Customize your environment',
    to: '/settings'
  }
]

// Computed
const installedCount = computed(() => toolsStore.installedCount)
const runningServices = computed(() => monitoringStore.runningServices.length)
const activePorts = computed(() => monitoringStore.activePorts.length)
const systemHealthy = computed(() => monitoringStore.systemHealthy)
const systemStats = computed(() => monitoringStore.systemStats)

// Methods
const formatBytes = (bytes) => {
  if (bytes === 0) return '0 Bytes'
  const k = 1024
  const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}

const formatTime = (timestamp) => {
  return dayjs(timestamp).fromNow()
}

const getProgressColor = (percent) => {
  if (percent < 50) return 'success'
  if (percent < 80) return 'warning'
  return 'error'
}

const getActivityColor = (type) => {
  const colors = {
    install: 'success',
    update: 'info',
    service: 'primary',
    error: 'error'
  }
  return colors[type] || 'grey'
}

// Lifecycle
onMounted(async () => {
  // Fetch initial data
  await Promise.all([
    toolsStore.fetchTools(),
    toolsStore.fetchInstalledTools(),
    monitoringStore.fetchHealth()
  ])
})
</script>