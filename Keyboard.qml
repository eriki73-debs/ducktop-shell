import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.VirtualKeyboard 2.4
import QtWayland.Compositor 1.14
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.14

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
