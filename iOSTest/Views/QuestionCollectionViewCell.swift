

import UIKit

class QuestionCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var lblQueDesc: UILabel!
    @IBOutlet var lblAnswerCollection: [UILabel]!
    @IBOutlet var btnRadioCollection: [UIButton]!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

  override func prepareForReuse() {
    super.prepareForReuse()
  }
  
  /// Configure Cell
  func configureCell(_ dicQue: Questions) {
    
    if let queTitle = dicQue.title {
      self.lblQueDesc.text = String(format: "%@", queTitle)
    }
    
    if dicQue.answers.count > 0 {
      
      for i in 0..<dicQue.answers.count {
        self.lblAnswerCollection[i].text = String(format: "%@", dicQue.answers[i].title ?? "")
      
        if dicQue.answers[i].isSelected ==  true {
          self.btnRadioCollection[i].isSelected = true
        }else {
          self.btnRadioCollection[i].isSelected = false
        }
        
      }

    }
    
  }
}
