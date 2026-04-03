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
    
    // Callback closure: used to pass scanned result outward
    var completionHandler: ((String) -> Void)?

    private var lastScanTime: Date = Date.distantPast
    private let scanInterval: TimeInterval = 5.0 // Scan interval set to 5 seconds

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
            // ISBN codes typically use EAN-13 format
            metadataOutput.metadataObjectTypes = [.ean13]
        } else {
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        // Start the session on a background thread to avoid blocking the main thread
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // --- Core update: 5-second interval throttling ---
        let now = Date()
        guard now.timeIntervalSince(lastScanTime) >= scanInterval else {
            return // Ignore if last scan was within 5 seconds
        }

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            // Update last successful scan time
            lastScanTime = now
            
            // Haptic feedback (vibration)
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            // Handle scanned ISBN code
            found(code: stringValue)
        }
    }

    func found(code: String) {
        print("Scanned ISBN: \(code)")
        
        // Notify caller via callback
        completionHandler?(code)
        
        // If you want to stop scanning after one result, uncomment below:
        // captureSession.stopRunning()
        // dismiss(animated: true)
    }
}
