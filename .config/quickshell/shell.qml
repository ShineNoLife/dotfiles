import Quickshell
import "windows" as Windows

ShellRoot {
    id: root

    Variants {
        model: Quickshell.screens

        Windows.BarSurface {
            required property ShellScreen modelData
            screen: modelData
        }
    }

    Variants {
        model: Quickshell.screens

        Windows.OverlaySurface {
            required property ShellScreen modelData
            screen: modelData
        }
    }
}
