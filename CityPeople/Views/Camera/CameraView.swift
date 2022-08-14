//
//  CameraView.swift
//  CityPeople
//
//  Created by Kamal Kishor on 25/04/22.
//

import AVFoundation
import UIKit
import RxSwift

class CameraView: UIView {
    
    private lazy var captureSession: AVCaptureSession = {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .iFrame960x540
        return captureSession
    }()
    private lazy var cameraDevice: AVCaptureDevice = {
        guard let camera = AVCaptureDevice.default(for: .video) else {
            fatalError("Camera is not avaiable")
        }
        return camera
    }()
    private var videoOutput: AVCaptureMovieFileOutput!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    private var cameraViewModel: CameraViewModelProtocol!
    private let disposeBag = DisposeBag()
    
    init(cameraViewModel: CameraViewModelProtocol) {
        super.init(frame: .zero)
        
        self.cameraViewModel = cameraViewModel
        setupViewLayouts()
        setupViewBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
// MARK: - Private methods
    private func setupCamera() {
        do {
            let input = try AVCaptureDeviceInput(device: cameraViewModel.cameraSide == .front ? getFrontCamera() : getBackCamera())
            captureSession.addInput(input)
            
            // Get an instance of ACCapturePhotoOutput class
            videoOutput = AVCaptureMovieFileOutput()
            // Set the output on the capture session
            captureSession.addOutput(videoOutput)
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer.videoGravity = .resizeAspectFill
            videoPreviewLayer.frame = layer.bounds
            layer.addSublayer(videoPreviewLayer)
            clipsToBounds = true
            
            // Set video settings to produce MP4 if supported
            if videoOutput.availableVideoCodecTypes.contains(.h264), let connection = videoOutput.connection(with: .video) {
                videoOutput.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.h264], for: connection)
            }
            
            captureSession.startRunning()
        } catch {
          fatalError()
        }
    }
    
    private func setupViewLayouts() {
    }
    
    private func setupViewBindings() {
        cameraViewModel
            .videoAction
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { action in
                self.cameraActions(action: action)
            })
            .disposed(by: disposeBag)
        
        cameraViewModel
            .toggleCamera
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] side in
                self?.toggleCamera(to: side)
            })
            .disposed(by: disposeBag)
    }
    
    func getFrontCamera() -> AVCaptureDevice {
        guard let device =  AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front).devices.first else { fatalError() }
        return device
    }

    func getBackCamera() -> AVCaptureDevice {
        guard let device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices.first else { fatalError() }
        return device
    }
    
    private func toggleCamera(to side: CameraSide) {
        // Don't toggle if requested side is same to current one
        if side == cameraViewModel.cameraSide { return }
        
        do{
            captureSession.removeInput(captureSession.inputs.first!)
            
            if(side == .front) {
                cameraDevice = getFrontCamera()
            } else {
                cameraDevice = getBackCamera()
            }
            let input = try AVCaptureDeviceInput(device: cameraDevice)
            captureSession.addInput(input)
        } catch{
            print(error.localizedDescription)
        }
    }
    
    private func cameraActions(action: VideoAction) {
        switch action {
        case .show:
#if !targetEnvironment(simulator)
        setupCamera()
#endif
        case .resume:
            captureSession.startRunning()
        case .start:
            startVideoRecording()
        case .stop:
            stopVideoRecording()
        case .remove:
            captureSession.stopRunning()
        }
    }
    
    private func startVideoRecording() {
        FileManager.default.deleteRecordingFile()
        let filePath = FileManager.default.videoFileUrl
        videoOutput.startRecording(to: filePath, recordingDelegate: self)
    }
    
    private func stopVideoRecording() {
        videoOutput.stopRecording()
    }
}

extension CameraView: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        let asset = AVAsset(url: outputFileURL)
        if CMTimeGetSeconds(asset.duration) > 1 {
            cameraViewModel.video.accept(outputFileURL)
        }
        cameraViewModel.stopped.accept(())
    }
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        print("Finished")
    }
}



