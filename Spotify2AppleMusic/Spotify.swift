//
//  Spotify.swift
//  Spotify2AppleMusic
//
//  Created by Mathias Quintero on 2/28/17.
//  Copyright © 2017 Finn Gaida. All rights reserved.
//

import UIKit
import SafariServices
import Sweeft

class Spotify {
    
    static var shared = Spotify()
    
    lazy var auth: SPTAuth! = {
        let auth = SPTAuth.defaultInstance()
        auth?.clientID = "987ecaba09cd47b1af5ecc13ad675aa9"
        let url = URL(string: "spotify2appleMusic://login/")
        auth?.redirectURL = url
        auth?.sessionUserDefaultsKey = "spotify session"
        auth?.requestedScopes = [SPTAuthUserLibraryReadScope]
        return auth
    }()
    
    var authViewController: UIViewController?
    
    var isLoggedIn: Bool {
        return auth.session?.isValid() ?? false
    }
    
    private init() {
    }
    
    private func handlePages<Item>(_ page: SPTListPage) -> Promise<[Item], APIError>  {

        let items = page.items.compactMap { $0 as? Item }

        return page.next(token: auth.session.accessToken).flatMap { page in
            guard let page = page else { return .successful(with: items) }
            return self.handlePages(page).map { items + $0 }
        }
    }
    
    func playlists() -> Promise<[ImportSelection], APIError> {

        return SPTPlaylistList.playlists(auth: auth).flatMap { page in
            return self.handlePages(page).map { $0 => ImportSelection.playlist }
        }
    }
    
    func songs(in playlist: SPTPartialPlaylist) -> Promise<[SpotifySong], APIError> {
        return SPTPlaylistSnapshot.snapshot(for: playlist, token: auth.session.accessToken).map { snapshot in
            let tracks = snapshot.tracksForPlayback().flatMap { $0 as? SPTPlaylistTrack }
            return tracks => SpotifySong.init(from:)
        }
    }
    
    func fetchSongs() -> Promise<[SpotifySong], APIError> {
        return SPTYourMusic.firstPage(auth: auth).flatMap { self.handlePages($0) }
                                                 .map { $0 => SpotifySong.init(from:) }
    }
    
    func loginIfNeeded(viewController: UIViewController) {
        guard let session = auth.session, session.isValid() else {
            let url = auth.spotifyWebAuthenticationURL()
            authViewController = SFSafariViewController(url: url!)
            guard let vc = authViewController else {
                return
            }
            viewController.present(vc, animated: true)
            return
        }
    }
    
    func callback(url: URL) -> Bool {
        auth.handleAuthCallback(withTriggeredAuthURL: url) { error, session in
            self.authViewController?.dismiss(animated: true)
        }
        return true
    }
    
}

extension SPTPlaylistList {

    static func playlists(auth: SPTAuth) -> Response<SPTListPage> {
        guard let session = auth.session else { return .errored(with: .noData) }
        return .calling { playlists(forUser: session.canonicalUsername, withAccessToken: session.accessToken, callback: $0) }
    }

}

extension SPTPlaylistSnapshot {

    static func snapshot(for playlist: SPTPartialPlaylist, token: String) -> Response<SPTPlaylistSnapshot> {
        return .calling { SPTPlaylistSnapshot.playlist(withURI: playlist.uri, accessToken: token, callback: $0) }
    }

}

extension SPTYourMusic {

    static func firstPage(auth: SPTAuth) -> Response<SPTListPage> {
        guard let session = auth.session else { return .errored(with: .noData) }
        return .calling { SPTYourMusic.savedTracksForUser(withAccessToken: session.accessToken, callback: $0) }
    }

}

extension SPTListPage {

    func next(token: String) -> Response<SPTListPage?> {
        guard hasNextPage else { return .successful(with: nil) }
        return .calling { self.requestNextPage(withAccessToken: token, callback: $0) }
    }

}

extension Promise where E == APIError {

    static func calling(handler: @escaping (@escaping SPTRequestCallback) -> Void) -> Response<T> {
        return .new { setter in
            handler { error, result in
                guard let result = result as? T, error == nil else {
                    return setter.error(with: .unknown(error: error!))
                }
                setter.success(with: result)
            }
        }
    }

}
