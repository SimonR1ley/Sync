import WidgetKit
import SwiftUI
import Intents
import HealthKit

struct Provider: IntentTimelineProvider {
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let healthStore = HKHealthStore()

        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let typesToRead: Set<HKObjectType> = [stepType]

        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { (success, error) in
            completion(success)
        }
    }

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), stepCount: 0)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, stepCount: 0)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        requestAuthorization { (success) in
            guard success else {
                // Handle authorization failure
                return
            }

            var entries: [SimpleEntry] = []

            let currentDate = Date()
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: currentDate)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

            let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictEndDate)

            let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (query, result, error) in
                if let result = result {
                    if let sum = result.sumQuantity() {
                        let stepCount = Int(sum.doubleValue(for: HKUnit.count()))
                        let entry = SimpleEntry(date: currentDate, configuration: configuration, stepCount: stepCount)
                        entries.append(entry)
                    }
                }

                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            }

            HKHealthStore().execute(query)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let stepCount: Int
}

struct Quick_View_WidgetEntryView : View {
    var entry: Provider.Entry

    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        
        switch widgetFamily {
        case .systemSmall, .systemMedium:
            ZStack{
                Color(.black).frame(width: .infinity, height: .infinity)
                
                Text("Steps: \(entry.stepCount)")
                    .foregroundColor(.white)
            }
        case .accessoryCircular, .accessoryRectangular, .accessoryInline:
            VStack{
                Text("Steps: \(entry.stepCount)")
                    .foregroundColor(.white)
            }
        default:
            Text("Not available yet")
        }
    }
}

struct Quick_View_Widget: Widget {
    let kind: String = "Quick_View_Widget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            Quick_View_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct Quick_View_Widget_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            Quick_View_WidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), stepCount: 1000))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            Quick_View_WidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), stepCount: 1000))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            Quick_View_WidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), stepCount: 1000))
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
            
            Quick_View_WidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), stepCount: 1000))
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
            
            Quick_View_WidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), stepCount: 1000))
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
        }
    }
}
