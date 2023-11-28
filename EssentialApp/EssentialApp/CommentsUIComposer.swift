//
//  CommentsUIComposer.swift
//  EssentialApp
//
//  Created by Tsz-Lung on 30/10/2023.
//

import Combine
import Foundation
import EssentialFeedPractice
import EssentialFeedPracticeiOS

public enum CommentsUIComposer {
    private typealias CommentsPresentationAdapter = LoadResourcePresentationAdapter<[ImageComment], CommentsViewAdapter>
    
    public static func commentsComposedWith(
        commentsLoader: @escaping () -> AnyPublisher<[ImageComment], Error>) -> ListViewController {
            let presentationAdapter = CommentsPresentationAdapter(loader: commentsLoader)
            let refreshController = RefreshViewController()
            refreshController.onRefresh = presentationAdapter.loadResource
            
            let commentsViewController = ListViewController(refreshController: refreshController)
            commentsViewController.title = ImageCommentsPresenter.title
            commentsViewController.registerTableCell(ImageCommentCell.self)
            
            presentationAdapter.presenter = LoadResourcePresenter(
                resourceView: CommentsViewAdapter(controller: commentsViewController),
                loadingView: WeakRefProxy(refreshController),
                errorView: WeakRefProxy(commentsViewController),
                mapper: { ImageCommentsPresenter.map($0) })
            
            return commentsViewController
        }
}

final class CommentsViewAdapter: ResourceView {
    private weak var controller: ListViewController?
    
    init(controller: ListViewController) {
        self.controller = controller
    }
    
    func display(_ viewModel: ImageCommentsViewModel) {
        controller?.display(viewModel.comments.map { viewModel in
            CellController(id: viewModel, ImageCommentCellController(model: viewModel))
        })
    }
}
