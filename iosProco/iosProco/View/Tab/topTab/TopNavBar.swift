//
//  TopNavBar.swift
//  proco
//
//  Created by 이은호 on 2021/01/13.
//

import SwiftUI

struct TopNavBar: View {
    //하단 탭바중에서 어떤 것을 선택했는지 알 수 있는 구분자.
    @State var tab_index = 0
    @State private var go_to_manage : Bool = false
    //설정화면으로 이동
    @State private var go_to_setting : Bool = false
    
    //랜딩페이지 이동
    @State private var go_to_intro : Bool = false
    var page_name: String
    
    var body: some View {
        HStack{
        //친구관리로 이동.
        NavigationLink("",destination:ManageFriendListView(), isActive: self.$go_to_manage)
        //환경 설정으로 이동
        NavigationLink("", destination: SettingView(), isActive: self.$go_to_setting)
        
        NavigationLink("",destination: UseMethodView(url: "https://withproco.com/ProcoGuidePage.html"), isActive: self.$go_to_intro)
        }
        .frame(width: 0, height: 0)
        
            //상단 네비게이션바
            HStack{
                Text("\(page_name)")
                    .font(.custom(Font.n_extra_bold, size: 15))
                Spacer()
                HStack{
                    Spacer()
                    //통합 검색 버튼..기획 변경 - 사라짐
//                    Button(action: {
//                        self.tab_index = 5
//                    }){
//                        Image("find_icon")
//                            .resizable()
//                            .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
//                            .aspectRatio(contentMode: .fill)                                       .foregroundColor(Color.yellow)
//                    }
                    Button(action: {
                        self.go_to_intro = true
                    }){
                        Image(systemName: "questionmark.circle")
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width/15, height: UIScreen.main.bounds.width/15)
                            .foregroundColor(Color.proco_black)
                    }
                    
                    //친구관리 버튼
                    Button(action: {
                        self.tab_index = 6
                        self.go_to_manage.toggle()
                    }){
                        Image("manage_friends_icon")
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
                            .aspectRatio(contentMode: .fill)
                        
                    }
                    .padding(.leading, UIScreen.main.bounds.width/30)
                    
                    //환경 설정 버튼
                    Button(action: {
                        self.tab_index = 7
                        self.go_to_setting.toggle()
                        
                    }){
                        Image("setting_icon")
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
                            .aspectRatio(contentMode: .fill)
                    }
                    .padding(.leading, UIScreen.main.bounds.width/30)

                }
            }
            .padding([.top,.leading, .trailing], UIScreen.main.bounds.width/10)
        .navigationBarHidden(true)
        .navigationBarTitle("", displayMode: .inline)
            .onAppear{
                if ViewRouter.get_view_router().fcm_destination == "manage_friend"{
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                    self.go_to_manage = true
                    }
                }
            }
        
    }
}
