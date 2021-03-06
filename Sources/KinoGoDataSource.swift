import SwiftSoup
import MediaApis
import TVSetKit

class KinoGoDataSource: DataSource {
  let service = KinoGoService.shared

  var seasons = [KinoGoAPI.Season]()
  
  override open func load(params: Parameters) throws -> [Any] {
    var items: [Any] = []

    let selectedItem = params["selectedItem"] as? MediaItem

    var request = params["requestType"] as! String
    let currentPage = params["currentPage"] as? Int ?? 1

    if selectedItem?.type == "serie" {
      request = "Seasons"
    }
    else if selectedItem?.type == "season" {
      request = "Episodes"
    }

    switch request {
    case "Bookmarks":
      if let bookmarksManager = params["bookmarksManager"] as? BookmarksManager,
         let bookmarks = bookmarksManager.bookmarks {
        let data = bookmarks.getBookmarks(pageSize: 60, page: currentPage)
        bookmarks.load()
        items = adjustItems(data)
      }

    case "History":
      if let historyManager = params["historyManager"] as? HistoryManager,
         let history = historyManager.history {
        history.load()
        let data = history.getHistoryItems(pageSize: 60, page: currentPage)

        items = adjustItems(data)
      }

    case "All Movies":
      let data = try service.getAllMovies(page: currentPage).items
      
      items = adjustItems(data)

    case "Premier Movies":
      let data = try service.getPremierMovies(page: currentPage).items
      
      items = adjustItems(data)
      
    case "Last Movies":
      let data = try service.getLastMovies(page: currentPage).items
    
      items = adjustItems(data)

    case "All Series":
      let data = try service.getAllSeries(page: currentPage).items
      
      items = adjustItems(data)

    case "Animations":
      let data = try service.getAnimations(page: currentPage).items
   
      items = adjustItems(data)

    case "Anime":
      let data = try service.getAnime(page: currentPage).items
  
      items = adjustItems(data)

    case "TV Shows":
      let data = try service.getTvShows(page: currentPage).items
      
      items = adjustItems(data)

    case "Seasons":
      if let selectedItem = selectedItem,
         let path = selectedItem.id {
        seasons = try service.getSeasons(path, selectedItem.name!, selectedItem.thumb)

        let pageSize = params["pageSize"] as! Int

        let paginatedItems = paginated(items: seasons, currentPage: currentPage, pageSize: pageSize)

        items = adjustItems(paginatedItems, selectedItem: selectedItem)
      }

    case "Episodes":
      if let selectedItem = selectedItem {
         let pageSize = params["pageSize"] as! Int
        let episodes = (selectedItem as! KinoGoMediaItem).episodes

        let paginatedItems = paginated(items: episodes, currentPage: currentPage, pageSize: pageSize)

        items = adjustItems(paginatedItems, selectedItem: selectedItem)
      }

    case "Categories":
      items = adjustItems(try service.getCategoriesByTheme())
      
    case "Countries":
      items = adjustItems(try service.getCategoriesByCountry())

    case "Years":
      items = loadYearsMenu()
      
    case "Category":
      if let selectedItem = selectedItem,
        let category = selectedItem.id?.replacingOccurrences(of: KinoGoAPI.SiteUrl, with: "") {
        let data = try service.getMoviesByCategory(category: category, page: currentPage).items
        items = adjustItems(data)
      }
      
    case "Country":
      if let selectedItem = selectedItem,
         let country = selectedItem.id?.replacingOccurrences(of: KinoGoAPI.SiteUrl, with: "") {
        let data = try service.getMoviesByCountry(country: country, page: currentPage).items
        items = adjustItems(data)
      }
      
    case "Year":
      if let selectedItem = selectedItem,
         let id = selectedItem.id,
         let year = Int(id) {
        let data = try service.getMoviesByYear(year: year, page: currentPage).items
        items = adjustItems(data)
      }
      
    case "Search":
      if let query = params["query"] as? String {
        if !query.isEmpty {
          let data = try service.search(query, page: currentPage).items
          
          items = adjustItems(data)
        }
      }

    default:
      items = []
    }

    return items
  }

  func adjustItems(_ items: [Any], selectedItem: MediaItem?=nil) -> [Item] {
    var newItems = [Item]()

    if let items = items as? [HistoryItem] {
      newItems = transform(items) { item in
        createHistoryItem(item as! HistoryItem)
      }
    }
    else if let items = items as? [BookmarkItem] {
      newItems = transform(items) { item in
        createBookmarkItem(item as! BookmarkItem)
      }
    }
    else if let items = items as? [KinoGoAPI.Season] {
      newItems = transformWithIndex(items) { (index, item) in
        let seasonNumber = String(index+1)
        
        return createSeasonItem(item as! KinoGoAPI.Season, selectedItem: selectedItem!, seasonNumber: seasonNumber)
      }
    }
    else if let items = items as? [KinoGoAPI.Episode] {
      newItems = transform(items) { item in
        createEpisodeItem(item as! KinoGoAPI.Episode, selectedItem: selectedItem!)
      }
    }
    else if let items = items as? [KinoGoAPI.File] {
      newItems = transform(items) { item in
        createFileItem(item as! KinoGoAPI.File, selectedItem: selectedItem!)
      }
    }
    else if let items = items as? [[String: Any]] {
      newItems = transform(items) { item in
        createMediaItem(item as! [String: Any])
      }
    }
    else if let items = items as? [Item] {
      newItems = items
    }

    return newItems
  }

  func createHistoryItem(_ item: HistoryItem) -> Item {
    let newItem = KinoGoMediaItem(data: ["name": ""])

    newItem.name = item.item.name
    newItem.id = item.item.id
    newItem.description = item.item.description
    newItem.thumb = item.item.thumb
    newItem.type = item.item.type

    return newItem
  }

  func createBookmarkItem(_ item: BookmarkItem) -> Item {
    let newItem = KinoGoMediaItem(data: ["name": ""])

    newItem.name = item.item.name
    newItem.id = item.item.id
    newItem.description = item.item.description
    newItem.thumb = item.item.thumb
    newItem.type = item.item.type

    return newItem
  }

    func createSeasonItem(_ item: KinoGoAPI.Season, selectedItem: MediaItem, seasonNumber: String) -> Item {
    let newItem = KinoGoMediaItem(data: ["name": ""])

    newItem.name = item.name
    
    if let path = selectedItem.id {
      newItem.id = path
    }
    
    newItem.type = "season"
    
    if let thumb = selectedItem.thumb {
      newItem.thumb = thumb
    }
    
    newItem.seasonNumber = seasonNumber
    newItem.episodes = item.folder

    return newItem
  }

  func createEpisodeItem(_ item: KinoGoAPI.Episode, selectedItem: MediaItem) -> Item {
    let newItem = KinoGoMediaItem(data: ["name": ""])

    newItem.name = item.name
    newItem.id = selectedItem.id
    newItem.type = "episode"
    newItem.files = item.files
        
    if let thumb = selectedItem.thumb {
      newItem.thumb = thumb
    }

    return newItem
  }
  
  func createFileItem(_ item: KinoGoAPI.File, selectedItem: MediaItem) -> Item {
    let newItem = KinoGoMediaItem(data: ["name": ""])
    
    newItem.name = item.name
    newItem.id = selectedItem.id
    newItem.type = "episode"
    newItem.files = item.urls()
    
    if let thumb = selectedItem.thumb {
      newItem.thumb = thumb
    }
    
    return newItem
  }

  func createMediaItem(_ item: [String: Any]) -> Item {
    let newItem = KinoGoMediaItem(data: ["name": ""])

    if let dict = item as? [String: String] {
      newItem.name = dict["name"]
      newItem.id = dict["id"]
      newItem.type = dict["type"]
      newItem.thumb = dict["thumb"]
    }

    return newItem
  }

  func loadYearsMenu() -> [Item] {
    var list = [MediaItem]()
    
    let date = Date()
    let calendar = Calendar.current
    
    let currentYear = calendar.component(.year, from: date)
    
    for year in (1932...currentYear).reversed() {
      list.append(MediaItem(name: "\(year)", id: "\(year)", imageName: ""))
    }
    
    return list
  }

}
