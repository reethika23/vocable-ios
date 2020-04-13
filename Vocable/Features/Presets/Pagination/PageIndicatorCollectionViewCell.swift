//
//  PageIndicatorCollectionViewCell.swift
//  Vocable AAC
//
//  Created by Patrick Gatewood on 2/20/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import Combine

final class PageIndicatorCollectionViewCell: VocableCollectionViewCell {
    
    @IBOutlet private weak var pageLabel: UILabel!
    private var disposables = Set<AnyCancellable>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        fillColor = .collectionViewBackgroundColor
        pageLabel.adjustsFontSizeToFitWidth = true
        
        ItemSelection.$presetsPageIndicatorProgress.sink(receiveValue: { pageInfo in
            self.pageLabel.text = pageInfo.localizedString
        }).store(in: &disposables)
    }
}
