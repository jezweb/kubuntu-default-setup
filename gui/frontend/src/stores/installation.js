import { defineStore } from 'pinia'
import axios from 'axios'
import { io } from 'socket.io-client'

export const useInstallationStore = defineStore('installation', {
  state: () => ({
    activeInstallations: [],
    installationHistory: [],
    currentInstallation: null,
    socket: null,
    connected: false
  }),

  getters: {
    isInstalling: (state) => {
      return state.activeInstallations.length > 0
    },
    
    installationProgress: (state) => {
      if (!state.currentInstallation) return 0
      return state.currentInstallation.progress || 0
    }
  },

  actions: {
    initSocket() {
      if (this.socket) return
      
      this.socket = io('/', {
        path: '/socket.io',
        transports: ['websocket', 'polling']
      })
      
      this.socket.on('connect', () => {
        console.log('Connected to server')
        this.connected = true
      })
      
      this.socket.on('disconnect', () => {
        console.log('Disconnected from server')
        this.connected = false
      })
      
      this.socket.on('install:progress', (data) => {
        this.handleInstallProgress(data)
      })
      
      this.socket.on('install:complete', (data) => {
        this.handleInstallComplete(data)
      })
      
      this.socket.on('install:error', (data) => {
        this.handleInstallError(data)
      })
    },
    
    disconnectSocket() {
      if (this.socket) {
        this.socket.disconnect()
        this.socket = null
        this.connected = false
      }
    },
    
    async installTools(toolIds) {
      try {
        const response = await axios.post('/api/install/tool', { toolIds })
        const { installationId, tools } = response.data
        
        this.currentInstallation = {
          id: installationId,
          tools,
          status: 'running',
          progress: 0,
          logs: []
        }
        
        this.activeInstallations.push(this.currentInstallation)
        
        // Start installation via WebSocket
        this.socket.emit('install:start', { tools: toolIds })
        
        return installationId
      } catch (error) {
        console.error('Error starting installation:', error)
        throw error
      }
    },
    
    async installToolSet(toolSetId) {
      try {
        const response = await axios.post('/api/install/toolset', { toolSetId })
        const { installationId, toolSet, tools } = response.data
        
        this.currentInstallation = {
          id: installationId,
          toolSet,
          tools,
          status: 'running',
          progress: 0,
          logs: []
        }
        
        this.activeInstallations.push(this.currentInstallation)
        
        // Start installation via WebSocket
        this.socket.emit('install:start', { toolSet: toolSetId })
        
        return installationId
      } catch (error) {
        console.error('Error starting tool set installation:', error)
        throw error
      }
    },
    
    async cancelInstallation(installationId) {
      try {
        await axios.delete(`/api/install/cancel/${installationId}`)
        this.socket.emit('install:cancel', { installationId })
        
        // Remove from active installations
        this.activeInstallations = this.activeInstallations.filter(
          i => i.id !== installationId
        )
        
        if (this.currentInstallation?.id === installationId) {
          this.currentInstallation = null
        }
      } catch (error) {
        console.error('Error cancelling installation:', error)
        throw error
      }
    },
    
    handleInstallProgress(data) {
      const installation = this.activeInstallations.find(i => i.id === data.installationId)
      if (installation) {
        installation.progress = data.toolProgress || 0
        installation.currentTool = data.currentTool
        installation.status = data.status
        
        if (data.log) {
          installation.logs.push({
            message: data.log,
            timestamp: new Date().toISOString()
          })
        }
      }
    },
    
    handleInstallComplete(data) {
      const installation = this.activeInstallations.find(i => i.id === data.installationId)
      if (installation) {
        installation.status = 'completed'
        installation.progress = 100
        
        // Move to history
        this.installationHistory.unshift(installation)
        this.activeInstallations = this.activeInstallations.filter(
          i => i.id !== data.installationId
        )
        
        if (this.currentInstallation?.id === data.installationId) {
          this.currentInstallation = null
        }
      }
    },
    
    handleInstallError(data) {
      const installation = this.activeInstallations.find(i => i.id === data.installationId)
      if (installation) {
        installation.status = 'error'
        installation.error = data.error
        
        // Move to history
        this.installationHistory.unshift(installation)
        this.activeInstallations = this.activeInstallations.filter(
          i => i.id !== data.installationId
        )
        
        if (this.currentInstallation?.id === data.installationId) {
          this.currentInstallation = null
        }
      }
    },
    
    async fetchActiveInstallations() {
      try {
        const response = await axios.get('/api/install/active')
        this.activeInstallations = response.data.installations
      } catch (error) {
        console.error('Error fetching active installations:', error)
      }
    }
  }
})