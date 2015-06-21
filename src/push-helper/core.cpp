#include "core.h"

#include "evernoteconnection.h"
#include "notesstore.h"
#include "note.h"

#include <Accounts/Manager>
#include <Accounts/AccountService>

#include <QDebug>
#include <QOrganizerEvent>
#include <QStandardPaths>
#include <QJsonDocument>

Core::Core(QObject *parent):
    QObject(parent)
{
    connect(EvernoteConnection::instance(), &EvernoteConnection::isConnectedChanged, this, &Core::connectedChanged);
    connect(NotesStore::instance(), &NotesStore::loadingChanged, this, &Core::notesLoaded);
}

bool Core::process(const QByteArray &pushNotification)
{
    qDebug() << "should process:" << pushNotification;

    QJsonParseError error;
    QJsonDocument jsonDoc = QJsonDocument::fromJson(pushNotification, &error);
    if (error.error != QJsonParseError::NoError) {
        qDebug() << "Error parsing notification json:" << error.errorString();
        return false;
    }
    QVariantMap notification = jsonDoc.toVariant().toMap().value("payload").toMap();

    QSettings settings(QStandardPaths::standardLocations(QStandardPaths::ConfigLocation).first() + "/com.ubuntu.reminders/reminders.conf", QSettings::IniFormat);
    settings.beginGroup("accounts");
    QString token = settings.value(notification.value("userId").toString()).toString();
    settings.endGroup();

    if (token.isEmpty()) {
        qDebug() << "No token found for this userId in " + settings.fileName() + ". Discarding push notification...";
        return false;
    }

    EvernoteConnection::instance()->setToken(token);
    EvernoteConnection::instance()->setHostname("www.evernote.com");
    EvernoteConnection::instance()->connectToEvernote();

    return true;
}

void Core::connectedChanged()
{
    if (!EvernoteConnection::instance()->isConnected()) {
        qWarning() << "Disconnected from Evernote.";
        return;
    }

    qDebug() << "Connected to Evernote.";
}

void Core::notesLoaded()
{
    qDebug() << "notes loading changed:" << NotesStore::instance()->loading();
}

