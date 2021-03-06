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

#include "userstore.h"
#include "evernoteconnection.h"
#include "jobs/fetchusernamejob.h"
#include "logging.h"

// Evernote sdk
#include <UserStore.h>
#include <UserStore_constants.h>
#include <Errors_types.h>

// Thrift
#include <arpa/inet.h> // seems thrift forgot this one
#include <protocol/TBinaryProtocol.h>
#include <transport/THttpClient.h>
#include <transport/TSSLSocket.h>
#include <Thrift.h>

using namespace apache::thrift;
using namespace apache::thrift::protocol;
using namespace apache::thrift::transport;

UserStore* UserStore::s_instance = 0;

UserStore::UserStore(QObject *parent) :
    QObject(parent),
    m_userId(-1)
{
    connect(EvernoteConnection::instance(), &EvernoteConnection::isConnectedChanged, this, &UserStore::fetchUsername);

    fetchUsername();
}

UserStore *UserStore::instance()
{
    if (!s_instance) {
        s_instance = new UserStore();
    }
    return s_instance;
}

qint32 UserStore::userId() const
{
    return m_userId;
}
QString UserStore::userName() const
{
    return m_userName;
}

void UserStore::fetchUsername()
{
    if (EvernoteConnection::instance()->isConnected()) {
        FetchUsernameJob *job = new FetchUsernameJob();
        connect(job, &FetchUsernameJob::jobDone, this, &UserStore::fetchUsernameJobDone);
        EvernoteConnection::instance()->enqueue(job);
    } else {
        m_userId = -1;
        m_userName.clear();
        emit userChanged();
    }
}

void UserStore::fetchUsernameJobDone(EvernoteConnection::ErrorCode errorCode, const QString &errorMessage, const int userId, const QString &userName)
{
    if (errorCode != EvernoteConnection::ErrorCodeNoError) {
        qCWarning(dcConnection) << "Error fetching username:" << errorMessage;
        return;
    }

    qCDebug(dcConnection) << "FetchUsername done. User ID:" << userId << "User name:" << userName;
    m_userId = userId;
    m_userName = userName;
    emit userChanged();
}
