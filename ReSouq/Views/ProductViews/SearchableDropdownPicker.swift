//
//  SearchableDropdownPicker.swift
//  ReSouq
//
//
import SwiftUI

struct SearchableDropdownPicker: View {
    var title: String? = nil
    @Binding var selection: String
    var options: [(label: String, value: String)]
    @State private var isExpanded = false
    @State private var searchText = ""

    private let borderColor = Color.gray.opacity(0.5)
    private let buttonColor = Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1))

    // Filter options based on search text
    var filteredOptions: [(label: String, value: String)] {
        if searchText.isEmpty {
            return options
        } else {
            return options.filter { $0.label.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if let title = title {
                   Text(title)
                       .font(.custom("ReemKufi-Bold", size: 18))
                       .foregroundColor(buttonColor)
                       .padding(.leading, 15)
            }

            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(selection.isEmpty ? "Select a category" : options.first(where: { $0.value == selection })?.label ?? "Select a category")
                        .foregroundColor(selection.isEmpty ? .gray : .black)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(borderColor, lineWidth: 1))
                .cornerRadius(10)
            }
            .padding(.horizontal)

            if isExpanded {
                VStack(spacing: 5) {
                    // Search Bar
                    TextField("Search categories...", text: $searchText)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)

                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(filteredOptions, id: \.value) { option in
                                Button(action: {
                                    selection = option.value
                                    isExpanded = false
                                    searchText = "" // Clear search text when selecting
                                }) {
                                    HStack {
                                        Text(option.label)
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(selection == option.value ? buttonColor.opacity(0.2) : Color.white)
                                            .foregroundColor(.black)
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 200) 
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
            }
        }
    }
}

