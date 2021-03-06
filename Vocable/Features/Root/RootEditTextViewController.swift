//
//  RootEditTextViewController.swift
//  Vocable
//
//  Created by Chris Stroud on 5/4/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import Combine
import CoreData

class RootEditTextViewController: EditTextViewController {

    private var disposables = Set<AnyCancellable>()

    private let favoriteButton: GazeableButton = {
        let button = GazeableButton()
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.accessibilityIdentifier = "keyboard.favoriteButton"
        button.addTarget(self, action: #selector(favoriteButtonSelected), for: .primaryActionTriggered)
        return button
    }()

    private var currentPhrase: Phrase? {
        didSet {
            if let _ = currentPhrase {
                favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            } else {
                favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        shouldWarnOnDismiss = false
        navigationBar.rightButton = favoriteButton
        $text.receive(on: DispatchQueue.main).sink { [weak self] newText in
            self?.updateFavoriteButton(with: self?.normalizedText(from: newText))
        }.store(in: &disposables)
    }

    private func normalizedText(from text: String?) -> String {
        let trimmed = text?.trimmingCharacters(in: .whitespaces) ?? ""
        return trimmed
    }

    private func updateFavoriteButton(with text: String?) {
        guard let text = text, !text.isEmpty else {
            self.currentPhrase = nil
            self.favoriteButton.isEnabled = false
            return
        }
        self.favoriteButton.isEnabled = true
        let userFavorites = Category.userFavoritesCategory()
        let fetchRequest: NSFetchRequest<Phrase> = Phrase.fetchRequest()
        fetchRequest.predicate = {
            let categoryPredicate = NSComparisonPredicate(\Phrase.category, .equalTo, userFavorites)
            let userGenerated = NSComparisonPredicate(\Phrase.isUserGenerated, .equalTo, true)
            let textMatches = NSComparisonPredicate(\Phrase.utterance, .equalTo, text)
            let subpredicates = [categoryPredicate, userGenerated, textMatches]
            return NSCompoundPredicate(andPredicateWithSubpredicates: subpredicates)
        }()
        fetchRequest.fetchLimit = 1
        let results = (try? NSPersistentContainer.shared.viewContext.fetch(fetchRequest)) ?? []
        self.currentPhrase = results.first
    }

    @objc private func favoriteButtonSelected(_ sender: Any) {
        let text = normalizedText(from: self.text)

        let context = NSPersistentContainer.shared.viewContext

        if let currentPhrase = currentPhrase {
            context.delete(currentPhrase)
        } else {
            _ = Phrase.create(withUserEntry: text, in: context)
        }

        do {
            try context.save()
        } catch {
            assertionFailure("Could not save: \(error)")
        }

        updateFavoriteButton(with: text)
    }
}
