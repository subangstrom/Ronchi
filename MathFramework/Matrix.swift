
//
//  Matrix.swift
//  Ronchigram
//
//  Created by James LeBeau on 5/19/17.
//  Copyright © 2017 The Handsome Microscopist. All rights reserved.
//

import Foundation
import Cocoa
import Accelerate


//MARK: - Constants
struct MatrixConstant {
    static let elementwise = "element-wise"
    static let product = "product"
}

struct MatrixOutput {
    static let uint16 = 16
    static let uint8 = 8
    static let float = 32
}

infix operator .*


class Matrix: CustomStringConvertible, CustomPlaygroundQuickLookable{

    
    //MARK: - Properties
    let rows:Int
    let columns:Int
    let type:String
    
    var real:Array<Float>
    var imag:Array<Float>?
    
    var count: Int {
        return rows*columns
    }
    var complex: Bool {
        if (imag as [Float]?) != nil{
            return true
        }else{
            return false
        }
        
    }
    
    var max:Complex {
        
        var maxValue = Complex(0,0)
        let length = vDSP_Length(count)
        
        if type == "real"{
            vDSP_maxv(real, 1, &maxValue.a, length)
        }else {
            
            vDSP_maxv(real, 1, &maxValue.a, length)
            vDSP_maxv(imag!, 1, &maxValue.b, length)
            
            
        }
        
        return maxValue
    }
    
    var min:Complex {
        
        var minValue = Complex(0,0)
        let length = vDSP_Length(count)
        
        if type == "real"{
            vDSP_minv(real, 1, &minValue.a, length)
        }else {
            
            vDSP_minv(real, 1, &minValue.a, length)
            vDSP_minv(imag!, 1, &minValue.b, length)
            
            
        }
        
        return minValue
    }
    
    // this currently doesn't really make sense
    
//MARK: - Initializers
    init(_ rows:Int, _ columns:Int, _ type:String? = nil){
               
        self.rows = rows
        self.columns = columns
        

        
            if let newType = type{
                
                
                if(newType == "real"){
                    self.type = newType

                    real = Array(repeating: Float(0), count: rows*columns)
                    imag = nil
                }else if (newType == "complex"){
                    self.type = newType

                    real = Array(repeating: Float(0), count: rows*columns)
                    imag = Array(repeating: Float(0), count: rows*columns)
                    
                }else{
                    self.type = "real"
                    
                    real = Array(repeating: Float(0), count: rows*columns)
                    imag = nil
                }
                
            }else{
                self.type = "real"
                
                real = Array(repeating: Float(0), count: rows*columns)
                imag = nil
        }
        

        
    }
    
    class func identity(size:Int)->Matrix{
        
        let newMat = Matrix(size, size)
        
        for i in 0..<size{
            newMat.set(i, i, 1.0)
        }
        
        return newMat
        
    }
    

    
    //MARK: - Matrix setters
    
//    mutating func setRange(range:Range<Int>, values:[Any]){
//        
//        switch values {
//        case let complexValue as [Complex]:
//            
//            real[index] = complexValue.a
//            imag?[index] = complexValue.b
//            
//        case let floatValue as [Float]:
//            real[index] = floatValue
//        case let intValue as [Int]:
//            real[index] = Float(intValue)
//        case let doubleValue as [Double]:
//            real[index] = Float(doubleValue)
//        default:
//            print("not a valid type")
//        }
//        
//    }
    

    func set(_ i:Int,_ j:Int,_ value:Any){
 
        let index = columns*i+j

        switch value {
            case let complexValue as Complex:
            
                real[index] = complexValue.a
                imag?[index] = complexValue.b
            
            case let floatValue as Float:
                real[index] = floatValue
            case let intValue as Int:
                real[index] = Float(intValue)
            case let doubleValue as Double:
            real[index] = Float(doubleValue)
            default:
                print("not a valid type")
        }
    }
    
    // TODO: Add capability to set a range with an array
     func set(array:[Float], type:String ){
        
        if(type == "real" && count == array.count){
            self.real = array
        }
        
    }
    
    func convert()->Matrix{
        
        let newMat:Matrix
        
        if complex{
            newMat = Matrix(rows, columns)
            newMat.real = real
            newMat.imag = imag!
        }else{
            newMat = Matrix(rows, columns, "complex")
            newMat.real = real
        }
        
        return newMat
        
    }
    
    //MARK: - Operations (replace values in this matrix)

    
     func add(_ addMatrix:Matrix)  {
        
        guard self.sameSize(addMatrix)  else {
           print("Matrices are not the same size for element-wise calculation")
            return
        }
        
         let length:vDSP_Length = UInt(self.count)
        vDSP_vadd(self.real, 1, addMatrix.real, 1, &self.real, 1, length)
                
        
    }
    
     func sub(_ subMatrix:Matrix)  {
        
        guard self.sameSize(subMatrix)  else {
            print("Matrices are not the same size for element-wise calculation")
            return
        }
        
        let length:vDSP_Length = UInt(self.count)
        vDSP_vsub(subMatrix.real, 1, self.real, 1, &self.real, 1, length)
        
    }
    
     func mul(_ mulMatrix:Matrix)  {
        
        guard self.sameSize(mulMatrix)  else {
            print("Matrices are not the same size for element-wise calculation")
            return
        }
        
        let length:vDSP_Length = UInt(self.count)
        vDSP_vmul(mulMatrix.real, 1, self.real, 1, &self.real, 1, length)
        
    }
    
    
    func sameSize(_ compareMatrix:Matrix)->Bool{
        
        if self.count == compareMatrix.count {
            return true
        }else{
            return false
        }
        
        
    }
    
    var description: String{
        
        var outString = ""
        
        var index = 0
        
        for i in 0..<rows{
            for j in 0..<columns{
                
               index = i*columns+j
                
                if type == "complex"{
                    
                    var sign:String;
                    let b = imag![index]
                    
                    if(b < 0){
                        sign = "-"
                    }else{
                        sign = "+"
                    }

                    outString = outString + String(format: "%.3f", real[index])
                    outString = outString + sign + String(format: "%.3f", Swift.abs(b)) + "i \t"
                    
                }else{
                    outString = outString + String(format: "%.3f", real[index]) + "\t"

                }
            }
            
            outString = outString + "\n"

        }

        return outString
    }
    
    
    // Scaled from max and min of the original matrix
    func realUint8()->[UInt8]{
        
        var maximum = self.max
        let minimum = self.min
        
        
        if maximum.a == 0 {
            maximum.a = 1
        }
        
        if  maximum.b == 0 {
            maximum.b = 1
            
        }
        
        
        var outUint8:[UInt8] = [UInt8].init(repeating: UInt8(0), count:self.count)
        
        for i in 0..<real.count{
            
            
            outUint8[i] = UInt8((real[i]-minimum.a)/(maximum.a-minimum.a)*255)
        }
        
        return outUint8
        
    }

    func realUint16()->[UInt16]{
        
        var maximum = self.max
        let minimum = self.min
        
        
        if maximum.a == 0 {
            maximum.a = 1
        }

        
        
        var outUint16:[UInt16] = [UInt16].init(repeating: UInt16(0), count:self.count)
        
        for i in 0..<real.count{
            
            
            outUint16[i] = UInt16((real[i]-minimum.a)/(maximum.a-minimum.a)*255)
        }
        
        return outUint16
        
    }

    
    func imagUint8()->[UInt8]{
        
        
        var maximum = self.max
        let minimum = self.min
        
    
        if  maximum.b == 0 {
            maximum.b = 1
            
        }
        
        var outUInt8:[UInt8] = [UInt8].init(repeating: UInt8(0), count:self.count)
        
        if imag != nil{
        
            for i in 0..<real.count{
                
                outUInt8[i] = UInt8((imag![i]-minimum.b)/(maximum.b-minimum.b)*255)
            }
        }
        
        return outUInt8

        
    }
    
    func imagUint16()->[UInt16]{
        
        var maximum = self.max
        let minimum = self.min
        
        
        
        if  maximum.b == 0 {
            maximum.b = 1
            
        }
        
        var outUint16:[UInt16] = [UInt16].init(repeating: UInt16(0), count:self.count)

        
        if imag != nil{
            
            for i in 0..<imag!.count{
                
                
                outUint16[i] = UInt16((imag![i]-minimum.b)/(maximum.b-minimum.b)*255)
            }
        }
        
        return outUint16
        
    }
    
    func imageRepresentation(part:String, format:Int) -> NSImage? {
        
    
        let typeSize:Int = format/8
        let dataSize:Int = format*count
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue).union(CGBitmapInfo())
        var providerRef:CGDataProvider?
        
        
        if format == MatrixOutput.uint16 {
            
            var out:[UInt16]
            
            if part == "imag" {
                out = self.imagUint16()

            }else{
                out = self.realUint16()

            }
            
            
            providerRef = CGDataProvider(data: NSData(bytes: &out, length: dataSize))!
            
        }else{

            var out:[UInt8]

            if part == "imag" {
                 out = self.imagUint8()
                
            }else{
                 out = self.realUint8()
                
            }
            
            let data = NSData(bytes: &out, length: dataSize)
            
            providerRef = CGDataProvider(data: data)!

            
        }
        
            // careful of bits not bytes!
            if let image = CGImage(width: columns,
                                      height: rows,
                                      bitsPerComponent: format,
                                      bitsPerPixel: format,
                                      bytesPerRow: typeSize*columns,
                                      space: CGColorSpaceCreateDeviceGray(),
                                      bitmapInfo: bitmapInfo,
                                      provider: providerRef!,
                                      decode: nil,
                                      shouldInterpolate: true,
                                      intent: CGColorRenderingIntent.defaultIntent){
                
                return NSImage(cgImage: image, size:  NSZeroSize)
            }
        
            return nil
    }
    
    /// A custom playground Quick Look for this instance.
    ///
    /// If this type has value semantics, the `PlaygroundQuickLook` instance
    /// should be unaffected by subsequent mutations.
    
    var customPlaygroundQuickLook: PlaygroundQuickLook{
        
        
        let realPartImage = self.imageRepresentation(part: "real", format: MatrixOutput.uint8)
        
        var combinedImage:NSImage?
        
        if type == "complex"{
            
            let imagPartImage = self.imageRepresentation(part: "imag", format: MatrixOutput.uint8)

            
            combinedImage = NSImage(size: NSSize.init(width: 2*columns, height: rows), flipped:false, drawingHandler: {rect in
                
                let realHalfRect = NSRect(x: 0, y: 0, width: self.columns, height: self.rows)
                realPartImage?.draw(in:realHalfRect)
                
                let imagHalfRect = NSRect(x: self.columns+1, y: 0, width: self.columns, height: self.rows)
                imagPartImage?.draw(in:imagHalfRect)
                
                return true
            })
            
        }

        if combinedImage != nil{
            return .image(combinedImage!)
        }else{
            return .image(realPartImage!)
        }
//        else{
//           return PlaygroundQuickLook.text(self.description)
//        }
    }
    
    
    
    
    
}

//MARK: - Operations (new matrix)

func +(lhs:Matrix,rhs:Matrix) -> Matrix? {
   
    if let newMatrix = validOutputMatrix(lhs, rhs) as Matrix? {
        
        
        let length:vDSP_Length = UInt(newMatrix.count)
        var outReal = newMatrix.real
        
        
        vDSP_vadd(lhs.real, 1, rhs.real, 1, &outReal, 1, length)

        newMatrix.real = outReal;

        
        if newMatrix.type == "complex" {
            
            var outImag = newMatrix.imag

            if let lhsImag = lhs.imag as [Float]? {
                vDSP_vadd(lhsImag, 1, outImag!, 1, &outImag!, 1, length)
            }
            
            if let rhsImag = rhs.imag as [Float]? {
                vDSP_vadd(rhsImag, 1, outImag!, 1, &outImag!, 1, length)
            }

        
        newMatrix.imag = outImag;
            
            
        }
        
        return newMatrix
        
        
    }else{
        return nil
    }
        
}

func -(lhs:Matrix,rhs:Matrix) -> Matrix? {
    
    if let newMatrix = validOutputMatrix(lhs, rhs) as Matrix? {
        
        
        let length:vDSP_Length = UInt(newMatrix.count)
        
        var outReal = newMatrix.real
        
        
        vDSP_vsub(rhs.real, 1, lhs.real, 1, &outReal, 1, length)
        
        newMatrix.real = outReal;
        
        
        if newMatrix.type == "complex" {
            
            var outImag = newMatrix.imag
            
            if let lhsImag = lhs.imag as [Float]? {
                vDSP_vadd(lhsImag, 1, outImag!, 1, &outImag!, 1, length)
            }
            
            if let rhsImag = rhs.imag as [Float]? {
                vDSP_vsub(rhsImag, 1, outImag!, 1, &outImag!, 1, length)
            }
            
            
            newMatrix.imag = outImag;
            
            
        }
        
        return newMatrix
        
        
    }else{
        return nil
    }
    
    
    
}

func .*(lhs:Matrix,rhs:Matrix) -> Matrix?{
    
    if let newMatrix = validOutputMatrix(lhs, rhs) as Matrix? {
        
        let length:vDSP_Length = UInt(newMatrix.count)
        
        var outReal = newMatrix.real
        
        var temp1 = [Float](repeatElement(0.0, count: newMatrix.count))
        var temp2 = [Float](repeatElement(0.0, count: newMatrix.count))
        
        if lhs.complex && rhs.complex {
            
            var outImag = newMatrix.imag!
            
            // Calculate the real part
            
            vDSP_vmul(rhs.real, 1, lhs.real, 1, &temp1, 1, length)
            vDSP_vmul(rhs.imag!, 1, lhs.imag!, 1, &temp2, 1, length)

            vDSP_vsub(temp2, 1, temp1, 1, &outReal, 1, length)
            
            // Calculate the imag part

            
            vDSP_vmul(rhs.real, 1, lhs.imag!, 1, &temp1, 1, length)
            vDSP_vmul(rhs.imag!, 1, lhs.real, 1, &temp2, 1, length)
            
            vDSP_vadd(temp1, 1, temp2, 1, &outImag, 1, length)
            

            newMatrix.imag = outImag
            newMatrix.real = outReal

    
        }else if lhs.complex{
            
            var outImag = newMatrix.imag!


            vDSP_vmul(rhs.real, 1, lhs.real, 1, &outReal, 1, length)
            vDSP_vmul(rhs.real, 1, lhs.imag!, 1, &outImag, 1, length)

            
            newMatrix.imag = outImag
            newMatrix.real = outReal

        }else if rhs.complex{
            
            var outImag = newMatrix.imag!

            
            vDSP_vmul(rhs.real, 1, lhs.real, 1, &outReal, 1, length)
            vDSP_vmul(rhs.imag!, 1, lhs.real, 1, &outImag, 1, length)

            
            newMatrix.imag = outImag
            newMatrix.real = outReal

            
        }else{
            vDSP_vmul(lhs.real, 1, rhs.real, 1, &outReal, 1, length)
            
            newMatrix.real = outReal

        }
        
        return newMatrix
        
    }else{
        return nil
    }
}

//MARK: - Testing and convenience


func complexMatricies(_ mat1:Matrix, _ mat2:Matrix)->Int{
    
    var numComplex = 0
    
    if mat1.complex{
        numComplex += 1
    }
    
    if mat2.complex{
        numComplex += 1
    }

    
    return numComplex
}


func validOutputMatrix(_ mat1:Matrix, _ mat2:Matrix,_ operation:String? = "element-wise")->Matrix?{
    
    var newMatrix:Matrix

    if operation == "element-wise" {
        guard mat1.sameSize(mat2)  else {
            
            print("Matrices are not the same size for element-wise calculation")
            return nil
        }
        
        if complexMatricies(mat1, mat2) > 0 {
            newMatrix = Matrix(mat1.rows, mat1.columns, "complex")
            
        }else{
            newMatrix = Matrix(mat1.rows, mat1.columns)
        }
        
    }else{
        
        if complexMatricies(mat1, mat2) > 0 {
            newMatrix = Matrix(mat1.columns, mat2.rows, "complex")
            
        }else{
            newMatrix = Matrix(mat1.columns, mat2.rows)
        }

        
    }

    return newMatrix
}






