//
//  AppDelegate.swift
//  LoginExample
//
//  Created by SeungMin on 2022/05/14.
//

import UIKit
import NaverThirdPartyLogin
import KakaoSDKCommon
import KakaoSDKAuth

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let instance = NaverThirdPartyLoginConnection.getSharedInstance()
        
        // 네이버 앱으로 인증
        instance?.isNaverAppOauthEnable = true
        
        // SafariViewController로 인증
        instance?.isInAppOauthEnable = true
        
        // 인증 화면 세로 모드로 설정
        instance?.isOnlyPortraitSupportedInIphone()
        
        // URL Scheme
        instance?.serviceUrlScheme = kServiceAppUrlScheme
        
        // 클라이언트 아이디
        instance?.consumerKey = kConsumerKey
        
        // 클라이언트 시크릿
        instance?.consumerSecret = kConsumerSecret
        
        // 앱 이름
        instance?.appName = kServiceAppName
        
        // Kakao SDK 초기화
        KakaoSDK.initSDK(appKey: Storage.kakaoApiKey)
        
        return true
    }

    // MARK: UISceneSession Lifecycle
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        NaverThirdPartyLoginConnection
            .getSharedInstance()
            .application(app, open: url, options: options)
        
        if AuthApi.isKakaoTalkLoginUrl(url) {
            return AuthController.handleOpenUrl(url: url)
        }
        
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

