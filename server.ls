config = require \./config
express = require \express
ejs = require \ejs
fs = require \fs
url = require \url

die = (err, res) ->
    res.status 500
    res.end err.to-string!

# create & setup express app
app = express!
    ..set \views, __dirname + \/
    ..set 'view engine', 'ejs'
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
    res.set 'Content-Type', 'text/xml'
    res.render do
        \ad-tags/vast-template.ejs
        {
            redirect-url: \http://www.mobileacademy.com
            session-id: \0
            user-id: \1
            visit-id: \2
            media-file-url: \http://stark-wave-4682.herokuapp.com/videos/photo-course.mp4
            height: 270
            width: 300
            mime-type: \video/mp4
            track-url: \http://stark-wave-4682.herokuapp.com/track/
            campaign-id: 5
        }

app.get "/track/:eventType", (req,res) ->
    { event-type } = req.params
    { user-id } = req.query.user-id
    { query : { user-id } } = url.parse(request.url, true);

    console.log event-type, user-id

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

app.listen (process.env.PORT or config.port)
console.log "listening on port #{config.port}"