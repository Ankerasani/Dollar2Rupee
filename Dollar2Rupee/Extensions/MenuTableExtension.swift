//
//  MenuTableExtension.swift
//  IOCode
//
//  Created by Ankersani on 8/2/18.
//  Copyright © 2018 Ankersani. All rights reserved.
//

import Foundation
import UIKit

extension MainVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if menuList.isEmpty {
            return 0
        }else{
            return menuList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menu = menuList[indexPath.row]
        let cell = menuTable.dequeueReusableCell(withIdentifier: menuCellId, for: indexPath)
        cell.textLabel?.text = menu.title
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 30)
        cell.textLabel?.textColor = UIColor.darkGray
        cell.backgroundColor = UIColor.white.withAlphaComponent(0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menu = menuList[indexPath.row]
         menuTable.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(menu.vc!, animated: true)
        handleMenu()
    }

}
