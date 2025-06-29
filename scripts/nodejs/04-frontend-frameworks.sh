#!/bin/bash

# Frontend Frameworks Setup Script
# This script installs and configures popular frontend frameworks and CSS libraries

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

log_info "Starting frontend frameworks setup..."

# Ensure npm is available
if ! command_exists npm; then
    log_error "npm is not installed. Please run the NVM/Node.js setup script first."
    exit 1
fi

# Tailwind CSS
install_tailwindcss() {
    if command_exists tailwindcss; then
        log_success "Tailwind CSS CLI is already installed"
    else
        if confirm "Would you like to install Tailwind CSS CLI?" "y"; then
            log_info "Installing Tailwind CSS CLI..."
            npm install -g tailwindcss
            
            if command_exists tailwindcss; then
                log_success "Tailwind CSS CLI installed successfully"
                log_info "Initialize Tailwind in a project with: npx tailwindcss init"
            fi
        fi
    fi
}

# Create Vue/Vuetify project helper
create_vuetify_helper() {
    if confirm "Would you like to create a Vuetify project helper script?" "y"; then
        cat > "$HOME/create-vuetify-project.sh" << 'EOF'
#!/bin/bash
# Create a new Vuetify 3 project

PROJECT_NAME="${1:-my-vuetify-app}"

echo "Creating Vuetify 3 project: $PROJECT_NAME"

# Create project with Vite
npm create vite@latest "$PROJECT_NAME" -- --template vue

cd "$PROJECT_NAME"

# Install Vuetify 3
npm install vuetify@^3.7.5
npm install @mdi/font -D

# Set up Vuetify
cat > src/plugins/vuetify.js << 'EOL'
import 'vuetify/styles'
import { createVuetify } from 'vuetify'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'
import '@mdi/font/css/materialdesignicons.css'

const vuetify = createVuetify({
  components,
  directives,
  theme: {
    defaultTheme: 'light',
    themes: {
      light: {
        primary: '#1976D2',
        secondary: '#424242',
        accent: '#82B1FF',
        error: '#FF5252',
        info: '#2196F3',
        success: '#4CAF50',
        warning: '#FFC107'
      },
    },
  },
})

export default vuetify
EOL

# Update main.js
cat > src/main.js << 'EOL'
import { createApp } from 'vue'
import App from './App.vue'
import vuetify from './plugins/vuetify'

const app = createApp(App)
app.use(vuetify)
app.mount('#app')
EOL

# Create example component
cat > src/App.vue << 'EOL'
<template>
  <v-app>
    <v-app-bar app color="primary" dark>
      <v-toolbar-title>{{ projectName }}</v-toolbar-title>
    </v-app-bar>

    <v-main>
      <v-container>
        <v-row>
          <v-col cols="12">
            <v-card>
              <v-card-title>Welcome to Vuetify 3</v-card-title>
              <v-card-text>
                Your Vuetify project is ready!
              </v-card-text>
              <v-card-actions>
                <v-btn color="primary" variant="elevated">
                  Get Started
                </v-btn>
              </v-card-actions>
            </v-card>
          </v-col>
        </v-row>
      </v-container>
    </v-main>
  </v-app>
</template>

<script setup>
const projectName = '$PROJECT_NAME'
</script>
EOL

echo ""
echo "✅ Vuetify project created successfully!"
echo ""
echo "Next steps:"
echo "  cd $PROJECT_NAME"
echo "  npm install"
echo "  npm run dev"
echo ""
echo "Vuetify documentation: https://vuetifyjs.com/"
EOF
        chmod +x "$HOME/create-vuetify-project.sh"
        log_success "Created Vuetify project helper at ~/create-vuetify-project.sh"
    fi
}

# Create Tailwind CSS project helper
create_tailwind_helper() {
    if confirm "Would you like to create a Tailwind CSS project helper script?" "y"; then
        cat > "$HOME/create-tailwind-project.sh" << 'EOF'
#!/bin/bash
# Create a new project with Tailwind CSS

PROJECT_NAME="${1:-my-tailwind-app}"
FRAMEWORK="${2:-vite}" # vite, react, vue, next

echo "Creating Tailwind CSS project: $PROJECT_NAME with $FRAMEWORK"

case $FRAMEWORK in
    react)
        npm create vite@latest "$PROJECT_NAME" -- --template react
        ;;
    vue)
        npm create vite@latest "$PROJECT_NAME" -- --template vue
        ;;
    next)
        npx create-next-app@latest "$PROJECT_NAME" --typescript --tailwind --app
        echo "✅ Next.js project created with Tailwind CSS already configured!"
        exit 0
        ;;
    *)
        npm create vite@latest "$PROJECT_NAME"
        ;;
esac

cd "$PROJECT_NAME"

# Install Tailwind CSS
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p

# Configure tailwind.config.js
cat > tailwind.config.js << 'EOL'
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx,vue}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOL

# Add Tailwind directives to CSS
mkdir -p src
cat > src/index.css << 'EOL'
@tailwind base;
@tailwind components;
@tailwind utilities;
EOL

# Update main entry file to import CSS
if [[ -f "src/main.jsx" ]]; then
    sed -i '1i import "./index.css"' src/main.jsx
elif [[ -f "src/main.js" ]]; then
    sed -i '1i import "./index.css"' src/main.js
elif [[ -f "src/main.ts" ]]; then
    sed -i '1i import "./index.css"' src/main.ts
fi

echo ""
echo "✅ Tailwind CSS project created successfully!"
echo ""
echo "Next steps:"
echo "  cd $PROJECT_NAME"
echo "  npm install"
echo "  npm run dev"
echo ""
echo "Tailwind documentation: https://tailwindcss.com/docs"
EOF
        chmod +x "$HOME/create-tailwind-project.sh"
        log_success "Created Tailwind CSS project helper at ~/create-tailwind-project.sh"
    fi
}

# Create Material-UI (MUI) project helper
create_mui_helper() {
    if confirm "Would you like to create a Material-UI (MUI) project helper script?" "y"; then
        cat > "$HOME/create-mui-project.sh" << 'EOF'
#!/bin/bash
# Create a new React project with Material-UI

PROJECT_NAME="${1:-my-mui-app}"

echo "Creating Material-UI project: $PROJECT_NAME"

# Create React project with Vite
npm create vite@latest "$PROJECT_NAME" -- --template react

cd "$PROJECT_NAME"

# Install MUI dependencies
npm install @mui/material @emotion/react @emotion/styled
npm install @mui/icons-material

# Create theme configuration
mkdir -p src/theme
cat > src/theme/theme.js << 'EOL'
import { createTheme } from '@mui/material/styles';

const theme = createTheme({
  palette: {
    mode: 'light',
    primary: {
      main: '#1976d2',
    },
    secondary: {
      main: '#dc004e',
    },
  },
  typography: {
    fontFamily: '"Roboto", "Helvetica", "Arial", sans-serif',
  },
});

export default theme;
EOL

# Update main.jsx
cat > src/main.jsx << 'EOL'
import React from 'react'
import ReactDOM from 'react-dom/client'
import { ThemeProvider } from '@mui/material/styles'
import CssBaseline from '@mui/material/CssBaseline'
import theme from './theme/theme'
import App from './App.jsx'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <App />
    </ThemeProvider>
  </React.StrictMode>,
)
EOL

# Create example component
cat > src/App.jsx << 'EOL'
import { useState } from 'react'
import {
  Container,
  Box,
  Typography,
  Button,
  Paper,
  AppBar,
  Toolbar,
} from '@mui/material'
import { Add as AddIcon } from '@mui/icons-material'

function App() {
  const [count, setCount] = useState(0)

  return (
    <>
      <AppBar position="static">
        <Toolbar>
          <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
            Material-UI App
          </Typography>
        </Toolbar>
      </AppBar>
      
      <Container maxWidth="sm">
        <Box sx={{ my: 4 }}>
          <Paper elevation={3} sx={{ p: 4, textAlign: 'center' }}>
            <Typography variant="h4" component="h1" gutterBottom>
              Welcome to Material-UI
            </Typography>
            <Typography variant="body1" paragraph>
              Count: {count}
            </Typography>
            <Button
              variant="contained"
              startIcon={<AddIcon />}
              onClick={() => setCount(count + 1)}
            >
              Increment
            </Button>
          </Paper>
        </Box>
      </Container>
    </>
  )
}

export default App
EOL

# Add Roboto font to index.html
sed -i '/<\/head>/i \    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Roboto:300,400,500,700&display=swap" />' index.html

echo ""
echo "✅ Material-UI project created successfully!"
echo ""
echo "Next steps:"
echo "  cd $PROJECT_NAME"
echo "  npm install"
echo "  npm run dev"
echo ""
echo "MUI documentation: https://mui.com/"
EOF
        chmod +x "$HOME/create-mui-project.sh"
        log_success "Created Material-UI project helper at ~/create-mui-project.sh"
    fi
}

# Install additional CSS framework tools
install_css_tools() {
    log_info "Additional CSS framework tools..."
    
    # PostCSS CLI
    if confirm "Would you like to install PostCSS CLI?" "y"; then
        npm install -g postcss postcss-cli
        log_success "PostCSS CLI installed"
    fi
    
    # Sass
    if confirm "Would you like to install Sass?" "y"; then
        npm install -g sass
        log_success "Sass installed"
    fi
}

# Framework comparison info
show_framework_info() {
    log_info "Frontend Framework Quick Reference:"
    echo ""
    echo "🎨 CSS Frameworks:"
    echo "  - Tailwind CSS: Utility-first CSS framework"
    echo "    Usage: npm install -D tailwindcss"
    echo ""
    echo "🖼️ Component Libraries:"
    echo "  - Vuetify: Material Design for Vue.js"
    echo "    Usage: npm install vuetify"
    echo ""
    echo "  - Material-UI (MUI): Material Design for React"
    echo "    Usage: npm install @mui/material @emotion/react @emotion/styled"
    echo ""
    echo "  - Ant Design: Enterprise-focused React UI"
    echo "    Usage: npm install antd"
    echo ""
    echo "  - Chakra UI: Modular React component library"
    echo "    Usage: npm install @chakra-ui/react @emotion/react @emotion/styled"
    echo ""
    echo "  - Bootstrap: Popular CSS framework"
    echo "    Usage: npm install bootstrap"
    echo ""
    echo "  - Bulma: Modern CSS framework based on Flexbox"
    echo "    Usage: npm install bulma"
}

# Main installation
install_tailwindcss
create_vuetify_helper
create_tailwind_helper
create_mui_helper
install_css_tools
show_framework_info

log_success "Frontend frameworks setup completed!"