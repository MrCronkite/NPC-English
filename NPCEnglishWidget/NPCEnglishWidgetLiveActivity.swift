//
//  NPCEnglishWidgetLiveActivity.swift
//  NPCEnglishWidget
//
//  Created by Влад Шимченко on 02.08.2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct NPCEnglishWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct NPCEnglishWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NPCEnglishWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension NPCEnglishWidgetAttributes {
    fileprivate static var preview: NPCEnglishWidgetAttributes {
        NPCEnglishWidgetAttributes(name: "World")
    }
}

extension NPCEnglishWidgetAttributes.ContentState {
    fileprivate static var smiley: NPCEnglishWidgetAttributes.ContentState {
        NPCEnglishWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: NPCEnglishWidgetAttributes.ContentState {
         NPCEnglishWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: NPCEnglishWidgetAttributes.preview) {
   NPCEnglishWidgetLiveActivity()
} contentStates: {
    NPCEnglishWidgetAttributes.ContentState.smiley
    NPCEnglishWidgetAttributes.ContentState.starEyes
}
