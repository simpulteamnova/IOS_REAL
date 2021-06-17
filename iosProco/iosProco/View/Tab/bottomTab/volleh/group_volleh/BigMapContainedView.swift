//
//  BigMapContainedView.swift
//  proco
//
//  Created by 이은호 on 2021/05/04.
//

import SwiftUI

struct BigMapContainedView: View {
    @Environment(\.presentationMode) var presentation
    
    @StateObject var vm : GroupVollehMainViewmodel
    @State private var show_map : Bool = false
    
    var body: some View {
        VStack{
            HStack{
                //돌아가기 버튼
                Image("left")
                    .resizable()
                    .frame(width: 10, height: 17)
                    .padding(.leading, UIScreen.main.bounds.width/20)
                    .onTapGesture {
                        withAnimation{
                            self.presentation.wrappedValue.dismiss()
                        }
                    }
                Spacer()
                Text("모임 위치")
                    .foregroundColor(Color.proco_black)
                    .font(.custom(Font.t_extra_bold, size: 22))
                Spacer()
            }
            
            MyWebView(vm: self.vm, url: "https://withproco.com/map/search_map.html?device=ios")
            
            Spacer()
            Button(action: {
                self.presentation.wrappedValue.dismiss()
                
                //self.vm.map_edited =- true
                // self.show_map.toggle()
                //self.vm.is_editing_card = false
                self.vm.is_making = false
                
                print("--------지도 위치 선택 후 확인 클릭 : \(self.vm.map_data)--------")
            }){
                Text("확인")
                    .font(.custom(Font.t_regular, size: 17))
                    .padding()
                    .foregroundColor(.proco_white)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(Color.proco_black)
            .cornerRadius(25)
            .padding([.leading, .trailing], UIScreen.main.bounds.width/20)
        }
        .onAppear{
            
            print("지도 맵뷰 나타남:\(self.vm.map_data) ")
            
        }
        .background(Color.proco_white)
    }
    
}


