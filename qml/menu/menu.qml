// import QtQuick 1.0 // to target Maemo 5
import QtQuick 1.1

Rectangle {
    id: rectangle1
    width: 360
    height: 360

    ListView {
        id: menu_list
        anchors.fill: parent
        cacheBuffer: 0
        keyNavigationWraps: false
        highlightMoveDuration: -1
        highlightRangeMode: ListView.StrictlyEnforceRange
        boundsBehavior: Flickable.StopAtBounds
        interactive: true
        contentWidth: parent.width
        delegate: Item {
            x: 5
            height: 40
            Row {
                id: row1
                spacing: 10
                Rectangle {
                    width: 40
                    height: 40
                    color: colorCode
                }

                Text {
                    text: name
                    anchors.verticalCenter: parent.verticalCenter
                    font.bold: true
                }
            }
        }
        model: ListModel {
            ListElement {
                name: "Grey"
                colorCode: "grey"
            }

            ListElement {
                name: "Red"
                colorCode: "red"
            }

            ListElement {
                name: "Blue"
                colorCode: "blue"
            }

            ListElement {
                name: "Green"
                colorCode: "green"
            }
        }
    }
}
