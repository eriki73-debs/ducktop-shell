#ifndef BACKLIGHT_H
#define BACKLIGHT_H

#include <QDebug>
#include <libudev.h>
#include <iostream>

class Backlight : public QObject
{
    Q_OBJECT
private:
    struct udev *udevInstance;
    struct udev_enumerate *udevEnumerator;
    struct udev_list_entry *udevEntry;
    struct udev_device *udevDevice;
    int maxBrightness;
public:
    Backlight();
    Q_INVOKABLE int getMaxBrightness();
    Q_INVOKABLE int getBrightness();
    Q_INVOKABLE int setBrightness(int value);
};

#endif // BACKLIGHT_H
