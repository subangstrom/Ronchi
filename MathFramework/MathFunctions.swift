//
//  Functions.swift
//  Ronchigram
//
//  Created by James LeBeau on 5/25/17.
//  Copyright © 2017 The Handsome Microscopist. All rights reserved.
//

import Foundation


// Polynomial expansion of I0 from abramowitz_and_stegun, page 378
func besselI0(_ x:Float) -> Float {
    
    var i0:Float = 0.0
    
    
    let t:Float = abs(x)/3.75

    if (-3.75...3.75).contains(x){
        
        let t2 = t * t
        
        let i0lowCoeffs:[Float] = [1.0, 3.5156229, 3.0899424,
                                   1.2067492, 0.2659732, 0.0360768, 0.0045813]
        
        i0 = polynomialSum(i0lowCoeffs){t2*$0}

    }else{
        
        // first value in coeffects for t^0
    
        let ti:Float = 1.0/(t)
        
        let i0highCoeffs:[Float] = [0.39894228, 0.01328592, 0.00225319, -0.00157565,
                                    0.00916281, -0.02057706, 0.02635537, -0.01647633, 0.00392377]
        
        i0 = polynomialSum(i0highCoeffs){ti*$0}
        i0 = i0/x.squareRoot()*expf(x)

        
    }
    return i0
}


// Polynomial expansion of K0 from abramowitz_and_stegun, page 379

func besselK0(_ x:Float) -> Float {
    
    var k0:Float
    
    let ax = abs(x)
    
    if (ax > 0 && ax <= 2){
        
        let x2 = (x * x)/4.0
        
        let k0lowCoeffs:[Float] = [-0.57721566, 0.42278420, 0.23069756,
                                   0.03488590, 0.00262698, 0.00010750, 0.00000740]
        
        k0 = -logf(x/2.0)*besselI0(x)
        k0 = k0+polynomialSum(k0lowCoeffs){x2*$0}

    }else if ax > 2{
        
        // first value in coeffects for t^0
        
        
        let xi:Float = 2.0/(x)
        
        let k0highCoeffs:[Float] = [1.25331414, -0.07832358, 0.02189568, -0.01062446,
                                    0.00587872, -0.00251540, 0.00053208]
        
        k0 = polynomialSum(k0highCoeffs){xi*$0}
        k0 = k0/x.squareRoot()*expf(-x)
        
        
    }else{
        k0 = 1e20
    }
    
    return k0
}

// Closure based polynomial expansion. Makes it easy to avoid loops for exansions

func polynomialSum(_ coeffs:[Float], f: (Float) -> (Float)) -> Float {

    var sum = Float(0)
    var tp = Float(1)
    
    for coeff in coeffs {
        sum = coeff*tp + sum
        tp = f(tp)
    }
    
    return sum
    
    
}

