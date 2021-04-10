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

class DucktopShell : public QObject{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "fi.erikinkinen.ducktop.shell")
private:
    QJsonDocument configJson;
    QByteArray configData;
    QByteArray wsocketname;
    int currentNotificationId = 1;

public:
    QQmlApplicationEngine engine;
    Q_INVOKABLE QByteArray getConfigData();
    Q_INVOKABLE QByteArray getWsocketname();
    Q_INVOKABLE void setWsocketname(QByteArray name);
    bool loadConfig();
    Q_INVOKABLE void execApp(QString program, QStringList args);
    Q_INVOKABLE void lock();
    Q_INVOKABLE void changeOpName(QString name);
    explicit DucktopShell (QObject* parent = 0) : QObject(parent) {}
public Q_SLOTS:
    void notification(QString title, QString body, int id);
    void delnotification(int id);
};

#endif // DUCKTOPSHELL_H
