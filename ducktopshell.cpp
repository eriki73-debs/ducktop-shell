#include "ducktopshell.h"

DucktopShell::DucktopShell(QObject *parent) : QObject(parent) {
    upower_properties = new org::freedesktop::DBus::Properties("org.freedesktop.UPower", "/org/freedesktop/UPower/devices/DisplayDevice",
                               QDBusConnection::systemBus(), this);
    connect(upower_properties, SIGNAL(PropertiesChanged(QString, QVariantMap, QStringList)), this, SLOT(onUPowerInfoChanged(QString, QVariantMap, QStringList)));
}

QByteArray DucktopShell::getConfigData() {
    return configData;
}

QByteArray DucktopShell::getWsocketname() {
    return wsocketname;
}

void DucktopShell::setWsocketname(QByteArray name) {
    wsocketname = name;
}

bool DucktopShell::loadConfig()
{
    QFile configFile(QTextCodec::codecForMib(106)->toUnicode(qgetenv("HOME")) + QStringLiteral("/.ducktop/shell/config.json"));
    if (!configFile.open(QIODevice::ReadOnly)) {
        qWarning("Couldn't open config file.");
        return false;
    }
    configData = configFile.readAll();
    configJson = QJsonDocument::fromJson(configData);
    return true;
}

void DucktopShell::execApp(QString program, QStringList args)
{
    qputenv("QT_QPA_PLATFORM", QByteArray("wayland"));
    qunsetenv("QT_IM_MODULE");
    //qputenv("QT_SCALE_FACTOR", QByteArray("2"));

    qputenv("WAYLAND_DISPLAY", wsocketname);
    if (!QProcess::startDetached(program, args))
        qDebug() << "Failed to run";
}

void DucktopShell::notification(QString title, QString body, int id) {
    QMetaObject::invokeMethod(engine.rootObjects()[0], "addNotification", Q_ARG(QVariant, title), Q_ARG(QVariant, body), Q_ARG(QVariant, id));
}

void DucktopShell::delnotification(int id) {
    QMetaObject::invokeMethod(engine.rootObjects()[0], "delNotification", Q_ARG(QVariant, id));
}

void DucktopShell::lock() {
    QMetaObject::invokeMethod(engine.rootObjects()[0], "lock");
}

void DucktopShell::changeOpName(QString name) {
    QMetaObject::invokeMethod(engine.rootObjects()[0], "changeOpName", Q_ARG(QVariant, name));
}

void DucktopShell::refreshBatteryInfo() {
    QVariantMap upower_display = upower_properties->GetAll("org.freedesktop.UPower.Device");
    QMetaObject::invokeMethod(engine.rootObjects()[0], "refreshBatteryInfo", Q_ARG(QVariant, upower_display));
}

void DucktopShell::onUPowerInfoChanged(QString interface, QVariantMap, QStringList) {
    if (interface == "org.freedesktop.UPower.Device") {
        refreshBatteryInfo();
    }
}
