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
    res.end """ <?xml version="1.0" ?>
                <cross-domain-policy>
                    <site-control permitted-cross-domain-policies="all"/>
                    <allow-access-from domain="*" secure="false"/>
                    <allow-http-request-headers-from domain="*" headers="*"/>
                </cross-domain-policy> """
    
app.get "/vast.xml", (req,res) ->
    try
        res.set 'Content-Type', 'text/xml'
        err, xml <- fs.read-file "#__dirname/ad-tags/vast-template.xml", \utf8 
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

app.get "/videos/:name", (req, res) ->
    name = req.params.name
    file-path = "#__dirname/ad-video/#{name}"
    stat = fs.stat-sync filePath

    res.writeHead do
        200
        {
            'Content-Type': 'video/x-flv'
            'Content-Length': stat.size
        }

    rs = fs.create-read-stream file-path
   
    rs.pipe res 

app.listen  (process.env.PORT or config.port)
console.log "listening on port #{config.port}"