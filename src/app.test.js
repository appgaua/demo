const request = require('supertest');
const { app, server } = require('./app');

describe('GitOps Demo App', () => {
  afterAll((done) => {
    // Close the server after all tests
    if (server) {
      server.close(done);
    } else {
      done();
    }
  });
  describe('GET /', () => {
    it('should return welcome message', async () => {
      const res = await request(app).get('/');
      
      expect(res.status).toBe(200);
      expect(res.body.message).toContain('GitOps Demo App');
      expect(res.body.features).toContain('GitHub Actions CI/CD');
    });
  });

  describe('GET /health', () => {
    it('should return health status', async () => {
      const res = await request(app).get('/health');
      
      expect(res.status).toBe(200);
      expect(res.body.status).toBe('healthy');
      expect(res.body.timestamp).toBeDefined();
    });
  });

  describe('GET /api/info', () => {
    it('should return app info', async () => {
      const res = await request(app).get('/api/info');
      
      expect(res.status).toBe(200);
      expect(res.body.app).toBe('GitOps Demo');
      expect(res.body.version).toBeDefined();
      expect(res.body.uptime).toBeDefined();
    });
  });

  describe('404 handler', () => {
    it('should return 404 for unknown routes', async () => {
      const res = await request(app).get('/unknown');
      
      expect(res.status).toBe(404);
      expect(res.body.error).toBe('Not Found');
    });
  });
});
