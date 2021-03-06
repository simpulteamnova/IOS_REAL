//
//  AllMyCardList.swift
//  proco
//
//  Created by 이은호 on 2021/01/26.
// 채팅방 드로어 - 친구 카드 초대하기에서 내 카드 리스트 보여주는 뷰
//상세 페이지 이동 후에 확인 버튼 클릭 누르면 채팅방 화면으로 이동.

import SwiftUI


struct AllMyCardList: View {
    @Environment(\.presentationMode) var presentation
    
    //여기에서 내가 만든 카드 리스트 가져오는 통신 진행, 모델에 데이터 저장해줌.
    @ObservedObject var socket: SockMgr
    //상세 페이지 이동시 친구, 모임 각각 뷰모델 넘겨주기 위함.
    @ObservedObject var friend_vm = FriendVollehMainViewmodel()
    @ObservedObject var group_vm = GroupVollehMainViewmodel()
    @StateObject var calendar_vm = CalendarViewModel()
    
    //각각 친구, 모임 상세 페이지 이동 구분값
    @State private var see_freind_card_detail: Bool = false
    @State private var see_group_card_detail: Bool = false
    //카드 잠금 이벤트시 토스트 띄우기 위한 구분값
    @State private var show_lock_alert : Bool = false
    //카드 잠금인지 잠금해제인지 이벤트 종류 알기 위해 저장할값 - 토스트에 띄움
    @State private var lock_event_kind : String = ""
    //카드 잠금 이벤트시 토스트 띄우기 위한 구분값
    @State private var show_group_card_lock_alert : Bool = false
    //카드 잠금인지 잠금해제인지 이벤트 종류 알기 위해 저장할값 - 토스트에 띄움
    @State private var group_card_lock_event_kind : String = ""
    var body: some View {
        NavigationView{
        VStack{
            HStack{
                Spacer()
                Text("친구 초대하기")
                    .font(.custom(Font.t_extra_bold, size: 20))
                    .foregroundColor(Color.proco_black)
                
                Spacer()
                Button(action: {
                    self.presentation.wrappedValue.dismiss()
                    
                    print("닫기 클릭")
                }, label: {
                    Image("card_dialog_close_icon")
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
                })
            }
            
            //친구랑 볼래 상세 페이지
//            NavigationLink("",destination: FriendVollehCardDetail(main_vm: self.friend_vm, group_main_vm: self.group_vm, socket: self.socket, calendar_vm: self.calendar_vm).navigationBarHidden(true), isActive: self.$see_freind_card_detail)
            
            //모여볼래 상세 페이지
//            NavigationLink("",destination: GroupVollehCardDetail(main_vm: self.group_vm, socket: self.socket, calendar_vm: self.calendar_vm).navigationBarHidden(true), isActive: self.$see_group_card_detail)
            
            ScrollView{
                
                HStack{
                    Text("친구카드")
                        .font(.custom(Font.n_bold, size: UIScreen.main.bounds.width/20))
                        .foregroundColor(.proco_black)
                    Spacer()
                    
                }.padding(.leading)
                
                if SockMgr.socket_manager.friend_card.count > 0 {
                ForEach(SockMgr.socket_manager.friend_card){card in
                    RoundedRectangle(cornerRadius: 25.0)
                        .foregroundColor(.proco_white)
                        .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        .frame(width: UIScreen.main.bounds.width*0.95, height: UIScreen.main.bounds.width*0.4)
                        .overlay(
                            MyCardListView(main_viewmodel: self.friend_vm, my_volleh_card_struct: card, current_card_index: friend_vm.get_index(item: card), show_lock_alert: self.$show_lock_alert, lock_event_kind: self.$lock_event_kind)
                        )
                        //한번 탭했을 때 상세 페이지로 이동.
                        .onTapGesture {
                            print("클릭한 카드 idx: \(card.card_idx!)")
                           // SockMgr.socket_manager.is_dynamic_link = true
                            
                            SockMgr.socket_manager.selected_card_idx = card.card_idx!
                            //상세 페이지로 들어오는 경우 - 메인, 드로어(카드 정보 보기), 친구 카드 초대하기 - 내 카드 1개 클릭..이것들 구분 위함.
                            SockMgr.socket_manager.is_from_chatroom = true
                            //상세 페이지에서 친구 카드 초대하기에서 이동할 경우에는 확인 버튼 예외처리 위해 사용
                            SockMgr.socket_manager.detail_to_invite = true
                            SockMgr.socket_manager.is_dynamic_link = false
                            //해당 카드의 상세 정보 가져오기 위한 쿼리.
                            //                        ChatDataManager.shared.get_card_by_card_idx(card_idx: card.card_idx!)
                            //이 값을 넣어줘야 상세페이지에서 데이터 가져오는 통신시 card idx값 사용가능.
                            friend_vm.selected_card_idx = card.card_idx!
                            self.see_freind_card_detail.toggle()
                        }
                }
                }else{
                    Text("내가 만든 친구 카드가 없어요")
                        .font(.custom(Font.n_bold, size: UIScreen.main.bounds.width/20))
                        .foregroundColor(.proco_black)
                }
                
                
                HStack{
                    Text("모임 카드")
                        .font(.custom(Font.n_bold, size: UIScreen.main.bounds.width/20))
                        .foregroundColor(.proco_black)
                    Spacer()
                    
                }
                .padding(.leading)
                if SockMgr.socket_manager.group_card.count > 0 {
                ForEach(SockMgr.socket_manager.group_card){card in
                    
                    RoundedRectangle(cornerRadius: 25.0)
                        .foregroundColor(.proco_white)
                        .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        .frame(width: UIScreen.main.bounds.width*0.95, height: UIScreen.main.bounds.width*0.4)
                        .overlay(
                            MyGroupVollehCard(main_vm: self.group_vm, my_group_card: card, current_card_index: group_vm.get_index(item: card), show_lock_alert: self.$show_group_card_lock_alert, lock_event_kind: self.$group_card_lock_event_kind)
                        )
                        //한번 탭했을 때 상세 페이지로 이동.
                        .onTapGesture {
                            print("클릭한 카드 idx: \(card.card_idx!)")
                            //상세 페이지로 들어오는 경우 - 메인, 드로어(카드 정보 보기), 친구 카드 초대하기 - 내 카드 1개 클릭..이것들 구분 위함.
                            SockMgr.socket_manager.is_from_chatroom = true
                            //상세 페이지에서 친구 카드 초대하기에서 이동할 경우에는 확인 버튼
                            SockMgr.socket_manager.detail_to_invite = true
                            SockMgr.socket_manager.is_dynamic_link = false

                            
                            print("카드 한 개 클릭: \( SockMgr.socket_manager.detail_to_invite)")
                            //해당 카드의 상세 정보 가져오기 위한 쿼리.
                            //                            ChatDataManager.shared.get_card_by_card_idx(card_idx: card.card_idx!)
                            SockMgr.socket_manager.selected_card_idx = card.card_idx!
                            group_vm.selected_card_idx = card.card_idx!
                            self.see_group_card_detail.toggle()
                            
                        }
                }
                }else{
                    Text("내가 만든 모임 카드가 없어요")
                        .font(.custom(Font.n_bold, size: UIScreen.main.bounds.width/20))
                        .foregroundColor(.proco_black)
                }
            }
            
        }
        .overlay(overlayView: Toast.init(dataModel: Toast.ToastDataModel.init(title: "카드가 \(self.lock_event_kind)되었습니다.", image: "checkmark"), show: self.$show_lock_alert), show: self.$show_lock_alert)
        .overlay(overlayView: Toast.init(dataModel: Toast.ToastDataModel.init(title: "카드가 \(self.group_card_lock_event_kind)되었습니다.", image: "checkmark"), show: self.$show_group_card_lock_alert), show: self.$show_group_card_lock_alert)
        .onAppear{
            SockMgr.socket_manager.get_all_my_cards()
            print("저장한 내 카드 리스트 확인: \(SockMgr.socket_manager.group_card), \(SockMgr.socket_manager.friend_card)")
            print("저장한 내 카드 리스트 확인: \(socket_manager.group_card), \(socket_manager.friend_card)")
            print("저장한 내 카드 리스트 확인: \(socket.group_card), \(socket.friend_card)")
        }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: self.$see_freind_card_detail){
        FriendVollehCardDetail(main_vm: self.friend_vm, group_main_vm: self.group_vm, socket: self.socket, calendar_vm: self.calendar_vm)
        }
        .fullScreenCover(isPresented: self.$see_group_card_detail){
          GroupVollehCardDetail(main_vm: self.group_vm, socket: self.socket, calendar_vm: self.calendar_vm)
        }
    }
}

