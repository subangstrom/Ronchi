//
//  Fourier Transform in Swift
//  Ronchigram
//
//  Created by James LeBeau on 5/24/17.
//  Copyright © 2017 The Handsome Microscopist. All rights reserved.
//

import Foundation
import Accelerate

class MFFftController: NSObject {
    
    var fftSetup:vDSP_DFT_Setup
    
    override init() {
        
        self.fftSetup =  vDSP_create_fftsetup(9, FFTRadix(kFFTRadix2))!
        
        super.init()


    }
    
    func fftInPlace(_ transform:Matrix){
        
        
        var testDSP =  DSPSplitComplex.init(realp: &transform.real, imagp: &transform.imag!)
        
        vDSP_fft2d_zip(fftSetup, &testDSP, 1, 0, 9, 9, FFTDirection(kFFTDirection_Forward))
        
    }
}
