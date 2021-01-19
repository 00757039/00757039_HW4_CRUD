//
//  DietRow.swift
//  00757039_HW4_CRUD
//
//  Created by User20 on 2021/1/20.
//

import SwiftUI

struct DietRow: View {
    var diet: Diet
    var body: some View {
        HStack{
            Text(diet.time)
            Text("\(diet.volume)cal")
        }
    }
}

struct DietRow_Previews: PreviewProvider {
    static var previews: some View {
        DietRow(diet: Diet(day: "11/17", volume: 200, time: "13:00"))
    }
}
