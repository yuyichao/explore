import QtQuick 1.1
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets

Item {
    id: root_item

    property int icons_size:     24
    property int icons_margins:  4
    property alias icons_number: list.count
    property alias model:    list.model
    property int cell_size: icons_size + 2*icons_margins
    property int min_width:   cell_size + icons_margins + __max_name_width
    property int min_height:  list.count*cell_size
    property int __max_name_width: 0
    Component {
        id: delegate_task
        Item {
            id: delegate_root_item
            width: min_width
            height: cell_size

            Item {
                id: tray_icon
                anchors { left: parent.left; top: parent.top; }
                width: cell_size
                height: width
                z: 10
            }

            PlasmaWidgets.Label {
                id: name_item
                anchors { left: tray_icon.right; top: parent.top; bottom: parent.bottom }
                alignment: Qt.AlignLeft | Qt.AlignVCenter
                wordWrap: false
                textSelectable: false
                text: task.name
                z: -10 // We place label under mouse area to be able to handle mouse events
            }

            Component.onCompleted: {
                var text_width = name_item.width
                if (text_width > __max_name_width) {
                    __max_name_width = text_width
                }
            }

        }
    }



    Component {
        id: delegate_highlight
        Item {
            height: cell_size
            width: min_width

            PlasmaWidgets.ItemBackground {
                anchors.fill: parent
            }
        }
    }

    ListView {
        id: list
        anchors.centerIn: parent
        width:  min_width
        height: min_height
        cacheBuffer: 0

        interactive: false
        delegate: delegate_task
        highlight: delegate_highlight
        highlightFollowsCurrentItem: true
        highlightMoveSpeed: -1
        highlightMoveDuration: 250
        spacing: 0
        snapMode: ListView.SnapToItem
    }
}
