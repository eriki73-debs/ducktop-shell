#ifndef DUCKTOPSHELL_H
#define DUCKTOPSHELL_H

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QFile>
#include <QJsonDocument>
#include <QQmlContext>
#include <QProcess>
#include <QObject>
#include <QDebug>
#include <QTextCodec>

#include "upower_interface.h"

class DucktopShell : public QObject{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "fi.erikinkinen.ducktop.shell")
private:
    QJsonDocument configJson;
    QByteArray configData;
    QByteArray wsocketname;
    int currentNotificationId = 1;
    org::freedesktop::DBus::Properties *upower_properties;
public:
    QQmlApplicationEngine engine;
    Q_INVOKABLE QByteArray getConfigData();
    Q_INVOKABLE QByteArray getWsocketname();
    Q_INVOKABLE void setWsocketname(QByteArray name);
    bool loadConfig();
    Q_INVOKABLE void execApp(QString command);
    Q_INVOKABLE void lock();
    Q_INVOKABLE void changeOpName(QString name);
    void refreshBatteryInfo();
    void loadAppList();
    DucktopShell (QObject* parent = 0);
public Q_SLOTS:
    void notification(QString title, QString body, int id);
    void delnotification(int id);
    void onUPowerInfoChanged(QString interface, QVariantMap, QStringList);
};

#endif // DUCKTOPSHELL_H
