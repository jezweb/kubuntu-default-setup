import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import pinia from './stores'
import vuetify from './plugins/vuetify'
import axios from 'axios'

// Set axios defaults
axios.defaults.baseURL = import.meta.env.DEV ? 'http://localhost:7842' : ''

const app = createApp(App)

app.use(router)
app.use(pinia)
app.use(vuetify)

app.mount('#app')
