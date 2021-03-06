//
//  GroupVollehMainView.swift
//  proco
//
//  Created by 이은호 on 2020/11/29.
//

import SwiftUI
import Combine
import UserNotifications
import Kingfisher

struct GroupVollehMainView: View {
    @ObservedObject var db : ChatDataManager = ChatDataManager()
    
    @StateObject var main_vm = GroupVollehMainViewmodel()
    //카드 만들기 페이지로 이동시 사용하는 값.
    @State private var go_to_make_card : Bool = false
    //카드 편집 페이지로 이동시 사용하는 값.
    @State private var go_to_edit : Bool = false
    
    //카드 삭제 버튼 클릭시 한 번 더 알림창 보여주기 위함.
    @State private var show_delete_alert : Bool = false
    
    //다른 사람 모임 카드 상세 페이지 들어갈 때
    @State private var go_to_detail: Bool = false
    //내 카드의 상세 페이지 들어갈 때
    @State private var go_to_my_detail: Bool = false
    
    //내 신청목록 들어갈 때
    @State private var go_to_apply_list: Bool = false
    
    //필터 버튼 클릭시 나오는 모달창 구분값
    @State private var show_filter = false
    
    //상세페이지 이동시 캘린더 뷰모델 넘겨줘야함.
    @StateObject var calendar_vm = CalendarViewModel()
    //온오프 버튼 구분위함
    @State private var state_on : Int = 0
    //내가 만든 모임 그룹 리스트 오픈 여부
    @State private var open_my_meetings = true
    
    //친구들 모임 카드 그룹 리스트 오픈 여부
    @State private var open_all_meeting_cards = true
    //내 프로필 사진
    @State private var my_photo_path : String = UserDefaults.standard.string(forKey: "profile_photo_path") ?? ""
    
    let scale = UIScreen.main.scale
    let img_processor = ResizingImageProcessor(referenceSize: CGSize(width: UIScreen.main.bounds.width/6, height: UIScreen.main.bounds.width/6)) |> RoundCornerImageProcessor(cornerRadius: 25)
    
    //내 프로필 클릭시 나타나는 다이얼로그
    @State private var my_info_dialog : Bool = false
    //카드 잠금 이벤트시 토스트 띄우기 위한 구분값
    @State private var show_lock_alert : Bool = false
    //카드 잠금인지 잠금해제인지 이벤트 종류 알기 위해 저장할값 - 토스트에 띄움
    @State private var lock_event_kind : String = ""
    
    @ViewBuilder
    var body: some View {
        
        VStack{
            TopNavBar(page_name: "모임")
            ScrollView(.vertical, showsIndicators: false){
                VStack{
                    
                    HStack{
                        NavigationLink("",destination: MakeCardViewGroup(main_vm: self.main_vm) .navigationBarHidden(true), isActive: self.$go_to_make_card)
                        
                        //문제 해결: 이동 링크에도 네비게이션바 hidden관련 속성을 넣어줘야 back button이 쌓이지 않음.
                        NavigationLink("", destination: EditGroupCard(main_vm: self.main_vm)
                                       , isActive: self.$go_to_edit)
                        
                        NavigationLink("",
                                       destination: AppliedMeetingListView(main_vm: self.main_vm),
                                       isActive: self.$go_to_apply_list)
                        NavigationLink("",destination: GroupVollehCardDetail(main_vm: self.main_vm, socket: SockMgr.socket_manager, calendar_vm: self.calendar_vm), isActive : self.$go_to_detail)
                        
                    }.frame(width: 0, height: 0)
                    Group{
                        //프로필 사진, 카드 만들기 버튼, on off버튼
                        user_profile_view
                            .padding(.top)
                        
                        
                        //신청목록보기, 필터, 지도로보기 버튼
                        HStack{
                            my_applied_meetings_btn
                            Spacer()
                            //필터 버튼 클릭시 지금.이날.모두.접속 선택하는 다이얼로그 나옴.
                            filter_btn
                            //전체로 보기
                            select_view_all_btn
                        }
                        .padding()
                    }
                    DisclosureGroup(isExpanded:$open_my_meetings, content: {
                        
                        if main_vm.my_group_card_struct.isEmpty{
                            
                            Text("내가 만든 모임이 아직 없네요.")
                                .font(.custom(Font.n_bold, size: UIScreen.main.bounds.width/25))
                                .foregroundColor(.gray)
                                .padding(.top)
                        }else{
                            
                            NavigationLink("",destination: GroupVollehCardDetail(main_vm: self.main_vm, socket: SockMgr.socket_manager, calendar_vm: self.calendar_vm)          .navigationBarTitle("", displayMode: .inline)
                                            .navigationBarHidden(true), isActive: self.$go_to_my_detail)
                            
                            //카드 1개 선택시 2-3 참가 신청 가능한 카드 선택 페이지로 이동(참가자)
                            ForEach(main_vm.my_group_card_struct){ card in
                                ZStack{
                                    // 1. hstack 버튼들 배경
                                    HStack(spacing: 0){
                                        Spacer()
                                        //오른쪽으로 스와이프시 빨간색 배경, 주황색 배경
                                        RoundedRectangle(cornerRadius: 5.0)
                                            .frame(width: UIScreen.main.bounds.width*0.2, height: UIScreen.main.bounds.width*0.35)
                                            .foregroundColor(Color.proco_red .opacity(main_vm.my_group_card_struct[self.main_vm.get_index(item: card)].offset ?? 0 < 0 ? 1 : 0))
                                        
                                        RoundedRectangle(cornerRadius: 5.0)
                                            .frame(width: UIScreen.main.bounds.width*0.2, height: UIScreen.main.bounds.width*0.35)
                                            .foregroundColor(    Color.main_orange .opacity(main_vm.my_group_card_struct[self.main_vm.get_index(item: card)].offset ?? 0 < 0 ? 1 : 0))
                                        
                                        
                                    }
                                    
                                    //2.hstack 버튼 액션 선언
                                    HStack{
                                        Spacer()
                                        HStack{
                                            //수정 버튼
                                            HStack{
                                                
                                                
                                                Button(action: {
                                                    //수정하려는 카드의 idx값을 이용해 데이터 꺼낼 때 사용.
                                                    self.main_vm.selected_card_idx = self.main_vm.my_group_card_struct[self.main_vm.get_index(item: card)].card_idx!
                                                    
                                                    print("이동하려는 카드 idx: \(self.main_vm.selected_card_idx)")
                                                    //수정하는 페이지 카드 정보 갖고 오는 통신 진행.-> 상세페이지에서 하는 것으로 변경.
                                                    //                                                    self.main_vm.get_detail_card()
                                                    withAnimation(.default){
                                                        
                                                        //수정하는 페이지로 이동
                                                        self.go_to_edit.toggle()
                                                    }
                                                }
                                                
                                                , label: {
                                                    VStack{
                                                        Image("swipe_edit_icon")
                                                            .resizable()
                                                            .frame(width:18.89, height: 19.03)
                                                        Image("swipe_edit_txt")
                                                            .resizable()
                                                            .frame(width:20, height: 13)
                                                    }
                                                })
                                                .frame(width: UIScreen.main.bounds.width*0.15, height: UIScreen.main.bounds.width*0.3)
                                                
                                                //삭제버튼
                                                Button(action: {
                                                    //지우려는 카드의 행과 idx정보 저장.
                                                    self.main_vm.selected_card_idx = self.main_vm.my_group_card_struct[self.main_vm.get_index(item: card)].card_idx!
                                                    //삭제할 건지 다시 한번 묻는 알림창
                                                    withAnimation(.default){
                                                        self.show_delete_alert.toggle()
                                                    }
                                                    
                                                }
                                                , label: {
                                                    VStack{
                                                        Image("swipe_del_icon")
                                                            .resizable()
                                                            .frame(width:16, height: 22)
                                                        Image("swipe_del_txt")
                                                            .resizable()
                                                            .frame(width:20, height: 13)
                                                    }
                                                })
                                                .frame(width: UIScreen.main.bounds.width*0.2, height: UIScreen.main.bounds.width*0.3)
                                                .alert(isPresented: $show_delete_alert){
                                                    Alert(title: Text("카드 삭제하기"), message: Text("내 카드를 지우시겠습니까?"), primaryButton: Alert.Button.default(Text("확인"), action: {
                                                        
                                                        //삭제하려는 카드의 idx삭제
                                                        self.main_vm.my_group_card_struct
                                                            .removeAll{$0.card_idx == self.main_vm.selected_card_idx}
                                                        
                                                        //카드 idx로 채팅방 idx 가져오기
                                                        let chatroom_idx =     ChatDataManager.shared.get_chatroom_from_card(card_idx: Int(self.main_vm.selected_card_idx))
                                                        
                                                        SockMgr.socket_manager.exit_room(chatroom_idx: chatroom_idx, idx: Int(main_vm.my_idx!)!, nickname: main_vm.my_nickname!, profile_photo_path: "", kinds: nil)
                                                        
                                                        print("확인클릭하고 데이터 삭제")
                                                        //확인 눌렀을 때 통신 시작
                                                        main_vm.delete_group_card()
                                                    }), secondaryButton: Alert.Button.default(Text("취소"), action: {
                                                    }))
                                                }
                                            }
                                        }
                                    }
                                    
                                    RoundedRectangle(cornerRadius: 25.0)
                                        .foregroundColor(.proco_white)
                                        .shadow(color: .gray, radius: 2, x: 0, y: 2)
                                        .frame(width: UIScreen.main.bounds.width*0.95, height: UIScreen.main.bounds.width*0.45)
                                        .overlay(
                                            MyGroupVollehCard(main_vm: self.main_vm,
                                                              my_group_card: main_vm.my_group_card_struct[main_vm.get_index(item: card)], current_card_index: self.main_vm.get_index(item: card), show_lock_alert : self.$show_lock_alert, lock_event_kind: self.$lock_event_kind)
                                                .padding()
                                        )
                                        .frame(width: UIScreen.main.bounds.width*0.95, height: UIScreen.main.bounds.width/2.5)
                                        //스와이프해서 수정, 삭제 위해 offset을 데이터 모델에 임의로 넣어줬음. 이 값을 이용한 것.
                                        .offset(x:main_vm.my_group_card_struct[self.main_vm.get_index(item: card)].offset!)
                                        //한번 탭했을 때 상세 페이지로 이동.
                                        .onTapGesture {
                                            //카드의 정보 세팅에 idx값을 이용해 데이터 꺼낼 때 사용.
                                            self.main_vm.selected_card_idx = self.main_vm.my_group_card_struct[self.main_vm.get_index(item: card)].card_idx!
                                            
                                            self.main_vm.selected_card_idx = self.main_vm.my_group_card_struct[self.main_vm.get_index(item: card)].card_idx!
                                            print("이동하려는 카드 idx: \( self.main_vm.selected_card_idx)")
                                            //상세 페이지 카드 정보 갖고 오는 통신 진행. -> 상세 페이지에서 진행.
                                            
                                            self.go_to_my_detail.toggle()
                                            
                                        }
                                        //스와이프할 때 Offset값을 얻어옴.
                                        .gesture(DragGesture().onChanged({ (value) in
                                            withAnimation(.default){
                                                main_vm.my_group_card_struct[self.main_vm.get_index(item: card)].offset! = value.translation.width
                                            }
                                        })
                                        //스와이프 동작이 끝났을 때에 따라 데이터모델의 offset값 조정.
                                        .onEnded({ (value) in
                                            withAnimation(.default){
                                                
                                                if value.translation.width < UIScreen.main.bounds.width * -0.01{
                                                    print("on ended에 들어옴 : offset 확인2")
                                                    
                                                    main_vm.my_group_card_struct[self.main_vm.get_index(item: card)].offset! = UIScreen.main.bounds.width * -0.4
                                                }
                                                else{
                                                    print("on ended에 들어옴 : offset 확인3")
                                                    main_vm.my_group_card_struct[self.main_vm.get_index(item: card)].offset! = 0
                                                }
                                            }
                                            //gesture끝
                                        }))
                                        .padding([.top,.bottom], UIScreen.main.bounds.width/20)
                                }
                            }
                        }
                    }, label: {
                        Text("내가 만든 모임")
                            .font(.custom(Font.n_bold, size: UIScreen.main.bounds.width/25))
                            .foregroundColor(.proco_black)
                            .padding(.leading, UIScreen.main.bounds.width/20)
                    })
                    .padding([.trailing, .leading])
                    
                    
                    
                    DisclosureGroup(isExpanded:$open_all_meeting_cards, content: {
                        
                        if main_vm.group_card_struct.isEmpty{
                            
                            Text("만들어진 모임이 아직 없네요")
                                .font(.custom(Font.n_bold, size: UIScreen.main.bounds.width/25))
                                .foregroundColor(.gray)
                        }else{
                            
                            ForEach(self.main_vm.group_card_struct){ card in
                                HStack{
                                    
                                    RoundedRectangle(cornerRadius: 25.0)
                                        .foregroundColor(.proco_white)
                                        .shadow(color: .gray, radius: 2, x: 0, y: 2)
                                        .frame(width: UIScreen.main.bounds.width*0.95, height: UIScreen.main.bounds.width*0.4)
                                        .overlay(
                                            Button(action: {
                                                //상세 페이지로 가려는 카드의 idx값을 뷰모델에 저장.
                                                self.main_vm.selected_card_idx = self.main_vm.group_card_struct[self.main_vm.get_other_card_index(item: card)].card_idx!
                                                
                                                self.go_to_detail.toggle()
                                            }, label: {
                                                GroupVollehCard(main_vm: self.main_vm,
                                                                group_card: main_vm.group_card_struct[self.main_vm.get_other_card_index(item: card)])
                                                    
                                                    .frame(width: UIScreen.main.bounds.width*0.95, height: UIScreen.main.bounds.width/2.5)
                                                // .padding()
                                            })
                                        )
                                }
                                
                                // .padding(.bottom, UIScreen.main.bounds.width/40)
                                
                            }
                        }
                    }, label: {
                        
                        Text("모임 카드")
                            .font(.custom(Font.n_bold, size: UIScreen.main.bounds.width/25))
                            .foregroundColor(.proco_black)
                            .padding(.leading, UIScreen.main.bounds.width/20)
                    })
                    .padding([.trailing, .leading])
                    
                }
            }
        }
        .background(Color.proco_dark_white)
        .overlay(MyInfoDialog(main_vm: self.main_vm, show_friend_info: $my_info_dialog, socket: SockMgr.socket_manager, state_on: self.$state_on, profile_photo_path: self.$my_photo_path))
        .overlay(overlayView: Toast.init(dataModel: Toast.ToastDataModel.init(title: "카드가 \(self.lock_event_kind)되었습니다.", image: "checkmark"), show: self.$show_lock_alert), show: self.$show_lock_alert)
        //필터 뷰
        .sheet(isPresented: $show_filter){
            GroupFilterModal(main_vm: self.main_vm, show_filter: self.$show_filter)
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .onAppear{
            self.main_vm.applied_filter = false
            
            print("*************모여 볼래 메인 뷰 나타남****************")
            my_photo_path = UserDefaults.standard.string(forKey: "profile_photo_path") ?? ""
            
            //user defaults에서 내 닉네임 꺼내오는 메소드 실행. 그래야 내 카드만 골라서 보여줄 수 있음.
            main_vm.get_my_nickname()
            //카드 데이터 갖고 오는 통신
            main_vm.get_group_volleh_card_list()
            print("내 닉네임 확인 : \(main_vm.my_nickname)")
            
        }
        .onDisappear{
            print("*************모여 볼래 메인 뷰 사라짐****************")
        }
        
    }
}

extension GroupVollehMainView{
    
    var user_profile_view: some View{
        //상단에 내 프로필, on.off버튼, 필터 버튼 그룹
        
        HStack{
            
            ZStack(alignment: .bottomTrailing){
                
                if self.my_photo_path == "" {
                    //내 프로필
                    Image("main_profile_img")
                        .resizable()
                        .background(Color.gray.opacity(0.5))
                        .frame(width: UIScreen.main.bounds.width/6, height: UIScreen.main.bounds.width/6)
                        .cornerRadius(50)
                        .scaledToFit()
                        .padding([.leading], UIScreen.main.bounds.width/30)
                    
                }else{
                    
                    KFImage(URL(string: self.my_photo_path))
                        .loadDiskFileSynchronously()
                        .cacheMemoryOnly()
                        .fade(duration: 0.25)
                        .setProcessor(img_processor)
                        .onProgress{receivedSize, totalSize in
                            print("on progress: \(receivedSize), \(totalSize)")
                        }
                        .onSuccess{result in
                            print("성공 : \(result)")
                        }
                        .onFailure{error in
                            print("실패 이유: \(error)")
                            
                            Image("main_profile_img")
                                .resizable()
                                .frame(width: 40, height: 40)
                        }
                        .padding([.leading], UIScreen.main.bounds.width/30)
                }
            }
            .onTapGesture {
                self.my_info_dialog = true
                
            }
            
            Spacer()
            Group{
                HStack{
                    
                    Text(main_vm.my_nickname!)
                        .font(.custom(Font.n_bold, size: 13))
                        .foregroundColor(.proco_black)
                    
                    Spacer()
                    
                    //카드 추가하기 버튼
                    Button(action: {
                        
                        self.go_to_make_card.toggle()
                        print("카드 추가하는 뷰로 이동 토글 값 : \(self.go_to_make_card)")
                        
                    }, label: {
                        Image("main_plus_group")
                            .resizable()
                            .frame(width: 44, height: 44)
                    })
                    .padding([.trailing], UIScreen.main.bounds.width/20)
                }
            }
        }
    }
    
    var filter_btn : some View{
        HStack{
            Button(action: {
                
                self.show_filter.toggle()
                //만약 필터 결과가 없을 시에 alert창 띄우기
                // self.main_vm.result_alert(main_vm.alert_type)
                
            }){
                HStack{
                    ZStack(alignment: .leading){
                        
                        Image("main_filter")
                            .resizable()
                            .frame(width: 18, height: 18)
                        
                        if self.main_vm.applied_filter{
                            
                            Image("check_end_btn")
                                .resizable()
                                .frame(width: 13, height: 13)
                        }
                    }
                    Text("필터")
                        .font(.custom(Font.n_bold, size: 10))
                        .foregroundColor(.proco_black)
                }
            }
            .frame(width: 50, height: 50)
            
        }
    }
    
    var select_view_all_btn : some View{
        HStack{
            
            Button(action: {
                main_vm.get_group_volleh_card_list()
                self.main_vm.selected_filter_tag_set.removeAll()
                self.main_vm.selected_filter_tag_list.removeAll()
                print("전체보기 버튼 클릭")
                self.main_vm.applied_filter = false
                
            }){
                
                Text("전체보기")
                    .font(.custom(Font.n_bold, size: 10))
                    .foregroundColor(self.main_vm.applied_filter ?  .light_gray : .proco_white)
                    .cornerRadius(25)
                    .padding(UIScreen.main.bounds.width/40)
            }
            .background(self.main_vm.applied_filter ? Color.gray :  Color.proco_black)
            .overlay(Capsule()
                        .stroke(self.main_vm.applied_filter ? Color.gray :  Color.proco_black, lineWidth: 1.5)
                     
            )
            .cornerRadius(25.0)
        }
        .padding([.trailing], UIScreen.main.bounds.width/20)
    }
    
    var my_applied_meetings_btn : some View{
        
        RoundedRectangle(cornerRadius: 5.0)
            .foregroundColor(Color.proco_black)
            .frame(width: UIScreen.main.bounds.width*0.3, height: UIScreen.main.bounds.width/15)
            .overlay(
                Button(action: {
                    print("신청 목록 보기 버튼 클릭")
                    self.go_to_apply_list = true
                    
                }){
                    Text("신청목록 보기")
                        .foregroundColor(Color.proco_white)
                        .font(.custom(Font.t_extra_bold, size: 13))
                }
                .padding(UIScreen.main.bounds.width/20)
            )
    }
    
    
}
