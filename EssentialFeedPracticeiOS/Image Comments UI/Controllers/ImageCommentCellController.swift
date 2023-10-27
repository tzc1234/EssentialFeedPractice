//
//  ImageCommentCellController.swift
//  EssentialFeedPracticeiOS
//
//  Created by Tsz-Lung on 27/10/2023.
//

import UIKit
import EssentialFeedPractice

public class ImageCommentCellController: CellController {
    private let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel) {
        self.model = model
    }
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageCommentCell.identifier) as! ImageCommentCell
        cell.messageLabel.text = model.message
        cell.dateLabel.text = model.date
        cell.usernameLabel.text = model.username
        return cell
    }
    
    public func startLoading(for cell: UITableViewCell) {
        
    }
    
    public func cancelLoading() {
        
    }
    
    public func preload() {
        
    }
}
