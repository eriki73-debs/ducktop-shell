import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.VirtualKeyboard 2.4
import QtWayland.Compositor 1.14
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.14

WaylandCompositor {
    id: comp

    function addNotification(title, body, id) {
        notifications.append({title: title, body: body, id: id});
    }

    function delNotification(id) {
        for (let c_i = 0; c_i < notifications.count; c_i++){
            if (notifications.get(c_i).id === id)
                notifications.remove(c_i);
        }
    }

    function refreshBatteryInfo(info) {
        batteryInfo = info
    }

    property bool locked: true
    property bool closed: false
    property var batteryInfo

    function lock() {
        closed = !closed;
        locked = true;
        shellData.execApp("light -s sysfs/backlight/auto -S " + (closed ? "0" : "100"))
    }

    property int hours
    property int minutes
    property int seconds
    property int day
    property int month
    property int year
    property string dstring
    property string tstring

    function timeChanged() {
        var date = new Date;
        hours = date.getHours()
        minutes = date.getMinutes()
        seconds = date.getUTCSeconds();
        day = date.getDate()
        month = date.getMonth() + 1;
        year = date.getFullYear();
        dstring = date.toDateString();
        tstring = date.toTimeString();
    }

    Timer {
        interval: 100; running: true; repeat: true;
        onTriggered: timeChanged()
    }

    onSocketNameChanged: {
        shellData.setWsocketname(socketName);
    }

    function addApp(name, exec) {
        launcherApps.append({
                        appName: name,
                        appExec: exec
                    })
    }

    Output {
        id: outp
    }

    XdgShell {
        onToplevelCreated: {
            outp.handleShellSurface(xdgSurface, toplevel)
        }
    }
    ListModel { id: shellSurfaces }
    ListModel { id: notifications }
    ListModel { id: launcherApps }
    TextInputManager {}
}
