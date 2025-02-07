import UIKit
import SnapKit
import RxSwift
import MarketKit

class MiscController: UIViewController {
    private let disposeBag = DisposeBag()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Misc"
        view.backgroundColor = .systemGroupedBackground

        let coinPricesButton = UIButton()

        view.addSubview(coinPricesButton)
        coinPricesButton.snp.makeConstraints { maker in
            maker.top.equalTo(view.safeAreaLayoutGuide).inset(16)
            maker.centerX.equalToSuperview()
        }

        coinPricesButton.setTitle("Coin Prices", for: .normal)
        coinPricesButton.setTitleColor(.systemBlue, for: .normal)
        coinPricesButton.addTarget(self, action: #selector(onTapCoinPrices), for: .touchUpInside)

        let coinHistoricalPriceButton = UIButton()

        view.addSubview(coinHistoricalPriceButton)
        coinHistoricalPriceButton.snp.makeConstraints { maker in
            maker.top.equalTo(coinPricesButton.snp.bottom).offset(8)
            maker.centerX.equalToSuperview()
        }

        coinHistoricalPriceButton.setTitle("Historical Price", for: .normal)
        coinHistoricalPriceButton.setTitleColor(.systemBlue, for: .normal)
        coinHistoricalPriceButton.addTarget(self, action: #selector(onTapCoinHistoricalPrice), for: .touchUpInside)

        let globalMarketInfoButton = UIButton()

        view.addSubview(globalMarketInfoButton)
        globalMarketInfoButton.snp.makeConstraints { maker in
            maker.top.equalTo(coinHistoricalPriceButton.snp.bottom).offset(8)
            maker.centerX.equalToSuperview()
        }

        globalMarketInfoButton.setTitle("Global Market Info", for: .normal)
        globalMarketInfoButton.setTitleColor(.systemBlue, for: .normal)
        globalMarketInfoButton.addTarget(self, action: #selector(onTapGlobalMarketInfo), for: .touchUpInside)

        let dumpCoinsButton = UIButton()

        view.addSubview(dumpCoinsButton)
        dumpCoinsButton.snp.makeConstraints { maker in
            maker.top.equalTo(globalMarketInfoButton.snp.bottom).offset(8)
            maker.centerX.equalToSuperview()
        }

        dumpCoinsButton.setTitle("Dump Coins", for: .normal)
        dumpCoinsButton.setTitleColor(.systemBlue, for: .normal)
        dumpCoinsButton.addTarget(self, action: #selector(onTapDumpCoins), for: .touchUpInside)

        let dumpBlockchainsButton = UIButton()

        view.addSubview(dumpBlockchainsButton)
        dumpBlockchainsButton.snp.makeConstraints { maker in
            maker.top.equalTo(dumpCoinsButton.snp.bottom).offset(8)
            maker.centerX.equalToSuperview()
        }

        dumpBlockchainsButton.setTitle("Dump Blockchains", for: .normal)
        dumpBlockchainsButton.setTitleColor(.systemBlue, for: .normal)
        dumpBlockchainsButton.addTarget(self, action: #selector(onTapDumpBlockchains), for: .touchUpInside)

        let dumpTokensButton = UIButton()

        view.addSubview(dumpTokensButton)
        dumpTokensButton.snp.makeConstraints { maker in
            maker.top.equalTo(dumpBlockchainsButton.snp.bottom).offset(8)
            maker.centerX.equalToSuperview()
        }

        dumpTokensButton.setTitle("Dump Tokens", for: .normal)
        dumpTokensButton.setTitleColor(.systemBlue, for: .normal)
        dumpTokensButton.addTarget(self, action: #selector(onTapDumpTokens), for: .touchUpInside)

        let platformsButton = UIButton()

        view.addSubview(platformsButton)
        platformsButton.snp.makeConstraints { maker in
            maker.top.equalTo(dumpTokensButton.snp.bottom).offset(8)
            maker.centerX.equalToSuperview()
        }

        platformsButton.setTitle("Platforms", for: .normal)
        platformsButton.setTitleColor(.systemBlue, for: .normal)
        platformsButton.addTarget(self, action: #selector(onTapPlatforms), for: .touchUpInside)
    }

    @objc private func onTapCoinPrices() {
        Singleton.instance.kit.coinPriceMapObservable(coinUids: ["bitcoin", "ethereum"], currencyCode: "USD")
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { coinPriceMap in
                    print("ON NEXT: \(coinPriceMap)")
                })
                .disposed(by: disposeBag)
    }

    @objc private func onTapCoinHistoricalPrice() {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: 2020, month: 3, day: 15)
        guard let date = calendar.date(from: components) else {
            return
        }

        Singleton.instance.kit.coinHistoricalPriceValueSingle(coinUid: "bitcoin", currencyCode: "USD", timestamp: date.timeIntervalSince1970)
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { value in
                    print("Historical Price: \(value)")
                })
                .disposed(by: disposeBag)
    }

    @objc private func onTapGlobalMarketInfo() {
        Singleton.instance.kit.globalMarketPointsSingle(currencyCode: "USD", timePeriod: .day1)
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { points in
                    print("SUCCESS: count: \(points.count)\n\(points.map { "\($0)" }.joined(separator: "\n"))")
                })
                .disposed(by: disposeBag)
    }

    @objc private func onTapDumpCoins() {
        dump { try Singleton.instance.kit.coinsDump() }
    }

    @objc private func onTapDumpBlockchains() {
        dump { try Singleton.instance.kit.blockchainsDump() }
    }

    @objc private func onTapDumpTokens() {
        dump { try Singleton.instance.kit.tokenRecordsDump() }
    }

    @objc private func onTapPlatforms() {
        Singleton.instance.kit.topPlatformsSingle(currencyCode: "USD")
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { topPlatforms in
                    print("SUCCESS: count: \(topPlatforms.count)\n\(topPlatforms.map { "\($0)" }.joined(separator: "\n"))")
                })
                .disposed(by: disposeBag)
    }

    private func dump(dumpBlock: () throws -> String?) {
        let message: String

        do {
            if let coinsDump = try dumpBlock() {
                UIPasteboard.general.string = coinsDump
                message = "The JSON dump is copied to the clipboard.\nPaste it into corresponding file and commit"
            } else {
                message = "Unexpected Error"
            }
        } catch {
            message = error.localizedDescription
        }

        let alert = UIAlertController(title: "Whoa", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        present(alert, animated: true)
    }

}
