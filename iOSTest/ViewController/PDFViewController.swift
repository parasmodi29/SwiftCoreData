//
//  PDFViewController.swift
//  iOSTest
//
//  Created by Techniexe Infolabs on 03/02/20.
//  Copyright © 2020 malaypatel. All rights reserved.
//

import UIKit
import PDFKit

class PDFViewController: UIViewController {
  
  var path: String!
  var fileURL: URL!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
     super.viewWillAppear(animated)
   }
   
   override func viewWillDisappear(_ animated: Bool) {
     super.viewWillDisappear(animated)
     self.navigationController?.setNavigationBarHidden(true, animated: true)
     self.navigationController?.popToRootViewController(animated: true)
   }
  
  /**
   - setup view
   */
  func setupView() {
    
    self.navigationController?.setNavigationBarHidden(false, animated: true)
    
    let pdfView = PDFView()
    
    pdfView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(pdfView)
    
    pdfView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
    pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    
    if let document = PDFDocument(url: fileURL)  {
      pdfView.document = document
    }
  }
  
 
}
