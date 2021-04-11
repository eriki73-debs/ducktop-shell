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
    interactive: !comp.locked && (shellSurfaces.count != 0 || position != 1.0)
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
        height: (shellSurfaces.count != 0) ? (win.height / 3 + 35) : 0
        spacing: 10
        visible: shellSurfaces.count != 0

        delegate: Rectangle {
            opacity: 1 + y/height
            width: win.width / 3
            height: win.height / 3 + 35
            color: "transparent"
            border.color: "white"
            border.width: 1
            radius: 10
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
            WaylandQuickItem {
                anchors.fill: parent
                anchors.bottomMargin: 35
                anchors.margins: 6
                surface: modelData.surface
                sizeFollowsSurface: false
                inputEventsEnabled: false
            }
            Text {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 11
                text: modelData.toplevel.title
                font.pixelSize: 14
                font.family: "Lato"
                font.weight: Font.Light
                clip: true
                color: "white"
            }
        }
    }

    Rectangle {
        id: bdrawerSeparator
        anchors.top: openAppGrid.bottom
        anchors.margins: 20
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: "white"
        visible: shellSurfaces.count != 0
    }

    Text {
        id: launchAppGridHeader
        text: qsTr("Apps")
        anchors.top: bdrawerSeparator.bottom
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
        height: 106
        model: launcherApps
        orientation: ListView.Horizontal
        delegate: Item {
            width: 72
            Button {
                id: appIconButton
                height: 72
                width: 72
                icon.name: appIcon
                icon.color: "transparent"
                icon.height: 64
                icon.width: 64
                background: Rectangle {
                    color: "transparent"
                }

                onClicked: {
                    shellData.execApp(appExec);
                    bdrawer.position = 0
                }
            }
            Text {
                anchors.top: appIconButton.bottom
                anchors.topMargin: 10
                text: appName
                font.pixelSize: 14
                font.family: "Lato"
                font.weight: Font.Light
                clip: true
                color: "white"
                width: 72
            }
        }
    }
}
