/// Copyright (c) 2024 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import WidgetKit
import SwiftUI
import CloudKit
import CoreData

struct Provider: AppIntentTimelineProvider {
  func placeholder(in context: Context) -> SimpleEntry {
    let entry = fetchData(for: ConfigurationAppIntent())
    return entry
  }
  
  func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
    fetchData(for: configuration)
  }
  
  func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
      print("Timeline requested with configuration: \(configuration)")
      var entries: [SimpleEntry] = []

      let currentDate = Date()
      let updateInterval = 2 * 60 // 2 minutes in seconds

      // Creating entries for the next hour (30 entries for every 2 minutes)
      for minuteOffset in stride(from: 0, to: 60, by: 2) {
        _ = Calendar.current.date(byAdding: .second, value: updateInterval * minuteOffset, to: currentDate)!
          let entry = fetchData(for: configuration)
        print("Timeline requested with configuration: \(entry)")
          entries.append(entry)
      }

      let timeline = Timeline(entries: entries, policy: .atEnd)
      return timeline
  }

  // Fetch data from CoreData
  private func fetchData(for configuration: ConfigurationAppIntent) -> SimpleEntry {
    // Create a new background context
    let context = CoreDataStack.shared.persistentContainer.viewContext
    
    // Create a fetch request for Destination
//    let fetchRequest: NSFetchRequest<Destination> = Destination.fetchRequest() 
    
    do {
      let results = try context.fetch(Destination.getAllDestinationItems())
      print(results.first?.caption ?? "no caption")
      return SimpleEntry(date: Date(), configuration: configuration, destination: results.first)
    } catch {
      // Handle errors
      print("Error fetching data: \(error)")
      // Return an entry with default or error state
      return SimpleEntry(date: Date(), configuration: configuration, destination: nil)
    }
  }
}




struct SimpleEntry: TimelineEntry {
  let date: Date
  let configuration: ConfigurationAppIntent
  let destination:  Destination?
}


struct WidgetsEntryView : View {
  var entry: Provider.Entry
  var body: some View {
    VStack {
      if let destination = entry.destination {
        VStack(alignment: .leading, spacing: 4) {
          if let imageData = destination.image, let image = UIImage(data: imageData) {
            Image(uiImage: image)
              .resizable()
              .scaledToFit()
          }
          Text(destination.caption)
            .font(.headline)
          Text(destination.details)
            .font(.subheadline)
          Text(destination.createdAt.description)
        }
      } else {
        Text("no")
      }
      Text("Time:")
      Text(entry.date, style: .time)
    }
    
  }
}

struct Widgets: Widget {
  let kind: String = "Widgets"
  
  var body: some WidgetConfiguration {
    AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
      WidgetsEntryView(entry: entry).environment(\.managedObjectContext, CoreDataStack.shared.context)
        .containerBackground(.fill.tertiary, for: .widget)
    }
  }
}

extension ConfigurationAppIntent {
  fileprivate static var smiley: ConfigurationAppIntent {
    let intent = ConfigurationAppIntent()
    intent.favoriteEmoji = "😀"
    return intent
  }
  
  fileprivate static var starEyes: ConfigurationAppIntent {
    let intent = ConfigurationAppIntent()
    intent.favoriteEmoji = "🤩"
    return intent
  }
}

#Preview(as: .systemSmall) {
  Widgets()
} timeline: {
  SimpleEntry(date: .now, configuration: .smiley, destination: nil)
  SimpleEntry(date: .now, configuration: .starEyes, destination: nil)
}
