<template>
  <div>
    <v-card class="mb-4">
      <v-card-title class="text-h5">
        Pre-configured Tool Sets
      </v-card-title>
      <v-card-text>
        <p>Quick setup with curated tool collections for different development profiles.</p>
      </v-card-text>
    </v-card>
    
    <v-row>
      <v-col
        v-for="toolSet in toolSets"
        :key="toolSet.id"
        cols="12"
        sm="6"
        md="4"
      >
        <v-card height="100%">
          <v-card-text>
            <div class="d-flex align-center mb-3">
              <v-icon :icon="toolSet.icon || 'mdi-folder-star'" size="32" class="mr-3"></v-icon>
              <div>
                <div class="text-h6">{{ toolSet.display_name }}</div>
                <div class="text-caption text-grey">{{ toolSet.tools.length }} tools</div>
              </div>
            </div>
            
            <p class="text-body-2 mb-3">{{ toolSet.description }}</p>
            
            <v-progress-linear
              :model-value="toolSet.progress"
              :color="toolSet.progress === 100 ? 'success' : 'primary'"
              height="8"
              class="mb-2"
            >
              <template v-slot:default="{ value }">
                <strong class="text-caption">{{ Math.ceil(value) }}%</strong>
              </template>
            </v-progress-linear>
            
            <div class="text-caption text-grey">
              {{ toolSet.installedTools }} of {{ toolSet.totalTools }} tools installed
            </div>
            
            <!-- Tool chips -->
            <div class="mt-3">
              <v-chip
                v-for="(tool, i) in toolSet.tools.slice(0, 5)"
                :key="i"
                size="x-small"
                class="mr-1 mb-1"
              >
                {{ tool }}
              </v-chip>
              <v-chip
                v-if="toolSet.tools.length > 5"
                size="x-small"
                variant="outlined"
              >
                +{{ toolSet.tools.length - 5 }} more
              </v-chip>
            </div>
          </v-card-text>
          
          <v-card-actions>
            <v-btn
              variant="text"
              @click="showSetDetails(toolSet)"
            >
              View Details
            </v-btn>
            <v-spacer></v-spacer>
            <v-btn
              v-if="toolSet.progress < 100"
              color="primary"
              variant="flat"
              @click="installToolSet(toolSet)"
              :disabled="installing"
            >
              Install
            </v-btn>
            <v-chip
              v-else
              color="success"
              variant="flat"
            >
              <v-icon start size="small">mdi-check</v-icon>
              Complete
            </v-chip>
          </v-card-actions>
        </v-card>
      </v-col>
    </v-row>
    
    <!-- Tool Set Details Dialog -->
    <v-dialog
      v-model="showDetails"
      max-width="600"
    >
      <v-card v-if="selectedSet">
        <v-card-title>
          <v-icon :icon="selectedSet.icon || 'mdi-folder-star'" class="mr-2"></v-icon>
          {{ selectedSet.display_name }}
        </v-card-title>
        <v-card-text>
          <p class="text-body-1 mb-4">{{ selectedSet.description }}</p>
          
          <div class="text-subtitle-2 mb-2">Included Tools:</div>
          <v-list density="compact">
            <v-list-item
              v-for="toolName in selectedSet.tools"
              :key="toolName"
            >
              <template v-slot:prepend>
                <v-icon :color="getToolStatus(toolName) ? 'success' : ''">
                  {{ getToolStatus(toolName) ? 'mdi-check-circle' : 'mdi-circle-outline' }}
                </v-icon>
              </template>
              <v-list-item-title>{{ getToolDisplayName(toolName) }}</v-list-item-title>
              <v-list-item-subtitle v-if="getToolStatus(toolName)">
                Installed
              </v-list-item-subtitle>
            </v-list-item>
          </v-list>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn variant="text" @click="showDetails = false">Close</v-btn>
          <v-btn
            v-if="selectedSet.progress < 100"
            color="primary"
            variant="flat"
            @click="installToolSet(selectedSet)"
            :disabled="installing"
          >
            Install Missing Tools
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useToolsStore } from '@/stores/tools'
import { useInstallationStore } from '@/stores/installation'

const toolsStore = useToolsStore()
const installationStore = useInstallationStore()

// State
const showDetails = ref(false)
const selectedSet = ref(null)

// Computed
const toolSets = computed(() => toolsStore.toolSets)
const installing = computed(() => installationStore.isInstalling)

// Methods
const showSetDetails = (toolSet) => {
  selectedSet.value = toolSet
  showDetails.value = true
}

const installToolSet = async (toolSet) => {
  try {
    await installationStore.installToolSet(toolSet.name)
    showDetails.value = false
  } catch (error) {
    console.error('Failed to install tool set:', error)
  }
}

const getToolStatus = (toolName) => {
  const tool = toolsStore.getToolByName(toolName)
  return tool?.installed || false
}

const getToolDisplayName = (toolName) => {
  const tool = toolsStore.getToolByName(toolName)
  return tool?.display_name || toolName
}

// Lifecycle
onMounted(async () => {
  await Promise.all([
    toolsStore.fetchTools(),
    toolsStore.fetchToolSets()
  ])
})
</script>