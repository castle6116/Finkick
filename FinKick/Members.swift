//
//  Members.swift
//  FinKick
//
//  Created by 김진우 on 2021/03/15.
//

import UIKit

class Members: UIViewController{
    @IBOutlet weak var IdInputField: UITextField!
    @IBOutlet var IdOverlapCheck: UIButton!
    @IBOutlet weak var PwInputField: UITextField!
    @IBOutlet var PwCheckInputField: UITextField!
    @IBOutlet weak var LoginError: UILabel!
    @IBOutlet var PasswordError: UILabel!
    @IBOutlet var PasswordErrorCheck: UILabel!
    @IBOutlet var MembershipButton: UIButton!
    @IBOutlet var EmailCertificationButton: UIButton!
    @IBOutlet var EmailTime: UILabel!
    @IBOutlet var PhoneInputField: UITextField!
    @IBOutlet var PhoneError: UILabel!
    
    var loginID : String!
    var loginPW : String!
    // 아이디 중복 체크 함수
    var IdCheckoverlap : Int = 0
    var emailCheckoverlap : Int = 0
    var successs : Int = 0
    var timer : Timer?
    var timeLeft : Int = 600
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func EmailTimer(_ sender : Any?) {
        EmailTime.isHidden = false
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: true)
    }
    
    @objc func onTimerFires()
    {
        timeLeft -= 1
        var timeMin = timeLeft / 60
        var timeSec = timeLeft % 60
        EmailTime.text = String(timeMin)+" : "+String(timeSec)
        if timeLeft <= 0 {
            timer?.invalidate()
            timer = nil
            showToast(message: "인증 시간이 초과 되었습니다.")
            EmailTime.isHidden = true
        }
    }
    
    
    @IBAction func Emailauthentication() {
        if IdError(self){
            appDelegate.EmailAuthentication(value: "N", email: IdInputField.text!){
                (data, message) in
                if let data = data{
                    if data == 0 {
                        self.EmailTimer(self)
                        print("왜죠")
                    }
                    else {
                        self.showToast(message: message ?? "오류발생")
                    }
                }
                
            }
        }
    }
    // 아이디 생성시 서버간 통신에 사용되는 코드
    func MemberShipPush(complation : ((Int?) -> ())?) {
        
        appDelegate.Putmember(id: IdInputField.text!, password: PwInputField.text!, phoneNumber: PhoneInputField.text!)
        {
            (data, statusCode) in
            if let statusCode = statusCode{
                if data != nil {
                    self.MemberCodestat(data: data?.code,statusCode: statusCode,message: data?.message)
                    complation!(statusCode)
                }
                complation!(statusCode)
                
            }
        }
    }
    // 아이디 생성시 유효성 검사 코드
    func MemberCodestat(data: Int?,statusCode : Int?,message : String?) {
        if(statusCode == 200 && data == 0){
            self.showToast(message: message!)
            self.successs = 1
        }else if statusCode == 200 && data == -99{
            self.showToast(message: message!)
            self.successs = 0
        }else if(statusCode == 400){
            self.successs = 2
        }else{
            self.showToast(message: message!)
        }
    }
    //아이디 중복 체크시 서버간 통신 코드
    @IBAction func IdOverlapCheckfunction(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if(IdInputField.text != ""){
            IdCheckoverlap = 0
            appDelegate.Getid(InputId: IdInputField.text!) {
                (data, statusCode) in
                if let statusCode = statusCode{
                    self.IdCodestat(statusCode: statusCode)
                }
            }
        }
        if(IdInputField.text == ""){
            showToast(message: "아이디를 입력해 주세요")
        }
        
    }
    //아이디 체크시 유효성 검사로 비동기로 돌아가는 코드
    func IdCodestat(statusCode : Int?) {
        if(statusCode == 200 ){
            self.showToast(message: "아이디가 중복됩니다.")
        }else if(statusCode == 400){
            self.showToast(message: "이메일 형식으로 요청해주세요.")
        }else if(statusCode == 404){
            self.showToast(message: "사용가능한 아이디 입니다.")
            IdCheckoverlap = 1
            loginID = IdInputField.text
        }else{
            self.showToast(message: "문제가 발생하였습니다 관리자에게 문의 하십시요. 에러코드:\(statusCode)")
        }
        IdError(self)
    }

    @objc func PassError(_ sender: Any?) -> Bool{
        if PwCheck(pw: PwInputField.text) == false {
            PasswordError.text = "영어,숫자,특수문자 1개 이상 8~20자리"
            PasswordError.isHidden = false
            return false
        }else if PwCheck(pw: PwInputField.text) == true{
            PasswordError.isHidden = true
            
            if PwInputField.text == PwCheckInputField.text {
                PasswordErrorCheck.isHidden = true
                return true
            }else{
                PasswordErrorCheck.text = "비밀번호와 동일하지 않습니다."
                PasswordErrorCheck.isHidden = false
                return false
            }
        }
        return false
    }
    @objc func IdError(_ sender: Any?) -> Bool{
        if IdCheckoverlap == 0 {
            LoginError.text = "중복 체크를 해주세요."
            LoginError.isHidden = false
            return false
        }else if IdCheck(id: IdInputField.text) == false {
            LoginError.text = "이메일 양식으로 작성해주세요."
            LoginError.isHidden = false
            return false
        }else{
            LoginError.isHidden = true
            return true
        }
    }
    // 아이디 정규식
//    func IdCheck(id: String?) -> Bool {
//            guard id != nil else { return false }
//            let idRegEx = "^[a-zA-Z]{1}[a-zA-Z0-9_]{4,11}$"
//            let pred = NSPredicate(format:"SELF MATCHES %@", idRegEx)
//            return pred.evaluate(with: id)
//    }
    @objc func PhoneError(_ sender: Any?) -> Bool{
        if PhoneCheck(phone: PhoneInputField.text) == false {
            PhoneError.text = "전화번호가 잘못됐습니다."
            PhoneError.isHidden = false
            return false
        }else{
            PhoneError.isHidden = true
            return true
        }
    }
    // 비밀번호 정규식
    func PwCheck(pw: String?) -> Bool {
            guard pw != nil else { return false }
            let pwRegEx = "^(?=.*[0-9])(?=.*[a-z])(?=.*\\W)(?=\\S+$).{8,20}$"
            let pred = NSPredicate(format:"SELF MATCHES %@", pwRegEx)
            return pred.evaluate(with: pw)
    }
    //  이메일 정규식
    func IdCheck(id: String?) -> Bool {
            guard id != nil else { return false }
            let idRegEx = "^[_A-Za-z0-9-]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$"
            let pred = NSPredicate(format:"SELF MATCHES %@", idRegEx)
            return pred.evaluate(with: id)
    }
    //  전화번호 정규식
    func PhoneCheck(phone: String?) -> Bool {
        guard phone != nil else { return false }
        let phoneRegEx = "^01(?:0|1|[6-9])(\\d{4})(\\d{4})$"
        let pred = NSPredicate(format:"SELF MATCHES %@",phoneRegEx)
        return pred.evaluate(with: phone)
    }
    
    @IBAction func OkButtonClick(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if PassError(self) == true && IdError(self) == true && IdInputField.text == loginID && PhoneError(self) == true{
            
            MemberShipPush(){
                (statusCode) in
                if self.successs == 1 {
                    appDelegate.success = 1
                    appDelegate.ID = self.IdInputField.text
                    appDelegate.Pass = self.PwInputField.text
                    print(appDelegate.success)
                    self.view.window?.rootViewController?.dismiss(animated: false, completion: {
                    let homeVC = SecondViewController()
                        homeVC.modalPresentationStyle = .fullScreen
                        appDelegate.window?.rootViewController?.present(homeVC, animated: true, completion: nil)
                    })
                }
                
                else if self.IdInputField.text != self.loginID{
                    self.IdCheckoverlap = 0
                    self.showToast(message: "입력된 아이디와 중복체크한 아이디가 동일하지 않습니다.")
                }
                else if self.successs == 2{
                    appDelegate.success = 0
                    self.showToast(message: "회원가입에 실패하셨습니다.")
                }
            }
        }
    }
    
    func showToast(message : String) {
            let width_variable:CGFloat = 10
            let toastLabel = UILabel(frame: CGRect(x: width_variable, y: self.view.frame.size.height-200, width: view.frame.size.width-2*width_variable, height: 80))
            // 뷰가 위치할 위치를 지정해준다. 여기서는 아래로부터 100만큼 떨어져있고, 너비는 양쪽에 10만큼 여백을 가지며, 높이는 35로
            toastLabel.backgroundColor = UIColor.black.withAlphaComponent(1)
            toastLabel.textColor = UIColor.white
            toastLabel.textAlignment = .center;
            toastLabel.font = UIFont(name: "NanumSquareBold", size: 18.0)
            toastLabel.text = message
            toastLabel.alpha = 1.0
            toastLabel.layer.cornerRadius = 10;
            toastLabel.clipsToBounds  =  true
            self.view.addSubview(toastLabel)
            UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }, completion: {(isCompleted) in
                toastLabel.removeFromSuperview()
            })
            self.view.endEditing(true)
        }
    func KeyboardSetting()
        {
            //키보드가 올라올 때 리스너
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            
            //키보드가 내려갈 때 리스너
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        }

        //키보드가 올라온 순간
        @objc func keyboardWillShow(_ sender: Notification) {
            //내가 선택한 UITextfield가 편집모드일 때
            if(PwCheckInputField.isEditing)
            {
                //키보드의 높이
                if let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                    let keyboardHeight = keyboardSize.height
                    print(keyboardHeight)
                    
                    //가상 키보드 높이만큼 화면의 y값을 감소
                    self.view.frame.origin.y = -120
                }
            }else if(PhoneInputField.isEditing){
                if let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                    let keyboardHeight = keyboardSize.height
                    print(keyboardHeight)
                    
                    //가상 키보드 높이만큼 화면의 y값을 감소
                    self.view.frame.origin.y = -180
                }
            }
        }
        
        //키보드가 내려온 순간
        @objc func keyboardWillHide(_ sender: Notification) {
            //화면 원상복귀
            self.view.frame.origin.y = 0
        }
    //빈 화면 터치 시 키보드 내림
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){

          self.view.endEditing(true)

    }
    override func viewWillAppear(_ animated: Bool) {
        LoginError.isHidden = true
        PasswordError.isHidden = true
        PasswordErrorCheck.isHidden = true
        PhoneError.isHidden = true
        EmailTime.isHidden = true
        IdInputField.keyboardType = .asciiCapable
        PwInputField.keyboardType = .asciiCapable
        PhoneInputField.keyboardType = .phonePad
    }
    //프로그램이 시작 될 때 제일 처음 실행 되는 함수
    override func viewDidAppear(_ animated: Bool) {
        
    }
    // 앱이 실행 되는 동안 계속 돌아가는 함수
    override func viewDidLoad() {
        KeyboardSetting()
        print(IdCheckoverlap)
        self.IdInputField.addTarget(self, action: #selector(self.IdError(_:)), for: .editingChanged)
        self.PwInputField.addTarget(self, action: #selector(self.PassError(_:)), for: .editingChanged)
        self.PwCheckInputField.addTarget(self, action: #selector(self.PassError(_:)), for: .editingChanged)
        self.PhoneInputField.addTarget(self, action: #selector(self.PhoneError(_:)), for: .editingChanged)
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
}
