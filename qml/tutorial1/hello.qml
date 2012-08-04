import QtQuick 1.0

Rectangle {
    id: page
    width: 500
    height: 200
    color: "lightgray"

    Text {
        id: hello_text
        text: "Hello World!"
        y: 30
        anchors.horizontalCenter: page.horizontalCenter
        font.pointSize: 24
        font.bold: true
    }
}