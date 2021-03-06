//
//  phone_auth_view.swift
//  iosProco
//
//  Created by 이은호 on 2020/11/10.
//
import Alamofire
import SwiftyJSON
import SwiftUI
//인증요청 alert창 위한 struct
struct alert_message: Identifiable {
    let id = UUID()
    let text: String
}


struct PhoneAuthView: View {
    @Environment(\.presentationMode) private var presentation
    
    //핸드폰 번호 맞는지 체크, 값 저장하기 위함.
    @StateObject var phone_viewmodel : SignupViewModel
    
    //인증 alert창에 메세지 구분값 주기 위한 변수
    @State private var auth_result: String = ""
    
    //핸드폰 번호 형식 맞는지 구분 변수
    @State private var is_phone_number_valid: Bool = false
    //인증번호 맞는지 체크
    @State private var is_auth_number_result: Bool = false
    
    //애플 로그인시 핸드폰 인증 진행하므로 애플로그인임을 알 수 있도록 구분값.
    @Binding var apple_login : Bool
    //애플로그인에서 핸드폰 인증 완료시 메인으로 이동시키기....서버 response에 따라 처리해줘야 함.
    @State private var apple_login_end : Bool = false
    //핸드폰 번호 인증 다음 단계로 이동 구분값
    @State private var go_next_stage : Bool = false
    
    var body: some View {
        NavigationView{
            VStack(alignment: .leading){
                
                title_view
                
                //핸드폰 번호 입력 필드
                Group{
                    phone_input_field
                    //핸드폰 번호 양식에 알맞지 않을 경우 나타나는 경고 문구
                    if !self.is_phone_number_valid{
                        wrong_phone_guide_txt
                    }
                    
                    //인증 요청 버튼
                    HStack{
                        Spacer()
                        //핸드폰 번호를 서버로 전송한다. response로 인증번호를 받는다.사용자가 입력한 인증번호와 같은지 비교한다.
                        Button(action:{
                            self.request_auth_number()
                            //인증요청 버튼 클릭 후 알림창 띄우기 위해 메소드를 버튼에 등록해 놓는 것.
                            phone_viewmodel.request_result_alert_func(phone_viewmodel.request_result_alert)
                        }){
                            Image(self.is_phone_number_valid ? "verify_active_btn" : "verify_inactive_btn")
                            
                        }
                        .disabled(!self.is_phone_number_valid)
                        .padding(.trailing, UIScreen.main.bounds.width/25)
                        .alert(isPresented: self.$phone_viewmodel.show_result_alert){
                            switch phone_viewmodel.request_result_alert{
                            case .success :
                                return Alert(title: Text(""),message: Text( "인증번호를 전송했습니다. 6분 이내에 입력해주세요"), dismissButton: .default(Text("확인")))
                            case .already_sended:
                                return Alert(title: Text(""),message: Text("인증 번호가 전송된 번호입니다"), dismissButton: .default(Text("확인")))
                            case .fail:
                                return Alert(title: Text(""),message: Text("인증요청을 다시 시도해주세요"), dismissButton: .default(Text("확인")))
                                
                            case .already_exist_user:
                                return Alert(title: Text(""),message: Text("이미 가입된 정보입니다."), dismissButton: .default(Text("확인")))
                            }
                        }
                    }
                }
                
                //self를 붙여서 회원가입 정보 저장하는 클래스에 데이터 저장.
                auth_input_field
                //인증번호가 알맞지 않은 경우 나타나는 경고 문구
                if self.is_auth_number_result{
                    if auth_result == "invalid"{
                        wrong_auth_guide_txt
                            .padding(.leading, UIScreen.main.bounds.width/15)
                        
                    }else if auth_result == "error"{
                        already_auth_guide_txt
                            .padding(.leading, UIScreen.main.bounds.width/15)
                    }
                }
                
                Spacer()
                HStack{
                    NavigationLink("",destination: TabbarView(view_router: ViewRouter()), isActive: self.$apple_login_end)
                    
                    if self.apple_login{
                        Button(action: {
                            //TODO 인증번호가 올바를 경우에 화면 이동시킬 것.
                            self.apple_login_end.toggle()
                            //인증요청 버튼 클릭 후 알림창 띄우기 위해 메소드를 버튼에 등록해 놓는 것.
                            phone_viewmodel.request_result_alert_func(phone_viewmodel.request_result_alert)
                            
                        }){
                            next_btn_txt
                        }
                        .disabled(auth_result == "" || auth_result != "ok")
                        
                    }else{
                        //다음 버튼 클릭시 인증번호 서버로 보내서 맞는지 확인하고 맞아야 이동 가능, self붙여야 데이터를 그대로 담아서 보낼 수 있음.
                        NavigationLink("",destination: SignupPasswordView(info_viewmodel: self.phone_viewmodel).navigationBarHidden(true), isActive: $go_next_stage )
                        
                        Button(action: {
                            send_auth_num()
                            
                            print("이메일 패스워드 이동하는 버튼 클릭")
                        }){
                            next_btn_txt
                        }
                        .disabled(!self.phone_viewmodel.auth_num_check)
                        //뷰가 사라질 때 값 저장하기
                        .onDisappear{
                          print("핸드폰 인증 뷰 사라짐")
                        }
                        .padding(.bottom, UIScreen.main.bounds.width/20)
                    }
                }
                //큰 vstack끝
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
            .background( Image("signup_second")
                            .resizable()
                            .scaledToFill())
        }
        //body끝
    }
    
    func request_auth_number(){
        APIClient.phone_auth_api(phone_num: self.phone_viewmodel.phone_number, type: "signup", completion: {result in
            if result.exists(){
                print("핸드폰 인증 첫번째 뷰에서 \(result)")
                let result_string = result["result"].stringValue
                print("result 뽑은 것 확인: \(result_string)")
                
                //인증요청 버튼 클릭 후 알림창 띄우기 위해 메소드를 버튼에 등록해 놓는 것.
                //                phone_viewmodel.request_result_alert_func(phone_viewmodel.request_result_alert)
                
                //응답 : 인증문자 전송됨 : message sended
                if(result_string == "already send auth message"){
                    phone_viewmodel.request_result_alert = .already_sended
                    
                }else if result_string == "already exist user"{
                    phone_viewmodel.request_result_alert = .already_exist_user
                                        
                }else if result_string == "message sended"{
                    phone_viewmodel.request_result_alert = .success

                }else{
                    phone_viewmodel.request_result_alert = .fail
                }
            }
        })
    }
    
    //$phone_viewmodel.phone_auth_num이라고 하면 바인딩 값이기 때문에 오류남.
    //인증번호 확인용 통신..다음 버튼 클릭시 통신 -> 확인되면 다음 페이지로 이동시키기. -> 틀릴 경우 빨간색 가이드 문자 나타내기
    func send_auth_num(){
        APIClient.check_phone_auth_api(phone_num: self.phone_viewmodel.phone_number, auth_num: self.phone_viewmodel.auth_num ,type: "confirm", completion: {result in
            
            //로그에 json으로 나옴
            print("핸드폰 인증뷰에서 \(result)")
            
            if result.exists(){
                is_auth_number_result = true
                let result_string = result["result"].string
                
                //만약 인증번호가 일치한다는 결과일 경우
                if (result_string ==  "ok"){
                    //뷰모델에도 데이터 저장
                    //phone_viewmodel.phone_auth_ok = true
                    auth_result = "ok"
                    self.go_next_stage = true
                }
                //인증번호가 일치하지 않을 경우
                else if result_string == "invalid auth num"{
                    // phone_viewmodel.phone_auth_ok = false
                    auth_result = "invalid"
                }  //인증번호가 일치하지 않을 경우
                else if result_string == "invalid auth number"{
                    // phone_viewmodel.phone_auth_ok = false
                    auth_result = "invalid"
                }
                //이미 인증한 경우
                else {
                    // phone_viewmodel.phone_auth_ok = true
                    auth_result = "already"
                }

                //통신에 실패한 경우
            }else{
                phone_viewmodel.phone_auth_ok = false
                print("핸드폰 인증 뷰에서 \(Error.self)")
                auth_result = "error"
                // phone_viewmodel.request_result_alert = .fail
            }
            
        })
    }
}

extension PhoneAuthView{
    
    var title_view: some View{
        HStack(alignment: .center){
            Button(action: {
                self.presentation.wrappedValue.dismiss()
                
            }){
                Image("left")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
            }
            .frame(width: 45, height: 45, alignment: .leading)
            
            Spacer()
            
            Text("휴대폰 인증")
                .font(.custom(Font.n_extra_bold, size: 20))
                .foregroundColor(Color.proco_black)
                .padding(.trailing)

            Spacer()
        }
        .padding([.trailing, .leading])
    }
    
    var phone_input_field: some View{
        HStack{
            Text("+82").padding([.leading, .trailing], UIScreen.main.bounds.width/20)
            
            TextField("휴대폰 번호", text: self.$phone_viewmodel.phone_number, onCommit: {
                print("핸드폰 번호 입력창 들어옴")
                
                print("입력창 is changed!")
                //phone_viewmodel에 있는 정규식 체크 메소드를 사용해 핸드폰 번호 양식 확인함.
                if self.phone_viewmodel.validator_phonenumber(self.phone_viewmodel.phone_number){
                    self.is_phone_number_valid = true
                    print("저장된 핸드폰 번호 확인 : \(self.phone_viewmodel.phone_number)")
                    
                }else{
                    print("입력창 is changed Else")
                    
                    self.is_phone_number_valid = false
                    // self.phone_viewmodel.phone_number = ""
                }
                
            })
            .onChange(of: self.phone_viewmodel.phone_number){ value in
                print("입력창 is changed!")
                //phone_viewmodel에 있는 정규식 체크 메소드를 사용해 핸드폰 번호 양식 확인함.
                if self.phone_viewmodel.validator_phonenumber(self.phone_viewmodel.phone_number){
                    self.is_phone_number_valid = true
                    print("저장된 핸드폰 번호 확인 : \(self.phone_viewmodel.phone_number)")
                    
                }else{
                    print("입력창 is changed Else")
                    
                    self.is_phone_number_valid = false
                    // self.phone_viewmodel.phone_number = ""
                }
            }
            .font(.custom(Font.n_regular, size: 15))
            .foregroundColor(Color.gray)
            .keyboardType(.phonePad)
        }
        .padding()
        .background(Color.proco_white)
        .cornerRadius(25.0)
        .shadow(color: .gray, radius: 2, x: 0, y: 2)
        .padding([.leading, .trailing, .top], UIScreen.main.bounds.width/20)
    }
    
    var auth_input_field: some View{
        TextField("인증번호 6자리", text: self.$phone_viewmodel.auth_num,onCommit: {
            print("인증번호\(self.$phone_viewmodel.auth_num)")
            if self.phone_viewmodel.auth_num != "" && self.phone_viewmodel.phone_number != ""{
            send_auth_num()
            }
            
        })
        .font(.custom(Font.n_regular, size: 15))
        .foregroundColor(Color.gray)
        .padding()
        .background(Color.proco_white)
        .cornerRadius(25.0)
        .shadow(color: .gray, radius: 2, x: 0, y: 2)
        .padding([.leading, .trailing], UIScreen.main.bounds.width/20)
    }
    
    var wrong_phone_guide_txt: some View{
        Text("핸드폰 번호를 알맞게 입력해주세요")
            .font(.custom(Font.n_regular, size: 12))
            .foregroundColor(Color.proco_red)
            .padding(.leading, UIScreen.main.bounds.width/15)
    }
    
    var wrong_auth_guide_txt: some View{
        Text("잘못된 인증번호 입니다")
            .font(.custom(Font.n_regular, size: 12))
            .foregroundColor(Color.proco_red)
    }
    
    var already_auth_guide_txt:some View{
        Text("이미 인증된 번호입니다")
            .font(.custom(Font.n_regular, size: 12))
            .foregroundColor(Color.proco_red)
    }
    
    var next_btn_txt: some View{
        Text("다음")
            .font(.custom(Font.t_extra_bold, size: 15))
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .foregroundColor(.proco_white)
            .background(self.phone_viewmodel.auth_num_check && self.is_phone_number_valid ?  Color.proco_black : Color.light_gray)
            .cornerRadius(25)
            .padding([.leading, .trailing], UIScreen.main.bounds.width/25)
            
    }
    
}
