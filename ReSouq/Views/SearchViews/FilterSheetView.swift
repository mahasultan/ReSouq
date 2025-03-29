import SwiftUI

struct FilterSheetView: View {
    @Binding var filters: FilterOptions
    @Binding var didApplyFilters: Bool
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var categoryViewModel: CategoryViewModel

    @State private var tempFilters: FilterOptions
    @State private var minPriceSlider: Double = 0
    @State private var maxPriceSlider: Double = 2500
    @State private var selectedCategoryID: String? = nil


    private let conditionOptions = ["New", "Used - Like New", "Used - Good", "Used - Acceptable"]
    private let clothingSizes = ["XS", "S", "M", "L", "XL"]
    private let shoeSizes = (36...44).map { "\($0)" }
    private let genderOptions = ["Male", "Female", "Unisex"]
    private let sortOptions = ["Newest", "Price: Low → High", "Price: High → Low"]

    private let maroon = Color(red: 120/255, green: 0, blue: 0)

    init(filters: Binding<FilterOptions>, didApplyFilters: Binding<Bool>) {
        self._filters = filters
        self._didApplyFilters = didApplyFilters
        self._tempFilters = State(initialValue: filters.wrappedValue)
        self._minPriceSlider = State(initialValue: filters.wrappedValue.minPrice ?? 0)
        self._maxPriceSlider = State(initialValue: filters.wrappedValue.maxPrice ?? 2500)
        self._selectedCategoryID = State(initialValue: filters.wrappedValue.categoryID)

    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    categorySection()
                    genderSection()
                    conditionSection()
                    sizeSection()
                    priceSection()
                    sortSection()

                    VStack(spacing: 12) {
                        Button(action: {
                            tempFilters.minPrice = minPriceSlider
                            tempFilters.maxPrice = maxPriceSlider
                            tempFilters.categoryID = selectedCategoryID
                            filters = tempFilters
                            didApplyFilters = true
                            dismiss()
                        }) {
                            Text("Apply Filters")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(maroon)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .font(.custom("ReemKufi-Bold", size: 16))
                        }

                        Button(action: {
                            tempFilters = FilterOptions()
                            minPriceSlider = 0
                            maxPriceSlider = 2500
                        }) {
                            Text("Clear Filters")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.red)
                                .font(.custom("ReemKufi-Bold", size: 16))
                        }
                    }
                    .padding(.top, 10)
                }
                .padding()
            }
            .background(Color(red: 232/255, green: 225/255, blue: 210/255).edgesIgnoringSafeArea(.all)) // Beige
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(maroon)
                }
            }
            .onAppear {
                categoryViewModel.fetchCategories()
            }
        }
    }

    // MARK: - Sections

    private func categorySection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .font(.custom("ReemKufi-Bold", size: 16))

            SearchableDropdownPicker(
                title: "",
                selection: Binding(
                    get: { selectedCategoryID ?? "" },
                    set: { selectedCategoryID = $0.isEmpty ? nil : $0 }
                ),
                options: categoryViewModel.categories.map { ($0.name, $0.id) }
            )
            .pickerStyle(.menu)
            .tint(maroon)
        }
    }

    private func genderSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Gender")
                .font(.custom("ReemKufi-Bold", size: 16))

            Picker("Gender", selection: $tempFilters.gender) {
                Text("Any").tag(String?.none).foregroundColor(maroon)
                ForEach(genderOptions, id: \.self) { gender in
                    Text(gender).tag(gender as String?)
                }
            }
            .pickerStyle(.segmented)
            .tint(maroon)
        }
    }

    private func conditionSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Condition")
                .font(.custom("ReemKufi-Bold", size: 16))

            Picker("Condition", selection: $tempFilters.condition) {
                Text("Any").tag(String?.none).foregroundColor(maroon)
                ForEach(conditionOptions, id: \.self) { condition in
                    Text(condition).tag(condition as String?)
                }
            }
            .pickerStyle(.menu)
            .tint(maroon)
        }
    }

    private func sizeSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Size")
                .font(.custom("ReemKufi-Bold", size: 16))

            VStack(alignment: .leading, spacing: 4) {
                Text("Clothing Sizes").font(.caption)
                SizeGrid(options: clothingSizes, selected: $tempFilters.size, maroon: maroon)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Shoe Sizes").font(.caption)
                SizeGrid(options: shoeSizes, selected: $tempFilters.size, maroon: maroon)
            }
        }
    }

    private func priceSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Price Range (QAR)")
                .font(.custom("ReemKufi-Bold", size: 16))

            HStack {
                Text("Min: \(Int(minPriceSlider)) QAR")
                Spacer()
                Text("Max: \(Int(maxPriceSlider)) QAR")
            }

            RangeSliderView(minValue: $minPriceSlider, maxValue: $maxPriceSlider, range: 0...2500, maroon: maroon)
                .frame(height: 40)
                .padding(.horizontal)
                .padding(.vertical, 10)
        }
    }

    private func sortSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sort By")
                .font(.custom("ReemKufi-Bold", size: 16))

            Picker("Sort", selection: $tempFilters.sortBy) {
                Text("None").tag(String?.none).foregroundColor(maroon)
                ForEach(sortOptions, id: \.self) { option in
                    Text(option).tag(option as String?)
                }
            }
            .pickerStyle(.menu)
            .tint(maroon)
        }
    }
}

// MARK: - Size Grid
private struct SizeGrid: View {
    var options: [String]
    @Binding var selected: String?
    var maroon: Color

    let columns = [GridItem(.adaptive(minimum: 40))]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(options, id: \.self) { size in
                Text(size)
                    .font(.custom("ReemKufi-Regular", size: 14))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(selected == size ? maroon : Color.white)
                    .foregroundColor(selected == size ? .white : .black)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                    .onTapGesture {
                        selected = (selected == size) ? nil : size
                    }
            }
        }
    }
}

// MARK: - Range Slider
private struct RangeSliderView: View {
    @Binding var minValue: Double
    @Binding var maxValue: Double
    let range: ClosedRange<Double>
    let maroon: Color

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 6)

                Capsule()
                    .fill(maroon)
                    .frame(
                        width: CGFloat((maxValue - minValue) / (range.upperBound - range.lowerBound)) * geometry.size.width,
                        height: 6
                    )
                    .offset(x: CGFloat((minValue - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width)

                HStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                        .shadow(radius: 2)
                        .offset(x: CGFloat((minValue - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width - 10)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let percent = max(0, min(1, value.location.x / geometry.size.width))
                                    minValue = Double(percent) * (range.upperBound - range.lowerBound) + range.lowerBound
                                    if minValue > maxValue { minValue = maxValue }
                                }
                        )

                    Spacer()

                    Circle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                        .shadow(radius: 2)
                        .offset(x: CGFloat((maxValue - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width - 10)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let percent = max(0, min(1, value.location.x / geometry.size.width))
                                    maxValue = Double(percent) * (range.upperBound - range.lowerBound) + range.lowerBound
                                    if maxValue < minValue { maxValue = minValue }
                                }
                        )
                }
            }
        }
    }
}
