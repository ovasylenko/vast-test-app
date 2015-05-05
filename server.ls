config = require \./config
fs = require \fs
express = require \express

die = (err, res)->
    res.status 500
    res.end err.to-string!

# create & setup express app
app = express!
    ..set \views, __dirname + \/
    ..use "/public" express.static "#__dirname/public"

app.get "/crossdomain.xml", (req,res) ->
    res.set 'Content-Type', 'text/xml'
    res.end '<?xml version="1.0" ?><cross-domain-policy><allow-access-from domain="*"/></cross-domain-policy>'
    
app.get "/vast", (req,res) ->
    res.set 'Content-Type', 'text/xml'
    console.log "#__dirname/ad-tags/VAST-template.xml"
    err, xml <- fs.read-file "#__dirname/ad-tags/VAST-template.xml", \utf8 
    return console.log "ERROR IN FILE WATECHER", err if !!err 
    res.end xml

app.get "/video.flv", (req, res) ->
    file-path = "#__dirname/ad-video/ad-video.flv"
    stat = fs.stat-sync filePath

    res.writeHead do
        200
        {
            'Content-Type': 'video/x-flv'
            'Content-Length': stat.size
        }

    rs = fs.create-read-stream file-path
   
    rs.pipe res 

app.listen config.port
console.log "listening on port #{config.port}"