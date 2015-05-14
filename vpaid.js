(function()
{
    var tagqa = '';
    var playerId = '';
    var playerContainerId = '';
    var playerWidth = '';
    var playerHeight = '';
 
    var tracki = '';
    var trackc = '';
 
    var viewMode = 'normal';
    var companionId = '';
    var pubMacros = '';
    var creativeData = '';
    var lkqdVPAID;
    var lkqdId = new Date().getTime().toString() + Math.round(Math.random()*1000000000).toString();
    var environmentVars = { slot: document.getElementById(playerContainerId), videoSlot: document.getElementById(playerId), videoSlotCanAutoPlay: true };
    
    // Subscribe to VPAID Ad Events
    function onVPAIDLoad()
    {   
        lkqdVPAID.subscribe(function() { lkqdVPAID.startAd(); }, 'AdLoaded');
    }
     
    var vpaidFrame = document.createElement('iframe');
    vpaidFrame.id = lkqdId;
    vpaidFrame.name = lkqdId;
    vpaidFrame.style.display = 'none';
    vpaidFrame.onload = function() {
        vpaidLoader = vpaidFrame.contentWindow.document.createElement('script');
        vpaidLoader.src = (document.location.protocol == 'https:' ? 'https:' : 'http:') + '//ad.lkqd.net/serve/pure.js?format=2&vpaid=true&env=1&apt=auto&ear=100&pid=0&sid=0&tagqa=' + tagqa + '&elementid=' + encodeURIComponent(playerId) + '&containerid=' + encodeURIComponent(playerContainerId) + '&width=' + playerWidth + '&height=' + playerHeight + '&mode=' + viewMode + '&companionid=' + encodeURIComponent(companionId) + '&tracki=' + encodeURIComponent(tracki) + '&trackc=' + encodeURIComponent(trackc) + '&rnd=' + Math.floor(Math.random() * 100000000) + '&cdata=' + encodeURIComponent(creativeData) + '&m=' + encodeURIComponent(pubMacros);
        vpaidLoader.onload = function() {
            lkqdVPAID = vpaidFrame.contentWindow.getVPAIDAd();
            lkqdVPAID.handshakeVersion('2.0');
            onVPAIDLoad();
            lkqdVPAID.initAd(playerWidth, playerHeight, viewMode, 600, creativeData, environmentVars);
        };
        vpaidFrame.contentWindow.document.body.appendChild(vpaidLoader);
    };
    document.body.appendChild(vpaidFrame);
})();