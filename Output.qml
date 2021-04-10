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
        toplevel.sendFullscreen(Qt.size(win.width, win.height));
        swipeviewofwins.currentIndex = shellSurfaces.count - 1;
    }

    window: Window {
        id: win
        width: 750
        height: 1000
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
                        height: win.height - (vkeyb.active ? vkeyb.height : 0) - 30
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
                height: 30
                width: win.width
                anchors.top: parent.top
                anchors.left: parent.left
                color: "black"
                Text {
                    anchors.fill: parent
                    font.pixelSize: 24
                    font.family: "Lato"
                    font.weight: Font.Light
                    horizontalAlignment: Text.AlignRight
                    id: clock
                    text: comp.tstring
                    color: "white"
                }
                Text {
                    anchors.fill: parent
                    font.pixelSize: 24
                    font.family: "Lato"
                    font.weight: Font.Light
                    horizontalAlignment: Text.AlignLeft
                    id: notificationCounter
                    text: "(" + notifications.count + ")"
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
                        shellSurfaces.get(i).shellSurface.toplevel.sendFullscreen(Qt.size(win.width, win.height - (vkeyb.active ? vkeyb.height : 0)));
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
