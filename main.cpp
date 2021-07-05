#include "ducktopshell.h"
#include "notifications.h"
#include "hwbuttons.h"
#include "backlight.h"
#include "login1_interface.h"
#include <notifications_adaptor.h>
#include <QDBusPendingReply>

int main(int argc, char *argv[])
{
    int shellScaleFactor = qEnvironmentVariable("QT_SCALE_FACTOR", "1").toDouble();
    qunsetenv("QT_SCALE_FACTOR");

    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));

    qApp->setApplicationName("Ducktop Shell");
    qApp->setOrganizationName("Erik Inkinen");

    QGuiApplication app(argc, argv);

    DucktopShell *shellData = new DucktopShell(&app);
    Notifications *notifid = new Notifications(shellData, &app);
    Backlight *backlight = new Backlight();

    org::freedesktop::login1::Manager *loginManager
            = new org::freedesktop::login1::Manager("org.freedesktop.login1", "/org/freedesktop/login1",
                                                                                            QDBusConnection::systemBus());

    QDBusUnixFileDescriptor inhibitDescriptorDBus;
    FILE *inhibitDescriptor = 0;
    QDBusPendingReply<QDBusUnixFileDescriptor> pendingReply = loginManager->Inhibit("handle-power-key", "ducktop-shell", "Handle locking correctly", "block");
    pendingReply.waitForFinished();
    if (pendingReply.isValid()) {
        inhibitDescriptorDBus = pendingReply.value();
        inhibitDescriptor = (FILE *) inhibitDescriptorDBus.fileDescriptor();
        std::cout << inhibitDescriptor;
    }

    shellData->loadConfig();
    shellData->engine.rootContext()->setContextProperty("shellData", shellData);
    shellData->engine.rootContext()->setContextProperty("backlight", backlight);
    shellData->engine.rootContext()->setContextProperty("shellScaleFactor", shellScaleFactor);

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

    backlight->setBrightness(backlight->getMaxBrightness());
    shellData->refreshBatteryInfo();
    shellData->loadAppList();

    return app.exec();

    if (inhibitDescriptor) fclose(inhibitDescriptor);
}
