//
//  DietEditor.swift
//  00757039_HW4_CRUD
//
//  Created by User20 on 2021/1/20.
//

import SwiftUI

func getTime(_ selectedTime:Date)->String{
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "HH:mm"
    let stringTime = timeFormatter.string(from: selectedTime)
    return stringTime
}
func getDate(_ selectedDate:Date)->String{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd MMM"
    let stringDate = dateFormatter.string(from: selectedDate)
    return stringDate
}


struct DietEditor: View {
    @Environment(\.presentationMode) var presentationMode
    var dietsData: DietsData
    var editDietIndex: Int?
    
    @State private var day = getDate(Date())
    @State private var volume = 0
    @State private var time = getTime(Date())
    @State private var showDatePicker = false
    @State private var showTimePicker = false
    
    @State private var selectedTime = Date()
    @State private var selectedDate = Date()
 
    var body: some View {
        
        Form{
            DateEditor(showDatePicker: $showDatePicker, day: $day, selectedDate: $selectedDate)
            TimeEditor(showTimePicker: $showTimePicker, time: $time, selectedTime: $selectedTime)
            VolumeEditor(volume: $volume)
        }
        .onAppear(perform: {
            if let editDietIndex = editDietIndex{
                let editDiet = dietsData.diets[editDietIndex]
                day = editDiet.day
                volume = editDiet.volume
                time = editDiet.time
            }
        })
        .navigationBarTitle(editDietIndex == nil ? "Add New Diet Data": "Edit Diet Data")
        .toolbar(content:{
            Button("Save"){
                let diet = Diet(day: day, volume: volume, time:time)
                if let editDietIndex = editDietIndex{
                    dietsData.diets[editDietIndex] = diet
                    dietsData.caculateTotal(3, selectDate: diet.day)
                    
                }
                else{
                    dietsData.diets.insert(diet, at: dietsData.diets.endIndex)
                    if(diet.day==getDate(Date())){
                        dietsData.caculateTotal(4, selectDate: diet.day)

                    }
                }
                presentationMode.wrappedValue.dismiss()
            }
        })
        
    }
}

struct DietEditor_Previews: PreviewProvider {
    static var previews: some View {
        DietEditor(dietsData: DietsData())
    }
}

struct DateEditor: View {
    @Binding var showDatePicker: Bool
    @Binding var day: String
    @Binding var selectedDate: Date
    
    var dateClosedRange: ClosedRange<Date> {
        let min = Calendar.current.date(byAdding: .day, value: -6, to: Date())!
        let max = Calendar.current.date(byAdding: .day, value: 0, to: Date())!
        return min...max
    }
    var body: some View {
        DisclosureGroup(
            isExpanded: $showDatePicker,
            content: {
                VStack{
                    DatePicker("", selection: $selectedDate,in:dateClosedRange,displayedComponents: .date).datePickerStyle(GraphicalDatePickerStyle())
                    Divider()
                    Button("Done"){
                        showDatePicker = false
                        day = getDate( selectedDate)
                    }
                }
            },
            label: {
                TextField("Date", text: $day)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
            }
        )
    }
}

struct TimeEditor: View{
    @Binding var showTimePicker: Bool
    @Binding var time: String
    @Binding var selectedTime: Date
    var body: some View {
        DisclosureGroup(
            isExpanded: $showTimePicker,
            content: {
                HStack{
                    DatePicker("", selection: $selectedTime,displayedComponents: .hourAndMinute).datePickerStyle(GraphicalDatePickerStyle())
                        .frame(alignment: .leading)
                    Button("Done"){
                        showTimePicker = false
                        time = getTime( selectedTime)
                    }
                    .frame(alignment: .leading)
                }
            },
            label: {
                TextField("Time", text: $time)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
            }
        )
    }
}

struct VolumeEditor: View {
    @Binding var volume: Int
    var body: some View {
        Stepper(value: $volume, in: 0...5000, step: 10){
            Text("\(volume) cal")
        }
    }
}
