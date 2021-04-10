#include "notifications.h"

Notifications::Notifications(DucktopShell *shell, QObject *parent) : QObject(parent)
{
    this->shell = shell;
}

QStringList Notifications::GetCapabilities() {
    QStringList caps = QStringList();
    caps.append("body");
    caps.append("persistence");
    return caps;
}

uint Notifications::Notify(QString app_name, uint replaces_id, QString app_icon, QString summary, QString body, QStringList actions, QVariantMap hints, int expire_timeout) {
    ++currentId;
    if (replaces_id != 0) {
        shell->delnotification(replaces_id);
    }
    shell->notification(summary, body, (replaces_id != 0) ? replaces_id : currentId);
    return (replaces_id != 0) ? replaces_id : currentId;
}

void Notifications::CloseNotification(uint id) {
    shell->delnotification(id);
}

QString Notifications::GetServerInformation(QString &vendor, QString &version, QString &spec_version) {
    vendor = "Erik Inkinen";
    version = "0.0.1";
    spec_version = "1.2";
    return "Ducktop Shell";
}
