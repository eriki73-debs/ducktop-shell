import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.VirtualKeyboard 2.4
import QtWayland.Compositor 1.14
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.14

Drawer {
    id: bdrawer
    width: win.width
    height: win.height - 20
    edge: Qt.BottomEdge
    dragMargin: 20
    interactive: !comp.locked && (shellSurfaces.count != 0 || !visible)
    visible: true
    z: 100
    modal: false
    background: Rectangle{
        color:"black"
    }

    onInteractiveChanged: {
        if (shellSurfaces.count == 0) {
            open();
        }
    }

    ListView {
        id: openAppGrid
        model: shellSurfaces
        orientation: ListView.Horizontal
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
        height: (shellSurfaces.count != 0) ? win.height / 3 : 0
        spacing: 10
        visible: shellSurfaces.count != 0

        delegate: WaylandQuickItem {
            width: win.width / 3
            height: win.height / 3
            surface: modelData.surface
            sizeFollowsSurface: false
            inputEventsEnabled: false
            opacity: 1 + y/height
            MouseArea {
                anchors.fill: parent

                drag.target: parent
                drag.axis: Drag.YAxis
                drag.maximumY: 0

                onReleased: {
                    if (parent.y < - parent.height/2) {
                        modelData.toplevel.sendClose()
                        return
                    }
                    parent.y = 0
                    swipeviewofwins.currentIndex = index
                    bdrawer.position = 0
                }
            }
        }
    }

    Rectangle {
        id: bdrawerSeparator
        anchors.top: openAppGrid.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.right: parent.right
        height: 2
        color: "white"
        visible: shellSurfaces.count != 0
    }

    Text {
        id: launchAppGridHeader
        text: qsTr("Apps")
        anchors.top: bdrawerSeparator.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
        color: "white"
        font.pixelSize: 48
        font.family: "Lato"
        font.weight: Font.Light
        horizontalAlignment: Text.AlignLeft
    }

    ListView {
        id: launchAppGrid
        anchors.top: launchAppGridHeader.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
        spacing: 10
        height: 124
        Repeater {
            model: JSON.parse(shellData.getConfigData())["apps"]
            Item {
                Rectangle {
                    id: appIcon
                    color: "white"
                    height: 96
                    width: 96
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            shellData.execApp(modelData['program'], modelData['args']);
                            bdrawer.position = 0
                        }
                    }
                }
                Text {
                    anchors.top: appIcon.bottom
                    anchors.topMargin: 10
                    text: modelData["name"]
                    font.pixelSize: 14
                    font.family: "Lato"
                    font.weight: Font.Light
                    wrapMode: Text.Wrap
                    color: "white"
                    width: 96
                }
            }
        }
    }
}
