# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Copyright (C) 2014 Canonical Ltd
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

from reminders import credentials, evernote, tests


class RemindersTestCaseWithAccount(tests.RemindersAppTestCase):

    def setUp(self):
        super(RemindersTestCaseWithAccount, self).setUp()
        no_account_dialog = self.app.main_view.no_account_dialog
        self.add_evernote_account()
        no_account_dialog.wait_until_destroyed()
        self.evernote_client = evernote.SandboxEvernoteClient()

    def add_evernote_account(self):
        account_manager = credentials.AccountManager()
        account = account_manager.add_evernote_account(
            'dummy', 'dummy', evernote.TEST_OAUTH_TOKEN)
        self.addCleanup(account_manager.delete_account, account)
        del account_manager._manager
        del account_manager

    def test1(self):
        pass

    def test2(self):
        pass
