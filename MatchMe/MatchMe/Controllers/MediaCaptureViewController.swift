import UIKit
import AVFoundation
import Photos

protocol MediaCaptureViewControllerDelegate: AnyObject {
    func mediaCaptureViewController(_ controller: MediaCaptureViewController, didCaptureMedia url: URL, type: ChatMessage.MessageType)
    func mediaCaptureViewControllerDidCancel(_ controller: MediaCaptureViewController)
}

class MediaCaptureViewController: UIViewController {
    
    weak var delegate: MediaCaptureViewControllerDelegate?
    
    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureMovieFileOutput?
    private var audioRecorder: AVAudioRecorder?
    private var currentVideoDevice: AVCaptureDevice?
    private var isRecording = false
    private var recordingTimer: Timer?
    private var recordingDuration: TimeInterval = 0
    private var mediaType: ChatMessage.MessageType = .video
    
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer()
        layer.videoGravity = .resizeAspectFill
        return layer
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var flipCameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "camera.rotate"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(flipCameraButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var recordButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 35
        button.layer.borderWidth = 4
        button.layer.borderColor = UIColor.white.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var mediaTypeSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Video", "Audio", "Photo"])
        control.selectedSegmentIndex = 0
        control.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        control.selectedSegmentTintColor = .systemPink
        control.translatesAutoresizingMaskIntoConstraints = false
        control.addTarget(self, action: #selector(mediaTypeChanged), for: .valueChanged)
        return control
    }()
    
    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var audioVisualizerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var audioIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "mic.circle.fill"))
        imageView.tintColor = .systemPink
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkPermissions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        view.layer.addSublayer(previewLayer)
        
        audioVisualizerView.addSubview(audioIconImageView)
        
        view.addSubview(audioVisualizerView)
        view.addSubview(closeButton)
        view.addSubview(flipCameraButton)
        view.addSubview(recordButton)
        view.addSubview(mediaTypeSegmentedControl)
        view.addSubview(timerLabel)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            
            flipCameraButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            flipCameraButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            flipCameraButton.widthAnchor.constraint(equalToConstant: 40),
            flipCameraButton.heightAnchor.constraint(equalToConstant: 40),
            
            timerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timerLabel.widthAnchor.constraint(equalToConstant: 80),
            timerLabel.heightAnchor.constraint(equalToConstant: 40),
            
            mediaTypeSegmentedControl.bottomAnchor.constraint(equalTo: recordButton.topAnchor, constant: -30),
            mediaTypeSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mediaTypeSegmentedControl.widthAnchor.constraint(equalToConstant: 250),
            
            recordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.widthAnchor.constraint(equalToConstant: 70),
            recordButton.heightAnchor.constraint(equalToConstant: 70),
            
            audioVisualizerView.topAnchor.constraint(equalTo: view.topAnchor),
            audioVisualizerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            audioVisualizerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            audioVisualizerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            audioIconImageView.centerXAnchor.constraint(equalTo: audioVisualizerView.centerXAnchor),
            audioIconImageView.centerYAnchor.constraint(equalTo: audioVisualizerView.centerYAnchor),
            audioIconImageView.widthAnchor.constraint(equalToConstant: 150),
            audioIconImageView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    private func checkPermissions() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            if granted {
                DispatchQueue.main.async {
                    self?.setupCamera()
                }
            }
        }
        
        AVCaptureDevice.requestAccess(for: .audio) { _ in }
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }
        
        captureSession.beginConfiguration()
        
        // Add video input
        if let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            currentVideoDevice = videoDevice
            do {
                let videoInput = try AVCaptureDeviceInput(device: videoDevice)
                if captureSession.canAddInput(videoInput) {
                    captureSession.addInput(videoInput)
                }
            } catch {
                print("Error setting up video input: \(error)")
            }
        }
        
        // Add audio input
        if let audioDevice = AVCaptureDevice.default(for: .audio) {
            do {
                let audioInput = try AVCaptureDeviceInput(device: audioDevice)
                if captureSession.canAddInput(audioInput) {
                    captureSession.addInput(audioInput)
                }
            } catch {
                print("Error setting up audio input: \(error)")
            }
        }
        
        // Add video output
        videoOutput = AVCaptureMovieFileOutput()
        if let videoOutput = videoOutput {
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }
        }
        
        // Add photo output
        let photoOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        captureSession.commitConfiguration()
        
        previewLayer.session = captureSession
        
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }
    }
    
    private func setupAudioRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    @objc private func closeButtonTapped() {
        stopRecording()
        delegate?.mediaCaptureViewControllerDidCancel(self)
    }
    
    @objc private func flipCameraButtonTapped() {
        guard let captureSession = captureSession else { return }
        
        captureSession.beginConfiguration()
        
        // Remove current input
        captureSession.inputs.forEach { input in
            if let deviceInput = input as? AVCaptureDeviceInput {
                captureSession.removeInput(deviceInput)
            }
        }
        
        // Add new input with opposite camera
        let position: AVCaptureDevice.Position = currentVideoDevice?.position == .back ? .front : .back
        if let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) {
            currentVideoDevice = videoDevice
            do {
                let videoInput = try AVCaptureDeviceInput(device: videoDevice)
                if captureSession.canAddInput(videoInput) {
                    captureSession.addInput(videoInput)
                }
            } catch {
                print("Error flipping camera: \(error)")
            }
        }
        
        // Re-add audio input
        if let audioDevice = AVCaptureDevice.default(for: .audio) {
            do {
                let audioInput = try AVCaptureDeviceInput(device: audioDevice)
                if captureSession.canAddInput(audioInput) {
                    captureSession.addInput(audioInput)
                }
            } catch {
                print("Error re-adding audio: \(error)")
            }
        }
        
        captureSession.commitConfiguration()
    }
    
    @objc private func recordButtonTapped() {
        switch mediaType {
        case .video:
            if isRecording {
                stopVideoRecording()
            } else {
                startVideoRecording()
            }
        case .audio:
            if isRecording {
                stopAudioRecording()
            } else {
                startAudioRecording()
            }
        case .photo:
            capturePhoto()
        default:
            break
        }
    }
    
    @objc private func mediaTypeChanged() {
        stopRecording()
        
        switch mediaTypeSegmentedControl.selectedSegmentIndex {
        case 0: // Video
            mediaType = .video
            audioVisualizerView.isHidden = true
            flipCameraButton.isHidden = false
            captureSession?.startRunning()
        case 1: // Audio
            mediaType = .audio
            audioVisualizerView.isHidden = false
            flipCameraButton.isHidden = true
            captureSession?.stopRunning()
            setupAudioRecording()
        case 2: // Photo
            mediaType = .photo
            audioVisualizerView.isHidden = true
            flipCameraButton.isHidden = false
            captureSession?.startRunning()
        default:
            break
        }
    }
    
    private func startVideoRecording() {
        guard let videoOutput = videoOutput else { return }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let videoPath = documentsPath.appendingPathComponent("video_\(Date().timeIntervalSince1970).mov")
        
        videoOutput.startRecording(to: videoPath, recordingDelegate: self)
        
        isRecording = true
        recordingDuration = 0
        timerLabel.isHidden = false
        
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
        
        UIView.animate(withDuration: 0.3) {
            self.recordButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            self.recordButton.layer.cornerRadius = 10
        }
    }
    
    private func stopVideoRecording() {
        videoOutput?.stopRecording()
        stopRecording()
    }
    
    private func startAudioRecording() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioPath = documentsPath.appendingPathComponent("audio_\(Date().timeIntervalSince1970).m4a")
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioPath, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            isRecording = true
            recordingDuration = 0
            timerLabel.isHidden = false
            
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.updateTimer()
                self?.animateAudioIcon()
            }
            
            UIView.animate(withDuration: 0.3) {
                self.recordButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                self.recordButton.layer.cornerRadius = 10
            }
        } catch {
            print("Error starting audio recording: \(error)")
        }
    }
    
    private func stopAudioRecording() {
        audioRecorder?.stop()
        
        if let url = audioRecorder?.url {
            delegate?.mediaCaptureViewController(self, didCaptureMedia: url, type: .audio)
        }
        
        stopRecording()
    }
    
    private func capturePhoto() {
        guard let photoOutput = captureSession?.outputs.compactMap({ $0 as? AVCapturePhotoOutput }).first else { return }
        
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    private func stopRecording() {
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
        timerLabel.isHidden = true
        
        UIView.animate(withDuration: 0.3) {
            self.recordButton.transform = .identity
            self.recordButton.layer.cornerRadius = 35
        }
    }
    
    private func updateTimer() {
        recordingDuration += 1
        let minutes = Int(recordingDuration) / 60
        let seconds = Int(recordingDuration) % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func animateAudioIcon() {
        UIView.animate(withDuration: 0.5, animations: {
            self.audioIconImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.5) {
                self.audioIconImageView.transform = .identity
            }
        }
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate

extension MediaCaptureViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error == nil {
            delegate?.mediaCaptureViewController(self, didCaptureMedia: outputFileURL, type: .video)
        } else {
            print("Error recording video: \(error?.localizedDescription ?? "")")
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension MediaCaptureViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil,
              let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            return
        }
        
        // Save photo to documents directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photoPath = documentsPath.appendingPathComponent("photo_\(Date().timeIntervalSince1970).jpg")
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            do {
                try jpegData.write(to: photoPath)
                delegate?.mediaCaptureViewController(self, didCaptureMedia: photoPath, type: .photo)
            } catch {
                print("Error saving photo: \(error)")
            }
        }
    }
}

// MARK: - AVAudioRecorderDelegate

extension MediaCaptureViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Audio recording failed")
        }
    }
}