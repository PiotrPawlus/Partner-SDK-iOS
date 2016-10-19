//
//  PredictionController.swift
//  Pods
//
//  Created by Matthew Reed on 7/15/16.
//
//

import UIKit

protocol PredictionControllerDelegate: class {
    func didUpdatePredictions(predictions: [GooglePlacesPrediction])
    func didSelectPrediction(prediction: GooglePlacesPrediction)
    func didTapXButton()
    func didTapSearchButton()
    func didBeginEditingSearchBar()
    func shouldSelectFirstPrediction()
}

class PredictionController: NSObject {
    let headerFooterHeight: CGFloat = 30
    
    var predictions = [GooglePlacesPrediction]() {
        didSet {
            guard let delegate = self.delegate?.didUpdatePredictions(self.predictions) else {
                return assertionFailure("delegate is nil")
            }
        }
    }
    
    weak var delegate: PredictionControllerDelegate?
}

//MARK: UITableViewDataSource

extension PredictionController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.predictions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("predictionCell", forIndexPath: indexPath) as! PredictionTableViewCell
        
        cell.configureCell(predictions[indexPath.row])
        
        return cell
    }
}

//MARK: UITableViewDelegate

extension PredictionController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let prediction = predictions[indexPath.row]
        guard let delegate = self.delegate else {
            return assertionFailure("delegate is nil")
        }
        self.predictions.removeAll()
        delegate.didSelectPrediction(prediction)
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier("predictionHeader") as! GooglePredictionTableHeader
        view.label.text = LocalizedStrings.BestMatches
        return view
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier("predictionFooter")
        return view
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Number chosen to match designs
        return self.headerFooterHeight
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // Number chosen to match designs
        return self.headerFooterHeight
    }
}

//MARK: UISearchBarDelegate

extension PredictionController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        GooglePlacesWrapper.getPredictions(searchText) {
            [weak self]
            predictions, error in
            self?.predictions = predictions
            self?.delegate?.shouldSelectFirstPrediction()
        }
        
        if (searchText.isEmpty) {
            self.delegate?.didTapXButton()
        }
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.delegate?.didBeginEditingSearchBar()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.delegate?.didTapSearchButton()
        searchBar.resignFirstResponder()
    }
}
