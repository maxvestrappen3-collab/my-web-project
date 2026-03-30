cat > server.js << 'EOF'
const express = require('express');
const http = require('http');
const fs = require('fs');
const app = express();
const server = http.createServer(app);
const io = require('socket.io')(server);

app.use(express.static('public'));
app.use(express.json({limit: '100mb'}));

let capturing = false;
let touches = 0;

app.get('/', (req, res) => res.sendFile(__dirname + '/public/index.html'));
app.post('/start', (req, res) => { capturing = true; console.log('\n✅ CAPTURING ON'); res.end(); });
app.post('/stop', (req, res) => { capturing = false; console.log('\n❌ CAPTURING OFF'); res.end(); });
app.post('/touch', (req, res) => { touches++; console.log(`👆 TOUCH #${touches}`); res.end(); });

app.post('/image', (req, res) => {
    if(!capturing) return res.end();
    let img = Buffer.from(req.body.image.split(',')[1], 'base64');
    let name = `img_${Date.now()}.jpg`;
    fs.writeFileSync(`captures/${name}`, img);
    console.log(`📸 ${name} (${Math.round(img.length/1024)}KB)`);
    res.end();
});

server.listen(8080, '127.0.0.1', () => {
    console.log('🌐 http://127.0.0.1:8080 READY');
});
EOF
