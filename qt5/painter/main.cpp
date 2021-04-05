#include <QApplication>
#include <QDebug>
#include <QPainter>
#include <QPainterPath>
#include <QWidget>

void buildSplitPath(const QRectF &r, double radius, double pixelRatio,
                    QPainterPath &tl, QPainterPath &br)
{
    double xd = r.x() + 0.5 / pixelRatio;
    double yd = r.y() + 0.5 / pixelRatio;
    double diameter = radius * 2;
    bool rounded = diameter > 0.0;
    double width = r.width() - 1 / pixelRatio;
    double height = r.height() - 1 / pixelRatio;

    if (rounded) {
        printf("1\n");
        tl.arcMoveTo(xd + width - diameter, yd, diameter, diameter, 45);
        tl.arcTo(xd + width - diameter, yd, diameter, diameter, 45, 45);
        if (width > diameter) {
            printf("2\n");
            tl.lineTo(xd + width - diameter, yd);
        }
    } else {
        printf("3\n");
        tl.moveTo(xd + width, yd);
    }

    if (rounded) {
        printf("4\n");
        tl.arcTo(xd, yd, diameter, diameter, 90, 90);
    } else {
        printf("5\n");
        tl.lineTo(xd, yd);
    }

    if (rounded) {
        printf("6\n");
        tl.arcTo(xd, yd + height - diameter, diameter, diameter, 180, 45);
        br.arcMoveTo(xd, yd + height - diameter, diameter, diameter, 180 + 45);
        br.arcTo(xd, yd + height - diameter, diameter, diameter, 180 + 45, 45);
    } else {
        printf("7\n");
        tl.lineTo(xd, yd + height);
        br.moveTo(xd, yd + height);
    }

    if (rounded) {
        printf("8\n");
        br.arcTo(xd + width - diameter, yd + height - diameter, diameter,
                 diameter, 270, 90);
    } else {
        printf("9\n");
        br.lineTo(xd + width, yd + height);
    }

    if (rounded) {
        printf("10\n");
        br.arcTo(xd + width - diameter, yd, diameter, diameter, 0, 45);
    } else {
        printf("11\n");
        br.lineTo(xd + width, yd);
    }
    qDebug() << __func__ << br << tl;
}

class RenderArea : public QWidget {
public:
    explicit RenderArea(QWidget *parent = nullptr)
        : QWidget(parent)
    {}

    QSize minimumSizeHint() const override
    {
        return QSize(100, 100);
    }

    QSize sizeHint() const override
    {
        return QSize(100, 100);
    }

private:
    void paintEvent(QPaintEvent *event) override;
};

void RenderArea::paintEvent(QPaintEvent*)
{
    double pixelRatio = devicePixelRatioF();

    QPainter painter(this);
    painter.setRenderHint(QPainter::Antialiasing, true);
    painter.setBrush(Qt::NoBrush);
    painter.setPen(QPen(Qt::black, 1 / pixelRatio));

    QPainterPath path;
    path.moveTo(10 + 0.5 / pixelRatio, 10 + 0.5 / pixelRatio);
    path.lineTo(90 + 0.5 / pixelRatio, 10 + 0.5 / pixelRatio);
    painter.drawPath(path);

    QPainterPath path1;
    QPainterPath path2;
    buildSplitPath(QRectF(0, 0, 100, 100), 5, pixelRatio, path1, path2);

    painter.setPen(QPen(Qt::red, 1 / pixelRatio));
    painter.drawPath(path1);
    painter.setPen(QPen(Qt::blue, 1 / pixelRatio));
    painter.drawPath(path2);
}

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    RenderArea area;
    area.show();
    app.exec();
    return 0;
}
