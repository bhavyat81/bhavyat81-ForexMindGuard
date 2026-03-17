// WatchlistView.swift
// ForexMindGuard – Features/Watchlist
//
// Live forex pairs watchlist with real-time price updates.

import SwiftUI

struct WatchlistView: View {

    @StateObject private var vm = WatchlistViewModel()
    @State private var showAddSheet = false
    @State private var newBase  = ""
    @State private var newQuote = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.deepNavy.ignoresSafeArea()

                List {
                    ForEach(vm.pairs) { pair in
                        pairRow(pair: pair)
                            .listRowBackground(AppColors.darkCharcoal)
                            .listRowSeparatorTint(AppColors.cardBorder)
                    }
                    .onDelete(perform: vm.removePair)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Watchlist")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    connectionDot
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showAddSheet = true }) {
                        Image(systemName: "plus")
                            .foregroundStyle(AppColors.electricBlue)
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                addPairSheet
            }
        }
    }

    // MARK: - Pair row
    private func pairRow(pair: ForexPair) -> some View {
        HStack(spacing: 0) {
            // Flag placeholder + pair
            VStack(alignment: .leading, spacing: 4) {
                Text(pair.symbol)
                    .font(.system(.headline, design: .monospaced).bold())
                    .foregroundStyle(.white)
                Text("\(pair.base) / \(pair.quote)")
                    .font(.caption)
                    .foregroundStyle(AppColors.mutedText)
            }

            Spacer()

            // Bid/Ask
            VStack(alignment: .trailing, spacing: 4) {
                Text(pair.formattedPrice)
                    .font(.system(.body, design: .monospaced).bold())
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())

                HStack(spacing: 4) {
                    Image(systemName: pair.isPositiveDay ? "arrow.up" : "arrow.down")
                        .font(.caption2)
                    Text(pair.dailyChangePips.asPipsWithSign())
                        .font(.caption)
                }
                .foregroundStyle(pair.isPositiveDay ? AppColors.neonGreen : AppColors.dangerRed)
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(pair.symbol), \(pair.formattedPrice), \(pair.dailyChangePips.asPipsWithSign())")
    }

    // MARK: - Connection dot
    private var connectionDot: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(vm.isConnected ? AppColors.neonGreen : .orange)
                .frame(width: 8, height: 8)
            Text(vm.isConnected ? "Live" : "Connecting…")
                .font(.caption)
                .foregroundStyle(AppColors.mutedText)
        }
    }

    // MARK: - Add pair sheet
    private var addPairSheet: some View {
        NavigationStack {
            Form {
                Section("Add Currency Pair") {
                    TextField("Base (e.g. EUR)", text: $newBase)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                    TextField("Quote (e.g. USD)", text: $newQuote)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppColors.deepNavy)
            .navigationTitle("Add Pair")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { showAddSheet = false }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        vm.addPair(base: newBase, quote: newQuote)
                        showAddSheet = false
                        newBase = ""; newQuote = ""
                    }
                    .disabled(newBase.count < 3 || newQuote.count < 3)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Preview
#Preview {
    WatchlistView()
        .preferredColorScheme(.dark)
}
