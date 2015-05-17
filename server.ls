config = require \./config
cors = require \cors
express = require \express
ejs = require \ejs
fs = require \fs
url = require \url
https = require \https

private-key  = fs.readFileSync('key.pem', 'utf8')
certificate = fs.readFileSync('cert.pem', 'utf8')

credentials = { key: private-key , cert: certificate }
die = (err, res) ->
    res.status 500
    res.end err.to-string!

empty-gif = new Buffer([
    0x47, 0x49, 0x46, 0x38, 0x39, 0x61, 0x01, 0x00, 0x01, 0x00, 
    0x80, 0x00, 0x00, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x2c, 
    0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0x02, 
    0x02, 0x44, 0x01, 0x00, 0x3b]);

cors-options = 
  origin: true
  credentials: true
  allowedH-haders: true
  max-age: 3600

# create & setup express app
app = express!
    ..options '*', cors cors-options
    ..set \views, __dirname + \/
    ..set 'view engine', 'ejs'
    ..use "/public" express.static "#__dirname/public"

app.get "/main.css", (req,res) ->
    err, css <- fs.read-file "#__dirname/public/main.css", \utf8 
    return die err, res if !!err 
    res.end css

app.get "/crossdomain.xml", (req,res) ->
    res.set 'Content-Type', 'text/xml'

    res.end """<?xml version="1.0" ?>
                <cross-domain-policy>
                    <site-control permitted-cross-domain-policies="all"/>
                    <allow-access-from domain="*" secure="false"/>
                    <allow-http-request-headers-from domain="*" headers="*"/>
                </cross-domain-policy>"""
    
app.get "/vast.xml", (req,res) ->
    res.set 'Content-Type', 'text/xml'
    res.render do
        \ad-tags/vast-template.ejs
        {
            redirect-url: \http://www.mobileacademy.com
            session-id: \0
            user-id: \1
            visit-id: \2
            media-file-url: \http://stark-wave-4682.herokuapp.com/videos/selfiesForDummies.mp4
            height: 270
            width: 300
            mime-type: \video/mp4
            track-url: \http://stark-wave-4682.herokuapp.com/track/
            campaign-id: 5
        }

app.get "/vpaid.js", (req,res) ->
    res.set 'Content-Type', 'application/javascript'
    err, js <- fs.read-file "#__dirname/vpaid.js", \utf8 
    return die err, res if !!err 
    res.end js

app.get "/track/:eventType", (req,res) ->
    { event-type } = req.params
    { user-id } = req.query.user-id
    { query : { user-id } } = url.parse(req.url, true)

    console.log event-type, user-id
    res.set \Content-Type, \image/gif
    res.send empty-gif
    res.end!

app.get "/companion.xml", (req,res) ->
    try
        res.set 'Content-Type', 'text/xml'
        err, xml <- fs.read-file "#__dirname/ad-tags/companion.xml", \utf8 
        return die err, res if !!err 
        res.end xml
    catch err
        res.end JSON.stringify err

app.get "/n-vast.xml", (req,res) ->
    try
        res.set 'Content-Type', 'text/xml'
        err, xml <- fs.read-file "#__dirname/ad-tags/non-linear-template.xml", \utf8 
        return die err, res if !!err 
        res.end xml
    catch err
        res.end JSON.stringify err

app.get "/tag.html" , (req, res) ->
    res.set 'Content-Type', 'text/html'
    res.end "<a>TESTSTSTESTSETSSET</a>"

app.get "/videos/:name", (req, res) ->
    name = req.params.name
    file-path = "#__dirname/ad-video/#{name}"
    stat = fs.stat-sync filePath

    res.writeHead do
        200
        {
            'Content-Type': 'video/mp4'
            'Content-Length': stat.size
        }

    rs = fs.create-read-stream file-path
   
    rs.pipe res 

https-server = https.createServer credentials, app
# https-server.listen 443
app.listen (process.env.PORT or config.port)
console.log "listening on port #{config.port}"