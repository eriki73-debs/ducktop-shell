import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.VirtualKeyboard 2.4
import QtWayland.Compositor 1.14
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.14

Drawer {
    visible: comp.locked
    interactive: comp.locked && !(comp.closed)
    width: win.width
    height: win.height
    edge: Qt.TopEdge
    z: 400
    background: Rectangle{
        color:"black"
    }

    Text {
        anchors.fill: parent
        anchors.margins: 20
        text: qsTr("Swipe up to unlock")
        font.pixelSize: 24
        font.family: "Lato"
        font.weight: Font.Light
        verticalAlignment: Text.AlignBottom
        horizontalAlignment: Text.AlignHCenter
        color: "white"
        wrapMode: Text.Wrap
    }

    Text {
        anchors.fill: parent
        text: comp.tstring
        font.pixelSize: 64
        font.family: "Lato"
        font.weight: Font.ExtraLight
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        color: "white"
        wrapMode: Text.Wrap
    }

    Text {
        anchors.fill: parent
        anchors.topMargin: 128
        text: comp.dstring
        font.pixelSize: 24
        font.family: "Lato"
        font.weight: Font.Light
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        color: "white"
        wrapMode: Text.Wrap
    }


    onClosed: {
        comp.locked = false;
    }
}
