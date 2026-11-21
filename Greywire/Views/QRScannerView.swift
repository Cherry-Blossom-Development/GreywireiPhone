import SwiftUI
import AVFoundation

/// A view that scans QR codes using the camera.
struct QRScannerView: View {
    let onCodeScanned: (String) -> Void
    let onCancel: () -> Void

    @State private var permissionDenied = false
    @State private var isScanning = true

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if permissionDenied {
                permissionDeniedView
            } else {
                QRCameraView(
                    isScanning: $isScanning,
                    onCodeFound: { code in
                        // Only process once
                        guard isScanning else { return }
                        isScanning = false
                        onCodeScanned(code)
                    }
                )
                .ignoresSafeArea()

                // Overlay with scanning frame
                scannerOverlay
            }
        }
        .task {
            await checkCameraPermission()
        }
    }

    private var scannerOverlay: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundStyle(Color.white)
                        .padding()
                }
                Spacer()
            }
            .background(Color.black.opacity(0.5))

            Spacer()

            // Scanning frame
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.greywireCopper, lineWidth: 3)
                .frame(width: 250, height: 250)
                .background(Color.clear)

            Spacer().frame(height: 24)

            Text("Point at the QR code on your pedal")
                .font(.greywireBody)
                .foregroundStyle(Color.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            // Manual entry option
            Button(action: onCancel) {
                Text("Enter serial manually")
                    .font(.greywireBody)
                    .foregroundStyle(Color.greywireCopper)
            }
            .padding(.bottom, 40)
        }
    }

    private var permissionDeniedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color.greywireMuted)

            Text("Camera access required")
                .font(.greywireHeadline)
                .foregroundStyle(Color.greywireText)

            Text("To scan QR codes, allow camera access in Settings.")
                .font(.greywireBody)
                .foregroundStyle(Color.greywireMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer().frame(height: 20)

            GreywireButton(title: "Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .padding(.horizontal, 40)

            Button(action: onCancel) {
                Text("Enter serial manually")
                    .font(.greywireBody)
                    .foregroundStyle(Color.greywireCopper)
            }
            .padding(.top, 12)
        }
        .padding()
    }

    private func checkCameraPermission() async {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionDenied = false
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            await MainActor.run {
                permissionDenied = !granted
            }
        case .denied, .restricted:
            await MainActor.run {
                permissionDenied = true
            }
        @unknown default:
            await MainActor.run {
                permissionDenied = true
            }
        }
    }
}

// MARK: - QR Camera View (UIKit wrapper)

private struct QRCameraView: UIViewControllerRepresentable {
    @Binding var isScanning: Bool
    let onCodeFound: (String) -> Void

    func makeUIViewController(context: Context) -> QRCameraViewController {
        let controller = QRCameraViewController()
        controller.onCodeFound = onCodeFound
        return controller
    }

    func updateUIViewController(_ uiViewController: QRCameraViewController, context: Context) {
        uiViewController.isScanning = isScanning
    }
}

private class QRCameraViewController: UIViewController {
    var onCodeFound: ((String) -> Void)?
    var isScanning = true

    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var metadataDelegate: MetadataDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScanning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanning()
    }

    private func setupCamera() {
        let session = AVCaptureSession()

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        let output = AVCaptureMetadataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            // Use a separate delegate object to avoid actor isolation issues
            metadataDelegate = MetadataDelegate { [weak self] code in
                guard let self, self.isScanning else { return }
                // Vibrate to indicate successful scan
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                self.onCodeFound?(code)
            }
            output.setMetadataObjectsDelegate(metadataDelegate, queue: .main)
            output.metadataObjectTypes = [.qr]
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)

        self.captureSession = session
        self.previewLayer = previewLayer
    }

    private func startScanning() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }

    private func stopScanning() {
        captureSession?.stopRunning()
    }
}

/// Separate delegate class to handle AVCaptureMetadataOutputObjectsDelegate without actor isolation issues.
private class MetadataDelegate: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    private let onCodeFound: (String) -> Void

    init(onCodeFound: @escaping (String) -> Void) {
        self.onCodeFound = onCodeFound
        super.init()
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              metadataObject.type == .qr,
              let code = metadataObject.stringValue else {
            return
        }
        onCodeFound(code)
    }
}
