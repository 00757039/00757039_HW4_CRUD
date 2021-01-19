//
//  ChartView.swift
//  00757039_HW4_CRUD
//
//  Created by User20 on 2021/1/20.
//

import SwiftUI

func getDate(selectedDate:Date)->String{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd MMM"
    let stringDate = dateFormatter.string(from: selectedDate)
    return stringDate
}


struct ChartView: View {
    //@StateObject var dietsData = DietsData()
    @EnvironmentObject var dietsData: DietsData
    @State private var today = Date()
    @State private var dayString = getDate(Date())
    @AppStorage("target") private var target = 0
   
    var body: some View {
        VStack{
            MyChartView(dayArray: dietsData.dayArray, totalArray:dietsData.getTotal(), target: target, dayString: $dayString)
                .frame(height: 500)
            ListView(dayString: $dayString)
        }
    }
    
}



struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView()
    }
}

struct BarView: View {
    var percentage: CGFloat
    var txt: String
    var color: Color

    @State var grow: Bool = false
    @State private var length = 0
    

    var body: some View {
        VStack{
            Text("\(Int(percentage*100))%")
                .padding(.bottom, 2)
                .font(.system(size: 11))
                .frame(width:30)
            ZStack(alignment: .bottom){
                
                RoundedRectangle(cornerRadius: 12)
                    .frame(width: 30, height: 225)
                    .foregroundColor(Color(UIColor.systemTeal))
                    .opacity(0.3)

                RoundedRectangle(cornerRadius: 12)
                    .frame(width: 30, height: (225*percentage))
                    .foregroundColor(color)

            }
            Text(txt)
                .padding(.top, 2)
                .font(.system(size: 12))
                .frame(width:35)
     
        }
    }
    
    struct AnimatableLength: AnimatableModifier {
        var length: CGFloat
        var width: CGFloat

        var animatableData: CGFloat {
            get { length }
            set { length = newValue }
        }

        func body(content: Content) -> some View {
            content
                .frame(width: width, height: length)
        }
    }
}

struct MyChartView: View {
    var dayArray: Array<String>
    var totalArray: Array<Int>
    var target: Int
    @Binding var dayString: String
    
    var body: some View {
        
        VStack{
            Text("Weekly Review")
                .font(.system(size: 20))
                .foregroundColor(.black)
                .padding(.bottom, 3)
                .background(Color(red: 255/255, green: 100/255, blue: 80/255))
            Text("\(dayArray[0]) - \(dayArray[6])")
                .background(Color(red: 255/255, green: 100/255, blue: 80/255))
                .foregroundColor(.black)
            HStack{
                ForEach(0..<dayArray.count){(index) in
                    if(dayArray[index]==getDate(Date())){
                        BarView(percentage: CGFloat(totalArray[index])/CGFloat(target) <= 1 ? CGFloat(totalArray[index])/CGFloat(target) : 1 , txt: "\(dayArray[index])", color:  Color(red: 255/255, green: 50/255, blue: 100/255))
                            .onTapGesture(count: 1, perform: {
                                dayString = dayArray[index]
                            })
                        
                    }//today: special color
                    else{
                        BarView(percentage: CGFloat(totalArray[index])/CGFloat(target) <= 1 ? CGFloat( totalArray[index])/CGFloat(target) : 1 , txt: "\(dayArray[index])", color:  Color(red: 255/255, green: 100/255, blue: 50/255))
                            .onTapGesture(count: 1, perform: {
                                dayString = dayArray[index]
                            })
                    }
                }
                
            }
            .padding(.top, 24)
        }

    }
}

struct ListView: View {
    @Binding var dayString: String
    @EnvironmentObject var dietsData: DietsData
    var body: some View {
        List{
            Section(header:CustomHeader(
                        name: "\(dayString)'s diets",
                        color: Color(red: 250/255, green: 200/255, blue: 235/255))){
                ForEach(dietsData.diets.indices, id : \.self){(index) in
                    if(dietsData.diets[index].day == dayString){
                        DietRow(diet: dietsData.diets[index])
                        
                    }
                    
                }
            }
        }
        .animation(.default)
    }
}
struct CustomHeader: View {
    let name: String
    let color: Color

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text(name)
                    .foregroundColor(.black)
                Spacer()
            }
            Spacer()
        }
        
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .background(color)
        
    }
}
