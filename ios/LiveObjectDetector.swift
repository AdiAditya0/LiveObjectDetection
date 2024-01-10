//
//  LiveObjectDetector.swift
//  LiveObjectDetection
//
//  Created by deq on 09/01/24.
//

import AVFoundation
import CoreVideo
import MLImage
import MLKit

private enum Constant {
  static let alertControllerTitle = "Vision Detectors"
  static let alertControllerMessage = "Select a detector"
  static let cancelActionTitleText = "Cancel"
  static let videoDataOutputQueueLabel = "com.google.mlkit.visiondetector.VideoDataOutputQueue"
  static let sessionQueueLabel = "com.google.mlkit.visiondetector.SessionQueue"
  static let noResultsMessage = "No Results"
  static let localModelFile = (name: "bird", type: "tflite")
  static let labelConfidenceThreshold = 0.75
  static let smallDotRadius: CGFloat = 4.0
  static let lineWidth: CGFloat = 3.0
  static let originalScale: CGFloat = 1.0
  static let padding: CGFloat = 10.0
  static let resultsLabelHeight: CGFloat = 200.0
  static let resultsLabelLines = 5
  static let imageLabelResultFrameX = 0.4
  static let imageLabelResultFrameY = 0.1
  static let imageLabelResultFrameWidth = 0.5
  static let imageLabelResultFrameHeight = 0.8
  static let segmentationMaskAlpha: CGFloat = 0.5
}

class LiveObjectDetector: UIViewController {
  private var isUsingFrontCamera = true
  private var previewLayer: AVCaptureVideoPreviewLayer!
  private lazy var captureSession = AVCaptureSession()
  private lazy var sessionQueue = DispatchQueue(label: Constant.sessionQueueLabel)
  private var lastFrame: CMSampleBuffer?
  
  private lazy var previewOverlayView: UIImageView = {

    precondition(isViewLoaded)
    let previewOverlayView = UIImageView(frame: .zero)
    previewOverlayView.contentMode = UIView.ContentMode.scaleAspectFill
    previewOverlayView.translatesAutoresizingMaskIntoConstraints = false
    return previewOverlayView
  }()

  private lazy var annotationOverlayView: UIView = {
    precondition(isViewLoaded)
    let annotationOverlayView = UIView(frame: .zero)
    annotationOverlayView.translatesAutoresizingMaskIntoConstraints = false
    return annotationOverlayView
  }()
}

extension LiveObjectDetector: AVCaptureVideoDataOutputSampleBufferDelegate {

  func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
      print("Failed to get image buffer from sample buffer.")
      return
    }

    lastFrame = sampleBuffer
    let visionImage = VisionImage(buffer: sampleBuffer)
    let orientation = UIUtilities.imageOrientation(
      fromDevicePosition: isUsingFrontCamera ? .front : .back
    )
    visionImage.orientation = orientation

    guard let inputImage = MLImage(sampleBuffer: sampleBuffer) else {
      print("Failed to create MLImage from sample buffer.")
      return
    }
    inputImage.orientation = orientation

    let imageWidth = CGFloat(CVPixelBufferGetWidth(imageBuffer))
    let imageHeight = CGFloat(CVPixelBufferGetHeight(imageBuffer))

    let options = ObjectDetectorOptions()
    options.shouldEnableClassification = true
    options.shouldEnableMultipleObjects = false
    detectObjectsOnDevice(
      in: visionImage,
      width: imageWidth,
      height: imageHeight,
      options: options)
  }
  
  private func detectObjectsOnDevice(
    in image: VisionImage,
    width: CGFloat,
    height: CGFloat,
    options: CommonObjectDetectorOptions
  ) {
    let detector = ObjectDetector.objectDetector(options: options)
    var objects: [Object] = []
    var detectionError: Error? = nil
    do {
      objects = try detector.results(in: image)
    } catch let error {
      detectionError = error
    }

    weak var weakSelf = self
    DispatchQueue.main.sync {
      guard let strongSelf = weakSelf else {
        print("Self is nil!")
        return
      }
      strongSelf.self.updatePreviewOverlayViewWithLastFrame()
      if let detectionError = detectionError {
        print("Failed to detect objects with error: \(detectionError.localizedDescription).")
        return

      }
      guard !objects.isEmpty else {
        print("On-Device object detector returned no results.")
        return
      }
      for object in objects {
        let normalizedRect = CGRect(
          x: object.frame.origin.x / width,
          y: object.frame.origin.y / height,
          width: object.frame.size.width / width,
          height: object.frame.size.height / height
        )
        let standardizedRect = strongSelf.previewLayer.layerRectConverted(
          fromMetadataOutputRect: normalizedRect
        ).standardized
        UIUtilities.addRectangle(
          standardizedRect,
          to: strongSelf.annotationOverlayView,
          color: UIColor.green
        )
        let label = UILabel(frame: standardizedRect)
        var description = ""
        if let trackingID = object.trackingID {
          description += "Object ID: " + trackingID.stringValue + "\n"
        }
        description += object.labels.enumerated().map { (index, label) in
          "Label \(index): \(label.text), \(label.confidence), \(label.index)"
        }.joined(separator: "\n")

        label.text = description
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        strongSelf.rotate(label, orientation: image.orientation)
        strongSelf.annotationOverlayView.addSubview(label)
      }
    }
  }
  
  private func updatePreviewOverlayViewWithLastFrame() {
    guard let lastFrame = lastFrame,
      let imageBuffer = CMSampleBufferGetImageBuffer(lastFrame)
    else {
      return
    }
    self.updatePreviewOverlayViewWithImageBuffer(imageBuffer)
    self.removeDetectionAnnotations()
  }
  
  private func updatePreviewOverlayViewWithImageBuffer(_ imageBuffer: CVImageBuffer?) {
    guard let imageBuffer = imageBuffer else {
      return
    }
    let orientation: UIImage.Orientation = isUsingFrontCamera ? .leftMirrored : .right
    let image = UIUtilities.createUIImage(from: imageBuffer, orientation: orientation)
    previewOverlayView.image = image
  }
  
  private func removeDetectionAnnotations() {
    for annotationView in annotationOverlayView.subviews {
      annotationView.removeFromSuperview()
    }
  }
  
  private func rotate(_ view: UIView, orientation: UIImage.Orientation) {
    var degree: CGFloat = 0.0
    switch orientation {
    case .up, .upMirrored:
      degree = 90.0
    case .rightMirrored, .left:
      degree = 180.0
    case .down, .downMirrored:
      degree = 270.0
    case .leftMirrored, .right:
      degree = 0.0
    }
    view.transform = CGAffineTransform.init(rotationAngle: degree * 3.141592654 / 180)
  }
}
