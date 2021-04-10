import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.VirtualKeyboard 2.4
import QtWayland.Compositor 1.14
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.14

WaylandOutput {
    property bool locked: false

    sizeFollowsWindow: true
    function handleShellSurface (xdgSurface, toplevel){
        shellSurfaces.append({shellSurface: xdgSurface});
        toplevel.sendFullscreen(Qt.size(win.width * shellScaleFactor, (win.height - 20) * shellScaleFactor));
        swipeviewofwins.currentIndex = shellSurfaces.count - 1;
    }

    window: Window {
        id: win
        width: 400
        height: 750
        visible: true
        color: "black"

        Lockscreen {
            id: lockscreen
        }

        Item {
            focus: true
            anchors.fill: parent
            visible: !comp.locked

            SwipeView {
                interactive: false
                anchors.fill: parent
                id: swipeviewofwins
                Repeater {
                    model: shellSurfaces
                    Item {
                        width: win.width
                        height: win.height - (vkeyb.active ? vkeyb.height : 0) - 20
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: (vkeyb.active ? vkeyb.height : 0)
                        ShellSurfaceItem {
                            anchors.fill: parent
                            autoCreatePopupItems: true
                            shellSurface: modelData
                            onSurfaceDestroyed: shellSurfaces.remove(index)
                            sizeFollowsSurface: false
                        }
                    }
                }
            }

            Rectangle {
                height: 20
                width: win.width
                anchors.top: parent.top
                anchors.left: parent.left
                color: "black"

                Text {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    font.pixelSize: 14
                    font.family: "Lato"
                    font.weight: Font.Light
                    horizontalAlignment: Text.AlignLeft
                    id: notificationCounter
                    text: "(" + notifications.count + ")"
                    color: "white"
                }

                Text {
                    anchors.right: batteryIndicator.left
                    anchors.top: parent.top
                    font.pixelSize: 14
                    font.family: "Lato"
                    font.weight: Font.Light
                    horizontalAlignment: Text.AlignLeft
                    id: batteryIndicatorText
                    text: "(" + (comp.batteryInfo ? comp.batteryInfo.Percentage.toString() + " %" : "0 %") + ") "
                    color: "white"
                }

                Rectangle {
                    id: batteryIndicator
                    anchors.right: clock.left
                    anchors.top: parent.top
                    anchors.margins: 3
                    width: 26
                    height: 10
                    color: "black"
                    border.color: "white"
                    border.width: 1
                    radius: 4

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.margins: 3
                        width: comp.batteryInfo ? 20 * comp.batteryInfo.Percentage / 100 : 0
                        radius: 2
                        color: comp.batteryInfo ? (comp.batteryInfo.State === 1 ? "green" : "white"): "black"
                    }
                }

                Text {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    font.pixelSize: 14
                    font.family: "Lato"
                    font.weight: Font.Light
                    horizontalAlignment: Text.AlignRight
                    id: clock
                    text: " " + comp.tstring
                    color: "white"
                }
            }

            AppDrawer {
                id: appDrawer
            }

            NotificationDrawer {
                id: notificationDrawer
            }

            InputPanel {
                id: vkeyb
                visible: active
                y: active ? parent.height - height : parent.height
                anchors.left: parent.left
                anchors.right: parent.right

                onActiveChanged: {
                    for (var i = 0; i < shellSurfaces.count; i++) {
                        shellSurfaces.get(i).shellSurface.toplevel.sendFullscreen(Qt.size(win.width * shellScaleFactor, (win.height - (vkeyb.active ? vkeyb.height : 0) - 20)*shellScaleFactor));
                    }
                }
            }
        }

        Shortcut {
            sequence: "Ctrl+Alt+Backspace"
            onActivated: Qt.quit()
        }
    }
}
