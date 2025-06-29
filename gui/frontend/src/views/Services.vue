<template>
  <div>
    <v-card class="mb-4">
      <v-card-title class="text-h5">
        Service Management
        <v-spacer></v-spacer>
        <v-btn
          icon="mdi-refresh"
          variant="text"
          @click="refreshServices"
          :loading="loading"
        ></v-btn>
      </v-card-title>
      <v-card-text>
        <p>Manage Docker containers, system services, and running processes.</p>
      </v-card-text>
    </v-card>
    
    <!-- Service Type Tabs -->
    <v-tabs
      v-model="selectedType"
      bg-color="primary"
      dark
    >
      <v-tab value="all">All Services</v-tab>
      <v-tab value="docker">Docker</v-tab>
      <v-tab value="systemd">System</v-tab>
      <v-tab value="process">Processes</v-tab>
    </v-tabs>
    
    <!-- Services List -->
    <v-card>
      <v-card-text>
        <v-data-table
          :headers="headers"
          :items="filteredServices"
          :loading="loading"
          item-value="name"
        >
          <template v-slot:item.status="{ item }">
            <v-chip
              :color="item.status === 'running' ? 'success' : 'error'"
              variant="flat"
              size="small"
            >
              <v-icon start size="small">
                {{ item.status === 'running' ? 'mdi-check-circle' : 'mdi-close-circle' }}
              </v-icon>
              {{ item.status }}
            </v-chip>
          </template>
          
          <template v-slot:item.type="{ item }">
            <v-chip variant="outlined" size="small">
              <v-icon start size="small">{{ getTypeIcon(item.type) }}</v-icon>
              {{ item.type }}
            </v-chip>
          </template>
          
          <template v-slot:item.actions="{ item }">
            <v-btn
              v-if="item.status === 'running'"
              icon="mdi-stop"
              size="small"
              variant="text"
              color="error"
              @click="performAction(item, 'stop')"
              :loading="item.loading"
            ></v-btn>
            <v-btn
              v-else
              icon="mdi-play"
              size="small"
              variant="text"
              color="success"
              @click="performAction(item, 'start')"
              :loading="item.loading"
            ></v-btn>
            <v-btn
              v-if="item.status === 'running'"
              icon="mdi-restart"
              size="small"
              variant="text"
              @click="performAction(item, 'restart')"
              :loading="item.loading"
            ></v-btn>
            <v-btn
              v-if="item.type === 'docker'"
              icon="mdi-text-box-outline"
              size="small"
              variant="text"
              @click="showLogs(item)"
            ></v-btn>
          </template>
        </v-data-table>
      </v-card-text>
    </v-card>
    
    <!-- Service Logs Dialog -->
    <v-dialog
      v-model="showLogsDialog"
      max-width="800"
    >
      <v-card>
        <v-card-title>
          Service Logs: {{ selectedService?.displayName }}
          <v-spacer></v-spacer>
          <v-btn
            icon="mdi-close"
            variant="text"
            @click="showLogsDialog = false"
          ></v-btn>
        </v-card-title>
        <v-card-text>
          <v-card
            variant="outlined"
            class="pa-3"
            style="max-height: 500px; overflow-y: auto; background-color: #1e1e1e;"
          >
            <pre class="text-caption" style="color: #d4d4d4;">{{ serviceLogs || 'Loading logs...' }}</pre>
          </v-card>
        </v-card-text>
      </v-card>
    </v-dialog>
    
    <!-- Action Confirmation Dialog -->
    <v-dialog
      v-model="confirmDialog"
      max-width="400"
    >
      <v-card>
        <v-card-title>Confirm Action</v-card-title>
        <v-card-text>
          Are you sure you want to {{ pendingAction?.action }} {{ pendingAction?.service.displayName }}?
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
            variant="text"
            @click="confirmDialog = false"
          >
            Cancel
          </v-btn>
          <v-btn
            color="primary"
            variant="flat"
            @click="confirmAction"
          >
            Confirm
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useMonitoringStore } from '@/stores/monitoring'

const monitoringStore = useMonitoringStore()

// State
const selectedType = ref('all')
const showLogsDialog = ref(false)
const confirmDialog = ref(false)
const selectedService = ref(null)
const serviceLogs = ref('')
const pendingAction = ref(null)

// Table headers
const headers = [
  { title: 'Service', key: 'displayName', value: 'displayName' },
  { title: 'Type', key: 'type', value: 'type' },
  { title: 'Status', key: 'status', value: 'status' },
  { title: 'Actions', key: 'actions', value: 'actions', sortable: false }
]

// Computed
const loading = computed(() => monitoringStore.loading)
const services = computed(() => {
  // Add loading state to each service
  return monitoringStore.services.map(s => ({
    ...s,
    displayName: s.display_name || s.name,
    loading: false
  }))
})

const filteredServices = computed(() => {
  if (selectedType.value === 'all') {
    return services.value
  }
  return services.value.filter(s => s.type === selectedType.value)
})

// Methods
const refreshServices = async () => {
  await monitoringStore.fetchServices()
}

const getTypeIcon = (type) => {
  const icons = {
    docker: 'mdi-docker',
    systemd: 'mdi-cog',
    process: 'mdi-application',
    mcp: 'mdi-server'
  }
  return icons[type] || 'mdi-help-circle'
}

const performAction = (service, action) => {
  // For critical services, show confirmation
  if (action === 'stop' && ['docker', 'postgresql', 'mysql'].includes(service.name)) {
    pendingAction.value = { service, action }
    confirmDialog.value = true
  } else {
    executeAction(service, action)
  }
}

const confirmAction = () => {
  if (pendingAction.value) {
    executeAction(pendingAction.value.service, pendingAction.value.action)
  }
  confirmDialog.value = false
  pendingAction.value = null
}

const executeAction = async (service, action) => {
  // Find the service in the array and set loading
  const serviceIndex = services.value.findIndex(s => s.name === service.name)
  if (serviceIndex !== -1) {
    services.value[serviceIndex].loading = true
  }
  
  try {
    await monitoringStore.performServiceAction(service.name, action)
    // Refresh services after action
    await refreshServices()
  } catch (error) {
    console.error('Service action failed:', error)
  } finally {
    if (serviceIndex !== -1) {
      services.value[serviceIndex].loading = false
    }
  }
}

const showLogs = async (service) => {
  selectedService.value = service
  showLogsDialog.value = true
  serviceLogs.value = 'Fetching logs...'
  
  try {
    // In a real implementation, this would fetch logs from the API
    const result = await monitoringStore.performServiceAction(service.name, 'logs')
    serviceLogs.value = result.output || 'No logs available'
  } catch (error) {
    serviceLogs.value = `Error fetching logs: ${error.message}`
  }
}

// Lifecycle
onMounted(async () => {
  await refreshServices()
})
</script>

<style scoped>
pre {
  font-family: 'Roboto Mono', monospace;
  white-space: pre-wrap;
  word-wrap: break-word;
}
</style>