//
//  ISBNScannerViewController.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/4/3.
//

import UIKit
import AVFoundation

class ISBNScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    // 回调闭包：用于将扫描结果传出
    var completionHandler: ((String) -> Void)?

    private var lastScanTime: Date = Date.distantPast
    private let scanInterval: TimeInterval = 5.0 // 设置间隔为 5 秒

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            // ISBN 通常使用 EAN-13 格式
            metadataOutput.metadataObjectTypes = [.ean13]
        } else {
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        // 在后台线程启动会话以避免阻塞主线程
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // --- 核心更新：5秒间隔逻辑 ---
        let now = Date()
        guard now.timeIntervalSince(lastScanTime) >= scanInterval else {
            return // 如果距离上次扫描不足 5 秒，直接忽略
        }

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            // 更新最后一次成功扫描的时间
            lastScanTime = now
            
            // 震动反馈
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            // 处理扫描到的 ISBN 码
            found(code: stringValue)
        }
    }

    func found(code: String) {
        print("Scanned ISBN: \(code)")
        
        // 执行回调通知调用方
        completionHandler?(code)
        
        // 如果你希望扫描一次后就关闭界面，取消下面两行的注释：
        //captureSession.stopRunning()
        //dismiss(animated: true)
    }
}
