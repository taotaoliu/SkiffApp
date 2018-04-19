//
//  ViewController.swift
//  OurDatingApp
//
//  Created by 柳涛涛 on 2017/8/13.
//  Copyright © 2017年 taotao. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class ViewController: UIViewController, GCDAsyncSocketDelegate {

    var clientSocket: GCDAsyncSocket!
    var cacheData = Data()
    
    var mainQueue = DispatchQueue.main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pbPractice()
    }
    
    func pbPractice() {
        let personBuilder = Person.Builder()
        personBuilder.email = "1000@gmail.com"
        personBuilder.name = "wanger"
        personBuilder.id = 01
        let person = try! personBuilder.build()
        print(person.email)
        
    }
    
    func addSocket()  {
        clientSocket = GCDAsyncSocket()
        clientSocket.delegate = self
        clientSocket.delegateQueue = DispatchQueue.global()
        do {
            try clientSocket.connect(toHost: "192.168.2.102", onPort: 9901)
        } catch  {
            print("error")
        }
        
        let button = UIButton()
        button.frame = CGRect(x: 20, y: 64, width: 60, height: 40)
        button.backgroundColor = UIColor.purple
        button.setTitle("发送", for: .normal)
        button.addTarget(self, action: #selector(sendMessageClick), for: .touchUpInside)
        view.addSubview(button)
    }
    
    func sendMessageClick() {
        let serviceStr: NSMutableString = NSMutableString()
        serviceStr.append("qqq")
        serviceStr.append("\n")
        clientSocket.write(serviceStr.data(using: String.Encoding.utf8.rawValue)!, withTimeout: -1, tag: 0)
    }
    
    func socket(_ sock:GCDAsyncSocket, didConnectToHost host:String, port:UInt16) {
        print("与服务器连接成功！")
        clientSocket.readData(withTimeout: -1, tag:0)
    }
    
    func socketDidDisconnect(_ sock:GCDAsyncSocket, withError err:Error?) {
        print("与服务器断开连接")
    }
    
    func socket(_ sock:GCDAsyncSocket, didRead data: Data, withTag tag:Int) {
        // 1 获取客户的发来的数据 ，把 NSData 转 NSString
        let myRange: Range = 12..<data.count
        let data2 = data.subdata(in: myRange)
        let str =  NSString(data:data2 ,encoding: String.Encoding.utf8.rawValue)
        print(data2)
        self.cacheData.append(data)
        
        while cacheData.count > 10 {
            var uInt: UInt16 = 0
            let data1 = data as NSData
            data1.getBytes(&uInt, range: NSRange(location: 0, length: 2))
            print(uInt)
            
            if cacheData.count < Int(uInt)  {
                sock.readData(withTimeout: -1, tag: 0)
                print("半包")
                break
            } else {
                let range: Range = Int(uInt)..<cacheData.count
                let data3 = cacheData.subdata(in: range)
                cacheData = data3
                print("拆包")
                print(cacheData)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

