#include <QApplication>
#include <QDebug>
#include <QDialog>
#include <QString>
#include <QRegExp>
#include <QRegExpValidator>
#include <QLabel>
#include <QLineEdit>
#include <QDialogButtonBox>
#include <QPushButton>
#include <QVBoxLayout>

class InputDialog : public QDialog {
public:
    explicit InputDialog(QWidget *parent=nullptr, Qt::WindowFlags=0);

    void setTitle(const QString &title);
    void setLabelText(const QString &label);
    void setText(const QString &text);
    void setValidator(QValidator *validator);

    QString getLabelText();
    QString getText();

    static QString getText(QWidget *parent, const QString &title,
                           const QString &label, const QString &text,
                           QValidator *validator=nullptr,
                           bool *ok=nullptr, Qt::WindowFlags flags=0);

private:
    void checkValid(const QString &text);

private:
    QLabel *m_label;
    QLineEdit *m_text;
    QDialogButtonBox *m_buttonBox;
    QValidator *m_validator;
};

InputDialog::InputDialog(QWidget *parent, Qt::WindowFlags flags)
    : QDialog(parent),
      m_validator(nullptr)
{
    if (flags != 0)
        setWindowFlags(flags);
    auto l = new QVBoxLayout(this);
    m_label = new QLabel(this);

    m_text = new QLineEdit(this);
    connect(m_text, &QLineEdit::textChanged, this, &InputDialog::checkValid);

    m_buttonBox = new QDialogButtonBox(QDialogButtonBox::Ok |
                                       QDialogButtonBox::Cancel,
                                       Qt::Horizontal, this);
    connect(m_buttonBox, &QDialogButtonBox::accepted,
            this, &InputDialog::accept);
    connect(m_buttonBox, &QDialogButtonBox::rejected,
            this, &InputDialog::reject);

    l->addWidget(m_label);
    l->addWidget(m_text);
    l->addWidget(m_buttonBox);
}

void
InputDialog::setTitle(const QString &title)
{
    setWindowTitle(title);
}
void
InputDialog::setLabelText(const QString &label)
{
    m_label->setText(label);
}
void
InputDialog::setText(const QString &text)
{
    m_text->setText(text);
}
void
InputDialog::setValidator(QValidator *validator)
{
    m_validator = validator;
    m_text->setValidator(validator);
    checkValid(m_text->text());
}
QString
InputDialog::getLabelText()
{
    return m_label->text();
}
QString
InputDialog::getText()
{
    return m_text->text();
}
void
InputDialog::checkValid(const QString &_text)
{
    if (!m_validator)
        return;
    QString text = QString(_text);
    int pos = 0;
    bool valid = (m_validator->validate(text, pos) == QValidator::Acceptable);
    m_buttonBox->button(QDialogButtonBox::Ok)->setEnabled(valid);
}

QString InputDialog::getText(QWidget *parent, const QString &title,
                             const QString &label, const QString &text,
                             QValidator *validator, bool *ok,
                             Qt::WindowFlags flags)
{
    InputDialog *r = new InputDialog(parent, flags);
    r->setTitle(title);
    r->setLabelText(label);
    r->setText(text);
    r->setValidator(validator);
    bool _ok = r->exec() == QDialog::Accepted;
    if (ok) {
        *ok = _ok;
    }
    if (_ok) {
        return r->getText();
    } else {
        return QString();
    }
}
int
main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QRegExp reg("[0-9]{3,}");
    QRegExpValidator validator(reg);
    qDebug() << InputDialog::getText(nullptr, "Title", "Label",
                                     "888", &validator);
    return 0;
}
