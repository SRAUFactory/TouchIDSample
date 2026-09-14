import UIKit
import LocalAuthentication

class ViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Touch ID 認証サンプル"
        label.font = .boldSystemFont(ofSize: 22)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "下のボタンをタップして指紋認証を開始してください。\n\n※ シミュレータで検証する場合は iPhone SE などの Touch ID 端末を選択し、メニューの Features > Touch ID > Enrolled を有効にしてください。"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var authenticateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Touch ID で認証する", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapAuthenticateButton), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(titleLabel)
        view.addSubview(statusLabel)
        view.addSubview(authenticateButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            statusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            authenticateButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            authenticateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            authenticateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            authenticateButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func didTapAuthenticateButton() {
        Task {
            await authenticateWithTouchID()
        }
    }

    // async/await を使用した Touch ID 認証処理
    func authenticateWithTouchID() async {
        let context = LAContext()
        var error: NSError?

        // 1. 生体認証が利用可能かチェック
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            let errorMsg = "生体認証が利用できません: \(error?.localizedDescription ?? "不明なエラー")"
            print(errorMsg)
            updateStatus(errorMsg, color: .systemRed)
            return
        }

        // 2. 認証方式が Touch ID かチェック（Face ID端末を除外する場合）
        if #available(iOS 11.0, *) {
            guard context.biometryType == .touchID else {
                let errorMsg = "この端末は Touch ID ではありません（Face ID等の別方式）\nシミュレータの設定で iPhone SE などを選択してください。"
                print(errorMsg)
                updateStatus(errorMsg, color: .systemOrange)
                return
            }
        }

        // 3. 認証の実行
        let reason = "アプリのロック解除のために指紋認証を行ってください"
        updateStatus("認証待ち...\nシミュレータメニューの\nFeatures > Touch ID > Matching Touch を選択してください", color: .systemBlue)

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            if success {
                let successMsg = "Touch ID 認証成功！"
                print(successMsg)
                updateStatus(successMsg, color: .systemGreen)
            }
        } catch let laError as LAError {
            let errorMsg: String
            switch laError.code {
            case .userCancel:
                errorMsg = "認証がユーザーによってキャンセルされました"
            case .authenticationFailed:
                errorMsg = "認証に失敗しました（指紋が一致しません）"
            case .biometryNotEnrolled:
                errorMsg = "Touch ID が登録されていません\nFeatures > Touch ID > Enrolled をオンにしてください"
            default:
                errorMsg = "認証エラー: \(laError.localizedDescription)"
            }
            print(errorMsg)
            updateStatus(errorMsg, color: .systemRed)
        } catch {
            let errorMsg = "予期せぬエラー: \(error.localizedDescription)"
            print(errorMsg)
            updateStatus(errorMsg, color: .systemRed)
        }
    }

    private func updateStatus(_ text: String, color: UIColor) {
        statusLabel.text = text
        statusLabel.textColor = color
    }
}
