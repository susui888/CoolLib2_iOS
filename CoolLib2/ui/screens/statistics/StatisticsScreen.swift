import SwiftUI

struct StatisticsScreen: View {
    @EnvironmentObject var router: AppRouter
    @StateObject private var statisticsViewModel: StatisticsViewModel

    init(container: AppContainer) {
        _statisticsViewModel = StateObject(
            wrappedValue: container.makeStatisticsViewModel()
        )
    }
    
    var body: some View {
        StatisticsScreenContent(
            state: statisticsViewModel.uiState,
            onSeeMoreLoans: {
                // router.navigate(to: .loanHistory) // 示例导航逻辑
            }
        )
    }
}

// MARK: - Main Content View
struct StatisticsScreenContent: View {
    let state: StatisticsUIState
    var onSeeMoreLoans: () -> Void = {}
    
    // Shared constants to match the design
    private let primaryCardHeight: CGFloat = 160
    
    var body: some View {
        ScrollView {
            if state.isLoading {
                ProgressView()
                    .padding(.top, 50)
            } else {
                VStack(spacing: 20) {
                    
                    // --- Section 1: Library Usage (Circular Progress) ---
                    ElevatedCardContainer {
                        HStack(spacing: 24) {
                            GradientProgressChart(
                                currentlyBorrowed: state.currentlyBorrowed,
                                targetLimit: 30
                            )
                            .frame(width: 110, height: 110)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Library Usage")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Text("Monthly limit: 30 books")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(20)
                    }
                    .frame(height: primaryCardHeight)
                    .shadow(color: .black.opacity(0.22), radius: 1, y: 1)

                    // --- Section 2: Quick Stats Grid ---
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        MiniStatCard(
                            title: "Overdue",
                            value: "\(state.overdue)",
                            icon: "exclamationmark.circle.fill",
                            color: .red
                        )
                        
                        MiniStatCard(
                            title: "Due Soon",
                            value: "\(state.dueSoon)",
                            icon: "clock.badge.exclamationmark.fill",
                            color: .orange
                        )
                    }

                    // --- Section 3: Activity Trend (Wave Chart) ---
                    ActivityTrendCard(activityData: state.weeklyActivity)
                        .frame(height: primaryCardHeight)

                    // --- Section 4: Lifetime Metrics & Action ---
                    VStack(spacing: 12) {
                        StatRowCard(
                            title: "Life-time Total Borrowed",
                            value: "\(state.totalBorrowed)",
                            icon: "books.vertical.fill",
                            color: .accentColor
                        )
                        
                        Button(action: onSeeMoreLoans) {
                            HStack {
                                Text("See Detailed Loan History")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.accentColor)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Statistics").font(.caption)
    }
}

// MARK: - Sub-components

struct GradientProgressChart: View {
    let currentlyBorrowed: Int
    let targetLimit: Int
    @State private var animatedPercent: Double = 0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.2), lineWidth: 10)
            
            Circle()
                .trim(from: 0, to: animatedPercent)
                .stroke(
                    LinearGradient(colors: [.green.opacity(0.6), .green], startPoint: .top, endPoint: .bottom),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            
            VStack(spacing: 0) {
                Text("\(currentlyBorrowed)")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(currentlyBorrowed > targetLimit ? .red : .primary)
                Text("/ \(targetLimit)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).delay(0.2)) {
                animatedPercent = min(Double(currentlyBorrowed) / Double(targetLimit), 1.0)
            }
        }
    }
}

struct ActivityTrendCard: View {
    let activityData: [Double]
    
    var body: some View {
        ElevatedCardContainer {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Activity Trend")
                            .font(.subheadline)
                            .fontWeight(.bold)
                        Text("Borrowing frequency")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("Last 14 Days")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // Wave Canvas placeholder
                ActivityWaveView(data: activityData)
                    .padding(.top, 4)
            }
            .padding(16)
        }
        .shadow(color: .black.opacity(0.22), radius: 1, y: 1)
    }
}

struct ActivityWaveView: View {
    let data: [Double]
    
    @State private var drawingProgress: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
    
                
                Path { path in
                    guard data.count > 1 else { return }
                    let step = geometry.size.width / CGFloat(data.count - 1)
                    let height = geometry.size.height
                    
                    let points = data.enumerated().map { index, value in
                        CGPoint(x: CGFloat(index) * step, y: height * (1 - CGFloat(value) * 0.7 - 0.15))
                    }
                    
                    path.move(to: points[0])
                    for i in 0..<points.count - 1 {
                        let p1 = points[i]
                        let p2 = points[i+1]
                        let controlMidX = (p1.x + p2.x) / 2
                        path.addCurve(to: p2,
                                     control1: CGPoint(x: controlMidX, y: p1.y),
                                     control2: CGPoint(x: controlMidX, y: p2.y))
                    }
                }
                .stroke(
                    LinearGradient(colors: [.green.opacity(0.4), .green], startPoint: .leading, endPoint: .trailing),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                )

                .mask(
                    Rectangle()
                        .frame(width: geometry.size.width * drawingProgress)
                        .frame(maxWidth: .infinity, alignment: .leading)
                )
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).delay(0.5)) {
                drawingProgress = 1.0
            }
        }
    }
}

struct MiniStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        ElevatedCardContainer {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                VStack(alignment: .leading, spacing: 2) {
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .shadow(color: .black.opacity(0.22), radius: 1, y: 1)
    }
}

struct StatRowCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        ElevatedCardContainer {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                    .frame(width: 40)
                
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(value)
                        .font(.title3)
                        .fontWeight(.bold)
                }
                Spacer()
            }
            .padding(16)
        }
        .shadow(color: .black.opacity(0.22), radius: 1, y: 1)
    }
}

struct ElevatedCardContainer<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    
    var body: some View {
        content
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Previews
#Preview {
    NavigationStack {
        StatisticsScreenContent(state: StatisticsUIState(
            currentlyBorrowed: 12,
            dueSoon: 2,
            overdue: 1,
            totalBorrowed: 128,
            weeklyActivity: [0.1, 0.4, 0.2, 0.8, 0.5, 0.6, 0.3, 0.9, 0.2, 0.4, 0.7, 0.3, 0.6, 0.5],
            isLoading: false,
            isLoggedIn: true,
        ))
    }
}
