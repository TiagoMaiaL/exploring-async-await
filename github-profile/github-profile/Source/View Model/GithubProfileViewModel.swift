//
//  GithubProfileViewModel.swift
//  github-profile
//
//  Created by Tiago Lopes on 16/05/21.
//

import UIKit
import Combine

final class GithubProfileViewModel {
    
    // MARK: Properties
    
    private let service = GithubProfileService()
    
    @Published
    private(set) var userViewModel: UserViewModel? = nil
    
    // MARK: Public API
    
    func fetchProfile() {
        service.fetchProfile { [weak self] result in
            switch result {
            case .success(let user):
                self?.fetchUserAvatar { [weak self] avatarResult in
                    switch avatarResult {
                    case .success(let image):
                        DispatchQueue.main.async {
                            self?.userViewModel = self?.makeUserViewModel(user: user, avatar: image)
                        }
                        
                    case .failure:
                        debugPrint("Failed fetching avatar")
                    }
                }
            case .failure:
                debugPrint("Failed fetching user")
            }
        }
    }
    
    private func fetchUserAvatar(completionHandler: (Result<UIImage?, Error>) -> Void) {
        // TODO:
    }
    
    private func makeUserViewModel(user: User, avatar: UIImage?) -> UserViewModel {
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
