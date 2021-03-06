/*
 * Copyright: 2013 Canonical, Ltd
 *
 * This file is part of reminders
 *
 * reminders is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * reminders is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors: Michael Zanetti <michael.zanetti@canonical.com>
 */

#ifndef FETCHNOTESJOB_H
#define FETCHNOTESJOB_H

#include "notesstorejob.h"

class FetchNotesJob : public NotesStoreJob
{
    Q_OBJECT
public:
    // Using a chunk size of 50 by default. This seems to be limited to a max of 250 on server side.
    // Using something smaller seems to produce better results.
    // Note: This job does not guarantee to return chunkSize results.
    explicit FetchNotesJob(const QString &filterNotebookGuid = QString(), const QString &searchWords = QString(), int startIndex = 0, int chunkSize = 50, QObject *parent = 0);

    virtual bool operator==(const EvernoteJob *other) const override;
    virtual void attachToDuplicate(const EvernoteJob *other) override;
    virtual QString toString() const override;

signals:
    void jobDone(EvernoteConnection::ErrorCode errorCode, const QString &errorMessage, const evernote::edam::NotesMetadataList &results, const QString &filterNotebookGuid);

protected:
    void startJob();
    void emitJobDone(EvernoteConnection::ErrorCode errorCode, const QString &errorMessage);

private:
    QString m_filterNotebookGuid;
    QString m_searchWords;
    evernote::edam::NotesMetadataList m_results;
    int m_startIndex;
    int m_chunkSize;
};

#endif // FETCHNOTESJOB_H
