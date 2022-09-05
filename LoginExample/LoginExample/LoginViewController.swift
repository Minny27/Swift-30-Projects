//
//  ViewController.swift
//  LoginExample
//
//  Created by SeungMin on 2022/05/14.
//

import UIKit
import Alamofire
import SnapKit
import Then
import NaverThirdPartyLogin
import KakaoSDKUser
import AuthenticationServices

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    let loginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
    var userInfo: User? = nil
    
    private let buttonStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
    }
    
    private let naverLoginButton = UIButton().then {
        $0.setImage(UIImage(named: "naver_login"), for: .normal)
        $0.layer.cornerRadius = 10
        $0.addTarget(self, action: #selector(clickNaverLoginButton), for: .touchUpInside)
    }
    
    private let kakaoLoginButton = UIButton().then {
        $0.setImage(UIImage(named: "kakao_login"), for: .normal)
        $0.layer.cornerRadius = 10
        $0.addTarget(self, action: #selector(clickKakaoLoginButton), for: .touchUpInside)
    }
    
    private let appleLoginButton = UIButton().then {
        $0.setTitle("애플 로그인", for: .normal)
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 10
        $0.addTarget(self, action: #selector(clickAppleLoginButton), for: .touchUpInside)
    }
    
    // MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints {
            $0.centerX.equalTo(view)
            $0.centerY.equalTo(view)
        }
        
        buttonStackView.addArrangedSubview(naverLoginButton)
        naverLoginButton.snp.makeConstraints {
            $0.left.equalTo(view).offset(16)
            $0.right.equalTo(view).offset(-16)
            $0.height.equalTo(50)
        }
        
        buttonStackView.addArrangedSubview(kakaoLoginButton)
        kakaoLoginButton.snp.makeConstraints {
            $0.left.equalTo(view).offset(16)
            $0.right.equalTo(view).offset(-16)
            $0.height.equalTo(50)
        }
        
        buttonStackView.addArrangedSubview(appleLoginButton)
        appleLoginButton.snp.makeConstraints {
            $0.left.equalTo(view).offset(16)
            $0.right.equalTo(view).offset(-16)
            $0.height.equalTo(50)
        }
    }
    
    private func setupNaverInfo() {
        ApiManager().getNaverLoginInfo(loginInstance: loginInstance) {
            self.userInfo = User(name: $0.response.name,
                                 email: $0.response.email,
                                 nickname: $0.response.nickname)
            print("유저 정보: \(self.userInfo)")
            self.sendUserInfo()
        }
    }
    
    @objc func clickNaverLoginButton(_ sender: Any) {
        loginInstance?.delegate = self
        loginInstance?.requestThirdPartyLogin()
    }
    
    @objc func clickKakaoLoginButton(_ sender: Any) {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { oAuthToken, error in
                if let error = error {
                    print(error)
                } else {
                    print("loginWithKakaoTalk() success.")
                    
                    self.setupKakaoInfo()
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { oAuthToken, error in
                if let error = error {
                    print(error)
                } else {
                    print("loginWithKakaoAccount() success.")
                    
                    let accessToken = oAuthToken?.accessToken
                    
                    self.setupKakaoInfo()
                }
            }
        }
    }
    
    @objc func clickAppleLoginButton() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self as? ASAuthorizationControllerPresentationContextProviding
        controller.performRequests()
    }
    
    func setupKakaoInfo() {
        UserApi.shared.me { user, error in
            if let error = error {
                print(error)
            } else {
                print("me() success.")
                
                self.userInfo = User(name: user?.kakaoAccount?.name,
                                     email: user?.kakaoAccount?.email,
                                     nickname: user?.kakaoAccount?.profile?.nickname)
            }
            print("유저 정보: \(self.userInfo)")
            self.sendUserInfo()
        }
    }
    
    func sendUserInfo() {
        let userDetailViewController = UserDetailViewController()
        userDetailViewController.userInfo = userInfo
        navigationController?.pushViewController(userDetailViewController, animated: true)
    }
    
    @objc func clickLogoutButton() {
        loginInstance?.requestDeleteToken()
    }
}

extension LoginViewController: NaverThirdPartyLoginConnectionDelegate {
    
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        print("Success: Success Naver Login")
        setupNaverInfo()
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        
    }
    
    func oauth20ConnectionDidFinishDeleteToken() {
        print("Success: Success Naver Logout")
        loginInstance?.requestDeleteToken()
    }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        print("[Error]: ", error.localizedDescription)
    }
}


extension LoginViewController: ASAuthorizationControllerDelegate {
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let user = credential.user      // 유저 아이디
            let email = credential.email    // 유저 이메일
            let userInfo = User(name: user, email: email, nickname: nil)
            
            let userDetailViewController = UserDetailViewController()
            userDetailViewController.userInfo = userInfo
            self.navigationController?.pushViewController(userDetailViewController, animated: true)
        }
    }
}
