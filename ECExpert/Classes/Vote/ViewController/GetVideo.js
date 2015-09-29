$(document).ready(function () {
    var scheme = 'kimree://video//';
                  
    var videos = document.getElementsByTagName('video');
    
    var src = ""
    if(videos.length > 0){
        src = videos[0].src
    }
    
    window.location.href = scheme + src
});
