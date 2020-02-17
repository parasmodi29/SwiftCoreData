
import UIKit
import CoreData

class ViewController: UIViewController {
  
  @IBOutlet weak var btnSubmit: UIButton!
  @IBOutlet weak var btnNext: UIButton!
  @IBOutlet weak var btnPrevious: UIButton!
  @IBOutlet weak var lblQuestionNo: UILabel!
  @IBOutlet weak var lblQuestionNoTitle: UILabel!
  @IBOutlet weak var noDataView: UIView!
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var lblTimer: UILabel!
  
  var behavior: MSCollectionViewPeekingBehavior!
     
  var arrQuestionList: [Questions] = []
  var currentIndexOfQue: Int = 0
  var totalQuestion: Int = 0
  var seconds: Int = 0
  
  var timer: Timer? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.setupView()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.collectionView.layoutIfNeeded()
  }
  
  /**
   - set up view
   */
  func setupView() {
    
    if let path = Bundle.main.path(forResource: "document", ofType: "json") {
      do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
        if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let questions = jsonResult["questions"] as? [AnyObject] {
          
          for questionDict in questions {
            
            // Check if exist or not Data in Database
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.QuestionEntity)
            fetchRequest.predicate = NSPredicate(format: "title = %@", (questionDict["title"] as? String)!)
            
            var results: [NSManagedObject] = []
            
            do {
              results = try Constants.kAppDelegate.persistentContainer.viewContext.fetch(fetchRequest)
            }
            catch {
              print("error executing fetch request: \(error)")
              self.noDataView.isHidden = false
            }
            
            if results.count > 0 {
            }
            else {
              
              // Insert New object in Database
              let questionDetail = NSEntityDescription.insertNewObject(forEntityName: Constants.QuestionEntity,
                                                                       into:  Constants.kAppDelegate.persistentContainer.viewContext) as! QuestionEntity
              
              questionDetail.id = questionDict["id"] as? String
              questionDetail.title = questionDict["title"] as? String
              
              let answerDict = questionDict["answers"] as! [AnyObject]
              
              var arrAnsTemp: [Answers] = []
              
              for dicAnswer in answerDict {
                arrAnsTemp.append(Answers(title: dicAnswer["title"] as? String, isSelected: dicAnswer["isSelected"] as! Bool, isCorrect: dicAnswer["isCorrect"] as! Bool))
              }
              
              let encoder = JSONEncoder()
              
              questionDetail.answers =  try? encoder.encode(arrAnsTemp) as NSObject
              
              Constants.kAppDelegate.saveContext()
            }
            
          }
          
          
          // Fetch Data From Databse
          let request = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.QuestionEntity)
          
          arrQuestionList = []
          
          request.returnsObjectsAsFaults = false
          
          do {
            let result = try Constants.kAppDelegate.persistentContainer.viewContext.fetch(request)
            
            for data in result as! [NSManagedObject] {
              
              let questionDetail = data as! QuestionEntity
              let decoder = JSONDecoder()
              
              arrQuestionList.append(Questions(id: questionDetail.id ?? "", title: questionDetail.title, answers: try decoder.decode(Array<Answers>.self, from: questionDetail.answers as! Data), isAttempt: false))
              
            }
            
            self.totalQuestion = self.arrQuestionList.count
            currentIndexOfQue = 0
            self.setupTopView(currentIndexOfQue)
            self.collectionView.register(UINib(nibName: "QuestionCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "QuestionCell")
            behavior = MSCollectionViewPeekingBehavior(cellSpacing: 0.0, cellPeekWidth: 0.0, maximumItemsToScroll: self.arrQuestionList.count, numberOfItemsToShow: 1, scrollDirection: .horizontal)
            collectionView.configureForPeekingBehavior(behavior: behavior)
            collectionView.reloadData()
            self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
            
          } catch {
            print("Failed to fetch")
            self.noDataView.isHidden = false
          }
          
        }
      } catch {
        // handle error
        print("Failed to insert")
        self.noDataView.isHidden = false
      }
    }
  }
  
  /**
   - set up Top and Bottom View
   */
  func setupTopView(_ currentIndex: Int) {
    
    
    self.lblQuestionNoTitle.text = String(format: "Question %d", currentIndex+1)
    self.lblQuestionNo.text = String(format: "(%d/%d)", currentIndex+1,totalQuestion)
    
    if currentIndex+1 == totalQuestion {
      self.btnNext.isEnabled = false
      self.btnNext.alpha = 0.5
      self.btnSubmit.isEnabled = true
      self.btnSubmit.alpha = 1.0
    }else {
      self.btnNext.isEnabled = true
      self.btnNext.alpha = 1.0
      self.btnSubmit.isEnabled = false
      self.btnSubmit.alpha = 0.5
    }
    
    if currentIndex == 0 {
      self.btnPrevious.isEnabled = false
      self.btnPrevious.alpha = 0.5
    }else {
      self.btnPrevious.isEnabled = true
      self.btnPrevious.alpha = 1.0
    }
         
    self.setupTimer()
    
  }
  
  /**
   - @IBActions
   */
  @IBAction func actionPrevious(_ sender: Any) {
   
    if currentIndexOfQue == 0 {
      return
    }
    self.updateTimerLabel()
    currentIndexOfQue -= 1
    self.setupTopView(currentIndexOfQue)
    self.collectionView.scrollToItem(at: IndexPath(item: currentIndexOfQue, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
  }
  
  @IBAction func actionNext(_ sender: Any) {
    
    if currentIndexOfQue == 9 {
      return
    }
    
    self.updateTimerLabel()
    currentIndexOfQue += 1
    self.setupTopView(currentIndexOfQue)
    self.collectionView.scrollToItem(at: IndexPath(item: currentIndexOfQue, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
  }
 
  @IBAction func actionSubmit(_ sender: Any) {
    
    self.openResultVC()
  }
  
  
  
  /**
   - Redirect to Result VC
   */
  func openResultVC() {
    self.invalidatetimer()
    if let objResultVC = Constants.kMainStoryBoard.instantiateViewController(withIdentifier: "ResultViewController") as? ResultViewController {
      objResultVC.arrQuestionList = []
      objResultVC.arrQuestionList = self.arrQuestionList
      self.navigationController?.pushViewController(objResultVC, animated: true)
    }
  }
  
  
  /**
   - set up Timer
   */
  func setupTimer() {
    self.seconds = 10
    self.invalidatetimer()
    timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fire), userInfo: nil, repeats: true)
  
  }
  
  /**
   - invalida Timer
   */
  func invalidatetimer() {
    if timer != nil {
      timer!.invalidate()
      timer = nil
    }
  }
  
  /**
   - update UI of Timer Label
   */
  func updateTimerLabel() {
    DispatchQueue.main.async {
      self.lblTimer.text = String(format: "%d seconds", self.seconds)
      
    }
      
  }
  
  /**
   - Fire the Timer
   */
  @objc func fire() {
    
    self.seconds -= 1
    
    if self.seconds == 0 {
      
      self.invalidatetimer()
      if currentIndexOfQue == 9 {
        self.openResultVC()
        return
      }
      currentIndexOfQue += 1
      self.setupTopView(currentIndexOfQue)
      self.collectionView.scrollToItem(at: IndexPath(item: currentIndexOfQue, section: 0), at: .right, animated: true)
    }
    
    self.updateTimerLabel()
   
  }
}

/**
 - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
 */
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    return self.arrQuestionList.count
    
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    guard let objCell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuestionCell", for: indexPath) as? QuestionCollectionViewCell else {
      return UICollectionViewCell()
    }
    
    for i in 0..<objCell.btnRadioCollection.count {
      objCell.btnRadioCollection[i].addTarget(self, action: #selector(actionRadioButton(_:)), for: UIControl.Event.touchUpInside)
    }
    
    objCell.configureCell(self.arrQuestionList[indexPath.item])
    
    return objCell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    
    return UIEdgeInsets.init(top: 0,left: 0,bottom: 0,right: 0)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width:self.collectionView.bounds.width, height:self.collectionView.bounds.height)
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    print(indexPath.item)
  }
  
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
      behavior.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
     
     if scrollView == collectionView {
      let introCellLayout = collectionView.collectionViewLayout as! MSCollectionViewCellPeekingLayout
      let pageSide = introCellLayout.scrollDirection == .horizontal ? (UIScreen.main.bounds.size.width) : 200
      let offset = introCellLayout.scrollDirection == .horizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y
      currentIndexOfQue = Int(floor((offset - pageSide / 2) / pageSide) + 1)
      self.updateTimerLabel()
      self.setupTopView(currentIndexOfQue)
      self.collectionView.scrollToItem(at: IndexPath(item: currentIndexOfQue, section: 0), at: .centeredVertically, animated: true)
    }
  }
}


extension ViewController {
  
  /**
   - Action for Radio Button
   */
  @objc func actionRadioButton(_ sender: UIButton) {
    
    self.updateRadioButton(sender.tag)
    
  }
  
  /**
   - update Radio Button UI
   */
  func updateRadioButton(_ tag: Int) {
    
    self.arrQuestionList[currentIndexOfQue].isAttempt = true
    
    for i in 0..<self.arrQuestionList[currentIndexOfQue].answers.count {
      
      if i == tag {
        self.arrQuestionList[currentIndexOfQue].answers[i].isSelected = true
      }else {
        self.arrQuestionList[currentIndexOfQue].answers[i].isSelected = false
      }
      
    }
    
    if self.arrQuestionList[currentIndexOfQue].answers[tag].isCorrect == true && self.arrQuestionList[currentIndexOfQue].answers[tag].isSelected == true {
        print("Your Answer is Correct")
    }
    
    self.collectionView.reloadItems(at: [IndexPath(item: currentIndexOfQue, section: 0)])
  }
}
