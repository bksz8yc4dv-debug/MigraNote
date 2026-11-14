import Foundation
import UIKit

enum PDFExportService {
    static func createReport(attacks: [Attack], customFieldNames: [String] = []) throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("MigraNote-Report.pdf")
        let page = CGRect(x: 0, y: 0, width: 595, height: 842)
        let renderer = UIGraphicsPDFRenderer(bounds: page)
        try renderer.writePDF(to: url) { rendererContext in
            rendererContext.beginPage()
            var y: CGFloat = 48
            let left: CGFloat = 44
            let width: CGFloat = page.width - 88

            func addText(_ text: String, font: UIFont, color: UIColor = .darkText, gap: CGFloat = 8) {
                let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
                let bounds = (text as NSString).boundingRect(
                    with: CGSize(width: width, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attributes,
                    context: nil
                )
                let height = max(bounds.height, font.lineHeight)
                if y + height + gap > page.height - 42 {
                    rendererContext.beginPage()
                    y = 48
                }
                (text as NSString).draw(
                    in: CGRect(x: left, y: y, width: width, height: height + 2),
                    withAttributes: attributes
                )
                y += height + gap
            }

            addText("MigraNote", font: .boldSystemFont(ofSize: 25), color: .systemPurple, gap: 4)
            addText("Report del diario dell’emicrania", font: .systemFont(ofSize: 13), color: .secondaryLabel)
            addText("Esportato il \(Date.now.formatted(date: .long, time: .shortened))", font: .systemFont(ofSize: 10), color: .secondaryLabel, gap: 18)
            addText("Totale registrazioni: \(attacks.count)", font: .boldSystemFont(ofSize: 14), gap: 5)
            let intensities = attacks.compactMap(\.intensity)
            if !intensities.isEmpty {
                let average = Double(intensities.reduce(0, +)) / Double(intensities.count)
                addText(String(format: "Intensità media registrata: %.1f / 10", average), font: .systemFont(ofSize: 11), gap: 14)
            } else {
                y += 10
            }

            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "it_IT")
            formatter.dateStyle = .long
            formatter.timeStyle = .short

            for (index, attack) in attacks.sorted(by: { $0.timestamp < $1.timestamp }).enumerated() {
                addText("\(index + 1). \(formatter.string(from: attack.timestamp))", font: .boldSystemFont(ofSize: 12), color: .systemPurple, gap: 3)
                addText("Intensità: \(attack.intensity.map { "\($0)/10" } ?? "non indicata")  •  Durata: \(attack.duration ?? "non indicata")", font: .systemFont(ofSize: 10), gap: 3)
                if !attack.factors.isEmpty {
                    addText("Fattori: \(attack.factors.joined(separator: ", "))", font: .systemFont(ofSize: 10), gap: 3)
                }
                let customData = Data(attack.customFieldValuesJSON.utf8)
                let customValues = (try? JSONDecoder().decode([String: String].self, from: customData)) ?? [:]
                for field in customFieldNames {
                    if let value = customValues[field], !value.isEmpty {
                        addText("\(field): \(value)", font: .systemFont(ofSize: 10), gap: 3)
                    }
                }
                if !attack.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    addText("Note: \(attack.notes)", font: .systemFont(ofSize: 10), gap: 10)
                } else {
                    y += 7
                }
            }
            addText("Questo documento riporta esclusivamente le informazioni inserite dall’utente e non costituisce una valutazione medica.", font: .italicSystemFont(ofSize: 9), color: .secondaryLabel, gap: 0)
        }
        return url
    }
}
