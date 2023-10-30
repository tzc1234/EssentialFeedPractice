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
    private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>
    
    public static func commentsComposedWith(
        commentsLoader: @escaping () -> AnyPublisher<[FeedImage], Error>) -> ListViewController {
            let presentationAdapter = FeedPresentationAdapter(loader: commentsLoader)
            let refreshController = RefreshViewController()
            refreshController.onRefresh = presentationAdapter.loadResource
            
            let feedViewController = ListViewController(refreshController: refreshController)
            feedViewController.title = ImageCommentsPresenter.title
            feedViewController.registerTableCell(FeedImageCell.self, forCellReuseIdentifier: FeedImageCell.identifier)
            
            presentationAdapter.presenter = LoadResourcePresenter<[FeedImage], FeedViewAdapter>(
                view: FeedViewAdapter(
                    controller: feedViewController,
                    imageLoader: { _ in Empty<Data, Error>().eraseToAnyPublisher() }),
                loadingView: WeakRefProxy(refreshController),
                errorView: WeakRefProxy(feedViewController),
                mapper: FeedPresenter.map)
            
            return feedViewController
        }
}
