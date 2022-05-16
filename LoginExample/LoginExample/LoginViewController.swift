//
//  ViewController.swift
//  LoginExample
//
//  Created by SeungMin on 2022/05/14.
//

import UIKit
import Alamofire
import NaverThirdPartyLogin

class LoginViewController: UIViewController {

    // MARK: - Properties
    let loginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "회원이름"
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "이메일"
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("로그인", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(clickLoginButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton()
        button.setTitle("로그아웃", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(clickLogoutButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(nameLabel)
        nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        
        view.addSubview(emailLabel)
        emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 30).isActive = true
        emailLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        emailLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
                
        view.addSubview(nicknameLabel)
        nicknameLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 30).isActive = true
        nicknameLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        nicknameLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        
        view.addSubview(loginButton)
        loginButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30).isActive = true
        loginButton.widthAnchor.constraint(equalToConstant: (view.frame.width - 32) / 2).isActive = true
        
        view.addSubview(logoutButton)
        logoutButton.leftAnchor.constraint(equalTo: loginButton.rightAnchor).isActive = true
        logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30).isActive = true
        logoutButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        
    }
    
    private func getNaverInfo() {
        guard let isValidAccessToken = loginInstance?.isValidAccessTokenExpireTimeNow() else { return }
        
        if !isValidAccessToken {
            return
        }
        
        guard let tokenType = loginInstance?.tokenType else { return }
        guard let accessToken = loginInstance?.accessToken else { return }
        guard let url = URL(string: "https://openapi.naver.com/v1/nid/me") else {
            print("Invlid Url!")
            return
        }
        
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
