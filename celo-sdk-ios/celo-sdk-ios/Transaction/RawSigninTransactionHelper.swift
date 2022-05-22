//
//  WalletCconnectHelper.swift
//

//   .
//

import BigInt
import Foundation
import WalletConnectSwift
import web3swift
import UIKit


public class RawSigninTransactionHelper {
    public static let shared = RawSigninTransactionHelper()

    var server: Server?
    var session: Session?
    var isConnecting: Bool = false
    var connectedDate: Date?
    private var sessionURL:String?
    typealias onAccept = () -> Void
    typealias onCancel = () -> Void


    public init() {

    }
    public func connect(url: String) throws {
            if isConnecting, session != nil {
                disconnect()
            }

        
//        guard let s = Server(delegate: self) else {
//            throw CeloError.custom("Unable to create Server instance")
//        }
        self.server = Server(delegate: self)
        server?.register(handler: SendTransactionHandler(server: self.server!))


            if let existing = getExistingSession() {
                do {
                    try server?.reconnect(to: existing)
                }
                catch{
                    print("##########server error ######### \(error)" )
                    throw error
                }
                    
            } else {
                guard let mUrl = WCURL(url) else { return }
                do {
                    try server?.connect(to: mUrl)
                } catch {
                    HUDManager.shared.showError(text: "Parse Wallet Connect QRcode failed")
                    throw error
                }
            }
            
        }


    public func disconnect() {
        guard let session = self.session, let server = self.server else { return }
        do {
           
            try server.disconnect(from: session)
        } catch {
            HUDManager.shared.showError(text: "Disconnect Wallet Failed")
        }
    }
    func saveSession(session:Session?) {
        guard session != nil else {
//            UserDefaults.standard.setValue(nil, forKey: "P_SESSION")
            Configuration.setPreviousSession(session: nil)
            return
            
        }
            do {
                let data  =  try JSONEncoder().encode(session!)
//                UserDefaults.standard.setValue(data, forKey: "P_SESSION")
                Configuration.setPreviousSession(session: data)

            } catch {
                print("session encoe error \(error)")
            }
        }
    func getExistingSession() -> Session? {
        if let session = Configuration.getPreviousSession() {
                do {
                    return try JSONDecoder().decode(Session.self, from: session)
                } catch {
                    print("session decode error \(error)")
                }
            }
            return nil
        }


    func disconnect(key: String) {
        guard let session = self.session else { return }
        if session.url.key == key {
            disconnect()
        }
    }
    
    func showPromptMessage(title:String?,message:String?,acceptTitle:String,cancelTitle:String,onAccept:@escaping(onAccept),onReject:@escaping(onCancel)) {
        let topVC = UIApplication.topViewController()
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: acceptTitle, style: .default, handler: { (_) in
                onAccept()
            }))
            if cancelTitle != "" {
                alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: { (_) in
                    onReject()
                }))
            }
            
            topVC?.present(alert, animated: true, completion: nil)
        }
}


extension RawSigninTransactionHelper: ServerDelegate {
    public func server(_ server: Server, didUpdate session: Session) {

    }

    public func server(_: Server, didFailToConnect _: WCURL) {
        HUDManager.shared.showErrorAlert(text: "Wallect Connect Faild to Connect")
    }

    public func server(_: Server, shouldStart session: Session, completion: @escaping (Session.WalletInfo) -> Void) {
        let heymateLogo = URL(string: "https://yashoid.com/peymate.png")!

        let walletMeta = Session.ClientMeta(name: "SreeTest",
                                            description: "Sreetest",
                                            icons: [heymateLogo],
                                            url: URL(string: "https://www.heymate.works/")!)
        let accounts = CeloSDK.currentAccount!.address
        let walletInfo = Session.WalletInfo(approved: true,
                                            accounts: [accounts],
                                            chainId: Setting.celoChainid,
                                            peerId: UUID().uuidString,
                                            peerMeta: walletMeta)


        self.session = session
        self.session?.walletInfo = walletInfo
        saveSession(session: self.session!)

        onMainThread {
            self.showPromptMessage(title: "Heymate", message: "Please connect to Telegram web app", acceptTitle: "Approve", cancelTitle: "Cancel", onAccept: {[weak self] in

                completion(walletInfo)
            }, onReject: {
                completion(Session.WalletInfo(approved: false, accounts: [accounts], chainId: Setting.celoChainid, peerId: "", peerMeta: walletMeta))
            })
        }

    }

    public func server(_: Server, didConnect session: Session) {
        onMainThread {
            NotificationCenter.default.post(name: .wallectConnectServerConnect, object: nil)
            let dappInfo = session.dAppInfo.peerMeta
            
            self.isConnecting = true
            self.connectedDate = Date()
        }
    }

    public func server(_: Server, didDisconnect session: Session) {
        let dict = ["key": session.url.key]
        print("server disconnect called")
        NotificationCenter.default.post(name: .wallectConnectServerDisconnect, object: nil, userInfo: dict)
        HUDManager.shared.showErrorAlert(text: "Wallect Connect Disconnect", isAlert: true)
        isConnecting = false
        server = nil
        self.session = nil
        connectedDate = nil
        saveSession(session: nil)
    }
}

