import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.VirtualKeyboard 2.4
import QtWayland.Compositor 1.14
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.14

Drawer {
    id: bdrawer
    width: win.width
    height: win.height - 20 * shellScaleFactor
    edge: Qt.BottomEdge
    dragMargin: 20 * shellScaleFactor
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
        anchors.topMargin: 10 * shellScaleFactor
        anchors.left: parent.left
        anchors.leftMargin: 10 * shellScaleFactor
        anchors.right: parent.right
        anchors.rightMargin: 10 * shellScaleFactor
        height: (shellSurfaces.count != 0) ? (win.height / 3 + 35 * shellScaleFactor) : 0
        spacing: 10 * shellScaleFactor
        visible: shellSurfaces.count != 0

        delegate: Rectangle {
            opacity: 1 + y/height
            width: win.width / 3
            height: win.height / 3 + 35 * shellScaleFactor
            color: "transparent"
            border.color: "white"
            border.width: 1
            radius: 10 * shellScaleFactor
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
                anchors.bottomMargin: 35 * shellScaleFactor
                anchors.margins: 6 * shellScaleFactor
                surface: modelData.surface
                sizeFollowsSurface: false
                inputEventsEnabled: false
            }
            Text {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 11 * shellScaleFactor
                text: modelData.toplevel.title
                font.pixelSize: 14 * shellScaleFactor
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
        anchors.margins: 20 * shellScaleFactor
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
        anchors.topMargin: 10 * shellScaleFactor
        anchors.left: parent.left
        anchors.leftMargin: 10 * shellScaleFactor
        anchors.right: parent.right
        anchors.rightMargin: 10 * shellScaleFactor
        color: "white"
        font.pixelSize: 36 * shellScaleFactor
        font.family: "Lato"
        font.weight: Font.Light
        horizontalAlignment: Text.AlignLeft
    }

    ListView {
        id: launchAppGrid
        anchors.top: launchAppGridHeader.bottom
        anchors.topMargin: 10 * shellScaleFactor
        anchors.left: parent.left
        anchors.leftMargin: 10 * shellScaleFactor
        anchors.right: parent.right
        anchors.rightMargin: 10 * shellScaleFactor
        spacing: 10 * shellScaleFactor
        height: 106 * shellScaleFactor
        model: launcherApps
        orientation: ListView.Horizontal
        delegate: Item {
            width: 72 * shellScaleFactor
            Button {
                id: appIconButton
                height: 72 * shellScaleFactor
                width: 72 * shellScaleFactor
                icon.name: appIcon
                icon.color: "transparent"
                icon.height: 64 * shellScaleFactor
                icon.width: 64 * shellScaleFactor
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
                anchors.topMargin: 10 * shellScaleFactor
                text: appName
                font.pixelSize: 14 * shellScaleFactor
                font.family: "Lato"
                font.weight: Font.Light
                clip: true
                color: "white"
                width: 72 * shellScaleFactor
            }
        }
    }
}
