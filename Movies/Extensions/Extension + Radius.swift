//
//  Extension + Radius.swift
//  Movies
//
//  Created by DuTuanMinh on 8/3/25.
//

import UIKit

// MARK: - Rounded Corners

extension UIView {
  func roundedCorners(radius: CGFloat? = nil) {
    layoutIfNeeded()
    layer.cornerRadius = radius != nil ? radius! : ceil(frame.height / 2)
    layer.masksToBounds = true
  }
}

extension UIView {
  @IBInspectable var cornerRadius: CGFloat {
    get {
      return layer.cornerRadius
    }
    set {
      layer.cornerRadius = newValue
    }
  }
  
  @IBInspectable var masksToBounds: Bool {
    get {
      return layer.masksToBounds
    }
    set {
      layer.masksToBounds = newValue
    }
  }
  
  @IBInspectable var borderWidth: CGFloat {
    get {
      return layer.borderWidth
    }
    set {
      layer.borderWidth = newValue
    }
  }
  
  @IBInspectable var borderColor: UIColor? {
    get {
      return UIColor(cgColor: layer.borderColor ?? UIColor.clear.cgColor)
    }
    set {
      layer.borderColor = newValue?.cgColor
    }
  }
  
}

public enum UIButtonBorderSide {
  case top, bottom, left, right
}

extension UIView {
  
  public func addBorder(side: UIButtonBorderSide, color: UIColor, width: CGFloat) {
    let border = CALayer()
    border.backgroundColor = color.cgColor
    
    switch side {
    case .top:
      border.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: width)
    case .bottom:
      border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
    case .left:
      border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
    case .right:
      border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
    }
    
    self.layer.addSublayer(border)
  }
  
  public func addBorders(sides: [UIButtonBorderSide], color: UIColor, width: CGFloat) {
    for side in sides {
      let border = CALayer()
      border.backgroundColor = color.cgColor
      
      switch side {
      case .top:
        border.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: width)
      case .bottom:
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
      case .left:
        border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
      case .right:
        border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
      }
      
      self.layer.addSublayer(border)
    }
  }
}

class NibView: UIView {
  
  // MARK: - Initializers
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupNib()
    configureView()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupNib()
    awakeFromNib()
    configureView()
  }
  
  override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    setupNib()
  }
  
  init() {
    super.init(frame: .zero)
    setupNib()
    configureView()
  }
  
}

// MARK: - Private

private extension NibView {
  
  func setupNib() {
    backgroundColor = .clear
    let nibName = NSStringFromClass(type(of: self)).components(separatedBy: ".").last!
    let nib = UINib(nibName: nibName, bundle: Bundle(for: type(of: self)))
    let topLevelViews = nib.instantiate(withOwner: self, options: nil)
    let nibView = topLevelViews.first as! UIView
    insertSubview(nibView, at: 0)
    
    nibView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      nibView.leftAnchor.constraint(equalTo: leftAnchor),
      nibView.rightAnchor.constraint(equalTo: rightAnchor),
      nibView.topAnchor.constraint(equalTo: topAnchor),
      nibView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
  }
  
}

extension NibView {
  
  @objc func configureView() {
    
  }
  
}


// MARK: - SafeArea

extension UIDevice {
  
  static var topSafeAreaInset: CGFloat {
    if #available(iOS 11.0, *) {
      if let topPadding = UIApplication.shared.keyWindow?.safeAreaInsets.top {
        return topPadding
      }
    }
    return 0
  }
  
  static var bottomSafeAreaInset: CGFloat {
    if #available(iOS 11.0, *) {
      if let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom {
        return bottomPadding
      }
    }
    return 0
  }
}

// MARK: - Device Size

class DeviceSize {
  enum DeviceKind {
    case retina // this is to support fonts for iPad
    case iphone5
    case iphone7
    case iphone7plus
    case iphoneX
  }
  
  static func screenSize() -> DeviceKind? {
    let screenHeight = UIScreen.main.bounds.size.height
    var deviceKind: DeviceKind?
    
    switch screenHeight {
    case 480: deviceKind = .retina
    case 568: deviceKind = .iphone5
    case 667: deviceKind = .iphone7
    case 736: deviceKind = .iphone7plus
    case 812: deviceKind = .iphoneX
    default: deviceKind = nil
    }
    return deviceKind
  }
  
  static func isIPhone5Size() -> Bool {
    return self.screenSize() == .iphone5 || self.screenSize() == .retina
  }
}

extension UIDevice {
  
  // The device is valid if it is not a simulator, rooted/jailbroken device
  static var isValid: Bool {
    if TARGET_IPHONE_SIMULATOR != 1 {
      if FileManager.default.fileExists(atPath: "/Applications/Cydia.app")
          || FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib")
          || FileManager.default.fileExists(atPath: "/usr/sbin/sshd")
          || FileManager.default.fileExists(atPath: "/etc/apt")
          || FileManager.default.fileExists(atPath: "/private/var/lib/apt/")
          || UIApplication.shared.canOpenURL(URL(string: "cydia://package/com.example.package")!) {
        return false
      }
      
      if canOpen(path: "/Applications/Cydia.app") ||
          canOpen(path: "/Library/MobileSubstrate/MobileSubstrate.dylib") ||
          canOpen(path: "/bin/bash") ||
          canOpen(path: "/usr/sbin/sshd") ||
          canOpen(path: "/etc/apt") ||
          canOpen(path: "/usr/bin/ssh") {
        return false
      }
      
      let stringToWrite = " is good to go"
      let path = "/private/" + NSUUID().uuidString
      do {
        try stringToWrite.write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
        return false
      } catch {
        return true
      }
    } else {
      return false
    }
  }
  
  static func canOpen(path: String) -> Bool {
    let file = fopen(path, "r")
    guard file != nil else { return false }
    fclose(file)
    return true
  }
}

protocol AppColorHexValueProvider {
  func hexValue() -> String
}

enum BrandedColor: String, AppColorHexValueProvider {
  case primary
  case cyan
  
  func hexValue() -> String {
    switch self {
    case .primary:
      return "00AFFF"
    case .cyan:
      return "0ECCDC"
    }
  }
}

enum TextColor: String, AppColorHexValueProvider {
  case white
  case mediumWhite
  case disabled
  case inactive
  case lightGray
  case mediumGray
  case darkGray
  case black
  
  func hexValue() -> String {
    switch self {
    case .white:
      return "FFFFFF"
    case .mediumWhite:
      return "F4F4F4"
    case .disabled:
      return "B0C0D1"
    case .inactive:
      return "97A6B9"
    case .lightGray:
      return "A4B2C3"
    case .mediumGray:
      return "808FA3"
    case .darkGray:
      return "525B64"
    case .black:
      return "354350"
    }
  }
}

enum SystemColor: String, AppColorHexValueProvider {
  case success
  case warning
  case error
  case active
  
  func hexValue() -> String {
    switch self {
    case .success:
      return "2DCC70"
    case .warning:
      return "FA8B00"
    case .error:
      return "F44336"
    case .active:
      return "459AFD"
    }
  }
}

enum NeutralColor: String, AppColorHexValueProvider {
  case snow
  case borderGray
  case mediumGray
  case menuGray
  
  func hexValue() -> String {
    switch self {
    case .snow:
      return "FAFAFA"
    case .borderGray:
      return "DCE1EC"
    case .mediumGray:
      return "9EB0C7"
    case .menuGray:
      return "434F5D"
    }
  }
}

enum GradientColor: String, AppColorHexValueProvider {
  case cyanStart
  case cyanEnd
  
  func hexValue() -> String {
    switch self {
    case .cyanStart:
      return "1DE9B6"
    case .cyanEnd:
      return "00AFFF"
    }
  }
}

extension UIColor {
  static func appBrandedColor(_ color: BrandedColor) -> UIColor {
    if #available(iOS 11.0, *) {
      return UIColor(named: "brand-" + color.rawValue)!
    } else {
      return color.hexValue().hexColor
    }
  }
  
  static func appTextColor(_ color: TextColor) -> UIColor {
    return color.hexValue().hexColor
  }
  
  static func appSystemColor(_ color: SystemColor) -> UIColor {
    return color.hexValue().hexColor
  }
  
  static func appNeutralColor(_ color: NeutralColor) -> UIColor {
    return color.hexValue().hexColor
  }
  
  static func appGradientColor(_ color: GradientColor) -> UIColor {
    return color.hexValue().hexColor
  }
}

extension String {
  var hexColor: UIColor {
    let hex = trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int = UInt32()
    Scanner(string: hex).scanHexInt32(&int)
    let a, r, g, b: UInt32
    switch hex.count {
    case 3: // RGB (12-bit)
      (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
    case 6: // RGB (24-bit)
      (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8: // ARGB (32-bit)
      (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default:
      return UIColor.clear
    }
    return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
  }
}

class GradientButton: UIButton {
  
  
  @IBInspectable var startColor: UIColor = .blue {
    didSet {
      reloadAppearance()
    }
  }
  
  @IBInspectable var endColor: UIColor = .black {
    didSet {
      reloadAppearance()
    }
  }
  
  @IBInspectable var isHorizontal: Bool = true {
    didSet {
      reloadAppearance()
    }
  }
  
  @IBInspectable var disabledColor: UIColor = .gray
  
  // MARK: - Overrides
  
  override class var layerClass: AnyClass {
    return CAGradientLayer.self
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    reloadAppearance()
  }
  
  override var isEnabled: Bool {
    didSet {
      reloadAppearance()
    }
  }
  
  // MARK: - Private
  
  internal func reloadAppearance() {
    let fromColor = isEnabled ? startColor : disabledColor
    let toColor = isEnabled ? endColor : disabledColor
    updateWithColor(fromColor, toColor)
  }
  
  private func updateWithColor(_ startColor: UIColor, _ endColor: UIColor) {
    let layer = self.layer as! CAGradientLayer
    layer.colors = [startColor, endColor].map {$0.cgColor}
    if (isHorizontal) {
      layer.startPoint = CGPoint(x: 0, y: 0.5)
      layer.endPoint = CGPoint (x: 1, y: 0.5)
    } else {
      layer.startPoint = CGPoint(x: 0.5, y: 0)
      layer.endPoint = CGPoint (x: 0.5, y: 1)
    }
  }
}

// MARK: - Nib

extension UIView {
  static var nib: UINib {
    let bundle = Bundle(for: self as AnyClass)
    let nib = UINib(nibName: String(describing: self), bundle: bundle)
    return nib
  }
  
  static func loadFromNib() -> Self {
    return _loadFromNib()
  }
  
  // MARK: - Private
  
  fileprivate static func _loadFromNib<T: UIView>() -> T {
    guard let view = nib.instantiate(withOwner: nil, options: nil).first as? T else {
      fatalError("The nib \(nib) expected its root view to be of type \(self)")
    }
    return view
  }
}

// MARK: - Subviews

extension UIView {
  class func recursiveSubviews<T: UIView>(view: UIView) -> [T] {
    return view.subviews.flatMap { subView -> [T] in
      var result = recursiveSubviews(view: subView) as [T]
      if let view = subView as? T {
        result.append(view)
      }
      return result
    }
  }
  
  func recursiveSubviews<T: UIView>() -> [T] {
    return UIView.recursiveSubviews(view: self) as [T]
  }
  
  func removeAllSubviews() {
    for subview in subviews {
      subview.removeFromSuperview()
    }
  }
}

// MARK: - Layout

extension UIView {
  func pinViewToEdgesOfSuperview(leftOffset: CGFloat = 0, rightOffset: CGFloat = 0, topOffset: CGFloat = 0, bottomOffset: CGFloat = 0) {
    translatesAutoresizingMaskIntoConstraints = false
    superview!.addConstraints([
      superview!.leftAnchor.constraint(equalTo: leftAnchor, constant: leftOffset),
      superview!.rightAnchor.constraint(equalTo: rightAnchor, constant: rightOffset),
      superview!.topAnchor.constraint(equalTo: topAnchor, constant: topOffset),
      superview!.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottomOffset)
    ])
  }
  
  func pinViewToCenterOfSuperview(offsetX: CGFloat = 0.0, offsetY: CGFloat = 0.0) {
    translatesAutoresizingMaskIntoConstraints = false
    superview!.addConstraints([
      centerXAnchor.constraint(equalTo: superview!.centerXAnchor, constant: offsetX),
      centerYAnchor.constraint(equalTo: superview!.centerYAnchor, constant: offsetY)
    ])
  }
  
  func pinViewWidthAndHeight(width: CGFloat, height: CGFloat) {
    translatesAutoresizingMaskIntoConstraints = false
    superview!.addConstraints([
      widthAnchor.constraint(equalToConstant: width),
      heightAnchor.constraint(equalToConstant: height)
    ])
  }
  
  @discardableResult
  func pinViewToBottomOfSuperview(height: CGFloat) -> (bottomConstarint: NSLayoutConstraint, heightConstarint: NSLayoutConstraint) {
    translatesAutoresizingMaskIntoConstraints = false
    let bottomConstraint = superview!.bottomAnchor.constraint(equalTo: bottomAnchor)
    let heightConstarint = heightAnchor.constraint(equalToConstant: height)
    superview!.addConstraints([
      heightConstarint,
      superview!.leftAnchor.constraint(equalTo: leftAnchor),
      superview!.rightAnchor.constraint(equalTo: rightAnchor),
      bottomConstraint
    ])
    return (bottomConstraint, heightConstarint)
  }
  
  func setViewToEdgesOfSuperview(leftOffset: CGFloat = 0, rightOffset: CGFloat = 0) {
    translatesAutoresizingMaskIntoConstraints = false
    superview!.addConstraints([
      superview!.leftAnchor.constraint(equalTo: leftAnchor, constant: leftOffset),
      superview!.rightAnchor.constraint(equalTo: rightAnchor, constant: rightOffset)
    ])
  }
}
}
