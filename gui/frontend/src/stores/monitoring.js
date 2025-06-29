import { defineStore } from 'pinia'
import axios from 'axios'

export const useMonitoringStore = defineStore('monitoring', {
  state: () => ({
    systemStats: {
      cpu: { usage: 0, cores: 0 },
      memory: { total: 0, used: 0, free: 0, percent: 0 },
      disk: { total: 0, used: 0, free: 0, percent: 0 },
      network: { rx: 0, tx: 0 },
      uptime: 0
    },
    ports: [],
    services: [],
    health: null,
    loading: false,
    error: null,
    updateInterval: null
  }),

  getters: {
    activePorts: (state) => {
      return state.ports.filter(p => p.state === 'LISTEN')
    },
    
    runningServices: (state) => {
      return state.services.filter(s => s.status === 'running')
    },
    
    systemHealthy: (state) => {
      return state.health?.status === 'healthy'
    },
    
    portsByRange: (state) => {
      const system = []
      const user = []
      const dynamic = []
      
      state.ports.forEach(port => {
        if (port.port <= 1023) system.push(port)
        else if (port.port <= 49151) user.push(port)
        else dynamic.push(port)
      })
      
      return { system, user, dynamic }
    }
  },

  actions: {
    async fetchSystemStats() {
      try {
        const response = await axios.get('/api/monitor/system')
        this.systemStats = response.data
      } catch (error) {
        console.error('Error fetching system stats:', error)
        this.error = error.message
      }
    },
    
    async fetchPorts() {
      try {
        const response = await axios.get('/api/monitor/ports')
        this.ports = response.data.ports
      } catch (error) {
        console.error('Error fetching ports:', error)
      }
    },
    
    async fetchServices() {
      try {
        const response = await axios.get('/api/monitor/services')
        this.services = response.data.services
      } catch (error) {
        console.error('Error fetching services:', error)
      }
    },
    
    async fetchHealth() {
      try {
        const response = await axios.get('/api/monitor/health')
        this.health = response.data
      } catch (error) {
        console.error('Error fetching health:', error)
      }
    },
    
    async performServiceAction(serviceName, action) {
      try {
        const response = await axios.post('/api/services/action', {
          service: serviceName,
          action
        })
        
        // Refresh services
        await this.fetchServices()
        
        return response.data
      } catch (error) {
        console.error('Error performing service action:', error)
        throw error
      }
    },
    
    startMonitoring(interval = 5000) {
      if (this.updateInterval) return
      
      // Initial fetch
      this.fetchAll()
      
      // Set up interval
      this.updateInterval = setInterval(() => {
        this.fetchAll()
      }, interval)
    },
    
    stopMonitoring() {
      if (this.updateInterval) {
        clearInterval(this.updateInterval)
        this.updateInterval = null
      }
    },
    
    async fetchAll() {
      this.loading = true
      try {
        await Promise.all([
          this.fetchSystemStats(),
          this.fetchPorts(),
          this.fetchServices(),
          this.fetchHealth()
        ])
      } finally {
        this.loading = false
      }
    },
    
    subscribeToUpdates(socket) {
      socket.emit('monitor:subscribe', { type: 'system', interval: 5000 })
      socket.emit('monitor:subscribe', { type: 'ports', interval: 10000 })
      socket.emit('monitor:subscribe', { type: 'services', interval: 10000 })
      
      socket.on('monitor:update', (data) => {
        switch (data.type) {
          case 'system':
            this.systemStats = data.data
            break
          case 'ports':
            this.ports = data.data
            break
          case 'services':
            this.services = data.data
            break
        }
      })
    },
    
    unsubscribeFromUpdates(socket) {
      socket.emit('monitor:unsubscribe', { type: 'system' })
      socket.emit('monitor:unsubscribe', { type: 'ports' })
      socket.emit('monitor:unsubscribe', { type: 'services' })
    }
  }
})