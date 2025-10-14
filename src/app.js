const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: process.env.APP_VERSION || '1.0.0',
    environment: process.env.NODE_ENV || 'development'
  });
});

// Main endpoint
app.get('/', (req, res) => {
  res.json({
    message: '🚀 Welcome to GitOps Demo App!',
    version: process.env.APP_VERSION || '1.0.0',
    environment: process.env.NODE_ENV || 'development',
    timestamp: new Date().toISOString(),
    features: [
      'GitHub Actions CI/CD',
      'ArgoCD GitOps',
      'Kubernetes Deployment',
      'Multi-environment Support'
    ]
  });
});

// API endpoints
app.get('/api/info', (req, res) => {
  res.json({
    app: 'GitOps Demo',
    version: process.env.APP_VERSION || '1.0.0',
    environment: process.env.NODE_ENV || 'development',
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    node: process.version
  });
});

// Error handling
app.use((err, req, res, _next) => {
  // eslint-disable-next-line no-console
  console.error(err.stack);
  res.status(500).json({
    error: 'Something went wrong!',
    message: err.message
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Route ${req.method} ${req.path} not found`
  });
});

app.listen(port, '0.0.0.0', () => {
  // eslint-disable-next-line no-console
  console.log(`🚀 Server running on port ${port}`);
  // eslint-disable-next-line no-console
  console.log(`📊 Health check: http://localhost:${port}/health`);
  // eslint-disable-next-line no-console
  console.log(`ℹ️  API info: http://localhost:${port}/api/info`);
});

module.exports = app;
