//
//  AddScheduleView.swift
//  proco
//
//  Created by 이은호 on 2021/03/15.
//

import SwiftUI

struct AddScheduleView: View {
    @Environment(\.presentationMode) var presentation
    @StateObject var main_vm: CalendarViewModel
    @Binding var back_to_calendar: Bool
    @State private var title: String = ""
    //메모 글자 수
    @State private var txt_count = "0"
    //스케줄 추가시 날짜 데이터 저장할 변수 - 기존에 뷰모델 변수 사용했더니 observable로 인해 모든 코드들이 돌아가버림.
    @State private var schedule_start_date : Date = Date()
    //시간 데이터 저장
    @State private var schedule_start_time : Date = Date()
    //메모 데이터 저장
    @State private var schedule_memo : String = ""
    
    var add_schedule_ok: Bool{
        return !self.title.isEmpty
    }
    
    func date_to_string(date: Date) -> String{
        let day = DateFormatter.dateformatter.string(from: date)
        print("date형식: \(date), 변환된 형식: \(day)")
        return day
    }
    
    var body: some View {
        VStack{
            HStack{
                Button(action: {
                    print("닫기 버튼 클릭")
                    self.presentation.wrappedValue.dismiss()
                }){
                    Image("card_dialog_close_icon")
                        .resizable()
                        .frame(width:13.89, height: 13.89)
                    
                }
                Spacer()
                Text("일정추가")
                    .font(.custom(Font.t_extra_bold, size: 22))
                    .foregroundColor(Color.proco_black)
                Spacer()
                Button(action: {
                    
                    print("개인 일정 추가 완료 버튼 클릭")
                    
                    let schedule_date = self.date_to_string(date: self.schedule_start_date).split(separator: " ")[0]
                    //시간만 string으로 변환하는데 사용하는 메소드. 생각보다 간단함.
                    let schedule_start_time = DateFormatter.time_formatter.string(from: self.schedule_start_time)
                    
                    print("시간 정보 date: \(self.schedule_start_time)")
                    print("시간 정보 string: \(schedule_start_time)")
                    print("제목 정보 입력한 것: \(title)")
                    
                    self.main_vm.add_personal_schedule(title: self.title, content: self.schedule_memo, schedule_date: String(schedule_date), schedule_start_time: String(schedule_start_time))
                    
                    //캘린더뷰로 돌아감.
                    self.back_to_calendar = false
                    
                }){
                    Image("check_end_btn")
                        .resizable()
                        .frame(width: 40, height: 40)
                    
                    //일정 제목, 날짜, 시간을 입력해야만 활성화되도록 처리.
                }
                .disabled(!self.add_schedule_ok)
                
                
            }
            .padding()
            
            TextField("일정을 입력해주세요", text: self.$title)
                .font(.custom(Font.n_regular, size: 15))
                .foregroundColor(Color.proco_black)
                .padding([.leading, .trailing], UIScreen.main.bounds.width/20)
                .overlay(VStack{Divider().offset(x: 0, y: 15)})
            //날짜 선택 칸
            //in: 은 미래 날짜만 선택 가능하도록 하기 위함. displayedComponents: 시간을 제외한 날짜만 캘린더에 보여주기 위함.
            HStack{
                Text("날짜")
                    .font(.custom(Font.t_extra_bold, size: 16))
                    .foregroundColor(Color.proco_black)
                
                DatePicker("", selection: self.$schedule_start_date, in: Date()..., displayedComponents: .date)
                    .font(.custom(Font.n_bold, size: 17))
                    .foregroundColor(Color.proco_black)
                    //다이얼로그식 캘린더 스타일
                    .datePickerStyle(CompactDatePickerStyle())
                    .environment(\.locale, Locale.init(identifier: "ko_KR"))
            }
            .padding()
            //시간 입력 칸
            HStack{
                Text("시간")
                    .font(.custom(Font.t_extra_bold, size: 16))
                    .foregroundColor(Color.proco_black)
                
                DatePicker("시간", selection: self.$schedule_start_time, displayedComponents: .hourAndMinute)
                    .font(.custom(Font.n_bold, size: 17))
                    .foregroundColor(Color.proco_black)
                    .labelsHidden()
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .environment(\.locale, Locale.init(identifier: "ko_KR"))
            }
            .padding()
            //메모 입력 필드
            HStack{
                Text("메모")
                    .font(.custom(Font.t_extra_bold, size: 16))
                    .foregroundColor(Color.proco_black)
                
                Text("\(self.txt_count)")
                    .foregroundColor(Color.gray)
                    .font(.custom(Font.n_regular, size: 10))
                
                Spacer()
            }
            .padding()
            
            HStack{
                TextEditor(text: self.$schedule_memo)
                    .font(.custom(Font.n_regular, size: 12))
                    .foregroundColor(Color.proco_black)
                    .foregroundColor(self.schedule_memo == "내용을 입력해주세요" ? .gray : .primary)
                    .colorMultiply(Color.light_gray)
                    .cornerRadius(3)
                    .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.width*0.4)
                    .onChange(of: self.schedule_memo) { value in
                        print("메모 onchange 들어옴")
                        //현재 몇 글자 작성중인지 표시
                        self.txt_count = "\(value.count)/255"
                        if value.count > 255 {
                            print("255글자 넘음")
                            self.schedule_memo = String(value.prefix(255))
                        }
                    }
                
            }
            .font(.custom(Font.t_extra_bold, size: 16))
            .foregroundColor(Color.proco_black)
            Spacer()
        }
        //키보드 올라왓을 때 화면 다른 곳 터치하면 키보드 내려가는 것
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .onAppear{
            self.main_vm.schedule_state_changed = false
        }
        .onDisappear{
            //스케줄 모델 objectwillchange 보내는 것.
            self.main_vm.schedule_state_changed = true
        }
    }
}

