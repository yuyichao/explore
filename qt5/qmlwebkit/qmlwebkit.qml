import QtQuick 2.0
import QtWebKit 3.0

Rectangle {
    WebView {
        id: webview
        // url: "http://qt-project.org"
        url: "file:///home/yuyichao/programming/explore/npapi/script/try.html"
        width: parent.width
        height: parent.height
        onNavigationRequested: {
            // detect URL scheme prefix, most likely an external link
            var schemaRE = /^\w+:/;
            if (schemaRE.test(request.url)) {
                request.action = WebView.AcceptRequest;
            } else {
                request.action = WebView.IgnoreRequest;
                // delegate request.url here
            }
        }
    }
}
