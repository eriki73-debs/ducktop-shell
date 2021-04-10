#ifndef NOTIFICATIONS_H
#define NOTIFICATIONS_H

#include <QObject>
#include <QMap>

#include "ducktopshell.h"

class Notifications : public QObject
{
    Q_OBJECT
private:
    int currentId = 0;
    DucktopShell *shell;
public:
    explicit Notifications(DucktopShell *shell, QObject *parent = nullptr);
public Q_SLOTS:
    QStringList GetCapabilities();
    uint Notify(QString app_name, uint replaces_id, QString app_icon, QString summary, QString body, QStringList actions, QVariantMap hints, int expire_timeout);
    void CloseNotification(uint id);
    QString GetServerInformation(QString &vendor, QString &version, QString &spec_version);
signals:

};

#endif // NOTIFICATIONS_H
