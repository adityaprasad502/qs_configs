import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

StyledPopup {
    id: root
    property string formattedDate: Qt.locale().toString(DateTime.clock.date, "dddd, MMMM dd, yyyy")
    property string formattedTime: DateTime.time
    property string formattedUptime: DateTime.uptime
    property string todosSection: getUpcomingTodos()

    function getUpcomingTodos() {
        const unfinishedTodos = Todo.list.filter(function (item) {
            return !item.done;
        });
        if (unfinishedTodos.length === 0) {
            return Translation.tr("No pending tasks");
        }

        // Limit to first 5 todos to keep popup manageable
        const limitedTodos = unfinishedTodos.slice(0, 5);
        let todoText = limitedTodos.map(function (item, index) {
            return `  ${index + 1}. ${item.content}`;
        }).join('\n');

        if (unfinishedTodos.length > 5) {
            todoText += `\n  ${Translation.tr("... and %1 more").arg(unfinishedTodos.length - 5)}`;
        }

        return todoText;
    }

    Column {
        anchors.centerIn: parent
        spacing: 8

        StyledPopupHeaderRow {
            anchors.horizontalCenter: parent.horizontalCenter
            icon: "calendar_month"
            label: root.formattedDate
        }

        GridLayout {
            columns: 2
            rowSpacing: 5
            columnSpacing: 5
            uniformCellWidths: true

            StatCard {
                symbol: "timelapse"
                title: Translation.tr("System Uptime")
                value: root.formattedUptime
            }

            StatCard {
                symbol: "fact_check"
                title: Translation.tr("Pending Tasks")
                value: {
                    const unfinishedTodos = Todo.list.filter(function (item) {
                        return !item.done;
                    });
                    return unfinishedTodos.length.toString();
                }
            }

            StatCard {
                symbol: TimerService.pomodoroBreak ? "coffee" : "timer"
                title: TimerService.pomodoroBreak ? (TimerService.pomodoroLongBreak ? Translation.tr("Long Break") : Translation.tr("Break")) : Translation.tr("Focus Timer")
                value: {
                    let s = TimerService.pomodoroSecondsLeft;
                    let m = Math.floor(s / 60);
                    let sec = s % 60;
                    let timeString = m.toString().padStart(2, '0') + ":" + sec.toString().padStart(2, '0');
                    if (TimerService.pomodoroRunning) {
                        return timeString;
                    } else if (s === TimerService.pomodoroLapDuration) {
                        return timeString + " " + Translation.tr("(Ready)");
                    } else {
                        return timeString + " " + Translation.tr("(Paused)");
                    }
                }
            }

            StatCard {
                symbol: "timer_10_alt_1"
                title: Translation.tr("Stopwatch")
                value: {
                    let totalSec = Math.floor(TimerService.stopwatchTime / 100);
                    let m = Math.floor(totalSec / 60);
                    let s = totalSec % 60;
                    let ms = TimerService.stopwatchTime % 100;
                    let timeString = m.toString().padStart(2, '0') + ":" + s.toString().padStart(2, '0') + "." + ms.toString().padStart(2, '0');
                    return timeString;
                }
            }
        }

        Rectangle {
            width: parent.width
            height: todoTextItem.implicitHeight + 16
            radius: Appearance.rounding.small
            color: Appearance.colors.colSurfaceContainerHigh

            StyledText {
                id: todoTextItem
                anchors.fill: parent
                anchors.margins: 8
                horizontalAlignment: Text.AlignLeft
                wrapMode: Text.Wrap
                color: Appearance.colors.colOnSurfaceVariant
                font.pixelSize: Appearance.font.pixelSize.small
                text: root.todosSection
            }
        }
    }
}
