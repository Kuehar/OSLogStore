//
//  ContentView.swift
//  OSLogStore
//
//  Created by kuehar on 2023/10/14.
//

import SwiftUI
import OSLog

struct ContentView: View {
    @State private var messages:String = ""
    @State private var isLogSendAlertDisplay = false
    
    var body: some View {
        Form {
            Section(header: Text("報告")) {
                Button(action: {
                    exportToLogFile()
                    isLogSendAlertDisplay = true
                }, label: {
                    Text("アプリがクラッシュしたことを報告する")
                })
                .alert("通知", isPresented:$isLogSendAlertDisplay) {
                    Button("OK") {
                        // ログ送付処理をここに書く
                        isLogSendAlertDisplay = false
                    }
                    Button("Cancel",role:.cancel){}
                } message: {
                    Text("クラッシュしたことを開発者に報告します。よろしいですか？")
                }
            }
        }
    }
    func exportToLogFile() {
        do {
            let store = try OSLogStore(scope: .currentProcessIdentifier)
            let position = store.position(date: Date().addingTimeInterval(-3600))
            let enumerator = try store.__entriesEnumerator(options: [.reverse], position: position, predicate: nil)
            
            var logString = ""
            messages = ""
            enumerator.forEach { element in
                if let message = (element as? OSLogEntry)?.composedMessage {
                    logString += message + "\n"
                    messages += message + "\n"
                }
            }
            
            // ドキュメントディレクトリのパスを取得
            if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let logURL = documentDirectory.appendingPathComponent("logs.txt")
                try logString.write(to: logURL, atomically: true, encoding: .utf8)
                print("Logs exported to: \(logURL)")
            }
        } catch {
            print("Error exporting logs: \(error)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
