import TVSetKit
import MediaApis

public class KinoGoService {
  static let shared: KinoGoAPI = {
    return KinoGoAPI()
  }()

  static let bookmarksFileName = NSHomeDirectory() + "/Library/Caches/kinogo-bookmarks.json"
  static let historyFileName = NSHomeDirectory() + "/Library/Caches/kinogo-history.json"

  public static let StoryboardId = "KinoGo"
  public static let BundleId = "com.rubikon.KinoGoSite"

  lazy var bookmarks = Bookmarks(KinoGoService.bookmarksFileName)
  lazy var history = History(KinoGoService.historyFileName)

  lazy var bookmarksManager = BookmarksManager(bookmarks)
  lazy var historyManager = HistoryManager(history)

  var dataSource = KinoGoDataSource()

  let mobile: Bool

  public init(_ mobile: Bool=false) {
    self.mobile = mobile
  }

  func buildLayout() -> UICollectionViewFlowLayout? {
    let layout = UICollectionViewFlowLayout()

    layout.itemSize = CGSize(width: 220*1.25, height: 303*1.25) // 220 x 303
    layout.sectionInset = UIEdgeInsets(top: 40.0, left: 40.0, bottom: 120.0, right: 40.0)
    layout.minimumInteritemSpacing = 40.0
    layout.minimumLineSpacing = 85.0

    layout.headerReferenceSize = CGSize(width: 500, height: 75)

    return layout
  }

  func getDetailsImageFrame() -> CGRect? {
    return CGRect(x: 40, y: 40, width: 180*2.7, height: 248*2.7)
  }

  func getConfiguration() -> [String: Any] {
    var conf = [String: Any]()

    conf["pageSize"] = 12

    if mobile {
      conf["rowSize"] = 1
    }
    else {
      conf["rowSize"] = 6
    }

    conf["mobile"] = mobile

    conf["bookmarksManager"] = bookmarksManager
    conf["historyManager"] = historyManager
    conf["dataSource"] = dataSource
    conf["storyboardId"] = KinoGoService.StoryboardId
    conf["bundleId"] = KinoGoService.BundleId
    conf["detailsImageFrame"] = getDetailsImageFrame()
    conf["buildLayout"] = buildLayout()

    return conf
  }
}
