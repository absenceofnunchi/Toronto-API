# Toronto API

Toronto API is an app that facilitates the browsing of the Toronto Open Data catalogue. Toronto Open Data is an initiative by the City of Toronto government in Toronto, Ontario, Canada. It provides a royalty-free licence to use, modify, and distribute the datasets in all current and future media and formats. Use the app to easily search, save, and share the datasets you want!

## App Store

https://apps.apple.com/ca/app/toronto-api/id1554374725

## Structure

### Front End

Makes URL requests to a remote REST API server.  Provides the ability to define search predicates through search tokens within a search bar.  Allows users to view the details of the results, rearrange the layout, share them as well as save the favourites.  Facilitate dataset visualisation, data stories, and links to blog relevant blog articles.  

### Open Data

Open Data is digital data that is made available with the technical and legal characteristics necessary for it to be freely used, reused, and redistributed by anyone. Digital data, in this context, is machine readable data, such as CSV, XML, JSON, Shapefiles, APIs. Unlike human readable formats, such as PDFs, HTML pages; machine readable data can be re-purposed, synthesized and modelled by computer applications to generate insights, analyses and/or used to develop web/mobile applications.

[The City of Toronto’s Open Data Portal](https://www.toronto.ca/city-government/data-research-maps/open-data/) is an open source delivery tool for such data as affordable housing, census, ambulance location, bicycle count, automated public washrooms, etc.

## Components

### Split View

The split view controller consisting of a main and a detail view controller is added to a container view controller as a child view controller.  The display mode button works as a expand/collapse toggle button when both the primary and the secondary view are showing in a landscape mode, but works as a back button when there is only a single view in a portrait mode.

```swift
func configureSplitVC() {
    var svc = UISplitViewController()
    svc.delegate = self
    svc.view.backgroundColor = UIColor(red: (247/255), green: (247/255), blue: (247/255), alpha: 1)
    svc.preferredDisplayMode = .oneBesideSecondary
    svc.primaryBackgroundStyle = .sidebar
    
    // master
    let vc = MainViewController()
    nav1 = UINavigationController(rootViewController: vc)
    
    // detail
    let detailViewController = DetailViewController()
    nav2 = UINavigationController(rootViewController: detailViewController)
    
    svc.viewControllers = [nav1, nav2]
    
    let button = svc.displayModeButtonItem
    detailViewController.navigationItem.leftBarButtonItem = button
    detailViewController.navigationItem.leftItemsSupplementBackButton = true
    
    self.addChild(svc)
    self.view.addSubview(svc.view)
    svc.view.frame = self.view.bounds
    svc.didMove(toParent: self)
}

func splitViewController(_ svc: UISplitViewController, collapseSecondary vc2: UIViewController, onto vc1: UIViewController) -> Bool {
    if self.detailChosen {
        return false
    }
    return true
}

```
The reason for the container view controller is to enable compact devices to also show the primary/secondary split views, which would otherwise collapse and only show a single view.  Following delegate method provides a trait collection for a compact device when the device orientation of the container view controller changes to a landscape to act as if it's a regular sized device.

```swift
override func overrideTraitCollection(forChild childViewController: UIViewController) -> UITraitCollection? {
    guard let windowInterfaceOrientation = ContainerViewController.windowInterfaceOrientation else { return nil }
    
    if windowInterfaceOrientation.isLandscape {
        // activate landscape changes
        return UITraitCollection(traitsFrom: [UITraitCollection(horizontalSizeClass: .regular)])
    } else {
        // activate portrait changes
        return super.traitCollection
    }
}
```

### Search Token

Search token is used inside the search text field to visually aid the users to narrow down the categories within which they want to search.

```swift
/// Create a search token using a selected search category value as the title and a table view index value to determine the colour of the token icon.
func searchToken(searchCategory: SearchCategories, index: Int) -> UISearchToken {
    let tokenColor = SearchResultsController.suggestedColor(fromIndex: index)
    let image = UIImage(systemName: "circle.fill")?.withTintColor(tokenColor, renderingMode: .alwaysOriginal)
    let searchToken = UISearchToken(icon: image, text: searchCategory.value)
    searchToken.representedObject = searchCategory
    
    return searchToken
}

override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let suggestedSearchDelegate = suggestedSearchDelegate else { return }

    switch showSuggestedSearches {
        case .suggested:
            /// Informs the delegate that the selected search token is created.
            /// The index path row determines the search category and the a colour of the search token icon.
            let tokenValue = searchCategoryArr[indexPath.row]
            let tokenToInsert = searchToken(searchCategory: tokenValue, index: indexPath.row)
        suggestedSearchDelegate.didSelectSuggestedSearch(token: tokenToInsert)
        
        /// Rest of the control flow abbreviated.
    }
}

```

### UIAdaptivePresentationControllerDelegate

Following method is called when a presentation view controller is dismissed. When a user sets certain filter settings for dataset queries in FilterViewController which is presented modally, the user is able to dismiss the view controller without manually saving the filter settings since the delegate method is called as the view controller is being dismissed and saves the settings automatically.  One thing to note is that the delegate method is not called if the presentation view controller is dismissed programmatically.  

```swift
extension FilterViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        delegate?.didApplyFilter()
    }
}
```

### Context Menu

Uses both the traditional bar button format as well as the [context menu](https://developer.apple.com/documentation/uikit/uibarbuttonitem/3600776-init) that gets displayed when a bar button is touched (since iOS 14).


```swift
func configureOptionsBar() {
    let image = UIImage(systemName: "line.horizontal.3.decrease")?.withRenderingMode(.alwaysOriginal)
    if #available(iOS 14.0, *) {
        let barButtonMenu = UIMenu(title: "", children: [
            UIAction(title: NSLocalizedString("Layout", comment: ""), image: UIImage(systemName: "square.grid.2x2"), handler: menuHandler),
            UIAction(title: NSLocalizedString("License", comment: ""), image: UIImage(systemName: "c.circle"), handler: menuHandler)
        ])
        
        optionsBarItem = UIBarButtonItem(title: nil, image: image, primaryAction: nil, menu: barButtonMenu)
        navigationItem.rightBarButtonItem = optionsBarItem
    } else {
        optionsBarItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(menuHandler(action:)))
        navigationItem.rightBarButtonItem = optionsBarItem
    }
}
```

### Tab Bar Animation

A custom tab bar controller uses an animated tab bar upon being pressed on.  `indicatorLayer` translates to the location of the touch using the CALayer's implicit animation.  The size of the button changes using `animatedKeyframes`.   

```swift
@objc func tabBarButtonHandler(_ sender: UIButton) {
    /// Toggle the selected satatus
    sender.isSelected = !sender.isSelected
    indicatorLayer.isHidden = false
    /// Uses CALayer's implicit animation
    indicatorLayer.position = CGPoint(x: sender.frame.midX, y: sender.frame.minY)
    
    /// Haptic feedback
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    feedbackGenerator.impactOccurred()
    
    /// Toggle the non-selected button's status as false
    for case let button in self.stackView.arrangedSubviews where button is UIButton && button != sender {
        (button as! UIButton).isSelected = false
    }
    
    /// Animate the scale of the selected button
    UIView.animateKeyframes(withDuration: 0.4, delay: 0, options: UIView.KeyframeAnimationOptions.calculationModeCubic, animations: {
        UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
            sender.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }
        
        UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
            sender.transform = .identity
        }
    }, completion: nil)
    
    delegate?.tabBarDidSelect(with: sender.tag)
}
```

### Dynamic Layout Change

The app uses the collection view's implicit animation to show the transition between the layout changes.  The layout displays the fetched results from the Open Data API.  

```swift
func createLayout(with layoutType: Int = 1) -> UICollectionViewLayout {
    // group
    // Depending on the layout type passed from the paramater, the group layout changes to different columns.
    var group: NSCollectionLayoutGroup!
    switch layoutType {
        case 1:
            group = singleColumnLayout()
        case 2:
            group = doubleColumnLayout()
        case 3:
            group = tripleColumnLayout()
        default:
            break
    }
    
    // section
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 20
    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
    
    // section header
    let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
    let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerFooterSize, elementKind: MainViewController.sectionHeaderElementKind, alignment: .top)
    sectionHeader.pinToVisibleBounds = true
    sectionHeader.zIndex = 2
    section.boundarySupplementaryItems = [sectionHeader]
    
    // layout
    let layout = UICollectionViewCompositionalLayout(section: section)
    return layout
}
```

## Screetshots

1. Show the latest dataset from Open Data.

![](https://github.com/igibliss00/readmetest/blob/master/ReadmeAssets/1.png)

2. Saved dataset.

![](https://github.com/igibliss00/readmetest/blob/master/ReadmeAssets/2.png)

3. Search tokens inside search text field.

![](https://github.com/igibliss00/readmetest/blob/master/ReadmeAssets/4.png)

4. Landscape mode showing the primary and the secondary view of the split view controller.

![](https://github.com/igibliss00/readmetest/blob/master/ReadmeAssets/3.png)

5. iPad app showing the visualization of the data set.

![](https://github.com/igibliss00/readmetest/blob/master/ReadmeAssets/5.png)
