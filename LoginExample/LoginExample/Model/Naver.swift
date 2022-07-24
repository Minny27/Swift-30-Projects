//
//  Naver.swift
//  LoginExample
//
//  Created by SeungMin on 2022/07/24.
//

import Foundation

struct Naver: Decodable {
    let response: response
}

struct response: Decodable {
    let name: String?
    let email: String?
    let nickname: String?
}
