import express from 'express';
const app = express();
const port = process.env.PORT || 8080;
app.get('/', (req, res) => {
  res.json({
    service: 'shop-api',
    version: process.env.VERSION || 'v1',
    region: process.env.REGION || 'unknown',
    ts: new Date().toISOString()
  });
});
app.listen(port, () => console.log(`shop-api listening on ${port}`));
