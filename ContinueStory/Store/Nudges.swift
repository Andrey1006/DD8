import Foundation
import UserNotifications

enum Nudges {
    private static let ripeTag = "ripe."
    private static let rhythmTag = "rhythm"

    static func ask() async -> Bool {
        let c = UNUserNotificationCenter.current()
        do {
            return try await c.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func status() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    static func arm(for p: Piece) {
        guard p.ripeAt > Date() else { return }
        let body = UNMutableNotificationContent()
        body.title = "Something came back"
        body.body = "A sealed opening is ready. You will not remember writing it."
        body.sound = .default

        let parts = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: p.ripeAt)
        let req = UNNotificationRequest(
            identifier: ripeTag + p.id.uuidString,
            content: body,
            trigger: UNCalendarNotificationTrigger(dateMatching: parts, repeats: false)
        )
        UNUserNotificationCenter.current().add(req)
    }

    static func disarm(_ id: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [ripeTag + id.uuidString])
    }

    static func disarmAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    static func reschedule(rhythm: Rhythm) {
        let c = UNUserNotificationCenter.current()
        c.removePendingNotificationRequests(withIdentifiers: [rhythmTag])
        guard let days = rhythm.days else { return }

        let body = UNMutableNotificationContent()
        body.title = "Two or three sentences"
        body.body = "Start something. You do not have to know where it goes."
        body.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(days) * 86_400, repeats: true)
        c.add(UNNotificationRequest(identifier: rhythmTag, content: body, trigger: trigger))
    }
}
