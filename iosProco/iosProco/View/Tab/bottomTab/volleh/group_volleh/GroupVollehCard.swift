//
//  GroupVollehCard.swift
//  proco
//
//  Created by 이은호 on 2020/11/29.
// 2-0 메인화면 모여볼래 카드 리스트

import SwiftUI
import Kingfisher

struct GroupVollehCard: View {
    @ObservedObject var main_vm : GroupVollehMainViewmodel
    //binding으로 했더니 카드 삭제시 계속 index에러 나서 state로 바꾼 것.
    @State var group_card : GroupCardStruct
    @State private var expiration_at = ""
    let img_processor = ResizingImageProcessor(referenceSize: CGSize(width: 43, height: 43)) |> RoundCornerImageProcessor(cornerRadius: 5)
    
    //모임 카드 이미지가 없는 경우 왼쪽에 공백 생기는 문제 해결 위함.
    var has_card_img : Bool{
        if self.group_card.card_photo_path == "" || self.group_card.card_photo_path == nil{
            return false
        }else{
            return true
        }
    }
    
    var body : some View{
        
        //카드 1개
        HStack{
            //카드 배경 위에 프로필 이미지, 이름, 상태타입, 시간 및 날짜, 태그
            //카드 1개 hstack 2칸으로 분할해서 수직 쌓기
            VStack{
                HStack{
                    if has_card_img{
                        card_img
                    }
                   category_and_title
                    Spacer()
                    
                    Image("card_label_blue")
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width*0.3, height: UIScreen.main.bounds.width/14)
                        .overlay(
                            
                    //카드 만료일
                            Text("\(self.expiration_at)")
                        .font(.custom(Font.n_extra_bold, size: 15))
                        .foregroundColor(.proco_white))
                }
                .padding(.leading)

                HStack{
                    current_user_num
                    Spacer()
                   
                }
                
                HStack{
                    like_icon_num
                    Spacer()
                    meeting_kinds_and_location
                }
            }
        }
        .onAppear{
            self.expiration_at = String.dot_form_date_string(date_string: group_card.expiration_at!)
           print("날짜 확인: \(self.expiration_at)")
        }
        //화면 하나에 카드 여러개 보여주기 위해 조정하는 값
        .frame(width: UIScreen.main.bounds.width*0.95, height: UIScreen.main.bounds.width*0.09)
    }
}

extension GroupVollehCard {
    
    var card_img : some View{
        HStack{
            KFImage(URL(string: self.group_card.card_photo_path!))
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
        .padding(.leading)
        .hidden(self.group_card.card_photo_path == "" || self.group_card.card_photo_path == nil)
    }
    
    var category_and_title : some View{
        VStack{
            HStack{
                
                Text("\(group_card.tags![0].tag_name)")
                    .font(.custom(Font.t_extra_bold, size: 13))
            .foregroundColor(.proco_white)
                    .padding(UIScreen.main.bounds.width/60)
                .background(group_card.tags![0].tag_name == "사교/인맥" ? Color.proco_yellow : group_card.tags![0].tag_name == "게임/오락" ? .proco_pink : group_card.tags![0].tag_name == "문화/공연/축제" ? .proco_olive : group_card.tags![0].tag_name == "운동/스포츠" ? .proco_green : group_card.tags![0].tag_name == "취미/여가" ? .proco_mint : group_card.tags![0].tag_name == "스터디" ? .proco_blue : .proco_red)
                    .cornerRadius(27.0)

                Spacer()
            }
            HStack{
            Text("\(group_card.title!)")
                .font(.custom(Font.n_extra_bold, size: 15))
                .foregroundColor(.proco_black)
                
                Spacer()
            }
        }
    }
    
    var card_date : some View{
        VStack{
            Image("card_label_blue")
                .resizable()
                .frame(width: UIScreen.main.bounds.width*0.3, height: UIScreen.main.bounds.width/14)
                .overlay(
                    
            //카드 만료일
                    Text("\(self.expiration_at)")
                .font(.custom(Font.n_extra_bold, size: 15))
                .foregroundColor(.proco_white))
                .padding(.top, UIScreen.main.bounds.width/20)
            Spacer()
        }
    }
    
    var current_user_num : some View{
        HStack{
            Image(self.group_card.cur_user ?? 0 > 0 ? "meeting_user_num_icon" : "")
                .resizable()
                .frame(width: 11, height: 11)
            
            Text(self.group_card.cur_user ?? 0 > 0 ? "\(self.group_card.cur_user!)명" : "")
                .font(.custom("", size: 13))
                .foregroundColor(.proco_black)
        }
        .padding(.leading)
    }
    
    var like_icon_num : some View{
        HStack{
            Button(action: {
                
                if self.group_card.like_state == 0{
                   
                    print("모임 카드 좋아요 클릭")
                    self.main_vm.send_like_card(card_idx: self.group_card.card_idx!)
                    
                }else{
                    print("모임 카드 좋아요 취소")
                    self.main_vm.cancel_like_card(card_idx: self.group_card.card_idx!)
                }
                
            }){
                
                if group_card.like_state == 0 {
                    
                    Image(systemName:  "heart")
                    .resizable()
                        .frame(width: UIScreen.main.bounds.width/21, height: UIScreen.main.bounds.width/25)
                        .foregroundColor(Color.proco_red)

                    
                }else{
                    
                    Image(systemName: "heart.fill")
                    .resizable()
                        .frame(width: UIScreen.main.bounds.width/21, height: UIScreen.main.bounds.width/25)
                        .foregroundColor(Color.proco_red)

                }
            
            }
            Text(group_card.like_count ?? 0 > 0 ? "좋아요\(group_card.like_count!)개" : "")
                .font(.custom(Font.t_extra_bold, size: 12))
            .foregroundColor(.proco_black)

        }
        .padding([.leading])
        .onReceive(NotificationCenter.default.publisher(for: Notification.clicked_like), perform: {value in
            print("내 카드 좋아요 클릭 통신 완료 받음.: \(value)")
            
            if let user_info = value.userInfo{
                let check_result = user_info["clicked_like"]
                print("내 카드 좋아요 데이터 확인: \(check_result)")
                
                if check_result as! String == "ok"{
                    let card = user_info["card_idx"] as! String
                    let card_idx = Int(card)
                    print("내 카드 좋아요 클릭한 idx: \(card_idx)")
                    
                    if card_idx == self.group_card.card_idx{
                        
                        self.group_card.like_count! += 1
                        self.group_card.like_state = 1

                }
                    
                }else if check_result as! String == "canceled_ok"{
                    let card = user_info["card_idx"] as! String
                    let card_idx = Int(card)
                    print("좋아요 취소한 idx: \(card_idx)")
                    if card_idx == self.group_card.card_idx{
                        self.group_card.like_count! -= 1
                        self.group_card.like_state = 0
                        
                }
            }
            }
        })
    }
    
    var meeting_kinds_and_location : some View{
        HStack{
            if group_card.kinds == "오프라인 모임"{
                Image("meeting_location_icon")
                    .resizable()
                    .frame(width: 12, height: 14)
                Text("\(self.group_card.address!)")
                    .font(.custom(Font.n_bold, size: 12))
                    .foregroundColor(Color.proco_black)
                
            }else{
                
                Image("small_chat_bubble_icon")
                    .resizable()
                    .frame(width: 12, height: 14)
                Text("온라인 채팅")
                    .font(.custom(Font.n_bold, size: 12))
                    .foregroundColor(Color.proco_black)
            }
        }
        .padding([.trailing])
    }
    
    
}

