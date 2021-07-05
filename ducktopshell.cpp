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

void DucktopShell::execApp(QString command)
{
    qputenv("QT_QPA_PLATFORM", QByteArray("wayland"));
    qunsetenv("QT_IM_MODULE");
    qunsetenv("QT_QPA_GENERIC_PLUGINS");
    qputenv("QT_SCALE_FACTOR", this->engine.rootContext()->contextProperty("shellScaleFactor").toString().toUtf8());
    qputenv("WAYLAND_DISPLAY", wsocketname);
    QStringList args = QStringList();
    args.append("-c");
    args.append(command);
    if (!QProcess::startDetached("bash", args))
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

void DucktopShell::loadAppList() {
    QString xdgDataDirs = QTextCodec::codecForMib(106)->toUnicode(qgetenv("XDG_DATA_DIRS"));
    QStringList dataDirList = xdgDataDirs.split(':');
    for (int dirI = 0; dirI < dataDirList.count(); dirI++) {
        QDir *curAppDir = new QDir(dataDirList.at(dirI) + "/applications");
        if (curAppDir->exists()) {
            QStringList entryFiles = curAppDir->entryList(QDir::Files);
            for (int fileI = 0; fileI < entryFiles.count(); fileI++) {
                QString curEntryFileName = entryFiles.at(fileI);
                QSettings *curEntryFile = new QSettings(dataDirList.at(dirI) + "/applications/" + curEntryFileName, QSettings::IniFormat);
                QString desktopType = curEntryFile->value("Desktop Entry/Type").toString();
                if (desktopType == "Application") {
                    QString appName = curEntryFile->value("Desktop Entry/Name").toString();
                    QString appHidden = curEntryFile->value("Desktop Entry/Hidden").toString();
                    QString appNoDisplay = curEntryFile->value("Desktop Entry/NoDisplay").toString();
                    QString appExec = curEntryFile->value("Desktop Entry/Exec").toString();
                    QString appIcon = curEntryFile->value("Desktop Entry/Icon").toString();
                    if (appName != "" && appExec != "" && appHidden != "true" && appNoDisplay != "true")
                        QMetaObject::invokeMethod(engine.rootObjects()[0], "addApp", Q_ARG(QVariant, appName), Q_ARG(QVariant, appExec), Q_ARG(QVariant, appIcon));
                }
                delete curEntryFile;
            }
        }
        delete curAppDir;
    }
}
