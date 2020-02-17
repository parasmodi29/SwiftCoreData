

import Foundation

extension Array {

  func findIndex(callback: (Element) -> Bool) -> Int? {
    return Dollar.findIndex(self, callback: callback)
  }
}
