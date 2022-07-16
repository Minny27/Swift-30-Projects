//
//  ViewController.swift
//  LoginExample
//
//  Created by SeungMin on 2022/05/14.
//

import UIKit
import Alamofire
import NaverThirdPartyLogin
import SnapKit
import Then

class LoginViewController: UIViewController {

    // MARK: - Properties
    let loginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
    
    private let nameLabel = UILabel().then {
        $0.text = "회원이름"
        $0.textAlignment = .center
        $0.textColor = .black
    }
    
    private let emailLabel = UILabel().then {
        $0.text = "이메일"
        $0.textAlignment = .center
        $0.textColor = .black
    }
    
    private let nicknameLabel = UILabel().then {
        $0.text = "닉네임"
        $0.textAlignment = .center
        $0.textColor = .black
    }
    
    private let loginButton = UIButton().then {
        $0.setTitle("로그인", for: .normal)
        $0.setTitleColor(UIColor.black, for: .normal)
        $0.addTarget(self, action: #selector(clickLoginButton), for: .touchUpInside)
    }
    
    private let logoutButton = UIButton().then {
        $0.setTitle("로그아웃", for: .normal)
        $0.setTitleColor(UIColor.black, for: .normal)
        $0.addTarget(self, action: #selector(clickLogoutButton), for: .touchUpInside)
    }
    
    // MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            $0.left.equalTo(view).offset(16)
            $0.right.equalTo(view).offset(-16)
        }
        
        view.addSubview(emailLabel)
        emailLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel).offset(30)
            $0.left.equalTo(view).offset(16)
            $0.right.equalTo(view).offset(-16)
        }
                
        view.addSubview(nicknameLabel)
        nicknameLabel.snp.makeConstraints {
            $0.top.equalTo(emailLabel).offset(30)
            $0.left.equalTo(view).offset(16)
            $0.right.equalTo(view).offset(-16)
        }
        
        view.addSubview(loginButton)
        loginButton.snp.makeConstraints {
            $0.left.equalTo(view).offset(16)
            $0.bottom.equalTo(view).offset(-30)
            $0.width.equalTo((view.frame.width - 32) / 2)
        }
        
        view.addSubview(logoutButton)
        logoutButton.snp.makeConstraints {
            $0.bottom.equalTo(view).offset(-30)
            $0.right.equalTo(view).offset(-16)
            $0.width.equalTo((view.frame.width - 32) / 2)
        }
    }
    
    private func getNaverInfo() {
        guard let isValidAccessToken = loginInstance?.isValidAccessTokenExpireTimeNow(), isValidAccessToken else { return }
        
        guard let tokenType = loginInstance?.tokenType else { return }
        guard let accessToken = loginInstance?.accessToken else { return }
        guard let url = URL(string: "https://openapi.naver.com/v1/nid/me") else { return }
        
        let authorization = "\(tokenType) \(accessToken)"
        
        let request = AF.request(
            url,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: ["Authorization": authorization]
        )
                        
        request.responseJSON { response in
            guard let result = response.value as? [String: Any] else { return }
            guard let object = result["response"] as? [String: Any] else { return }
            guard let name = object["name"] as? String else { return }
            guard let email = object["email"] as? String else { return }
            guard let nickname = object["nickname"] as? String else { return }
            
            self.nameLabel.text = name
            self.emailLabel.text = email
            self.nicknameLabel.text = nickname
            
            print(name)
            print(email)
            print(nickname)
        }
    }
    
    @objc func clickLoginButton() {
        loginInstance?.delegate = self
        loginInstance?.requestThirdPartyLogin()
    }

    @objc func clickLogoutButton() {
        loginInstance?.requestDeleteToken()
    }
}

extension LoginViewController: NaverThirdPartyLoginConnectionDelegate {
    
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        print("Success: Success Naver Login")
        getNaverInfo()
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
