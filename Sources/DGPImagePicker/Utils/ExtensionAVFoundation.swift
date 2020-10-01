//
//  ExtensionAVFile.swift
//  DGPImagePicker
//
//  Created by Daniel Gallego Peralta on 27/08/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import Foundation
import AVFoundation 
import MobileCoreServices

extension AVFileType {
    /// Fetch and extension for a file from UTI string
    var fileExtension: String {
        if let ext = UTTypeCopyPreferredTagWithClass(self as CFString, kUTTagClassFilenameExtension)?.takeRetainedValue() {
            return ext as String
        }
        return "None"
    }
}

extension AVCaptureSession {
    func resetInputs() {
        self.inputs.forEach {
            self.removeInput($0)
        }
    }
}

