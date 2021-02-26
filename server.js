const {PrismaClient} = require('@prisma/client');
const express = require('express');
const prisma = new PrismaClient();

const app = express();

app.get('/api/test', async(req, res) => {
  console.log('Starting: GET /api/test');
  const user = await prisma.user.findFirst({ select: { id: true } });
  console.log('Finished: GET /api/test');
  return res.send(user);
});

app.post('/api/test/:name', async (req, res) => {
  console.log('Starting: POST /api/test/:name')
  const {name} = req.params
  const user = await prisma.user.create({data: {name}});
  console.log('Finished: POST /api/test/:name');
  return res.send('ok');
})

app.listen(process.env.PORT || 3000, async() => {
  console.log(`> Listening on port ${process.env.PORT || 3000}`)
  const time = Date.now();
  console.log('> Connecting to Prisma');
  await prisma.$connect();
  console.log(`> Done in ${Date.now() - time}ms`);
})
