import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.VirtualKeyboard 2.4
import QtWayland.Compositor 1.14
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.14

Drawer {
    id: tdrawer
    width: win.width
    height: win.height
    edge: Qt.TopEdge
    interactive: !comp.locked
    dragMargin: 30 * shellScaleFactor
    z: 200
    background: Rectangle{
        color:"black"
    }

    Text {
        id: notificationListHeader
        text: qsTr("Notifications")
        anchors.top: parent.top
        anchors.topMargin: 40 * shellScaleFactor
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
        id: notificationList
        model: notifications
        orientation: ListView.Vertical
        anchors.fill: parent
        anchors.margins: 10 * shellScaleFactor
        anchors.topMargin: 100 * shellScaleFactor
        spacing: 10 * shellScaleFactor

        delegate: Rectangle {
            width: notificationList.width
            height: titleText.height + bodyText.height + 30 * shellScaleFactor * (1 - Math.abs(x/width))
            color: "black"
            border.color: "white"
            border.width: 1
            radius: 10 * shellScaleFactor
            opacity: 1 - Math.abs(x/width)

            MouseArea {
                anchors.fill: parent

                drag.target: parent
                drag.axis: Drag.XAxis

                onReleased: {
                    if (parent.x < - parent.width / 2 || parent.x > parent.width / 2) {
                        notifications.remove(index)
                    }
                    parent.x = 0
                }
            }

            Text {
                id: titleText
                color: "white"
                text: title
                anchors.left: parent.left
                anchors.leftMargin: 10 * shellScaleFactor
                anchors.right: parent.right
                anchors.rightMargin: 10 * shellScaleFactor
                anchors.top: parent.top
                anchors.topMargin: 10 * shellScaleFactor * (1 - Math.abs(parent.x/parent.width))
                font.pixelSize: 24 * shellScaleFactor * (1 - Math.abs(parent.x/parent.width))
                font.bold: true
                wrapMode: Text.Wrap
            }

            Text {
                id: bodyText
                color: "white"
                text: body
                anchors.left: parent.left
                anchors.leftMargin: 10 * shellScaleFactor
                anchors.right: parent.right
                anchors.rightMargin: 10 * shellScaleFactor
                anchors.top: titleText.bottom
                anchors.topMargin: 10 * shellScaleFactor * (1 - Math.abs(parent.x/parent.width))
                font.pixelSize: 18 * shellScaleFactor * (1 - Math.abs(parent.x/parent.width))
                wrapMode: Text.Wrap
            }
        }
    }
}
