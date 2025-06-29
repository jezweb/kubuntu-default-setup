<template>
  <div>
    <!-- Header -->
    <v-card class="mb-4">
      <v-card-title class="text-h5">
        Installation Wizard
      </v-card-title>
      <v-card-text>
        <p>Select the tools you want to install. Dependencies will be automatically handled.</p>
        <v-text-field
          v-model="searchQuery"
          prepend-inner-icon="mdi-magnify"
          label="Search tools..."
          hide-details
          clearable
          class="mt-2"
        ></v-text-field>
      </v-card-text>
    </v-card>
    
    <!-- Category Tabs -->
    <v-tabs
      v-model="selectedCategory"
      bg-color="primary"
      dark
    >
      <v-tab value="all">All Tools</v-tab>
      <v-tab
        v-for="category in categories"
        :key="category"
        :value="category"
      >
        {{ category }}
      </v-tab>
    </v-tabs>
    
    <!-- Tools Grid -->
    <v-card>
      <v-card-text>
        <v-row v-if="!loading">
          <v-col
            v-for="tool in filteredTools"
            :key="tool.id"
            cols="12"
            sm="6"
            md="4"
            lg="3"
          >
            <v-card
              :color="tool.installed ? 'success' : ''"
              :variant="tool.installed ? 'tonal' : 'outlined'"
              height="100%"
            >
              <v-card-text>
                <div class="d-flex align-center mb-2">
                  <v-icon :icon="tool.icon || 'mdi-package-variant'" size="24" class="mr-2"></v-icon>
                  <div class="text-h6">{{ tool.display_name }}</div>
                </div>
                <p class="text-body-2 text-grey mb-2">{{ tool.description }}</p>
                <v-chip
                  v-if="tool.installed"
                  color="success"
                  size="small"
                  variant="flat"
                >
                  <v-icon start size="small">mdi-check</v-icon>
                  Installed
                </v-chip>
              </v-card-text>
              <v-card-actions>
                <v-checkbox
                  v-model="selectedTools"
                  :value="tool.id"
                  :disabled="tool.installed || installing"
                  hide-details
                ></v-checkbox>
                <v-spacer></v-spacer>
                <v-btn
                  v-if="!tool.installed"
                  size="small"
                  variant="text"
                  @click="showToolDetails(tool)"
                >
                  Details
                </v-btn>
              </v-card-actions>
            </v-card>
          </v-col>
        </v-row>
        
        <!-- Loading State -->
        <div v-else class="text-center py-8">
          <v-progress-circular indeterminate color="primary"></v-progress-circular>
          <p class="mt-4">Loading tools...</p>
        </div>
      </v-card-text>
      
      <!-- Installation Actions -->
      <v-card-actions v-if="selectedTools.length > 0" class="pa-4">
        <v-chip color="primary" variant="flat">
          {{ selectedTools.length }} tools selected
        </v-chip>
        <v-spacer></v-spacer>
        <v-btn
          color="primary"
          variant="flat"
          :disabled="installing"
          @click="installSelected"
        >
          <v-icon start>mdi-download</v-icon>
          Install Selected
        </v-btn>
      </v-card-actions>
    </v-card>
    
    <!-- Installation Progress Dialog -->
    <v-dialog
      v-model="showProgress"
      persistent
      max-width="600"
    >
      <v-card>
        <v-card-title>
          Installing Tools
          <v-spacer></v-spacer>
          <v-btn
            icon="mdi-close"
            variant="text"
            @click="cancelInstallation"
            :disabled="!canCancel"
          ></v-btn>
        </v-card-title>
        <v-card-text>
          <div v-if="currentInstallation">
            <p class="text-body-1 mb-2">
              Installing: {{ currentInstallation.currentTool }}
            </p>
            <v-progress-linear
              :model-value="currentInstallation.progress"
              color="primary"
              height="8"
              striped
              class="mb-4"
            ></v-progress-linear>
            
            <!-- Installation Logs -->
            <v-card variant="outlined" class="pa-2" style="max-height: 300px; overflow-y: auto;">
              <pre class="text-caption">{{ installationLogs }}</pre>
            </v-card>
          </div>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
            variant="text"
            @click="showProgress = false"
            :disabled="installing"
          >
            {{ installing ? 'Installing...' : 'Close' }}
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    
    <!-- Tool Details Dialog -->
    <v-dialog
      v-model="showDetails"
      max-width="500"
    >
      <v-card v-if="selectedTool">
        <v-card-title>
          <v-icon :icon="selectedTool.icon || 'mdi-package-variant'" class="mr-2"></v-icon>
          {{ selectedTool.display_name }}
        </v-card-title>
        <v-card-text>
          <p class="text-body-1 mb-4">{{ selectedTool.description }}</p>
          
          <div class="mb-2">
            <strong>Category:</strong> {{ selectedTool.category }}
          </div>
          <div class="mb-2">
            <strong>Script:</strong> {{ selectedTool.script_path }}
          </div>
          <div v-if="selectedTool.version" class="mb-2">
            <strong>Version:</strong> {{ selectedTool.version }}
          </div>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn variant="text" @click="showDetails = false">Close</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useToolsStore } from '@/stores/tools'
import { useInstallationStore } from '@/stores/installation'

const toolsStore = useToolsStore()
const installationStore = useInstallationStore()

// State
const searchQuery = ref('')
const selectedCategory = ref('all')
const selectedTools = ref([])
const showProgress = ref(false)
const showDetails = ref(false)
const selectedTool = ref(null)

// Computed
const loading = computed(() => toolsStore.loading)
const tools = computed(() => toolsStore.tools)
const categories = computed(() => Object.keys(toolsStore.categories))
const installing = computed(() => installationStore.isInstalling)
const currentInstallation = computed(() => installationStore.currentInstallation)
const canCancel = computed(() => currentInstallation.value?.status === 'running')

const filteredTools = computed(() => {
  let filtered = tools.value
  
  // Filter by category
  if (selectedCategory.value !== 'all') {
    filtered = filtered.filter(tool => tool.category === selectedCategory.value)
  }
  
  // Filter by search query
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(tool => 
      tool.name.toLowerCase().includes(query) ||
      tool.display_name.toLowerCase().includes(query) ||
      tool.description.toLowerCase().includes(query)
    )
  }
  
  return filtered
})

const installationLogs = computed(() => {
  if (!currentInstallation.value?.logs) return ''
  return currentInstallation.value.logs
    .map(log => log.message)
    .join('\n')
})

// Watch for installation completion
watch(installing, (newVal) => {
  if (!newVal && showProgress.value) {
    // Installation completed
    selectedTools.value = []
    toolsStore.fetchInstalledTools()
  }
})

// Methods
const installSelected = async () => {
  if (selectedTools.value.length === 0) return
  
  showProgress.value = true
  
  try {
    await installationStore.installTools(selectedTools.value)
  } catch (error) {
    console.error('Installation error:', error)
  }
}

const cancelInstallation = async () => {
  if (currentInstallation.value) {
    await installationStore.cancelInstallation(currentInstallation.value.id)
  }
}

const showToolDetails = (tool) => {
  selectedTool.value = tool
  showDetails.value = true
}

// Lifecycle
onMounted(async () => {
  await toolsStore.fetchTools()
})
</script>

<style scoped>
pre {
  font-family: 'Roboto Mono', monospace;
  white-space: pre-wrap;
  word-wrap: break-word;
}
</style>