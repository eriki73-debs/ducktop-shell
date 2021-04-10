#include "ducktopshell.h"
#include "notifications.h"
#include "hwbuttons.h"
#include <shell_adaptor.h>
#include <notifications_adaptor.h>

int main(int argc, char *argv[])
{
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));

    QGuiApplication app(argc, argv);

    DucktopShell *shellData = new DucktopShell(&app);
    Notifications *notifid = new Notifications(shellData, &app);

    shellData->loadConfig();
    shellData->engine.rootContext()->setContextProperty("shellData", shellData);
    shellData->engine.rootContext()->setContextProperty("shellScaleFactor", qEnvironmentVariableIntValue("QT_SCALE_FACTOR"));

    new ShellAdaptor(shellData);
    new NotificationsAdaptor(notifid);
    QDBusConnection::sessionBus().registerObject("/fi/erikinkinen/ducktop/shell", shellData);
    QDBusConnection::sessionBus().registerService("fi.erikinkinen.ducktop.shell");
    QDBusConnection::sessionBus().registerObject("/org/freedesktop/Notifications", notifid);
    QDBusConnection::sessionBus().registerService("org.freedesktop.Notifications");

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&(shellData->engine), &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    shellData->engine.load(url);

    HWButtons *btns = new HWButtons(shellData);
    app.installEventFilter(btns);

    shellData->execApp("light", QString("-S 100").split(" "));
    shellData->refreshBatteryInfo();

    return app.exec();
}
