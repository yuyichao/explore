#include <QApplication>
#include <QMainWindow>
#include <QGLWidget>

int
main(int argc, char **argv)
{
    QApplication app(argc, argv);
    QMainWindow mw;
    // always work without this (next) line
    mw.setAttribute(Qt::WA_TranslucentBackground);
    // no error if there isn't a widget in between
    QWidget *parentWidget = new QWidget(&mw);
    // parentWidget->setAttribute(Qt::WA_TranslucentBackground);
    // QWidget *w = new QWidget(parentWidget); // This line works
    // but the following line generates xcb error like
    // QXcbConnection: XCB error: 8 (BadMatch), sequence: ..., resource id: ..,
    // major code: 130 (Unknown), minor code: 3
    // where ... represent runtime dependent numbers
    QWidget *w = new QGLWidget(parentWidget);
    Q_UNUSED(w);
    mw.setCentralWidget(parentWidget);
    mw.show();
    return app.exec();
}
