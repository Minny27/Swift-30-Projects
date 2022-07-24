//
//  UserDetil.swift
//  LoginExample
//
//  Created by SeungMin on 2022/07/24.
//

import Foundation
import UIKit
import SnapKit
import Then

class UserDetailViewController: UIViewController {
    var userInfo: User? = nil
    
    let labelStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
    }
    
    let nameLabel = UILabel().then {
        $0.text = "이름: "
        $0.textAlignment = .left
        $0.textColor = .black
    }
    
    let emailLabel = UILabel().then {
        $0.text = "이메일: "
        $0.textAlignment = .left
        $0.textColor = .black
    }
    
    let nicknameLabel = UILabel().then {
        $0.text = "닉네임: "
        $0.textAlignment = .left
        $0.textColor = .black
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupUI()
        updateUserInfo()
    }
    
    func setupUI() {
        view.addSubview(labelStackView)
        labelStackView.snp.makeConstraints {
            $0.centerX.equalTo(view)
            $0.centerY.equalTo(view)
        }
        
        labelStackView.addArrangedSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.width.equalTo(200)
            $0.height.equalTo(30)
        }
        
        labelStackView.addArrangedSubview(emailLabel)
        emailLabel.snp.makeConstraints {
            $0.width.equalTo(200)
            $0.height.equalTo(30)
        }
        
        labelStackView.addArrangedSubview(nicknameLabel)
        nicknameLabel.snp.makeConstraints {
            $0.width.equalTo(200)
            $0.height.equalTo(30)
        }
    }
    
    func updateUserInfo() {
        nameLabel.text! += userInfo?.name ?? ""
        emailLabel.text! += userInfo?.email ?? ""
        nicknameLabel.text! += userInfo?.nickname ?? ""
    }
}
