//
//  ButtonNode.swift
//  Final Flappy
//
//  Created by Michael Burlingame on 2/25/23.
//

import SpriteKit

enum MSButtonNodeState {
    case MSButtonNodeStateActive, MSButtonNodeStateSelected, MSButtonNodeStateHidden
}

class MSButtonNode: SKSpriteNode {
    // PlaceHolder Handler
    var selectedHandler: () -> Void = { print("No button action set") }
    
    var state: MSButtonNodeState = .MSButtonNodeStateActive {
        
        didSet {
            
            switch state {
                
        // If Button isActive, Allow Touch & Show
            case .MSButtonNodeStateActive:
                self.isUserInteractionEnabled = true
                self.alpha = 1
                break
                
        // If Button isSelected, "Fade Away"
            case .MSButtonNodeStateSelected:
                self.alpha = 0.7
                break
                
        // If Button isHidden, Disable Touch & Hide
            case .MSButtonNodeStateHidden:
                self.isUserInteractionEnabled = false
                self.alpha = 0
                break
                
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isUserInteractionEnabled = true
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // When Tapped, Set The State To Selected
        state = .MSButtonNodeStateSelected
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // When The Tap Ends, Execute The Handler & Set State To Active
        selectedHandler()
        state = .MSButtonNodeStateActive
    }
    
}
