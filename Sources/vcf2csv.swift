// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Contacts
import Foundation
import UniformTypeIdentifiers

@main
struct vcf2csv: ParsableCommand {
    @Argument(
        help: "CSVに変換したいvCardファイルを指定してください。",
        transform: { arg in
            URL(filePath: NSString(string: arg).expandingTildeInPath)
        }
    )
    var input: URL
    
    @Argument(
        help: "CSVファイルの出力先を指定してください。",
        transform: { arg in
            let fm = FileManager.default
            let url = URL(filePath: NSString(string: arg).expandingTildeInPath)
            if !fm.fileExists(atPath: url.path(percentEncoded: false)) {
                return url
            }
            
            let dir = url.deletingLastPathComponent()
            let baseName = url.deletingPathExtension().lastPathComponent
            let ext = UTType(filenameExtension: url.pathExtension) ?? .delimitedText
            
            var i = 1
            while true {
                let candidate = dir.appendingPathComponent("\(baseName) \(i)", conformingTo: ext)
                
                if !fm.fileExists(atPath: candidate.path(percentEncoded: false)) {
                    return candidate
                }
                
                i += 1
            }
        }
    )
    var output: URL
    
    mutating func run() throws {
        do {
            let vCardData = try Data(contentsOf: input)
            let contacts = try CNContactVCardSerialization.contacts(with: vCardData)
            
            var lines = [String]()
            // ヘッダー行を追加
            lines.append(CSVHeader.allCases.map(\.rawValue).map(csvCell).joined(separator: ","))
            
            // 連絡先レコードを追加
            for c in contacts {
                let cols = row(for: c).map(csvCell).joined(separator: ",")
                lines.append(cols)
            }
            
            let csv = lines.joined(separator: "\n")
            try csv.data(using: .utf8)?.write(to: output)
            
            print("OK: \(contacts.count) contact(s) -> \(output)")
        } catch {
            fputs("Error: \(error)\n", stderr)
        }
    }
}

enum CSVHeader: String, CaseIterable {
    // 姓
    case familyName
    // 名
    case givenName
    // 電話番号
    case phone
    // メールアドレス
    case email
    // 会社名
    case organization
    // 役職
    case role
}

// RFC4180に準拠するよう文字列をフォーマットする
// - 文字列中に`"`がある場合は`""`に置き換えて内部のクオートをエスケープする
// - 文字列中に`,`や`\n`がある場合は文字列全体を`"`で囲う
func csvCell(_ string: String) -> String {
    let escaped = string.replacingOccurrences(of: "\"", with: "\"\"")
    return "\"\(escaped)\""
}

// CSVレコードに変換
func row(for contact: CNContact) -> [String] {
    let phone = contact.phoneNumbers.map { $0.value.stringValue }.joined(separator: "; ")
//    let phoneWithLabel = contact.phoneNumbers.map { lv in
//        let label = if let lvLabel = lv.label {
//            CNLabeledValue<NSString>.localizedString(forLabel: lvLabel)
//        } else {
//            ""
//        }
//        let num = lv.value.stringValue
//        
//        return label.isEmpty ? num : "\(label):\(num)"
//    }.joined(separator: "; ")
    
    let email = contact.emailAddresses.map { String($0.value) }.joined(separator: "; ")
//    let emailWithLabel = contact.emailAddresses.map { lv in
//        let label = if let lvLabel = lv.label {
//            CNLabeledValue<NSString>.localizedString(forLabel: lvLabel)
//        } else {
//            ""
//        }
//        let addr = String(lv.value)
//        
//        return label.isEmpty ? addr : "\(label):\(addr)"
//    }.joined(separator: "; ")
    
    return [
        contact.familyName,
        contact.givenName,
        phone,
        email,
        contact.organizationName,
        contact.jobTitle,
    ]
}
