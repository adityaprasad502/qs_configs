import QtQuick
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import Quickshell
import Quickshell.Io

QuickToggleModel {
    id: root
    name: Translation.tr("NextDNS")

    toggled: false
    icon: "shield_lock"

    function notify(msg) {
        Quickshell.execDetached(["notify-send",
            Translation.tr("NextDNS"),
            msg,
            "-a", "Shell"
        ])
    }

    mainAction: () => {
        if (toggled) {
            stopProc.running = true
        } else {
            startProc.running = true
        }
    }

    Process {
        id: startProc
        command: ["nextdns", "start"]
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root.notify(Translation.tr("Failed to start NextDNS. Please inspect manually with the <tt>nextdns</tt> command"))
            }
            statusProc.running = true
        }
    }

    Process {
        id: stopProc
        command: ["nextdns", "stop"]
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root.notify(Translation.tr("Failed to stop NextDNS. Please inspect manually with the <tt>nextdns</tt> command"))
            }
            statusProc.running = true
        }
    }

    // Syncs toggle state and availability. Unavailable when the CLI is missing.
    Process {
        id: statusProc
        running: true
        command: ["bash", "-c", "command -v nextdns >/dev/null 2>&1 && nextdns status"]
        stdout: StdioCollector {
            id: nextDnsStatusCollector
            onStreamFinished: {
                const text = nextDnsStatusCollector.text.trim().toLowerCase();
                if (text.includes("running")) {
                    root.toggled = true;
                } else if (text.includes("stopped")) {
                    root.toggled = false;
                }
            }
        }
        onExited: (exitCode, exitStatus) => {
            root.available = exitCode === 0
        }
    }

    tooltipText: Translation.tr("NextDNS")
}
