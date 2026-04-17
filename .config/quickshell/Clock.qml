// Clock.qml
pragma Singleton

import Quickshell
import QtQuick

Singleton {
  id: root
  readonly property string time: {
    Qt.formatDateTime(clock.date, "hh:mm dddd, MMMM d")
  }

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }
}
