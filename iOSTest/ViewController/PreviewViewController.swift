
import UIKit
import PDFKit

class PreviewViewController: UIViewController {
  
  @IBOutlet weak var tblView: UITableView!
  @IBOutlet weak var noDataView: UIView!
  
  var arrQuestionList: [Questions] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupView()
    // Do any additional setup after loading the view.
  }
  
  /**
   - setup view
   */
  func setupView() {
    
    self.arrQuestionList = self.arrQuestionList.filter({$0.isAttempt == true})
    
    guard self.arrQuestionList.count > 0 else {
      self.noDataView.isHidden = false
      return
    }
    
    self.tblView.register(UINib(nibName: "PreviewTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "PreviewCell")
    self.tblView.estimatedRowHeight = 44.0
    self.tblView.rowHeight = UITableView.automaticDimension
    self.tblView.reloadData()
    
  }
  
  @IBAction func actionBack(_ sender: Any) {
     self.navigationController?.popViewController(animated: true)
   }
  
  /**
   - @IBActions
   */
  @IBAction func actionGeneratePDF(_ sender: Any) {
    
    let A4paperSize = CGSize(width: 595, height: 842)
    let pdf = SimplePDF(pageSize: A4paperSize)
    
    pdf.addText("")
    
    var pdfData: Data!
    
    for (_, item) in self.arrQuestionList.enumerated() {
      
      var strAnswer: String = ""
      var strGivenAnswer: String = ""
      
      if let index = item.answers.findIndex(callback: {$0.isSelected == true}) {
        
        if item.answers[index].isCorrect == true {
          strAnswer = "Correct Answer"
        }else {
          strAnswer = "Incorrect Answer"
        }
      }else {
        strAnswer = ""
      }
      
      if let index = item.answers.findIndex(callback: {$0.isSelected == true}) {
        
        strGivenAnswer = item.answers[index].title ?? ""
        
      }else {
        strGivenAnswer = ""
      }
      
      
      let dataArray = [["Question \(item.id): \(item.title ?? "")"],["Answer: \(strAnswer)"], ["Given Answer: \(strGivenAnswer)"],[" "]]
      
      pdf.addTable(4, columnCount: 1, rowHeight: 20.0, columnWidth: 555, tableLineWidth: 1.0, font: UIFont.systemFont(ofSize: 10.0), dataArray: dataArray)
      
   
      pdfData = pdf.generatePDFdata()
      
    }
    
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let filePath = "\(path)/iosTest.pdf"
    
    print(filePath)
    
    let url = NSURL(fileURLWithPath: filePath)
    try? pdfData.write(to: url as URL, options: Data.WritingOptions.atomic)
    
    
    
    if let objPDFVC = Constants.kMainStoryBoard.instantiateViewController(withIdentifier: "PDFViewController") as? PDFViewController {
      objPDFVC.fileURL = url as URL
      self.navigationController?.pushViewController(objPDFVC, animated: true)
    }
    
  }
}

/**
 - UITableViewDelegate, UITableViewDataSource
 */
extension PreviewViewController: UITableViewDelegate, UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return self.arrQuestionList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let objCell = tableView.dequeueReusableCell(withIdentifier: "PreviewCell", for: indexPath) as? PreviewTableViewCell else {
      return UITableViewCell()
    }
    
    objCell.configureCell(self.arrQuestionList[indexPath.row])
    
    return objCell
  }
  
}
