#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QDebug>

int
main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QQmlApplicationEngine engine("main.qml");
    QObject *topLevel = engine.rootObjects().value(0);
    QQuickWindow *window = qobject_cast<QQuickWindow *>(topLevel);
    window->show();
    return app.exec();
}
