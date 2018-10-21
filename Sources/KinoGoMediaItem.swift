import UIKit
import WebAPI
import TVSetKit

class KinoGoMediaItem: MediaItem {
  let service = KinoGoService.shared

  var episodes = [KinoGoAPI.Episode]()
  var files = [String]()

  public override init(data: [String: String]) {
    super.init(data: data)
  }

  required convenience init(from decoder: Decoder) throws {
    fatalError("init(from:) has not been implemented")
  }
  
  override func isContainer() -> Bool {
    return type == "serie" || type == "season" || type == "rating"
  }

  override func getBitrates() throws -> [[String: String]] {
    var bitrates: [[String: String]] = []

    var urls: [String] = []

    if type == "episode" {
      urls = files
    }
    else {
      urls = try service.getUrls(id!)
    }

    let qualityLevels = QualityLevel.availableLevels(urls.count)

    for (index, url) in urls.enumerated() {
      //let metadata = service.getMetadata(url)

      var bitrate: [String: String] = [:]
      //bitrate["id"] = metadata["width"]
      bitrate["url"] = url

      bitrate["name"] = qualityLevels[index].rawValue

      bitrates.append(bitrate)
    }

    return bitrates
  }
  
  override func getRequestHeaders() -> [String: String] {
    var headers: [String : String] = [:]
    
    headers["Cookie"] = service.getCookie(url: self.id!)

    return headers
  }

}
