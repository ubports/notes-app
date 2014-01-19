/*
 * Copyright: 2013 Canonical, Ltd
 *
 * This file is part of reminders-app
 *
 * reminders-app is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * reminders-app is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors: Michael Zanetti <michael.zanetti@canonical.com>
 */

#ifndef NOTESSTORE_H
#define NOTESSTORE_H

#include "evernoteconnection.h"
#include "utils/enmldocument.h"

// Thrift
#include <arpa/inet.h> // seems thrift forgot this one
#include <protocol/TBinaryProtocol.h>
#include <transport/THttpClient.h>
#include <transport/TSSLSocket.h>
#include <Thrift.h>

// Evernote SDK
#include <NoteStore.h>
#include <NoteStore_constants.h>
#include <Errors_types.h>

#include <QAbstractListModel>
#include <QHash>

class Notebook;
class Note;

using namespace apache::thrift::transport;

class NotesStore : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        RoleGuid,
        RoleNotebookGuid,
        RoleCreated,
        RoleTitle,
        RoleReminder,
        RoleReminderTime,
        RoleReminderDone,
        RoleReminderDoneTime,
        RoleIsSearchResult,
        RoleEnmlContent,
        RoleHtmlContent,
        RoleRichTextContent,
        RolePlaintextContent,
        RoleResources
    };

    ~NotesStore();
    static NotesStore *instance();

    // reimplemented from QAbstractListModel
    int rowCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;
    QHash<int, QByteArray> roleNames() const;

    QList<Note*> notes() const;

    Q_INVOKABLE Note* note(const QString &guid);
    Q_INVOKABLE void createNote(const QString &title, const QString &notebookGuid, const QString &richTextContent);
    void createNote(const QString &title, const QString &notebookGuid, const EnmlDocument &content);
    Q_INVOKABLE void saveNote(const QString &guid);
    Q_INVOKABLE void deleteNote(const QString &guid);
    Q_INVOKABLE void findNotes(const QString &searchWords);

    QList<Notebook*> notebooks() const;
    Notebook* notebook(const QString &guid);
    Q_INVOKABLE void createNotebook(const QString &name);
    Q_INVOKABLE void expungeNotebook(const QString &guid);

public slots:
    void refreshNotes(const QString &filterNotebookGuid = QString());
    void refreshNoteContent(const QString &guid);
    void refreshNotebooks();

signals:
    void tokenChanged();

    void noteAdded(const QString &guid, const QString &notebookGuid);
    void noteChanged(const QString &guid, const QString &notebookGuid);
    void noteRemoved(const QString &guid, const QString &notebookGuid);

    void notebookAdded(const QString &guid);
    void notebookChanged(const QString &guid);
    void notebookRemoved(const QString &guid);

private slots:
    void fetchNotesJobDone(EvernoteConnection::ErrorCode errorCode, const QString &errorMessage, const evernote::edam::NotesMetadataList &results);
    void fetchNotebooksJobDone(EvernoteConnection::ErrorCode errorCode, const QString &errorMessage, const std::vector<evernote::edam::Notebook> &results);
    void fetchNoteJobDone(EvernoteConnection::ErrorCode errorCode, const QString &errorMessage, const evernote::edam::Note &result);
    void createNoteJobDone(EvernoteConnection::ErrorCode errorCode, const QString &errorMessage, const evernote::edam::Note &result);
    void saveNoteJobDone(EvernoteConnection::ErrorCode errorCode, const QString &errorMessage, const evernote::edam::Note &result);
    void deleteNoteJobDone(EvernoteConnection::ErrorCode errorCode, const QString &errorMessage, const QString &guid);
    void createNotebookJobDone(EvernoteConnection::ErrorCode errorCode, const QString &errorMessage, const evernote::edam::Notebook &result);
    void expungeNotebookJobDone(EvernoteConnection::ErrorCode errorCode, const QString &errorMessage, const QString &guid);

private:
    explicit NotesStore(QObject *parent = 0);
    static NotesStore *s_instance;

    QList<Note*> m_notes;
    QList<Notebook*> m_notebooks;

    // Keep hashes for faster lookups as we always identify notes via guid
    QHash<QString, Note*> m_notesHash;
    QHash<QString, Notebook*> m_notebooksHash;
};

#endif // NOTESSTORE_H