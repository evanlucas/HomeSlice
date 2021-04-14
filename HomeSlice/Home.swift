//
//  Home.swift
//  HomeSlice
//
//  Created by Evan Lucas on 6/23/20.
//

import HomeKit

class Home: NSObject, HMHomeManagerDelegate, HMAccessoryDelegate, ObservableObject {
  let homeManager = HMHomeManager()
  var actionSets: [UUID: HMActionSet] = [:]

  static var appKitController: NSObject?

  class func loadAppKitIntegrationFramework() {
    if let frameworksPath = Bundle.main.privateFrameworksPath {
      let bundlePath = "\(frameworksPath)/AppKitIntegration.framework"
      do {
        try Bundle(path: bundlePath)?.loadAndReturnError()

        let bundle = Bundle(path: bundlePath)!
        print("[AppKit Bundle] Loaded successfully")

        if let appKitControllerClass = bundle.classNamed("AppKitIntegration.AppKitController") as? NSObject.Type {
          appKitController = appKitControllerClass.init()
        }
      }
      catch {
        print("[AppKit Bundle] Error loading: \(error)")
      }
    }
  }

  override init() {
    Home.loadAppKitIntegrationFramework()

    super.init()

    homeManager.delegate = self

    NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "HomeSlice"), object: nil, queue: nil) { note in
      print("got notification \(String(describing: note.userInfo))")
      if let userInfo = note.userInfo {
        if userInfo["type"] as! String == "run" {
          let id = userInfo["actionId"] as! UUID
          self.runActionWithID(id)
        }
      }
    }
  }

  func runActionWithID(_ id: UUID) {
    guard let home = self.homeManager.primaryHome else {
      return
    }

    if let actionSet = self.actionSets[id] {
      home.executeActionSet(actionSet) { error in
        print("Done executing \(String(describing: error))")
      }
    }
  }

  func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
    print("homes updated")

    for actionset in homeManager.primaryHome!.actionSets {
      print("Found action set \(actionset.name)")
      actionSets[actionset.uniqueIdentifier] = actionset
    }

    self.updateInfo()
  }

  func updateInfo() {
    var data: [UUID: String] = [:]
    for actionSet in actionSets {
      data[actionSet.key] = actionSet.value.name
    }

    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "HomeSlice"), object: nil, userInfo: [
      "data": data,
      "type": "update"
    ])
  }

  func homeManager(_ manager: HMHomeManager, didUpdate status: HMHomeManagerAuthorizationStatus) {
    switch status {
    case .authorized:
      print("[HOMEKIT STATUS] Authorized")
    case .determined:
      print("[HOMEKIT STATUS] Determined")
    case .restricted:
      print("[HOMEKIT STATUS] Restricted")

    default:
      break
    }
  }

  func accessory(_ accessory: HMAccessory, service: HMService, didUpdateValueFor characteristic: HMCharacteristic) {
    print("accessory updated value \(accessory) - \(service)")
  }
}
