/*
See LICENSE.txt for this sample’s licensing information.

Abstract:
View controller for camera interface.
*/

import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
	// MARK: View Controller Life Cycle
	
    weak var delegate : AAPLCameraViewDelegate?
    
    
    override func viewDidLoad() {
		super.viewDidLoad()
		
		// Disable UI. The UI is enabled if and only if the session starts running.
        if _cameraButton != nil { _cameraButton.isEnabled = false }
        if _recordButton != nil { _recordButton.isEnabled = false }
        if _photoButton  != nil { _photoButton.isEnabled = false  }
        if _livePhotoModeButton     != nil { _livePhotoModeButton.isEnabled = false }
        if _depthDataDeliveryButton != nil { _depthDataDeliveryButton.isEnabled = false }
        if _captureModeControl      != nil {_captureModeControl.isEnabled = false }
        
		// Set up the video preview view.
		_previewView.session = session
		
		/*
			Check video authorization status. Video access is required and audio
			access is optional. If audio access is denied, audio is not recorded
			during movie recording.
		*/
		switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
            case .authorized:
				// The user has previously granted access to the camera.
				break
			
			case .notDetermined:
				/*
					The user has not yet been presented with the option to grant
					video access. We suspend the session queue to delay session
					setup until the access request has completed.
				
					Note that audio access will be implicitly requested when we
					create an AVCaptureDeviceInput for audio during session setup.
				*/
				sessionQueue.suspend()
				AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { [unowned self] granted in
					if !granted {
						self.setupResult = .notAuthorized
					}
					self.sessionQueue.resume()
				})
			
			default:
				// The user has previously denied access.
				setupResult = .notAuthorized
		}
		
		/*
			Setup the capture session.
			In general it is not safe to mutate an AVCaptureSession or any of its
			inputs, outputs, or connections from multiple threads at the same time.
		
			Why not do all of this on the main queue?
			Because AVCaptureSession.startRunning() is a blocking call which can
			take a long time. We dispatch session setup to the sessionQueue so
			that the main queue isn't blocked, which keeps the UI responsive.
		*/
		sessionQueue.async { [unowned self] in
			self.configureSession()
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		sessionQueue.async {
			switch self.setupResult {
                case .success:
				    // Only setup observers and start the session running if setup succeeded.
                    self.addObservers()
                    self.session.startRunning()
                    self.isSessionRunning = self.session.isRunning
				
                case .notAuthorized:
                    DispatchQueue.main.async { [unowned self] in
                        let changePrivacySetting = "AVCam doesn't have permission to use the camera, please change privacy settings"
                        let message = NSLocalizedString(changePrivacySetting, comment: "Alert message when the user has denied access to the camera")
                        let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                        
                        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                                style: .cancel,
                                                                handler: nil))
                        
                        alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"),
                                                                style: .`default`,
                                                                handler: { _ in
                            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
                        }))
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
				
                case .configurationFailed:
                    DispatchQueue.main.async { [unowned self] in
                        let alertMsg = "Alert message when something goes wrong during capture session configuration"
                        let message = NSLocalizedString("Unable to capture media", comment: alertMsg)
                        let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                        
                        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                                style: .cancel,
                                                                handler: nil))
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
			}
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		sessionQueue.async { [unowned self] in
			if self.setupResult == .success {
				self.session.stopRunning()
				self.isSessionRunning = self.session.isRunning
				self.removeObservers()
			}
		}
		
		super.viewWillDisappear(animated)
	}
	
    override var shouldAutorotate: Bool {
		// Disable autorotation of the interface when recording is in progress.
		if let movieFileOutput = movieFileOutput {
			return !movieFileOutput.isRecording
		}
		return true
	}
	
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .all
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		if let videoPreviewLayerConnection = _previewView.videoPreviewLayer.connection {
			let deviceOrientation = UIDevice.current.orientation
			guard let newVideoOrientation = deviceOrientation.videoOrientation, deviceOrientation.isPortrait || deviceOrientation.isLandscape else {
				return
			}
			
			videoPreviewLayerConnection.videoOrientation = newVideoOrientation
		}
	}

	// MARK: Session Management
	
	private enum SessionSetupResult {
		case success
		case notAuthorized
		case configurationFailed
	}
	
	private let session = AVCaptureSession()
	
	private var isSessionRunning = false
	
	private let sessionQueue = DispatchQueue.main
                            /*DispatchQueue(label: "session queue",
	                                         attributes: [],
	                                         target: nil)*/
    // Communicate with the session and other session objects on this queue.
	
	private var setupResult: SessionSetupResult = .success
	
	var videoDeviceInput: AVCaptureDeviceInput!
	
    weak var _previewView: PreviewView!
	
	// Call this on the session queue.
	private func configureSession() {
		if setupResult != .success {
			return
		}
		
		session.beginConfiguration()
		
		/*
			We do not create an AVCaptureMovieFileOutput when setting up the session because the
			AVCaptureMovieFileOutput does not support movie recording with AVCaptureSessionPresetPhoto.
		*/
		session.sessionPreset = AVCaptureSession.Preset.photo
		
		// Add video input.
		do {
			var defaultVideoDevice: AVCaptureDevice?
			
			// Choose the back dual camera if available, otherwise default to a wide angle camera.
            if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: AVMediaType.video, position: .back) {
				defaultVideoDevice = dualCameraDevice
            } else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                                     for: AVMediaType.video, position: .back) {
				// If the back dual camera is not available, default to the back wide angle camera.
				defaultVideoDevice = backCameraDevice
            } else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                                      for: AVMediaType.video, position: .front) {
				/*
                   In some cases where users break their phones, the back wide angle camera is not available.
                   In this case, we should default to the front wide angle camera.
                */
				defaultVideoDevice = frontCameraDevice
			}
			
            let videoDeviceInput = try AVCaptureDeviceInput(device: defaultVideoDevice!)
			
			if session.canAddInput(videoDeviceInput) {
				session.addInput(videoDeviceInput)
				self.videoDeviceInput = videoDeviceInput
				
				DispatchQueue.main.async {
					/*
						Why are we dispatching this to the main queue?
						Because AVCaptureVideoPreviewLayer is the backing layer for PreviewView and UIView
						can only be manipulated on the main thread.
						Note: As an exception to the above rule, it is not necessary to serialize video orientation changes
						on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
					
						Use the status bar orientation as the initial video orientation. Subsequent orientation changes are
						handled by CameraViewController.viewWillTransition(to:with:).
					*/
					let statusBarOrientation = UIApplication.shared.statusBarOrientation
					var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
					if statusBarOrientation != .unknown {
						if let videoOrientation = statusBarOrientation.videoOrientation {
							initialVideoOrientation = videoOrientation
						}
					}
					
                    self._previewView.videoPreviewLayer.connection?.videoOrientation = initialVideoOrientation
				}
			} else {
				print("Could not add video device input to the session")
				setupResult = .configurationFailed
				session.commitConfiguration()
				return
			}
		} catch {
			print("Could not create video device input: \(error)")
			setupResult = .configurationFailed
			session.commitConfiguration()
			return
		}
		
		// Add audio input.
		do {
            let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice!)
			
			if session.canAddInput(audioDeviceInput) {
				session.addInput(audioDeviceInput)
			} else {
				print("Could not add audio device input to the session")
			}
		} catch {
			print("Could not create audio device input: \(error)")
		}
		
		// Add photo output.
		if session.canAddOutput(photoOutput) {
			session.addOutput(photoOutput)

            photoOutput.isHighResolutionCaptureEnabled = true
			photoOutput.isLivePhotoCaptureEnabled = photoOutput.isLivePhotoCaptureSupported
            photoOutput.isDepthDataDeliveryEnabled = photoOutput.isDepthDataDeliverySupported
			livePhotoMode = photoOutput.isLivePhotoCaptureSupported ? .on : .off
            depthDataDeliveryMode = photoOutput.isDepthDataDeliverySupported ? .on : .off
            
		} else {
			print("Could not add photo output to the session")
			setupResult = .configurationFailed
			session.commitConfiguration()
			return
		}
		
		session.commitConfiguration()
	}
	
	@IBAction func resumeInterruptedSession(_ resumeButton: UIButton) {
		sessionQueue.async { [unowned self] in
			/*
				The session might fail to start running, e.g., if a phone or FaceTime call is still
				using audio or video. A failure to start the session running will be communicated via
				a session runtime error notification. To avoid repeatedly failing to start the session
				running, we only try to restart the session running in the session runtime error handler
				if we aren't trying to resume the session running.
			*/
			self.session.startRunning()
			self.isSessionRunning = self.session.isRunning
			if !self.session.isRunning {
				DispatchQueue.main.async { [unowned self] in
					let message = NSLocalizedString("Unable to resume", comment: "Alert message when unable to resume the session running")
					let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
					let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil)
					alertController.addAction(cancelAction)
					self.present(alertController, animated: true, completion: nil)
				}
			} else {
				DispatchQueue.main.async { [unowned self] in
					self._resumeButton.isHidden = true
				}
			}
		}
	}
	
	private enum CaptureMode: Int {
		case photo = 0
		case movie = 1
	}

	@IBOutlet weak var _captureModeControl: UISegmentedControl!
	
	@IBAction func toggleCaptureMode(_ captureModeControl: UISegmentedControl) {
		if captureModeControl.selectedSegmentIndex == CaptureMode.photo.rawValue {
			_recordButton.isEnabled = false
			
			sessionQueue.async { [unowned self] in
				/*
					Remove the AVCaptureMovieFileOutput from the session because movie recording is
					not supported with AVCaptureSessionPresetPhoto. Additionally, Live Photo
					capture is not supported when an AVCaptureMovieFileOutput is connected to the session.
				*/
				self.session.beginConfiguration()
                self.session.removeOutput(self.movieFileOutput!)
                self.session.sessionPreset = AVCaptureSession.Preset.photo
				self.session.commitConfiguration()
				
				self.movieFileOutput = nil
				
				if self.photoOutput.isLivePhotoCaptureSupported {
					self.photoOutput.isLivePhotoCaptureEnabled = true
					
					DispatchQueue.main.async {
						self._livePhotoModeButton.isEnabled = true
						self._livePhotoModeButton.isHidden = false
					}
				}
                
                if self.photoOutput.isDepthDataDeliverySupported {
                    self.photoOutput.isDepthDataDeliveryEnabled = true
                    
                    DispatchQueue.main.async {
                        self._depthDataDeliveryButton.isHidden = false
                        self._depthDataDeliveryButton.isEnabled = true
                    }
                }
			}
		} else if captureModeControl.selectedSegmentIndex == CaptureMode.movie.rawValue {
			_livePhotoModeButton.isHidden = true
            _depthDataDeliveryButton.isHidden = true
			
			sessionQueue.async { [unowned self] in
 				let movieFileOutput = AVCaptureMovieFileOutput()
				
				if self.session.canAddOutput(movieFileOutput) {
					self.session.beginConfiguration()
					self.session.addOutput(movieFileOutput)
                    self.session.sessionPreset = AVCaptureSession.Preset.high
                    if let connection = movieFileOutput.connection(with: AVMediaType.video) {
						if connection.isVideoStabilizationSupported {
							connection.preferredVideoStabilizationMode = .auto
						}
					}
					self.session.commitConfiguration()
					
					self.movieFileOutput = movieFileOutput
					
					DispatchQueue.main.async { [unowned self] in
						self._recordButton.isEnabled = true
					}
				}
			}
		}
	}
	
	// MARK: Device Configuration
	
	@IBOutlet weak var _cameraButton: UIButton!
	
	@IBOutlet weak var _cameraUnavailableLabel: UILabel!
	private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera],
                                                                               mediaType: AVMediaType.video, position: .unspecified)
    
	@IBAction func changeCamera(_ cameraButton: UIButton) {
		cameraButton.isEnabled = false
		_recordButton.isEnabled = false
		_photoButton.isEnabled = false
		_livePhotoModeButton.isEnabled = false
		_captureModeControl.isEnabled = false
		
		sessionQueue.async { [unowned self] in
			let currentVideoDevice = self.videoDeviceInput.device
            let currentPosition = currentVideoDevice.position
			
			let preferredPosition: AVCaptureDevice.Position
			let preferredDeviceType: AVCaptureDevice.DeviceType
			
			switch currentPosition {
				case .unspecified, .front:
					preferredPosition = .back
					preferredDeviceType = .builtInDualCamera
				
				case .back:
					preferredPosition = .front
					preferredDeviceType = .builtInWideAngleCamera
			}
			
            let devices = self.videoDeviceDiscoverySession.devices
			var newVideoDevice: AVCaptureDevice? = nil
			
			// First, look for a device with both the preferred position and device type. Otherwise, look for a device with only the preferred position.
            if let device = devices.first(where: { $0.position == preferredPosition && $0.deviceType == preferredDeviceType }) {
				newVideoDevice = device
            } else if let device = devices.first(where: { $0.position == preferredPosition }) {
				newVideoDevice = device
			}

            if let videoDevice = newVideoDevice {
                do {
					let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
					
					self.session.beginConfiguration()
					
					// Remove the existing device input first, since using the front and back camera simultaneously is not supported.
					self.session.removeInput(self.videoDeviceInput)
					
					if self.session.canAddInput(videoDeviceInput) {
						NotificationCenter.default.removeObserver(self, name: .AVCaptureDeviceSubjectAreaDidChange, object: currentVideoDevice)
						
						NotificationCenter.default.addObserver(self, selector: #selector(self.subjectAreaDidChange), name: .AVCaptureDeviceSubjectAreaDidChange, object: videoDeviceInput.device)
						
						self.session.addInput(videoDeviceInput)
						self.videoDeviceInput = videoDeviceInput
					} else {
						self.session.addInput(self.videoDeviceInput)
					}
					
					if let connection = self.movieFileOutput?.connection(with: AVMediaType.video) {
						if connection.isVideoStabilizationSupported {
							connection.preferredVideoStabilizationMode = .auto
						}
					}
					
                    /*
                     Set Live Photo capture and depth data delivery if it is supported. When changing cameras, the
                     `livePhotoCaptureEnabled and depthDataDeliveryEnabled` properties of the AVCapturePhotoOutput gets set to NO when
                     a video device is disconnected from the session. After the new video device is
                     added to the session, re-enable them on the AVCapturePhotoOutput if it is supported.
                     */
					self.photoOutput.isLivePhotoCaptureEnabled = self.photoOutput.isLivePhotoCaptureSupported
					self.photoOutput.isDepthDataDeliveryEnabled = self.photoOutput.isDepthDataDeliverySupported
                    
					self.session.commitConfiguration()
				} catch {
					print("Error occured while creating video device input: \(error)")
				}
			}
			
			DispatchQueue.main.async { [unowned self] in
				self._cameraButton.isEnabled = true
				self._recordButton.isEnabled = self.movieFileOutput != nil
				self._photoButton.isEnabled = true
				self._livePhotoModeButton.isEnabled = true
				self._captureModeControl.isEnabled = true
                self._depthDataDeliveryButton.isEnabled = self.photoOutput.isDepthDataDeliveryEnabled
                self._depthDataDeliveryButton.isHidden = !self.photoOutput.isDepthDataDeliverySupported
			}
		}
	}
	
	@IBAction private func focusAndExposeTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let devicePoint = self._previewView.videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: gestureRecognizer.location(in: gestureRecognizer.view))
        focus(with: .autoFocus, exposureMode: .autoExpose, at: devicePoint, monitorSubjectAreaChange: true)
	}
	
    private func focus(with focusMode: AVCaptureDevice.FocusMode, exposureMode: AVCaptureDevice.ExposureMode, at devicePoint: CGPoint, monitorSubjectAreaChange: Bool) {
        sessionQueue.async { [unowned self] in
            let device = self.videoDeviceInput.device
            do {
                try device.lockForConfiguration()
                
                /*
                 Setting (focus/exposure)PointOfInterest alone does not initiate a (focus/exposure) operation.
                 Call set(Focus/Exposure)Mode() to apply the new point of interest.
                 */
                if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                    device.focusPointOfInterest = devicePoint
                    device.focusMode = focusMode
                }
                
                if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                    device.exposurePointOfInterest = devicePoint
                    device.exposureMode = exposureMode
                }
                
                device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                device.unlockForConfiguration()
            } catch {
                print("Could not lock device for configuration: \(error)")
            }
        }
    }
	
	// MARK: Capturing Photos

	private let photoOutput = AVCapturePhotoOutput()

	
	private var inProgressPhotoCaptureDelegates = [Int64: PhotoCaptureProcessor]()
	
	@IBOutlet weak var _photoButton: UIButton!
	@IBAction func capturePhoto(_ photoButton: UIButton) {
        /*
			Retrieve the video preview layer's video orientation on the main queue before
			entering the session queue. We do this to ensure UI elements are accessed on
			the main thread and session configuration is done on the session queue.
		*/
        let videoPreviewLayerOrientation = _previewView.videoPreviewLayer.connection?.videoOrientation
		
		sessionQueue.async {
			// Update the photo output's connection to match the video orientation of the video preview layer.
            if let photoOutputConnection = self.photoOutput.connection(with: AVMediaType.video) {
                photoOutputConnection.videoOrientation = videoPreviewLayerOrientation!
			}
			
            var photoSettings = AVCapturePhotoSettings()
            // Capture HEIF photo when supported, with flash set to auto and high resolution photo enabled.
            if  self.photoOutput.availablePhotoCodecTypes.contains(AVVideoCodecType(rawValue: AVVideoCodecType.hevc.rawValue)) {
                
            photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])

            }
            
            if self.videoDeviceInput.device.isFlashAvailable {
                photoSettings.flashMode = .auto
            }
            
			photoSettings.isHighResolutionPhotoEnabled = true
			if !photoSettings.availablePreviewPhotoPixelFormatTypes.isEmpty {
				photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoSettings.availablePreviewPhotoPixelFormatTypes.first!]
			}
			if self.livePhotoMode == .on && self.photoOutput.isLivePhotoCaptureSupported { // Live Photo capture is not supported in movie mode.
				let livePhotoMovieFileName = NSUUID().uuidString
				let livePhotoMovieFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((livePhotoMovieFileName as NSString).appendingPathExtension("mov")!)
				photoSettings.livePhotoMovieFileURL = URL(fileURLWithPath: livePhotoMovieFilePath)
			}
            
            if self.depthDataDeliveryMode == .on && self.photoOutput.isDepthDataDeliverySupported {
                photoSettings.isDepthDataDeliveryEnabled = true
            } else {
                photoSettings.isDepthDataDeliveryEnabled = false
            }
			
			// Use a separate object for the photo capture delegate to isolate each capture life cycle.
			let photoCaptureProcessor = PhotoCaptureProcessor(with: photoSettings, willCapturePhotoAnimation: {
					DispatchQueue.main.async { [unowned self] in
						self._previewView.videoPreviewLayer.opacity = 0
						UIView.animate(withDuration: 0.25) { [unowned self] in
							self._previewView.videoPreviewLayer.opacity = 1
						}
					}
				}, livePhotoCaptureHandler: { capturing in
					/*
						Because Live Photo captures can overlap, we need to keep track of the
						number of in progress Live Photo captures to ensure that the
						Live Photo label stays visible during these captures.
					*/
					self.sessionQueue.async { [unowned self] in
						if capturing {
							self.inProgressLivePhotoCapturesCount += 1
						} else {
							self.inProgressLivePhotoCapturesCount -= 1
						}
						
						let inProgressLivePhotoCapturesCount = self.inProgressLivePhotoCapturesCount
						DispatchQueue.main.async { [unowned self] in
							if inProgressLivePhotoCapturesCount > 0 {
								self._capturingLivePhotoLabel.isHidden = false
							} else if inProgressLivePhotoCapturesCount == 0 {
								self._capturingLivePhotoLabel.isHidden = true
							} else {
								print("Error: In progress live photo capture count is less than 0")
							}
						}
					}
				}, completionHandler: { [unowned self] photoCaptureProcessor in
					// When the capture is complete, remove a reference to the photo capture delegate so it can be deallocated.
                    
                    

                    self.sessionQueue.async { [unowned self] in
                       
                        let delegate = self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID]
                        
                        if let data = delegate?.photoData {
                            self.delegate?.imageTaken(data: data)
                        } else {
                            self.delegate?.imageFailed(errorMessage: "Ha habido un error al hacer la foto...")
                        }
                    self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = nil
                        
                        
					}
				}
			)
			
			/*
				The Photo Output keeps a weak reference to the photo capture delegate so
				we store it in an array to maintain a strong reference to this object
				until the capture is completed.
			*/
			self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = photoCaptureProcessor
			self.photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureProcessor)
		}
	}

	
	private enum LivePhotoMode {
		case on
		case off
	}
    
    private enum DepthDataDeliveryMode {
        case on
        case off
    }
	
	private var livePhotoMode: LivePhotoMode = .off
	
	@IBOutlet weak var _livePhotoModeButton: UIButton!
	
    @IBAction func toggleLivePhotoMode(_ livePhotoModeButton: UIButton) {
        sessionQueue.async { [unowned self] in
            self.livePhotoMode = (self.livePhotoMode == .on) ? .off : .on
            let livePhotoMode = self.livePhotoMode
            
            DispatchQueue.main.async { [unowned self] in
                if livePhotoMode == .on {
                    self._livePhotoModeButton.setTitle(NSLocalizedString("Live : On", comment: "Live photo mode button on title"), for: [])
                } else {
                    self._livePhotoModeButton.setTitle(NSLocalizedString("Live : Off", comment: "Live photo mode button off title"), for: [])
                }
            }
        }
    }
    
    private var depthDataDeliveryMode: DepthDataDeliveryMode = .off
    
    @IBOutlet weak var _depthDataDeliveryButton: UIButton!
    
    @IBAction func toggleDepthDataDeliveryMode(_ depthDataDeliveryButton: UIButton) {
        sessionQueue.async { [unowned self] in
            self.depthDataDeliveryMode = (self.depthDataDeliveryMode == .on) ? .off : .on
            let depthDataDeliveryMode = self.depthDataDeliveryMode
            
            DispatchQueue.main.async { [unowned self] in
                if depthDataDeliveryMode == .on {
                    self._depthDataDeliveryButton.setTitle(NSLocalizedString("Depth : On", comment: "Depth Data Delivery button on title"), for: [])
                } else {
                    self._depthDataDeliveryButton.setTitle(NSLocalizedString("Depth : Off", comment: "Depth Data Delivery button off title"), for: [])
                }
            }
        }
    }
    
	private var inProgressLivePhotoCapturesCount = 0
	
	@IBOutlet weak var _capturingLivePhotoLabel: UILabel!
	
	// MARK: Recording Movies
	
	private var movieFileOutput: AVCaptureMovieFileOutput?
	
	private var backgroundRecordingID: UIBackgroundTaskIdentifier?
	
	@IBOutlet weak var _recordButton: UIButton!
	
	@IBOutlet weak var _resumeButton: UIButton!
	
	@IBAction func toggleMovieRecording(_ recordButton: UIButton) {
		guard let movieFileOutput = self.movieFileOutput else {
			return
		}
		
		/*
			Disable the Camera button until recording finishes, and disable
			the Record button until recording starts or finishes.
		
			See the AVCaptureFileOutputRecordingDelegate methods.
		*/
		_cameraButton.isEnabled = false
		recordButton.isEnabled = false
		_captureModeControl.isEnabled = false
		
		/*
			Retrieve the video preview layer's video orientation on the main queue
			before entering the session queue. We do this to ensure UI elements are
			accessed on the main thread and session configuration is done on the session queue.
		*/
        let videoPreviewLayerOrientation = _previewView.videoPreviewLayer.connection?.videoOrientation
		
		sessionQueue.async { [unowned self] in
			if !movieFileOutput.isRecording {
				if UIDevice.current.isMultitaskingSupported {
					/*
						Setup background task.
						This is needed because the `capture(_:, didFinishRecordingToOutputFileAt:, fromConnections:, error:)`
						callback is not received until AVCam returns to the foreground unless you request background execution time.
						This also ensures that there will be time to write the file to the photo library when AVCam is backgrounded.
						To conclude this background execution, endBackgroundTask(_:) is called in
						`capture(_:, didFinishRecordingToOutputFileAt:, fromConnections:, error:)` after the recorded file has been saved.
					*/
					self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
				}
				
				// Update the orientation on the movie file output video connection before starting recording.
                let movieFileOutputConnection = self.movieFileOutput?.connection(with: AVMediaType.video)
                movieFileOutputConnection?.videoOrientation = videoPreviewLayerOrientation!
                
                let availableVideoCodecTypes = movieFileOutput.availableVideoCodecTypes as [AVVideoCodecType]
                
                if availableVideoCodecTypes.contains(.hevc) {
                    movieFileOutput.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.hevc], for: movieFileOutputConnection!)
                }
                
				// Start recording to a temporary file.
				let outputFileName = NSUUID().uuidString
				let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
                movieFileOutput.startRecording(to: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
			} else {
				movieFileOutput.stopRecording()
			}
		}
	}
	
	func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
		// Enable the Record button to let the user stop the recording.
		DispatchQueue.main.async { [unowned self] in
			self._recordButton.isEnabled = true
			self._recordButton.setTitle(NSLocalizedString("Stop", comment: "Recording button stop title"), for: [])
		}
	}
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
		/*
			Note that currentBackgroundRecordingID is used to end the background task
			associated with this recording. This allows a new recording to be started,
			associated with a new UIBackgroundTaskIdentifier, once the movie file output's
			`isRecording` property is back to false — which happens sometime after this method
			returns.
		
			Note: Since we use a unique file path for each recording, a new recording will
			not overwrite a recording currently being saved.
		*/
		func cleanup() {
			let path = outputFileURL.path
            if FileManager.default.fileExists(atPath: path) {
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch {
                    print("Could not remove file at url: \(outputFileURL)")
                }
            }
			
			if let currentBackgroundRecordingID = backgroundRecordingID {
				backgroundRecordingID = UIBackgroundTaskInvalid
				
				if currentBackgroundRecordingID != UIBackgroundTaskInvalid {
					UIApplication.shared.endBackgroundTask(currentBackgroundRecordingID)
				}
			}
		}
		
		var success = true
		
		if error != nil {
            
            print("Movie file finishing error: \(String(describing: error))")
            success = (((error! as NSError).userInfo[AVErrorRecordingSuccessfullyFinishedKey] as AnyObject).boolValue)!
            
            self.delegate?.videoRecordingFailed(errorMessage: "Movie file finishing error: \(String(describing: error))")
		}
		
		if success {
            
            self.delegate?.videoRecordingComplete(videoURL: outputFileURL)
            
			/*// Check authorization status.
			PHPhotoLibrary.requestAuthorization { status in
				if status == .authorized {
					// Save the movie file to the photo library and cleanup.
					PHPhotoLibrary.shared().performChanges({
							let options = PHAssetResourceCreationOptions()
							options.shouldMoveFile = true
							let creationRequest = PHAssetCreationRequest.forAsset()
							creationRequest.addResource(with: .video, fileURL: outputFileURL, options: options)
						}, completionHandler: { success, error in
							if !success {
								print("Could not save movie to photo library: \(String(describing: error))")
							}
							cleanup()
						}
					)
				} else {
					cleanup()
				}
			}*/
		} else {
            self.delegate?.videoRecordingFailed(errorMessage:nil)
			cleanup()
		}
		
		// Enable the Camera and Record buttons to let the user switch camera and start another recording.
		DispatchQueue.main.async { [unowned self] in
			// Only enable the ability to change camera if the device has more than one camera.
			self._cameraButton.isEnabled = self.videoDeviceDiscoverySession.uniqueDevicePositionsCount() > 1
			self._recordButton.isEnabled = true
			self._captureModeControl.isEnabled = true
			self._recordButton.setTitle(NSLocalizedString("Record", comment: "Recording button record title"), for: [])
		}
	}
	
	// MARK: KVO and Notifications
	
	private var sessionRunningObserveContext = 0
	
	private func addObservers() {
		session.addObserver(self, forKeyPath: "running", options: .new, context: &sessionRunningObserveContext)
		
		NotificationCenter.default.addObserver(self, selector: #selector(subjectAreaDidChange), name: .AVCaptureDeviceSubjectAreaDidChange, object: videoDeviceInput.device)
		NotificationCenter.default.addObserver(self, selector: #selector(sessionRuntimeError), name: .AVCaptureSessionRuntimeError, object: session)
		
		/*
			A session can only run when the app is full screen. It will be interrupted
			in a multi-app layout, introduced in iOS 9, see also the documentation of
			AVCaptureSessionInterruptionReason. Add observers to handle these session
			interruptions and show a preview is paused message. See the documentation
			of AVCaptureSessionWasInterruptedNotification for other interruption reasons.
		*/
		NotificationCenter.default.addObserver(self, selector: #selector(sessionWasInterrupted), name: .AVCaptureSessionWasInterrupted, object: session)
		NotificationCenter.default.addObserver(self, selector: #selector(sessionInterruptionEnded), name: .AVCaptureSessionInterruptionEnded, object: session)
	}
	
	private func removeObservers() {
		NotificationCenter.default.removeObserver(self)
		session.removeObserver(self, forKeyPath: "running", context: &sessionRunningObserveContext)
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if context == &sessionRunningObserveContext {
			let newValue = change?[.newKey] as AnyObject?
			guard let isSessionRunning = newValue?.boolValue else { return }
			let isLivePhotoCaptureSupported = photoOutput.isLivePhotoCaptureSupported
			let isLivePhotoCaptureEnabled = photoOutput.isLivePhotoCaptureEnabled
            let isDepthDeliveryDataSupported = photoOutput.isDepthDataDeliverySupported
            let isDepthDeliveryDataEnabled = photoOutput.isDepthDataDeliveryEnabled
			
			DispatchQueue.main.async { [unowned self] in
				// Only enable the ability to change camera if the device has more than one camera.
				self._cameraButton.isEnabled = isSessionRunning && self.videoDeviceDiscoverySession.uniqueDevicePositionsCount() > 1
				self._recordButton.isEnabled = isSessionRunning && self.movieFileOutput != nil
				self._photoButton.isEnabled = isSessionRunning
				self._captureModeControl.isEnabled = isSessionRunning
				self._livePhotoModeButton.isEnabled = isSessionRunning && isLivePhotoCaptureEnabled
				self._livePhotoModeButton.isHidden = !(isSessionRunning && isLivePhotoCaptureSupported)
                self._depthDataDeliveryButton.isEnabled = isSessionRunning && isDepthDeliveryDataEnabled
                self._depthDataDeliveryButton.isHidden = !(isSessionRunning && isDepthDeliveryDataSupported)
			}
		} else {
			super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
		}
	}
	
@objc
	func subjectAreaDidChange(notification: NSNotification) {
		let devicePoint = CGPoint(x: 0.5, y: 0.5)
		focus(with: .autoFocus, exposureMode: .continuousAutoExposure, at: devicePoint, monitorSubjectAreaChange: false)
	}
	
@objc
	func sessionRuntimeError(notification: NSNotification) {
		guard let errorValue = notification.userInfo?[AVCaptureSessionErrorKey] as? NSError else {
			return
		}
		
        let error = AVError(_nsError: errorValue)
		print("Capture session runtime error: \(error)")
		
		/*
			Automatically try to restart the session running if media services were
			reset and the last start running succeeded. Otherwise, enable the user
			to try to resume the session running.
		*/
		if error.code == .mediaServicesWereReset {
			sessionQueue.async { [unowned self] in
				if self.isSessionRunning {
					self.session.startRunning()
					self.isSessionRunning = self.session.isRunning
				} else {
					DispatchQueue.main.async { [unowned self] in
						self._resumeButton.isHidden = false
					}
				}
			}
		} else {
            _resumeButton.isHidden = false
		}
	}
	
@objc
	func sessionWasInterrupted(notification: NSNotification) {
		/*
			In some scenarios we want to enable the user to resume the session running.
			For example, if music playback is initiated via control center while
			using AVCam, then the user can let AVCam resume
			the session running, which will stop music playback. Note that stopping
			music playback in control center will not automatically resume the session
			running. Also note that it is not always possible to resume, see `resumeInterruptedSession(_:)`.
		*/
        if let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?, let reasonIntegerValue = userInfoValue.integerValue, let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue) {
			print("Capture session was interrupted with reason \(reason)")
			
			var showResumeButton = false
			
			if reason == .audioDeviceInUseByAnotherClient || reason == .videoDeviceInUseByAnotherClient {
				showResumeButton = true
			} else if reason == .videoDeviceNotAvailableWithMultipleForegroundApps {
				// Simply fade-in a label to inform the user that the camera is unavailable.
				_cameraUnavailableLabel.alpha = 0
				_cameraUnavailableLabel.isHidden = false
				UIView.animate(withDuration: 0.25) { [unowned self] in
					self._cameraUnavailableLabel.alpha = 1
				}
			}
			
			if showResumeButton {
				// Simply fade-in a button to enable the user to try to resume the session running.
				_resumeButton.alpha = 0
				_resumeButton.isHidden = false
				UIView.animate(withDuration: 0.25) { [unowned self] in
					self._resumeButton.alpha = 1
				}
			}
		}
	}
	
@objc
	func sessionInterruptionEnded(notification: NSNotification) {
		print("Capture session interruption ended")
		
		if !_resumeButton.isHidden {
			UIView.animate(withDuration: 0.25,
				animations: { [unowned self] in
					self._resumeButton.alpha = 0
				}, completion: { [unowned self] _ in
					self._resumeButton.isHidden = true
				}
			)
		}
		if !_cameraUnavailableLabel.isHidden {
			UIView.animate(withDuration: 0.25,
			    animations: { [unowned self] in
					self._cameraUnavailableLabel.alpha = 0
				}, completion: { [unowned self] _ in
					self._cameraUnavailableLabel.isHidden = true
				}
			)
		}
	}
}

extension UIDeviceOrientation {
    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
            case .portrait: return .portrait
            case .portraitUpsideDown: return .portraitUpsideDown
            case .landscapeLeft: return .landscapeRight
            case .landscapeRight: return .landscapeLeft
            default: return nil
        }
    }
}

extension UIInterfaceOrientation {
    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
            case .portrait: return .portrait
            case .portraitUpsideDown: return .portraitUpsideDown
            case .landscapeLeft: return .landscapeLeft
            case .landscapeRight: return .landscapeRight
            default: return nil
        }
    }
}

extension AVCaptureDevice.DiscoverySession {
    func uniqueDevicePositionsCount() -> Int {
        var uniqueDevicePositions: [AVCaptureDevice.Position] = []
        
        for device in devices {
            if !uniqueDevicePositions.contains(device.position) {
                uniqueDevicePositions.append(device.position)
            }
        }
        
        return uniqueDevicePositions.count
    }
}


protocol AAPLCameraViewDelegate : class {
    func videoRecordingComplete(videoURL: URL)
    func videoRecordingFailed(errorMessage: String?)
    func imageTaken(data: Data)
    func imageFailed(errorMessage: String?)
}
