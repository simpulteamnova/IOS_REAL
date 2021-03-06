//
//  MyCardListView.swift
//  proco
//
//  Created by 이은호 on 2020/12/24.
// 친구랑 볼래 내 카드 카테고리 리스트

import SwiftUI
import Kingfisher

struct MyCardListView: View {
    
    @ObservedObject var main_viewmodel: FriendVollehMainViewmodel
    @State var my_volleh_card_struct : FriendVollehCardStruct
    
    //선택한 카드의 인덱스값을 알기 위해 친구랑 볼래 메인 뷰에서 받는다.
    var current_card_index : Int
    
    @State private var expiration_at = ""
    //카드 잠금 이벤트시 토스트 띄우기 위한 구분값
    @Binding var show_lock_alert : Bool
    //카드 잠금인지 잠금해제인지 이벤트 종류 알기 위해 저장할값 - 토스트에 띄움
    @Binding var lock_event_kind : String
    
    //이미지 원처럼 보이게 하기 위해 scale값을 곱함.
    let scale = UIScreen.main.scale
    let img_processor = ResizingImageProcessor(referenceSize: CGSize(width: UIScreen.main.bounds.width/6, height: UIScreen.main.bounds.width/6)) |> RoundCornerImageProcessor(cornerRadius: 25)
    
    let my_profile_img = UserDefaults.standard.string(forKey: "profile_photo_path") ?? ""
    var body: some View{
        
        //카드 1개
        HStack{
            //카드 배경 위에 프로필 이미지, 이름, 상태타입, 시간 및 날짜, 태그
            //카드 1개 hstack 2칸으로 분할해서 수직 쌓기
            VStack{
                HStack{
                    //채팅방에서 내 카드 리스트를 보여줄 때는 서버에서 creator정보 안줘서 소켓 클래스에서 가져옴.
                    card_owner_img
                        .padding([.leading, .top], UIScreen.main.bounds.width/20)
                    
                    nickname_and_category
                    Spacer()
                    Image("card_label_orange")
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width*0.3, height: UIScreen.main.bounds.width/14)
                        .overlay(
                            
                            //카드 만료일
                            Text("\(self.expiration_at)")
                                .font(.custom(Font.n_extra_bold, size: 15))
                                .foregroundColor(.proco_white)
                        )
                }
                tags
                
                HStack{
                    if SockMgr.socket_manager.is_from_chatroom{}else{
                        like_icon
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        print("잠금 버튼 클릭")
                        //0: 안 잠금 1: 잠금
                        if self.my_volleh_card_struct.lock_state == 0{
                            print("카드 잠그기")
                            self.main_viewmodel.lock_card(card_idx: self.my_volleh_card_struct.card_idx!, lock_state: 1)
                        }else{
                            print("카드 열기")
                            
                            self.main_viewmodel.lock_card(card_idx: self.my_volleh_card_struct.card_idx!, lock_state: 0)
                        }
                        
                    }){
                        
                        Image(self.my_volleh_card_struct.lock_state == 0 ? "lock_public" : "lock_private")
                            .resizable()
                            .frame(width: 15, height: 16.61)
                            .padding(.trailing)
                        
                    }
                    .onReceive(NotificationCenter.default.publisher(for: Notification.event_finished), perform: {value in
                        print("내 카드 잠금 통신 완료 받음.: \(value)")
                        
                        if let user_info = value.userInfo,  let check_result = user_info["lock"]{
                           
                            print("내 카드 잠금 데이터 확인: \(check_result)")
                            
                            if check_result as! String == "잠금"{
                                let card = user_info["card_idx"] as! String
                                let card_idx = Int(card)
                                print("내 카드 잠금한 idx: \(card_idx)")
                                
                                if card_idx == self.my_volleh_card_struct.card_idx{
                                    
                                    self.my_volleh_card_struct.lock_state = 1
                                    self.lock_event_kind = "잠금"
                                    self.show_lock_alert = true
                                }
                            }else if check_result as! String == "잠금해제"{
                                
                                let card = user_info["card_idx"] as! String
                                let card_idx = Int(card)
                                print("잠금 취소한 idx: \(card_idx)")
                                if card_idx == self.my_volleh_card_struct.card_idx{
                                    self.my_volleh_card_struct.lock_state = 0
                                    self.lock_event_kind = "잠금 해제"
                                    self.show_lock_alert = true
                                }
                            }
                        }
                    })
                    
                }
                .padding(.bottom, UIScreen.main.bounds.width/20)
            }
        }
        .onAppear{
            print("변환하려는 날짜 my card list view에서 : \(my_volleh_card_struct.expiration_at!)")
            self.expiration_at = String.dot_form_date_string(date_string: my_volleh_card_struct.expiration_at!)
            print("날짜 확인: \(self.expiration_at)")
            
        }
        //화면 하나에 카드 여러개 보여주기 위해 조정하는 값
        .frame(width: UIScreen.main.bounds.width*0.95, height: UIScreen.main.bounds.width*0.09)
        
    }
}

private extension MyCardListView{
    
    var like_icon : some View{
        HStack{
            Button(action: {
                if self.my_volleh_card_struct.like_state == 0{
                    //좋아요 클릭 이벤트
                    print("좋아요 클릭: \(String(describing: self.my_volleh_card_struct.like_state))")
                    
                    self.main_viewmodel.send_like_card(card_idx: self.my_volleh_card_struct.card_idx!)
                    
                }else{
                    
                    print("좋아요 취소")
                    
                    self.main_viewmodel.cancel_like_card(card_idx: self.my_volleh_card_struct.card_idx!)
                }
            }){
                if self.my_volleh_card_struct.like_state == 0 {
                    
                    Image(systemName: "heart")
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width/21, height: UIScreen.main.bounds.width/25)
                        .padding([.leading], UIScreen.main.bounds.width/20)
                        .foregroundColor(Color.proco_red)

                    
                }else{
                    
                Image(systemName: "heart.fill")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width/21, height: UIScreen.main.bounds.width/25)
                    .padding([.leading], UIScreen.main.bounds.width/20)
                    .foregroundColor(Color.proco_red)

                }
            }
            
            Text(my_volleh_card_struct.like_count > 0 ? "좋아요 \(my_volleh_card_struct.like_count)개" : "")
                .font(.custom(Font.t_extra_bold, size: 12))
                .foregroundColor(.proco_black)
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.clicked_like), perform: {value in
            print("내 카드 좋아요 클릭 통신 완료 받음.: \(value)")
            
            if let user_info = value.userInfo{
                let check_result = user_info["clicked_like"]
                print("내 카드 좋아요 데이터 확인: \(check_result)")
                
                if check_result as! String == "ok"{
                    let card = user_info["card_idx"] as! String
                    let card_idx = Int(card)
                    print("내 카드 좋아요 클릭한 idx: \(card_idx)")
                    
                    if card_idx == self.my_volleh_card_struct.card_idx{
                        
                        self.my_volleh_card_struct.like_count += 1
                        self.my_volleh_card_struct.like_state = 1
                        
                    }
                    
                }else if check_result as! String == "canceled_ok"{
                    let card = user_info["card_idx"] as! String
                    let card_idx = Int(card)
                    print("좋아요 취소한 idx: \(card_idx)")
                    if card_idx == self.my_volleh_card_struct.card_idx{
                        self.my_volleh_card_struct.like_count -= 1
                        self.my_volleh_card_struct.like_state = 0
                    }
                }
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: Notification.get_data_finish), perform: {value in
            
            if let user_info = value.userInfo, let data = user_info["friend_card_edited"]{
                print("모임 카드 편집 노티 \(data)")
                
                if data as! String == "ok"{
                    
                  let card_idx = user_info["card_idx"] as! String
                    
                    //편집한 카드인 경우
                    if self.my_volleh_card_struct.card_idx! == Int(card_idx){
                      
                      
                        let tags = user_info["tags"] as! [FriendVollehTags]
                        
                        print("노티에서 받은 태그 : \(tags)")
                        
                
                        self.my_volleh_card_struct.expiration_at = self.main_viewmodel.card_expire_time
                        //이전에 입력했던 태그 삭제하고 업데이트하는 형식.그래야 이전 태그와 중첩돼서 저장 안됨.
                        self.my_volleh_card_struct.tags?.removeAll()
                        self.my_volleh_card_struct.tags =  tags
                        
                        self.expiration_at = String.dot_form_date_string(date_string: self.main_viewmodel.card_expire_time)

                        //편집한 데이터 집어넣고는 publish변수에 있던 값들 없애주기
                        self.main_viewmodel.card_expire_time = ""
                        self.main_viewmodel.user_selected_tag_list = []
                        self.main_viewmodel.user_selected_tag_set = []
                      
                    }
                }
            }else{
                print("모임카드 편집 노티 아님")
            }
        })
    }
    
    var tags: some View{
        
        HStack{
            if SockMgr.socket_manager.is_from_chatroom{
                if self.my_volleh_card_struct.tags?.count ?? 0 > 0{
                    ForEach(self.my_volleh_card_struct.tags!.indices){index in
                        //index 0태그는 카테고리이므로 빼고 보여준다.
                        if index == 0{
                        }else{
                            HStack{
                                Image("tag_sharp")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: UIScreen.main.bounds.width/15, height: UIScreen.main.bounds.width/15)
                                    .padding([.leading], UIScreen.main.bounds.width/20)
                                
                                Text("\(my_volleh_card_struct.tags![index].tag_name!)")
                                    .font(.custom(Font.n_bold, size: 15))
                                    .foregroundColor(.proco_black)
                                
                            }
                        }
                    }
                }
            }else{
                //TODO: if문 - 카드 삭제시 리스트 갯수 업데이트 안돼서 문제 발생 아래 코드로 해결. 나중에 다시 볼 것.
                if self.my_volleh_card_struct.tags?.count ?? 0 > 0{
                    
                    //태그들도 리스트를 포함하고 있기 때문에 여기서 다시 foreach문 돌림.
                    ForEach(my_volleh_card_struct.tags!.indices, id: \.self){ index in
                        if index == 0{

                        }else{
                            
                            HStack{

                                Image("tag_sharp")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: UIScreen.main.bounds.width/15, height: UIScreen.main.bounds.width/15)
                                    .padding([.leading], UIScreen.main.bounds.width/20)

                                Text("\(my_volleh_card_struct.tags![index].tag_name!)")
                                    .font(.custom(Font.n_bold, size: 15))
                                    .foregroundColor(.proco_black)
                            }
                        }
                        
                        
                    }
                }
            }
            Spacer()
        }
    }
    
    var nickname_and_category: some View{
        
        VStack{
            ///카테고리
            if SockMgr.socket_manager.is_from_chatroom{
                
                 HStack{
                    
                    Text("\(my_volleh_card_struct.tags![0].tag_name!)")
                        .font(.custom(Font.t_extra_bold, size: 13))
                        .foregroundColor(.proco_white)
                        .padding(UIScreen.main.bounds.width/60)
                 }
                 .background(my_volleh_card_struct.tags![0].tag_name! == "사교/인맥" ? Color.proco_yellow : my_volleh_card_struct.tags![0].tag_name! == "게임/오락" ? .proco_pink : my_volleh_card_struct.tags![0].tag_name! == "문화/공연/축제" ? .proco_olive : my_volleh_card_struct.tags![0].tag_name! == "운동/스포츠" ? .proco_green : my_volleh_card_struct.tags![0].tag_name! == "취미/여가" ? .proco_mint : my_volleh_card_struct.tags![0].tag_name! == "스터디" ? .proco_blue : .proco_red)
                 .cornerRadius(27.0)

                
            }else{
                //TODO: if문 - 카드 삭제시 리스트 갯수 업데이트 안돼서 문제 발생 아래 코드로 해결. 나중에 다시 볼 것.
                if main_viewmodel.my_friend_volleh_card_struct.count > self.current_card_index{
                    
                    HStack{
                       
                       Text("\(my_volleh_card_struct.tags![0].tag_name!)")
                           .font(.custom(Font.t_extra_bold, size: 13))
                           .foregroundColor(.proco_white)
                           .padding(UIScreen.main.bounds.width/60)
                    }
                    .background(my_volleh_card_struct.tags![0].tag_name! == "사교/인맥" ? Color.proco_yellow : my_volleh_card_struct.tags![0].tag_name! == "게임/오락" ? .proco_pink : my_volleh_card_struct.tags![0].tag_name! == "문화/공연/축제" ? .proco_olive : my_volleh_card_struct.tags![0].tag_name! == "운동/스포츠" ? .proco_green : my_volleh_card_struct.tags![0].tag_name! == "취미/여가" ? .proco_mint : my_volleh_card_struct.tags![0].tag_name! == "스터디" ? .proco_blue : .proco_red)
                    .cornerRadius(27.0)
                }
            }
            
            ///내 닉네임
            //채팅방에서 내 카드 리스트를 보여줄 때는 서버에서 creator정보 안줘서 소켓 클래스에서 가져옴.
            if SockMgr.socket_manager.is_from_chatroom{
                
                Text(ChatDataManager.shared.my_nickname!)
                    .font(.custom(Font.n_bold, size: 15))
                    .foregroundColor(.proco_black)
                
            }else{
                //친구 이름
                Text(self.main_viewmodel.my_nickname!)
                    .font(.custom(Font.n_bold, size: 15))
                    .foregroundColor(.proco_black)
            }
        }
        
    }
    
    var card_owner_img : some View{
        VStack{
            if SockMgr.socket_manager.is_from_chatroom{
                
                if SockMgr.socket_manager.my_profile_photo == "" {
                    
                    Image("main_profile_img")
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width/6, height: UIScreen.main.bounds.width/6)
                        .scaledToFit()
                        .padding([.trailing], UIScreen.main.bounds.width/30)
                }else{
                    KFImage(URL(string: SockMgr.socket_manager.my_profile_photo))
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
                        }
                    
                }
                
            }else{
                //프로필 이미지는 없을 수 있기 때문에 나눔.
                if  my_profile_img == ""{
                    
                    Image("main_profile_img")
                        .resizable()
                        .background(Color.gray.opacity(0.5))
                        .frame(width: UIScreen.main.bounds.width/6, height: UIScreen.main.bounds.width/6)
                        .cornerRadius(50)
                        .scaledToFit()
                        .padding([.trailing], UIScreen.main.bounds.width/30)
                    
                }else{
                    KFImage(URL(string: my_profile_img))
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
                        }
                    
                }
                
            }
        }
    }
}

