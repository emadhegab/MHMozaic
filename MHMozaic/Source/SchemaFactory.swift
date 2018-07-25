//
//  SchemaFactory.swift
//  HeyBeach
//
//  Created by Mohamed Emad Abdalla Hegab on 14.05.18.
//  Copyright © 2018 Mohamed Emad Hegab. All rights reserved.
//

import Foundation


enum PhotoOrientation: String {
    // we need to categorize the images to help in creating the scheme we need
    case fullLandscape
    case landscape
    case portrait
    case square
}

class SchemaFactory {
    class func generateSchemas() -> [PhotoOrientation] {

        return [
            // Schema A

            PhotoOrientation.square,
            .portrait,
            .square,
            .square,
            .square,
            .fullLandscape,

            // B

            .fullLandscape,
            .landscape,
            .square,
            .square,
            .square,
            .square,


            // C

            .portrait,
            .square,
            .square,
            .landscape,
            .landscape,
            .square,

            // D

            .landscape,
            .portrait,
            .square,
            .square,
            .landscape,
            .square

        ]
    }
}
