//
//  GithubProfileViewModel.swift
//  github-profile
//
//  Created by Tiago Lopes on 16/05/21.
//

import UIKit

final class GithubProfileViewModel {
    
    // MARK: Properties
    
    private let service = GithubProfileService()
    
    private let imageFetcher = ImageFetcher()
        
    // MARK: Public API
    
    func fetchProfile(completionHandler: @escaping (Result<UserViewModel, Error>) -> Void) {
        service.fetchProfile { [weak self] result in
            switch result {
            case .success(let user):
                self?.fetchUserAvatar(at: user.avatarUrl) { [weak self] avatarResult in
                    guard let self = self else {
                        return
                    }
                    
                    switch avatarResult {
                    case .success(let image):
                        DispatchQueue.main.async {
                            completionHandler(.success(self.makeUserViewModel(user: user, avatar: image)))
                        }
                    case .failure(let error):
                        debugPrint("Failed fetching avatar")
                        completionHandler(.failure(error))
                    }
                }
            case .failure(let error):
                debugPrint("Failed fetching user")
                completionHandler(.failure(error))
            }
        }
    }
    
    private func fetchUserAvatar(at url: URL?, completionHandler: @escaping (Result<UIImage, ImageFetcher.Error>) -> Void) {
        guard let url = url else {
            completionHandler(.failure(ImageFetcher.Error.fetchFailure))
            return
        }
        
        imageFetcher.fetchImage(at: url, withCompletionHandler: completionHandler)
    }
    
    private func makeUserViewModel(user: User, avatar: UIImage) -> UserViewModel {
        UserViewModel(
            name: user.name,
            location: user.location,
            avatar: avatar,
            repositoriesCount: user.publicRepositoriesCount,
            blog: user.blog?.absoluteString,
            company: user.company,
            bio: user.bio
        )
    }
}
