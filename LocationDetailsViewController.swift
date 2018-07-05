//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Gustavo Quenca on 19/05/18.
//  Copyright © 2018 Quenca. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    print(formatter)
    return formatter
}()

class LocationDetailsViewController: UITableViewController {
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addPhotoLabel: UILabel!
    @IBOutlet weak var image: UIImage!
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    var location: CLLocation?
    
    var categoryName = "No Category"
    
    var manageObjectContext: NSManagedObjectContext!
    
    var date = Date()
    
    var observer: Any?
    
    // If a variable has a didSet block, then the code in this block is performed whenever you put a new value into that variable
    var locationToEdit: Location? {
        didSet {
            if let location = locationToEdit {
                descriptionText = location.locationDescription
                categoryName = location.category
                date = location.date
                coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                placemark = location.placemark
            }
        }
    }
    var descriptionText = ""
    
    deinit {
        // You’re also adding a print() here so you can see some proof that the view controller really does get destroyed when you close the Tag/Edit Location screen
        print("*** deinit \(self)")
    NotificationCenter.default.removeObserver(observer)
    }
    
    // MARK - Actions
    @IBAction func done() {
        navigationController?.popViewController(animated: true)
        
        let hudView = HudView.hud(inView: navigationController!.view,
                                     animated: true)
        hudView.text = "Tagged"
        // 1
        var location = Location()
        if let temp = locationToEdit {
            hudView.text = "Updated"
            location = temp
        } else {
            hudView.text = "Tagged"
            location = Location(context: manageObjectContext)
            location.photoID = nil
        }
        // Save Image
        if let image = image {
            // You need to get a new ID and assign it to the Location’s photoID property, but only if you’re adding a photo to a Location that didn’t already have one.
            if !location.hasPhoto {
                location.photoID = Location.nextPhotoID() as NSNumber
            }
            // The UIImageJPEGRepresentation() function converts the UIImage to JPEG format and returns a Data object.
            if let data = UIImageJPEGRepresentation(image, 0.5) {
                // You save the Data object to the path given by the photoURL property
                do {
                    try data.write(to: location.photoURL, options: .atomic)
                    print("** Saved \(data)")
                } catch {
                    print("Error writing file: \(error)")
                }
            }
        }
        
        // 2
        location.locationDescription = descriptionTextView.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark
        do {
            try manageObjectContext.save()
        // Tell the app to close the Tag Location screen after 0.6 seconds
            afterDelay(0.6) {
                hudView.hide()
                self.navigationController?.popViewController(
                    animated: true)
            }
        } catch {
            // 4
            fatalCoreDataError(error)
           // fatalError("Error: \(error)")
        }
    }
    
    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) {
        let controller = segue.source as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
    
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TagLocation" {
            let controller = segue.destination as! LocationDetailsViewController
            controller.coordinate = location!.coordinate
            controller.placemark = placemark
        }
        
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as!
            CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let location = locationToEdit {
            title = "Edit Location"
            
            if location.hasPhoto {
                if let theImage = location.photoImage {
                    show(image: theImage)
                }
            }
        }
        
        descriptionTextView.text = descriptionText
        categoryLabel.text = categoryName
        
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = placemark {
            addressLabel.text = string(from: placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        
        dateLabel.text = format(date: date)
        
        // Hide keyboard
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    
        listenForBackgroundNotification()
    }
    
    func show(image: UIImage) {
        imageView.image = image
        imageView.isHidden = false
        imageView.frame = CGRect(x: 10, y: 10, width: 250, height: 260)
        addPhotoLabel.isHidden = true
    }
    
    func listenForBackgroundNotification() {
        // The [weak self] bit is the capture list for the closure. It tells the closure that the variable self will still be captured, but as a weak reference. As a result, the closure no longer keeps the view controller alive. 
        observer = NotificationCenter.default.addObserver(
            forName: Notification.Name.UIApplicationDidEnterBackground,
            object: nil, queue: OperationQueue.main) { [weak self] _ in
                
                if let weakSelf = self {
                    if weakSelf.presentedViewController != nil {
                        weakSelf.dismiss(animated: false, completion: nil)
                    }
                    weakSelf.descriptionTextView.resignFirstResponder()
                }
        }
    }
    
    // Whenever the user taps somewhere in the table view, the gesture recognizer calls this method
    @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
            return
        }
        descriptionTextView.resignFirstResponder()
    }
    
    // MARK:- Private Methods
    func string(from placemark: CLPlacemark) -> String {
        var line = ""
        line.add(text: placemark.subThoroughfare)
        line.add(text: placemark.thoroughfare, separatedBy: " ")
        line.add(text: placemark.locality, separatedBy: ", ")
        line.add(text: placemark.administrativeArea,
                 separatedBy: ", ")
        line.add(text: placemark.postalCode, separatedBy: " ")
        line.add(text: placemark.country, separatedBy: ", ")
        return line
    }
    
    func format(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    // MARK: - Table View Delegates
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch (indexPath.section, indexPath.row) {
        // case (0, 0) corresponds to section 0, row 0
        case (0, 0):
            return 88
            // case (1, _) corresponds to section 1, any row
        case (1, _):
            return imageView.isHidden ? 44 : 280
            // case (2, 2) corresponds to section 2, row 2
        case (2, 2):
            addressLabel.frame.size = CGSize(
                width: view.bounds.size.width - 115,
                height: 10000)
            addressLabel.sizeToFit()
            addressLabel.frame.origin.x = view.bounds.size.width -
                addressLabel.frame.size.width - 15
            return addressLabel.frame.size.height + 20
            
        default:
            return 44
        }
    }
    
    // Limits taps to just the cells from the first two sections
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    // Handles the actual taps on the rows
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        } else if indexPath.section == 1 && indexPath.row == 0{
           // takePhotoWithCamera()
           // choosePhotoFromLibrary()
            tableView.deselectRow(at: indexPath, animated: true)
            pickPhoto()
        }
    }
    
    // The willDisplay delegate method is called just before a cell becomes visible
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let selection = UIView(frame: CGRect.zero)
        selection.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        cell.selectedBackgroundView = selection
    }
}

extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func takePhotoWithCamera() {
        let imagePicker = MyImagePickerController()
        
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.view.tintColor = view.tintColor
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK:- Image Picker Delegates
    
    // Currently these delegate methods simply remove the image picker from the screen
    // “This is the method that gets called when the user has selected a photo in the image picker.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        image = info[UIImagePickerControllerEditedImage] as! UIImage
        
        if let theImage = image {
            show(image: theImage)
        }
        
        dismiss(animated: true, completion: nil)
        tableView.reloadData()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.view.tintColor = view.tintColor
        present(imagePicker, animated: true, completion: nil)
    }
    
    func pickPhoto() {
        
    // You use UIImagePickerController’s isSourceTypeAvailable() method to check whether there’s a camera present. If not, you call choosePhotoFromLibrary() as that is the only option then
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }
    
    func showPhotoMenu() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let actCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actCancel)
        
        let actPhoto = UIAlertAction(title: "Take photo", style: .default, handler: {
            _ in
            self.takePhotoWithCamera()
        })
        alert.addAction(actPhoto)
        
        let actLibrary = UIAlertAction(title: "Choose From Library", style: .default, handler: {
            _ in
            self.choosePhotoFromLibrary()
        })
        alert.addAction(actLibrary)
        
        present(alert, animated: true, completion: nil)
    }
}
