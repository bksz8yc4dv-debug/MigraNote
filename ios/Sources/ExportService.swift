import Foundation
import UIKit

enum ExportService {
    static func csv(_ attacks: [MigraineAttack]) -> URL? {
        let header = "Data e ora;Intensità;Durata (minuti);Fattori;Note"
        let rows = attacks.sorted { $0.startedAt < $1.startedAt }.map { item in
            [
                date(item.startedAt),
                item.intensity.map(String.init) ?? "",
                item.durationMinutes.map(String.init) ?? "",
                item.factors.joined(separator: ", "),
                item.notes
            ].map(csvCell).joined(separator: ";")
        }
        return write([header] + rows, name: "MigraNote-esportazione.csv")
    }

    static func pdf(_ attacks: [MigraineAttack]) -> URL? {
        let bounds = CGRect(x: 0, y: 0, width: 595, height: 842)
        let renderer = UIGraphicsPDFRenderer(bounds: bounds)
        let data = renderer.pdfData { context in
            context.beginPage()
            var y: CGFloat =  forty
            let title = "MigraNote — Diario degli attacchi"
            title.draw(at: CGPoint(x: 40, y: y), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 20)])
            y += 42
            let bodyFont = UIFont.systemFont(ofSize: 11)
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineBreakMode = .byWordWrapping
            for item in attacks.sorted(by: { $0.startedAt < $1.startedAt }) {
                let text = """
                \(date(item.startedAt))   •   Intensità: \(item.intensity.map(String.init) ?? "—")/10
                Durata: \(item.durationMinutes.map { "\($0) min" } ?? "—")
                Fattori: \(item.factors.isEmpty ? "Non indicati" : item.factors.joined(separator: ", "))
                Note: \(item.notes.isEmpty ? "—" : item.notes)
                
                """
                let attributes: [NSAttributedString.Key: Any] = [.font: bodyFont, .paragraphStyle: paragraph]
                let rect = CGRect(x: 40, y: y, width: 515, height: 100)
                let height = (text as NSString).boundingRect(with: rect.size, options: [.usesLineFragmentOrigin], attributes: attributes, context: nil).height
                if y + height > 800 {
                    context.beginPage()
                    y = 40
                }
                (text as NSString).draw(in: CGRect(x: 40, y: y, width: 515, height: height + 4), withAttributes: attributes)
                y += height + 12
            }
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("MigraNote-report.pdf")
        do { try data.write(to: url); return url } catch { return nil }
    }

    private static let forty: CGFloat = 40

    private static func date(_ value: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: value)
    }

    private static func csvCell(_ value: String) -> String {
        "\"" + value.replacingOccurrences(of: "\"", with: "\"\"").replacingOccurrences(of: "\n", with: " ") + "\""
    }

    private static func write(_ lines: [String], name: String) -> URL? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        do { try lines.joined(separator: "\n").write(to: url, atomically: true, encoding: .utf8); return url } catch { return nil }
    }
}
