#include "hwbuttons.h"

HWButtons::HWButtons(QObject *parent) : QObject(parent)
{

}

bool HWButtons::eventFilter(QObject *, QEvent *ev)
{
      if (ev->type() == QEvent::KeyPress)
      {
           QKeyEvent* keyEvent = (QKeyEvent*)ev;

           if (keyEvent->key() == Qt::Key_PowerOff)
           {
               ((DucktopShell*)parent())->lock();
               return true;
           }
    }
    return false;
}
