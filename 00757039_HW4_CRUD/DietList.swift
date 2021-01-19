//
//  DietList.swift
//  00757039_HW4_CRUD
//
//  Created by User20 on 2021/1/20.
//

import SwiftUI
func caculate(target: Int, num: Int) -> Double{
    return Double(num)/Double(target)
}
func getDate()->String{
    let time = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd MMM"
    let stringDate = dateFormatter.string(from: time)
    return stringDate
}

struct DietList: View {
    @EnvironmentObject var dietsData: DietsData
    @AppStorage("target") private var target = 0
    @State private var txtTarget = ""
    @State private var editTarget = false
    @State private var showAlert = false
    var body: some View {
        
        NavigationView{
            VStack{
                HStack{
                    Text("卡路里上限：")
                    TextField("target", text: $txtTarget)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(!editTarget)
                        .frame(width: 100, alignment: .leading)
                        .onAppear(){
                            txtTarget = String(target)
                        }
                    Text("cal")
                    Image(systemName: "pencil")
                        .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                            if isNumber(txtTarget: txtTarget){
                                target = Int(txtTarget) ?? 2000
                                if(editTarget){
                                    editTarget = false
                                }
                                else{
                                    editTarget = true
                                }
                            }
                            else{
                                showAlert = true
                            }
                            
                        })
                        .alert(isPresented:$showAlert){()-> Alert in
                            return Alert(title: Text("請輸入數字！"))
                                        
                        }
                }

                RingGraph(target: target)
    
                
                Text("剩餘\(target-dietsData.total)cal")
                
                TodayListView()
            }
            
            
        }
    }
    
    func isNumber(txtTarget: String?) -> Bool {
            if Int(txtTarget!) != nil{
                return true
            }
            else{
                return false
            }
        }
    
}

struct DietList_Previews: PreviewProvider {
    static var previews: some View {
        DietList()
    }
}

struct RingGraph: View {
    var target: Int
    @EnvironmentObject var dietsData: DietsData
    @State private var waveOffset = Angle(degrees: 0)
    var body: some View {
        ZStack{
            Circle()
                .stroke(Color.orange, lineWidth: 20)
                .opacity(0.2)
                .overlay(
                    Wave(offset: Angle(degrees: self.waveOffset.degrees), percent: Double(caculate(target: target, num: dietsData.total)))
                        .fill(Color(red: 0.5, green: 0.2, blue: 0.0, opacity: 0.5))
                        .opacity(0.6)
                        .clipShape(Circle().scale(0.92))
                )
                .overlay(
                    Text("\(Float(caculate(target: target, num: dietsData.total)*100))%")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                        .padding(40)
                )
                .onAppear {
                    withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                            self.waveOffset = Angle(degrees: 360)
                        }
                }
            Circle()
                .trim(from: 0, to: CGFloat(caculate(target: target, num: dietsData.total)))
                .stroke(Color.red, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
        }
        .animation(.default)
        .frame(width: 250, height: 250, alignment: .center)
    }
}

struct TodayListView: View {
    @EnvironmentObject var dietsData: DietsData
    @State private var showEditDiet = false
    var body: some View {
        List{
            Section(header:Text("Today's diets")){
                ForEach(dietsData.diets.indices, id : \.self){(index) in
                    if(dietsData.diets[index].day == getDate()){
                        NavigationLink(destination:DietEditor(dietsData: dietsData, editDietIndex: index)){
                            DietRow(diet: dietsData.diets[index])
                            
                        }
                    }
                    
                }
                .onMove(perform: move)
                .onDelete{(indexSet) in
                    dietsData.diets.remove(atOffsets: indexSet)
                    dietsData.caculateTotal(5, selectDate: getDate())
                }
            }
        }

        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showEditDiet = true
                }, label: {
                    Image(systemName: "plus.circle.fill")
                })
            }
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
        })
        .sheet(isPresented:$showEditDiet){
            NavigationView{
                DietEditor(dietsData: dietsData)
            }
        }
    }
    func move(from source: IndexSet, to destination: Int) {
        dietsData.diets.move(fromOffsets: source, toOffset: destination)
    }
}

struct Wave: Shape {

    var offset: Angle
    var percent: Double
    
    var animatableData: Double {
        get { offset.degrees }
        set { offset = Angle(degrees: newValue) }
    }
    
    func path(in rect: CGRect) -> Path {
        var p = Path()

        // empirically determined values for wave to be seen
        // at 0 and 100 percent
        let lowfudge = 0.02
        let highfudge = 0.98
        
        let newpercent = lowfudge + (highfudge - lowfudge) * percent
        let waveHeight = 0.015 * rect.height
        let yoffset = CGFloat(1 - newpercent) * (rect.height - 4 * waveHeight) + 2 * waveHeight
        let startAngle = offset
        let endAngle = offset + Angle(degrees: 360)
        
        p.move(to: CGPoint(x: 0, y: yoffset + waveHeight * CGFloat(sin(offset.radians))))
        
        for angle in stride(from: startAngle.degrees, through: endAngle.degrees, by: 5) {
            let x = CGFloat((angle - startAngle.degrees) / 360) * rect.width
            p.addLine(to: CGPoint(x: x, y: yoffset + waveHeight * CGFloat(sin(Angle(degrees: angle).radians))))
        }
        
        p.addLine(to: CGPoint(x: rect.width, y: rect.height))
        p.addLine(to: CGPoint(x: 0, y: rect.height))
        p.closeSubpath()
        
        return p
    }
}

