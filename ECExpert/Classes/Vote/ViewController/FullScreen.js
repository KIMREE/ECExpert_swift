
var scheme = 'kimree://';
          
var videos = document.getElementsByTagName('video');

for (var i = 0; i < videos.length; i++) {
          videos[i].addEventListener('webkitbeginfullscreen', onBeginFullScreen, false);
          videos[i].addEventListener('webkitendfullscreen', onEndFullScreen, false);
}
          
function onBeginFullScreen() {
    window.location.href = scheme + 'video-beginfullscreen';
}
          
function onEndFullScreen() {
    window.location.href = scheme + 'video-endfullscreen';
}



