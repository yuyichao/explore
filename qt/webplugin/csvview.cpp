/****************************************************************************
 **
 ** Copyright (C) 2008 Nokia Corporation and/or its subsidiary(-ies).
 ** Contact: Qt Software Information (qt-info@nokia.com)
 **
 ** This file is part of the documentation of Qt. It was originally
 ** published as part of Qt Quarterly.
 **
 ** Commercial Usage
 ** Licensees holding valid Qt Commercial licenses may use this file in
 ** accordance with the Qt Commercial License Agreement provided with the
 ** Software or, alternatively, in accordance with the terms contained in
 ** a written agreement between you and Nokia.
 **
 **
 ** GNU General Public License Usage
 ** Alternatively, this file may be used under the terms of the GNU
 ** General Public License versions 2.0 or 3.0 as published by the Free
 ** Software Foundation and appearing in the file LICENSE.GPL included in
 ** the packaging of this file.  Please review the following information
 ** to ensure GNU General Public Licensing requirements will be met:
 ** http://www.fsf.org/licensing/licenses/info/GPLv2.html and
 ** http://www.gnu.org/copyleft/gpl.html.  In addition, as a special
 ** exception, Nokia gives you certain additional rights. These rights
 ** are described in the Nokia Qt GPL Exception version 1.3, included in
 ** the file GPL_EXCEPTION.txt in this package.
 **
 ** Qt for Windows(R) Licensees
 ** As a special exception, Nokia, as the sole copyright holder for Qt
 ** Designer, grants users of the Qt/Eclipse Integration plug-in the
 ** right for the Qt/Eclipse Integration to link to functionality
 ** provided by Qt Designer and its related libraries.
 **
 ** If you are unsure which license is appropriate for your use, please
 ** contact the sales department at qt-sales@nokia.com.
 **
 ****************************************************************************/

#include <QtGui>
#include <QtNetwork>
#include "csvview.h"

CSVView::CSVView(const QString &mimeType, const QString &related,
                 QWidget *parent)
    : QTableView(parent)
{
    this->mimeType = mimeType;
    this->related = related;

    setEditTriggers(NoEditTriggers);
    setSelectionBehavior(SelectRows);
    setSelectionMode(SingleSelection);
}

void CSVView::updateModel()
{
    QNetworkReply *reply = static_cast<QNetworkReply *>(sender());

    if (reply->error() != QNetworkReply::NoError)
        return;

    bool hasHeader = false;
    QString charset = "latin1";

    foreach (QString piece, mimeType.split(";")) {
        piece = piece.trimmed();
        if (piece.contains("=")) {
            int index = piece.indexOf("=");
            QString left = piece.left(index).trimmed();
            QString right = piece.mid(index + 1).trimmed();
            if (left == "header")
                hasHeader = (right == "present");
            else if (left == "charset")
                charset = right;
        }
    }

    QTextStream stream(reply);
    stream.setCodec(QTextCodec::codecForName(charset.toLatin1()));

    QStandardItemModel *model = new QStandardItemModel(this);
    QList<QStandardItem *> items;
    bool firstLine = hasHeader;
    bool wasQuote = false;
    bool wasCR = false;
    bool quoted = false;
    QString text;

    while (!stream.atEnd()) {
        QString ch = stream.read(1);
        if (wasQuote) {
            if (ch == "\"") {
                if (quoted) {
                    text += ch;         // quoted "" are inserted as "
                    wasQuote = false;   // no quotes are pending
                } else {
                    quoted = true;      // unquoted "" starts quoting
                    wasQuote = true;    // with a pending quote
                }
                continue;               // process the next character

            } else {
                quoted = !quoted;       // process the pending quote
                wasQuote = false;       // no quotes are pending
            }                           // process the current character

        } else if (wasCR) {
            wasCR = false;

            if (ch == "\n") {           // CR LF represents the end of a row
                if (!text.isEmpty())
                    items.append(new QStandardItem(QString(text)));

                addRow(firstLine, model, items);
                items.clear();
                text = "";
                firstLine = false;
                continue;               // process the next character
            } else
                text += "\r";           // CR on its own is inserted
        }                               // process the current character

        // wasQuote is never true here.
        // wasCR is never true here.

        if (ch == "\"")
            wasQuote = true;            // handle the pending quote later

        else if (ch == ",") {
            if (quoted)
                text += ch;
            else {
                items.append(new QStandardItem(QString(text)));
                text = "";
            }
        }

        else if (ch == "\r") {
            if (!quoted)
                wasCR = true;
            else
                text += ch;
        }

        else if (ch == "\n")
            text += ch;
        else
            text += ch;

    }

    if (items.count() > 0)
        addRow(firstLine, model, items);

    reply->close();

    setModel(model);

    connect(selectionModel(),
            SIGNAL(currentChanged(const QModelIndex &, const QModelIndex &)),
            this, SLOT(exportRow(const QModelIndex &)));

    resizeColumnsToContents();
    horizontalHeader()->setStretchLastSection(true);
}

void CSVView::addRow(bool firstLine, QStandardItemModel *model,
                     const QList<QStandardItem *> &items)
{
    if (firstLine) {
        for (int j = 0; j < items.count(); ++j)
            model->setHorizontalHeaderItem(j, items[j]);
    } else
        model->appendRow(items);
}

void CSVView::exportRow(const QModelIndex &current)
{
    QString name = model()->index(current.row(), 0).data().toString();
    QString address = model()->index(current.row(), 1).data().toString();
    QString quantity = model()->index(current.row(), 2).data().toString();

    emit rowSelected(related, name, address, quantity);
}
