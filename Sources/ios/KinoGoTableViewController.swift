import UIKit
import TVSetKit
import PageLoader

open class KinoGoTableViewController: UITableViewController {
  let CellIdentifier = "KinoGoTableCell"

  let localizer = Localizer(KinoGoService.BundleId, bundleClass: KinoGoSite.self)
  let pageLoader = PageLoader()
  let service = KinoGoService(true)

  private var items = Items()

  override open func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    title = localizer.localize("KinoGo")

    pageLoader.loadData(onLoad: getMenuItems) { result in
      if let items = result as? [Item] {
        self.items.items = items

        self.tableView?.reloadData()
      }
    }
  }

  func getMenuItems() throws -> [Any] {
    return [
      MediaName(name: "Bookmarks", imageName: "Star"),
      MediaName(name: "History", imageName: "Bookmark"),
      MediaName(name: "All Movies", imageName: "Retro TV"),
      MediaName(name: "Premier Movies", imageName: "Retro TV"),
      MediaName(name: "Last Movies", imageName: "Retro TV"),
      MediaName(name: "All Series", imageName: "Retro TV"),
      MediaName(name: "Animations", imageName: "Retro TV"),
      MediaName(name: "Anime", imageName: "Retro TV"),
      MediaName(name: "TV Shows", imageName: "Briefcase"),
      MediaName(name: "By Categories", imageName: "Briefcase"),
      MediaName(name: "By Countries", imageName: "Briefcase"),
      MediaName(name: "By Years", imageName: "Briefcase"),
      MediaName(name: "Settings", imageName: "Engineering"),
      MediaName(name: "Search", imageName: "Search")
    ]
  }

  // MARK: UITableViewDataSource

  override open func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }

  override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath) as? MediaNameTableCell {
      let item = items[indexPath.row]

      cell.configureCell(item: item, localizedName: localizer.getLocalizedName(item.name))

      return cell
    }
    else {
      return UITableViewCell()
    }
  }

  override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let view = tableView.cellForRow(at: indexPath),
      let indexPath = tableView.indexPath(for: view) {
      let mediaItem = items.getItem(for: indexPath)

      switch mediaItem.name! {
        case "By Categories":
          performSegue(withIdentifier: CategoriesTableViewController.SegueIdentifier, sender: view)

        case "By Countries":
          performSegue(withIdentifier: CountriesTableViewController.SegueIdentifier, sender: view)
        
        case "By Years":
          performSegue(withIdentifier: YearsTableViewController.SegueIdentifier, sender: view)
        
        case "Settings":
          performSegue(withIdentifier: "Settings", sender: view)

        case "Search":
          performSegue(withIdentifier: SearchTableController.SegueIdentifier, sender: view)

        default:
          performSegue(withIdentifier: MediaItemsController.SegueIdentifier, sender: view)
      }
    }
  }

  // MARK: - Navigation

  override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case MediaItemsController.SegueIdentifier:
          if let destination = segue.destination.getActionController() as? MediaItemsController,
             let view = sender as? MediaNameTableCell,
             let indexPath = tableView.indexPath(for: view) {

            let mediaItem = items.getItem(for: indexPath)

            destination.params["requestType"] = mediaItem.name
            destination.params["parentName"] = localizer.localize(mediaItem.name!)

            destination.configuration = service.getConfiguration()
          }

        case SearchTableController.SegueIdentifier:
          if let destination = segue.destination.getActionController() as? SearchTableController {
            destination.params["requestType"] = "Search"
            destination.params["parentName"] = localizer.localize("Search Results")
            destination.params["pageSize"] = 10

            destination.configuration = service.getConfiguration()
          }

        default:
          break
      }
    }
  }

}
