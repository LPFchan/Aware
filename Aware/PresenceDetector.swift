import AVFoundation
import Foundation
import ImageIO
import Vision

/// Returns true if the frame is mostly black (camera warmup). Samples 32BGRA pixels.
private func isPredominantlyBlack(_ pixelBuffer: CVPixelBuffer) -> Bool {
    CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
    defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }
    guard let base = CVPixelBufferGetBaseAddress(pixelBuffer) else { return true }
    let width = CVPixelBufferGetWidth(pixelBuffer)
    let height = CVPixelBufferGetHeight(pixelBuffer)
    let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
    let step = max(1, (width * height) / 64)  // Sample ~64 pixels
    var sum: Int = 0
    var count = 0
    for i in Swift.stride(from: 0, to: width * height, by: step) {
        let row = i / width
        let col = i % width
        let offset = row * bytesPerRow + col * 4
        let b = (base + offset).load(as: UInt8.self)
        let g = (base + offset + 1).load(as: UInt8.self)
        let r = (base + offset + 2).load(as: UInt8.self)
        sum += Int(b) + Int(g) + Int(r)
        count += 1
    }
    let avgLuminance = count > 0 ? Double(sum) / Double(count * 3) : 0
    return avgLuminance < 15  // Threshold: 0=black, 255=white
}

/// Owns AVCaptureSession lifecycle and VNDetectFaceRectanglesRequest execution.
/// Captures a single low-resolution frame and checks for face presence.
final class PresenceDetector: NSObject {
    enum Result {
        case faceDetected
        case noFace
        case cameraUnavailable
        case permissionDenied
    }
    
    private let session = AVCaptureSession()
    private let workQueue = DispatchQueue(label: "com.aware.presence", qos: .userInitiated)
    private var captureCompletion: ((Result) -> Void)?
    private var frameCount = 0
    
    override init() {
        super.init()
    }

    /// Stops any in-flight capture without reporting a detection result.
    func cancelPendingCapture() {
        workQueue.async { [weak self] in
            self?.finishWith(nil)
        }
    }
    
    /// Captures a single frame and runs face detection. Completion is called on the main queue.
    func checkForPresence(completion: @escaping (Result) -> Void) {
        captureCompletion = completion
        
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            DispatchQueue.main.async { [weak self] in
                self?.captureCompletion?(.permissionDenied)
                self?.captureCompletion = nil
            }
            return
        }
        
        workQueue.async { [weak self] in
            self?.performCapture()
        }
    }
    
    private func performCapture() {
        frameCount = 0  // Reset for each capture session
        session.beginConfiguration()
        
        // Prefer front-facing (FaceTime on Mac); fall back to default video device
        let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            ?? AVCaptureDevice.default(for: .video)
        guard let camera = camera else {
            session.commitConfiguration()
            finishWith(.cameraUnavailable)
            return
        }
        // Prefer 720p for better face detection; fall back to 640x480
        let preset: AVCaptureSession.Preset = camera.supportsSessionPreset(.hd1280x720) ? .hd1280x720 : .vga640x480
        session.sessionPreset = preset
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(input) {
                session.addInput(input)
            }
        } catch {
            session.commitConfiguration()
            finishWith(.cameraUnavailable)
            return
        }
        
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: workQueue)
        
        guard session.canAddOutput(output) else {
            session.commitConfiguration()
            finishWith(.cameraUnavailable)
            return
        }
        session.addOutput(output)
        session.commitConfiguration()
        
        session.startRunning()
    }
    
    private func finishWith(_ result: Result?) {
        session.stopRunning()
        if let input = session.inputs.first {
            session.removeInput(input)
        }
        session.outputs.forEach { session.removeOutput($0) }
        
        DispatchQueue.main.async { [weak self] in
            if let result {
                self?.captureCompletion?(result)
            }
            self?.captureCompletion = nil
        }
    }
}

extension PresenceDetector: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            finishWith(.noFace)
            return
        }
        
        // Skip warmup frames — Mac camera often produces 5–15 black frames before valid image
        frameCount += 1
        guard frameCount > 15 else {
            return  // Don't stop session; wait for camera to produce valid frames
        }
        
        // Discard black frames — average luminance too low means camera not ready yet
        // After 60 frames (~2s), accept whatever we have to avoid waiting forever in dark room
        if frameCount <= 60, isPredominantlyBlack(pixelBuffer) {
            return
        }
        
        session.stopRunning()
        
        let request = VNDetectFaceRectanglesRequest()
        // Use Revision 1 for broader compatibility; Revision 3 can be stricter on some Macs
        if #available(macOS 14.0, *) {
            request.revision = VNDetectFaceRectanglesRequestRevision2
        }
        
        // Try .left first (most Mac FaceTime cameras); then fall back to others
        let orientations: [CGImagePropertyOrientation] = [.left, .up, .down, .right, .leftMirrored, .upMirrored, .downMirrored, .rightMirrored]
        var hasFace = false
        
        for orientation in orientations {
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])
            do {
                try handler.perform([request])
                if (request.results?.count ?? 0) >= 1 {
                    hasFace = true
                    break
                }
            } catch {
                continue
            }
        }
        
        finishWith(hasFace ? .faceDetected : .noFace)
    }
}
