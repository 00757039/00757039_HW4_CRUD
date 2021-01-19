//
//  DietData.swift
//  00757039_HW4_CRUD
//
//  Created by User20 on 2021/1/20.
//

import SwiftUI

class DietsData: ObservableObject{
    @AppStorage("diets") var dietsData: Data?
    @Published var total = 0
    @Published var selectDate = ""
    var dayArray = [""]
    var totals = [0,0,0,0,0,0,0]
    
    func getDate(_ selectedDate:Date)->String{
        //let time = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM"
        let stringDate = dateFormatter.string(from: selectedDate)
        return stringDate
    }
    
    func makeDayArray(){
        var newArray = [String]()
        var dayComponent = DateComponents()
        for num in 1..<8{
            dayComponent.day = num-7
            let calendar = Calendar.current
            let nextDay = calendar.date(byAdding: dayComponent, to: Date())!
            newArray.append(getDate(nextDay))
        }
        dayArray = newArray
    }
    func getTotal()->Array<Int>{
        var totalsArray = [0,0,0,0,0,0,0]
        for num in 0..<dayArray.count{
            for diet in diets {
                if(diet.day==dayArray[num] ){
                    totalsArray[num] = totalsArray[num] + diet.volume
                }
            }
        }
        return totalsArray
    }

    func caculateTotal( _ num: Int, selectDate: String){
        totals = [0,0,0,0,0,0,0]
        for num in 0..<dayArray.count{
            for diet in diets {
                if(diet.day==dayArray[num] ){
                    totals[num] = totals[num] + diet.volume
                }
            }
        }
        total = totals[6]
    }
    


    
    init(){
        makeDayArray()
        if let dietsData = dietsData{
            let decoder = JSONDecoder()
            selectDate = getDate(Date())
            if let decodedData = try? decoder.decode([Diet].self, from: dietsData){
                diets = decodedData
                for diet in diets {
                    if(diet.day == selectDate){
                        total = total + diet.volume
                    }
                }
                caculateTotal(0,selectDate: getDate(Date()))
            }
        }
        
        
    }
    @Published var diets = [Diet](){
        didSet{
            let encoder = JSONEncoder()
            do{
                let data = try encoder.encode(diets)
                dietsData = data
                
            }catch{
                
            }
        }
    }
}

struct DietsData_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
