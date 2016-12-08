var express = require('express');
var bunyan  = require('bunyan');

var app     = express();
var log     = bunyan.createLogger({ name: 'dipstick' });
var port    = process.env.PORT || 3000;

log.info('hi');

app.post('/cool', function(req, res) {
  res.json({
    sick: Math.random()
  })
})

app.get('/slow', function(req, res) {
  const time = 1000;
  setTimeout(function() {
    res.json({
      time: time,
    })
  }, time);
})

app.get('/sometimes500', function(req, res) {
  const roll = Math.random();

  if( roll > 0.5 ) {
    const err = new Error("Bad roll");
    err.roll = roll;
    log.error({err: err}, "Ya burnt");
    res.status(500);
  }
  res.json({roll: roll});
})

app.get('*', function(req, res) {
  res.json({hi: true, good: 'great'})
})

app.listen(port, function() {
  log.info({port: port}, 'server is running');
})

process.on('uncaughtException', function(err) {
  log.error({err: err}, 'Uncaught Error');
  throw err;
})
