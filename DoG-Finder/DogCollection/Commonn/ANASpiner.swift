//
//  ANASpiner.swift
//  DoG-Finder
//
//  Created by Ghaffar on 10/16/23.
//

import Foundation
import ANActivityIndicator



import Foundation

protocol AppSpinnerProtocol {
    func show()
    func hide()
}


class ANAppSpinner {
    static let shared: ANAppSpinner = ANAppSpinner()

    private init() {
    }
}

extension ANAppSpinner: AppSpinnerProtocol {
    func show() {
        DispatchQueue.main.async {
            ANActivityIndicatorPresenter.shared.showIndicator()
        }
    }

    func hide() {
        DispatchQueue.main.async {
            ANActivityIndicatorPresenter.shared.hideIndicator()
        }
    }
}
