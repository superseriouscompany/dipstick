// This is for the kubernetes hello world at http://kubernetes.io/docs/hellonode/

var http   = require('http');
var app    = http.createServer(function(request, response) {
  console.log('Received request for URL: ' + request.url);
  response.writeHead(200);
  response.end('Hello World!');
});
app.listen(8080);
