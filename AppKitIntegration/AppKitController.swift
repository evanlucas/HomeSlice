//
//  AppKitController.swift
//  AppKitIntegration
//
//  Created by Evan Lucas on 10/29/20.
//

import AppKit

extension NSWindow {
  @objc func HomeSlice_makeKeyAndOrderFront(_ sender: Any) {
    print("[NSWindow] No window for you")
  }
}

@objc class AppKitController: NSObject {
  let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
  var actionTags: [Int: UUID] = [:]

  override init() {
    super.init()

    let m1 = class_getInstanceMethod(NSClassFromString("NSWindow"), NSSelectorFromString("makeKeyAndOrderFront:"))
    let m2 = class_getInstanceMethod(NSClassFromString("NSWindow"), NSSelectorFromString("HomeSlice_makeKeyAndOrderFront:"))

    if let m1 = m1, let m2 = m2 {
      print("Swizzling NSWindow")
      method_exchangeImplementations(m1, m2)
    }

    print("[AppKitController] Loaded successfully")

    NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "HomeSlice"), object: nil, queue: nil) { note in
      print("got notification \(String(describing: note.userInfo))")
      if let userInfo = note.userInfo {
        if userInfo["type"] as! String == "update" {
          let data = userInfo["data"] as! Dictionary<UUID, String>
          self.setupMenuItem(data: data)
        }
      }
    }
  }

  func setupMenuItem(data: Dictionary<UUID, String>) {
    print("got data \(data)")
    statusItem.button?.title = "Home"
//    statusItem.title = "Home"
    statusItem.menu = createMenu(data)
  }

  func createMenu(_ data: Dictionary<UUID, String>) -> NSMenu {
    let menu = NSMenu()
    actionTags = [:]
    var tag = 0
    for (id, name) in data {
      let item = NSMenuItem(title: name, action: #selector(clickedItem), keyEquivalent: "")
      item.target = self
      tag = tag + 1
      item.tag = tag
      actionTags[tag] = id
      menu.addItem(item)
    }
    menu.addItem(NSMenuItem.separator())
    let menuItem = menu.addItem(withTitle: "Quit", action: #selector(quit), keyEquivalent: "")
    menuItem.target = self

    return menu
  }

  @objc func clickedItem(_ sender: Any?) {
    let item = sender as! NSMenuItem
    if let id = actionTags[item.tag] {
      print("clicked item with id: \(id)")
      NotificationCenter.default.post(name: NSNotification.Name(rawValue: "HomeSlice"), object: nil, userInfo: [
        "actionId": id,
        "type": "run"
      ])
    }
  }

  @objc func quit(_ sender: Any?) {
    exit(0)
  }
}
