
import UIKit

class ResultViewController: UIViewController {
  
  @IBOutlet weak var lblRightAnswer: UILabel!
  @IBOutlet weak var lblWrongAnswer: UILabel!
  @IBOutlet weak var lblNotAttempt: UILabel!
  @IBOutlet weak var lblPercentage: UILabel!
  @IBOutlet weak var btnPreview: UIButton!
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
    
    let rightAnsfilter = self.arrQuestionList.filter({$0.answers.contains(where: {$0.isCorrect == true && $0.isSelected == true})})
    
    let wrongAnsfilter = self.arrQuestionList.filter({$0.answers.contains(where: {$0.isCorrect == false && $0.isSelected == true})})
    
    let Notattemptfilter = self.arrQuestionList.filter({$0.isAttempt == false})
    
    self.lblRightAnswer.text = String(format: "Right Answers: %d", rightAnsfilter.count)
    self.lblWrongAnswer.text = String(format: "Wrong Answers: %d", wrongAnsfilter.count)
    self.lblNotAttempt.text = String(format: "Not Attempt: %d", Notattemptfilter.count)
    
    var percentage: Float = 0
    
    percentage = Float(((100 * rightAnsfilter.count)/arrQuestionList.count))
    
    self.lblPercentage.text = String(format: "Percentage: %d %%", Int(percentage))
    
    let arrQuelist = self.arrQuestionList.filter({$0.isAttempt == true})
    
    guard arrQuelist.count > 0 else {
      self.btnPreview.isHidden = true
      return
    }
    
    self.btnPreview.isHidden = false
  }
  
  /**
   - @IBActions
   */
  @IBAction func actionPreviewAnswers(_ sender: Any) {
    
    if let objPreviewVC = Constants.kMainStoryBoard.instantiateViewController(withIdentifier: "PreviewViewController") as? PreviewViewController {
      objPreviewVC.arrQuestionList = []
      objPreviewVC.arrQuestionList = self.arrQuestionList
      self.navigationController?.pushViewController(objPreviewVC, animated: true)
    }
  }
  
  @IBAction func actionBack(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
}
