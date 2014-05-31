#include <QCoreApplication>
#include <QDebug>
#include <QSharedPointer>

struct MyProperty {
    int i;
    int j;
    MyProperty()
    {
        qDebug() << this << "created";
    }
    ~MyProperty()
    {
        qDebug() << this << "destroyed";
    }
};
Q_DECLARE_METATYPE(QSharedPointer<MyProperty>)

int
main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    QObject *obj = new QObject;
    qDebug() << 1;
    obj->setProperty("__my_prop__",
                     QVariant::fromValue(
                         QSharedPointer<MyProperty>(new MyProperty)));
    {
        QSharedPointer<MyProperty> p =
            obj->property("__my_prop__").value<QSharedPointer<MyProperty> >();
        if (p) {
            qDebug("P is NOT NULL");
        }
        qDebug() << 2;
        delete obj;
        qDebug() << 3;
    }
    QSharedPointer<MyProperty> p2(NULL);
    if (!p2) {
        qDebug("P2 is NULL");
    }
    qDebug() << 4;
    return 0;
}
