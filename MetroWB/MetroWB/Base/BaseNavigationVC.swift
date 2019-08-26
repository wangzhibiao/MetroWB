//
//  BaseNavigationVC.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/5/24.
//

import UIKit

class BaseNavigationVC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

//        self.navigationBar.backgroundColor = UIColor.white
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.barTintColor = ConstFile.gloab_nav_color//UIColor.black
        self.navigationBar.setBackgroundImage(ConstFile.gloab_nav_color.withAlphaComponent(1).toImage(viewSize: CGSize(width: ConstFile.ScreenW, height: 10)), for: .any, barMetrics: .default)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
