import { defineStore } from 'pinia'
import axios from 'axios'

export const useToolsStore = defineStore('tools', {
  state: () => ({
    tools: [],
    categories: {},
    installedTools: [],
    toolSets: [],
    loading: false,
    error: null
  }),

  getters: {
    toolsByCategory: (state) => {
      return state.categories
    },
    
    installedCount: (state) => {
      return state.installedTools.length
    },
    
    getToolById: (state) => {
      return (id) => state.tools.find(tool => tool.id === id)
    },
    
    getToolByName: (state) => {
      return (name) => state.tools.find(tool => tool.name === name)
    }
  },

  actions: {
    async fetchTools() {
      this.loading = true
      this.error = null
      try {
        const response = await axios.get('/api/tools')
        this.tools = response.data.tools
        this.categories = response.data.categories
      } catch (error) {
        this.error = error.message
        console.error('Error fetching tools:', error)
      } finally {
        this.loading = false
      }
    },

    async fetchInstalledTools() {
      try {
        const response = await axios.get('/api/tools/installed')
        this.installedTools = response.data.tools
      } catch (error) {
        console.error('Error fetching installed tools:', error)
      }
    },

    async fetchToolSets() {
      try {
        const response = await axios.get('/api/tools/sets')
        this.toolSets = response.data.toolSets
      } catch (error) {
        console.error('Error fetching tool sets:', error)
      }
    },

    async searchTools(query) {
      try {
        const response = await axios.get(`/api/tools/search/${encodeURIComponent(query)}`)
        return response.data.tools
      } catch (error) {
        console.error('Error searching tools:', error)
        return []
      }
    },

    async updateToolStatus(toolId, installed) {
      try {
        const response = await axios.put(`/api/tools/${toolId}/update`, { installed })
        const updatedTool = response.data.tool
        
        // Update local state
        const index = this.tools.findIndex(t => t.id === toolId)
        if (index !== -1) {
          this.tools[index] = updatedTool
        }
        
        // Refresh installed tools
        await this.fetchInstalledTools()
        
        return updatedTool
      } catch (error) {
        console.error('Error updating tool status:', error)
        throw error
      }
    }
  }
})