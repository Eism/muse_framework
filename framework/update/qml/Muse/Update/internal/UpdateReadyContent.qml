/*
 * SPDX-License-Identifier: GPL-3.0-only
 * MuseScore-Studio-CLA-applies
 *
 * MuseScore Studio
 * Music Composition & Notation
 *
 * Copyright (C) 2026 MuseScore Limited and others
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
import QtQuick
import QtQuick.Layouts

import Muse.Ui
import Muse.UiComponents

ColumnLayout {
    id: root

    property string updateVersion: ""

    signal installRequested()

    spacing: 8

    StyledTextLabel {
        Layout.fillWidth: true

        horizontalAlignment: Text.AlignLeft
        wrapMode: Text.WordWrap

        text: root.updateVersion.length > 0
              ? qsTrc("update", "Update to version %1 is ready").arg(root.updateVersion)
              : qsTrc("update", "An update is ready")
    }

    FlatButton {
        Layout.fillWidth: true

        text: qsTrc("update", "Update")
        accentButton: true

        onClicked: {
            root.installRequested()
        }
    }
}
