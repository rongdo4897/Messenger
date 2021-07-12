//
//  ViewController.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 28/05/2021.
//

import UIKit
import ProgressHUD

class LoginViewController: UIViewController {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var lblPass: UILabel!
    @IBOutlet weak var tfPass: UITextField!
    @IBOutlet weak var lblRe_Pass: UILabel!
    @IBOutlet weak var tfRe_Pass: UITextField!
    @IBOutlet weak var viewLineRe_Pass: UIView!
    @IBOutlet weak var btnForgotPass: UIButton!
    @IBOutlet weak var btnResendEmail: UIButton!
    @IBOutlet weak var btnLogin_Register: UIButton!
    @IBOutlet weak var lblSignUp: UILabel!
    @IBOutlet weak var btnSignUp: UIButton!
    
    var checkEyePassword = false 
    var checkEyeRe_Password = false // Trạng thái bảo mật mật khẩu (Mật khẩu bảo mật : false)
    var checkSignUp = true // Trạng thái login hay register (login: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if LocalResourceRepository.getUserLocally() != nil {
            let vc = RouterType.tabbar.getVc()
            navigationController?.pushViewController(vc, animated: true)
        } else {
            initComponents()
            customizeComponents()
            setDeffaultComponents()
        }
    }
    
    // Chạm icon bên phải text field pass
    @objc func tapRightImagePassword() {
        checkEyePassword = !checkEyePassword
        if checkEyePassword {
            tfPass.isSecureTextEntry = false
            setRightImageTextField(view: tfPass, imageName: "ic_openEye")
        } else {
            tfPass.isSecureTextEntry = true
            setRightImageTextField(view: tfPass, imageName: "ic_closeEye")
        }
    }
    
    // Chạm icon bên phải text field re - pass
    @objc func tapRightImageRe_Password() {
        checkEyeRe_Password = !checkEyeRe_Password
        if checkEyeRe_Password {
            tfRe_Pass.isSecureTextEntry = false
            setRightImageTextField(view: tfRe_Pass, imageName: "ic_openEye")
        } else {
            tfRe_Pass.isSecureTextEntry = true
            setRightImageTextField(view: tfRe_Pass, imageName: "ic_closeEye")
        }
    }
    
    // Hiệu ứng ẩn hiển thị label khi text field thay đổi
    @objc func textFieldEditngChange(_ textField: UITextField) {
        switch textField {
        case tfEmail:
            lblEmail.text = textField.hasText ? "Email".localized() : "" // nếu text field không nil
        case tfPass:
            lblPass.text = textField.hasText ? "Password".localized() : ""
        case tfRe_Pass:
            lblRe_Pass.text = textField.hasText ? "Re - Password".localized() : ""
        default:
            break
        }
    }

    @IBAction func btnForgotPassTapped(_ sender: Any) {
        // Kiểm tra các trường xem có rỗng không
        if isDataInputedFor(type: "password") {
            self.resetPassword()
        } else {
            ProgressHUD.showFailed("Email is required".localized())
        }
    }
    
    @IBAction func btnResendEmailTapped(_ sender: Any) {
        // Kiểm tra các trường xem có rỗng không
        if isDataInputedFor(type: "password") {
            self.resendVerificationEmail()
        } else {
            ProgressHUD.showFailed("Email is required".localized())
        }
    }
    
    @IBAction func btnLogin_RegisterTapped(_ sender: Any) {
        // Kiểm tra các trường xem có rỗng không
        if isDataInputedFor(type: btnLogin_Register.titleLabel?.text ?? "") {
            if checkSignUp {
                self.loginUser()
            } else {
                self.registerUser()
            }
        } else {
            ProgressHUD.showFailed("All fields are required".localized())
        }
    }
    
    @IBAction func btnSignUpTapped(_ sender: Any) {
        checkSignUp = !checkSignUp
        hiddenRe_PassView(isHidden: checkSignUp)
        
        // gán lại giá trị rỗng cho các trường
        setDeffaultComponents()
        
        // Chuyển đổi trạng thái nút login
        if checkSignUp {
            btnLogin_Register.setTitle("Login".localized(), for: .normal)
            lblSignUp.text = "Don't have an account?".localized()
            btnSignUp.setTitle("Sign up".localized(), for: .normal)
        } else {
            btnLogin_Register.setTitle("Register".localized(), for: .normal)
            lblSignUp.text = "You have an account?".localized()
            btnSignUp.setTitle("Login".localized(), for: .normal)
        }
    }
}

//MARK: - Các hàm init , setup
extension LoginViewController {
    func initComponents() {
        initLocalizableTexts()
        initTextFields()
        hiddenRe_PassView(isHidden: checkSignUp)
        initOtherComponents()
    }
    
    func initLocalizableTexts() {
        lblTitle.text = "Login".localized()
        lblEmail.text = ""
        lblPass.text = ""
        lblRe_Pass.text = ""
        tfEmail.placeholder = "Email".localized()
        tfPass.placeholder = "Password".localized()
        tfRe_Pass.placeholder = "Re - Password".localized()
        btnForgotPass.setTitle("Forgot Password?".localized(), for: .normal)
        btnResendEmail.setTitle("Resend Email".localized(), for: .normal)
        btnLogin_Register.setTitle("Login".localized(), for: .normal)
        btnSignUp.setTitle("Sign up".localized(), for: .normal)
        lblSignUp.text = "Don't have an account?".localized()
    }
    
    func initTextFields() {
        tfPass.isSecureTextEntry = true
        tfRe_Pass.isSecureTextEntry = true
        tfEmail.addTarget(self, action: #selector(textFieldEditngChange(_:)), for: .editingChanged)
        tfPass.addTarget(self, action: #selector(textFieldEditngChange(_:)), for: .editingChanged)
        tfRe_Pass.addTarget(self, action: #selector(textFieldEditngChange(_:)), for: .editingChanged)
    }
    
    func initOtherComponents() {
        btnResendEmail.isHidden = true
    }
    
    // ẩn view đặt lại mật khẩu
    func hiddenRe_PassView(isHidden: Bool) {
        lblRe_Pass.isHidden = isHidden
        tfRe_Pass.isHidden = isHidden
        viewLineRe_Pass.isHidden = isHidden
    }
    
    // set lại giá trị mặc định cho các thành phần
    func setDeffaultComponents() {
        lblEmail.text = ""
        lblPass.text = ""
        lblRe_Pass.text = ""
        tfEmail.text = ""
        tfPass.text = ""
        tfRe_Pass.text = ""
        checkEyePassword = false
        checkEyeRe_Password = false
        tfPass.isSecureTextEntry = true
        tfRe_Pass.isSecureTextEntry = true
        customizeTextFields(views: [tfPass, tfRe_Pass])
    }
    
    func setNullPassWhenLogin() {
        
    }
    
    func setNullPassWhenRegister() {
        lblPass.text = ""
        lblRe_Pass.text = ""
        tfPass.text = ""
        tfRe_Pass.text = ""
        checkEyePassword = false
        checkEyeRe_Password = false
        tfPass.isSecureTextEntry = true
        tfRe_Pass.isSecureTextEntry = true
        customizeTextFields(views: [tfPass, tfRe_Pass])
    }
}

//MARK: - Các hàm Customize
extension LoginViewController {
    func customizeComponents() {
        customizeTextFields(views: [tfPass, tfRe_Pass])
        customizeButtons()
    }
    
    func customizeTextFields(views: [UITextField]) {
        for view in views {
            if view == tfPass || view == tfRe_Pass {
                setRightImageTextField(view: view, imageName: "ic_closeEye")
            }
        }
    }
    
    func customizeButtons() {
        btnLogin_Register.layer.cornerRadius = btnLogin_Register.height / 2
    }
    
    // cài đặt ảnh bên phải cho password và re - password
    func setRightImageTextField(view: UITextField, imageName: String) {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        view.rightViewMode = .always
        let image = UIImage(named: imageName)
        imageView.image = image
        view.rightView = imageView
        if view == tfPass {
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapRightImagePassword)))
            imageView.isUserInteractionEnabled = true
        }
        else if view == tfRe_Pass {
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapRightImageRe_Password)))
            imageView.isUserInteractionEnabled = true
        }
    }
}

//MARK: - Các hàm chức năng
extension LoginViewController {
    // kiểm tra các thuộc tính có bị rỗng không
    func isDataInputedFor(type: String) -> Bool {
        switch type {
        case "Login".localized():
            return tfEmail.text != "" && tfPass.text != ""
        case "Register".localized():
            return tfEmail.text != "" && tfPass.text != "" && tfRe_Pass.text != ""
        default:
            return tfEmail.text != ""
        }
    }
    
    // login
    private func loginUser() {
        FirebaseUserListener.shared.loginUserWith(email: tfEmail.text!, password: tfPass.text!) { error, isEmailVerified in
            if error == nil {
                if isEmailVerified {
                    // đăng nhập thành công -> Chuyển màn
                    let vc = RouterType.tabbar.getVc()
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    AlertUtil.showAlert(from: self, with: "Email is not verified".localized(), message: "")
                    self.btnResendEmail.isHidden = false
                }
            } else {
                ProgressHUD.showFailed("Login Failed: \(error!.localizedDescription)")
            }
        }
    }
    
    // register
    private func registerUser() {
        if tfPass.text!.elementsEqual(tfRe_Pass.text!) {
            FirebaseUserListener.shared.registerUserWith(email: tfEmail.text!, password: tfPass.text!) { error in
                if error == nil {
                    ProgressHUD.showSuccess("Verification email sent".localized())
                    self.btnResendEmail.isHidden = false
                } else {
                    ProgressHUD.showFailed("Register Failed: \(error!.localizedDescription)")
                }
            }
        } else {
            ProgressHUD.showFailed("The Passwords don't match".localized())
            setNullPassWhenRegister()
        }
    }
    
    private func resetPassword() {
        FirebaseUserListener.shared.resetPasswordFor(email: tfEmail.text!) { error in
            if error == nil {
                ProgressHUD.showSuccess("Reset link sent to email".localized())
            } else {
                ProgressHUD.showFailed("Reset Failed: \(error!.localizedDescription)")
            }
        }
    }
    
    private func resendVerificationEmail() {
        FirebaseUserListener.shared.resendVerificationEmail(email: tfEmail.text!) { error in
            if error == nil {
                ProgressHUD.showSuccess("New verification email sent".localized())
            } else {
                ProgressHUD.showFailed("Resend Email Failed: \(error!.localizedDescription)")
            }
        }
    }
}
