

import UIKit

class PreviewTableViewCell: UITableViewCell {

   @IBOutlet var lblCollection: [UILabel]!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
  /// Configure Cell
  func configureCell(_ dicQue: Questions) {
    
    if let queTitle = dicQue.title {
      
      self.lblCollection[0].text = String(format: "Question %@:  %@",dicQue.id,queTitle)
      
      if let index = dicQue.answers.findIndex(callback: {$0.isSelected == true}) {
        
        if dicQue.answers[index].isCorrect == true {
          self.lblCollection[1].attributedText = self.setAttributedInAnswer("Correct Answer")
        }else {
          self.lblCollection[1].attributedText = self.setAttributedInAnswer("Incorrect Answer")
        }
      }else {
        self.lblCollection[1].text = ""
      }
      
      if let index = dicQue.answers.findIndex(callback: {$0.isSelected == true}) {
        
        self.lblCollection[2].text = String(format: "Given Answer: %@",dicQue.answers[index].title ?? "")
        
      }else {
         self.lblCollection[2].text = ""
      }
      
    }
    
    
    
  }
  
   /// setAttributed text
  func setAttributedInAnswer(_ str: String) -> NSMutableAttributedString {
    
    var answer = NSMutableAttributedString()
    
    let aStrMainString = "Answer:  \(str)"  as NSString
    
    let aStrAttributed = NSMutableAttributedString(string:aStrMainString as String)
    
    aStrAttributed.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.0)], range: aStrMainString.range(of: "\(str)"))
    
    if str == "Correct Answer" {
      aStrAttributed.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.green], range: aStrMainString.range(of: "\(str)"))
         
    }else {
      aStrAttributed.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], range: aStrMainString.range(of: "\(str)"))
         
    }
    
   
    answer = aStrAttributed
    
    return answer
  }
}
