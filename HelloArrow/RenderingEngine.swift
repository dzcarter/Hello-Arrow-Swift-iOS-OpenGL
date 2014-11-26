//
//  RenderingEngine.swift
//  HelloArrow2
//
//  Created by Dan Carter on 2014-10-27.
//  Copyright (c) 2014 Dan Carter. All rights reserved.
//

import UIKit


class RenderingEngine: NSObject {
    // MARK: - Properties
    let api: EAGLRenderingAPI
    
    var renderbuffer: GLuint = 0
    var framebuffer: GLuint = 0
    var program: GLuint = 0
    
    let vertexBuffer: [GLfloat] = [
        -0.5, -0.866,
        0.5, -0.866,
        0, 1,
        -0.5, -0.866,
        0.5, -0.866,
        0, -0.4]
    
    let colorBuffer: [GLfloat] = [
        1, 1, 0.5, 1,
        1, 1, 0.5, 1,
        1, 1, 0.5, 1,
        0.5, 0.5, 0.5, 1,
        0.5, 0.5, 0.5,1,
        0.5, 0.5, 0.5, 1]
    
    var currentAngle: Float = 0
    var desiredAngle: Float = 0
    let rotationSpeed: Float = 450 // degree/sec
    
    //MARK: - Common
    
    init(width: GLsizei, height: GLsizei, api: EAGLRenderingAPI) {
        self.api = api
        
        super.init()
        
        switch(self.api) {
        case .OpenGLES1:
            self.setup1(width: width, height: height)
        case .OpenGLES2:
            setup2(width: width, height: height)
        case .OpenGLES3:
            println("Hello world")
        }
    }
    
    
    func render() {
        switch(self.api) {
        case .OpenGLES1:
            self.render1()
        case .OpenGLES2:
            self.render2()
        case .OpenGLES3:
            println()
        }
    }
    
    func rotationDirection() -> Float {
        let angleDelta = self.desiredAngle - self.currentAngle
        
        if(angleDelta == 0) { return 0 }
        
        if((angleDelta > 0 && angleDelta <= 180)
            || (angleDelta <= -180)) { return +1 }
        else { return -1 }
    }
    
    func updateAnimationWithTimeStep(timeStep : Float) {
        let directionSign = self.rotationDirection()
        
        if(directionSign == 0) { return }
        
        let angleIncrement = self.rotationSpeed * timeStep
        
        self.currentAngle += directionSign * angleIncrement
        
        // Adjust angle if went outside of range [0,360]
        if(self.currentAngle < 0) {
            self.currentAngle += 360 }
        
        if(self.currentAngle > 360) {
            self.currentAngle -= 360 }
        
        if(directionSign != self.rotationDirection()) {
            self.currentAngle = self.desiredAngle }
        
        self.render()
    }
    
    
    func updateForNewOrientation(orientation : UIDeviceOrientation, animated : Bool = false) {
        switch(orientation) {
        case .Portrait:
            self.desiredAngle = 0
        case .LandscapeLeft:
            self.desiredAngle = 270
        case .LandscapeRight:
            self.desiredAngle = 90
        case .PortraitUpsideDown:
            self.desiredAngle = 180
            //        case .FaceDown:
            //        case .FaceDown:
        default:
            println()
        }
        
        if(animated == false) {
            self.currentAngle = self.desiredAngle
            println("Setting both desired and current angle to \(self.currentAngle)")
        }
    }
    
    //MARK: - ES 1.1
    
    func setup1(#width: GLsizei, height: GLsizei) {
        glGenRenderbuffersOES(1, &self.renderbuffer)
        glBindRenderbufferOES(
            GLenum(GL_RENDERBUFFER_OES),
            self.renderbuffer)
        
        glGenFramebuffersOES(1, &self.framebuffer)
        glBindFramebufferOES(
            GLenum(GL_FRAMEBUFFER_OES),
            self.framebuffer)
        
        glFramebufferRenderbufferOES(
            GLenum(GL_FRAMEBUFFER_OES),
            GLenum(GL_COLOR_ATTACHMENT0_OES),
            GLenum(GL_RENDERBUFFER_OES),
            self.renderbuffer)
        
        glViewport(
            0,
            0,
            width,
            height)
        
        glMatrixMode(GLenum(GL_PROJECTION))
        
        let maxX: GLfloat = 2
        let maxY: GLfloat = 3
        glOrthof(-maxX, maxX, -maxY, maxY, -1, 1)
        
        glMatrixMode(GLenum(GL_MODELVIEW))
        
        
    }
    
    func render1() {
        glClearColor(
            GLfloat(0.4),
            GLfloat(0.4),
            GLfloat(0.9),
            GLfloat(1.0))
        
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        glPushMatrix()
        glRotatef(GLfloat(self.currentAngle), 0, 0, 1)
        
        glEnableClientState(GLenum(GL_VERTEX_ARRAY))
        glEnableClientState(GLenum(GL_COLOR_ARRAY))
        
        glVertexPointer(
            2,
            GLenum(GL_FLOAT),
            0,
            self.vertexBuffer)
        
        glColorPointer(
            4,
            GLenum(GL_FLOAT),
            0,
            self.colorBuffer)
        
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 6)
        
        glDisableClientState(GLenum(GL_VERTEX_ARRAY))
        glDisableClientState(GLenum(GL_COLOR_ARRAY))
        
        glPopMatrix()
    }
    
    //MARK: - ES2.0
    
    func setup2(#width: GLsizei, height: GLsizei) {
        glGenRenderbuffers(1, &self.renderbuffer)
        glBindRenderbuffer(
            GLenum(GL_RENDERBUFFER),
            self.renderbuffer)
        
        glGenFramebuffers(1, &self.framebuffer)
        glBindFramebuffer(
            GLenum(GL_FRAMEBUFFER),
            self.framebuffer)
        
        glFramebufferRenderbuffer(
            GLenum(GL_FRAMEBUFFER),
            GLenum(GL_COLOR_ATTACHMENT0),
            GLenum(GL_RENDERBUFFER),
            self.renderbuffer)
        
        glViewport(0, 0, width, height)
        
        self.program = buildProgram()
        
        glUseProgram(self.program)
        
        applyOrtho(2, maxY:3)
    }
    
    func buildProgram() -> GLuint {
        let vertexShaderSourcePath = NSBundle.mainBundle().pathForResource("SimpleVertex", ofType: "glsl")
        let vertexShaderSource = String(contentsOfFile: vertexShaderSourcePath!, encoding: NSUTF8StringEncoding, error: nil)
        
        let fragmentShaderSourcePath = NSBundle.mainBundle().pathForResource("SimpleFragment", ofType: "glsl")
        let fragmentShaderSource = String(contentsOfFile: fragmentShaderSourcePath!, encoding: NSUTF8StringEncoding, error: nil)

        
        let vertexShader = buildShader(
            vertexShaderSource!,
            type: GLenum(GL_VERTEX_SHADER))
        let fragmentShader = buildShader(
            fragmentShaderSource!,
            type: GLenum(GL_FRAGMENT_SHADER))
        
        let programHandle = glCreateProgram()
        glAttachShader(programHandle, vertexShader)
        glAttachShader(programHandle, fragmentShader)
        glLinkProgram(programHandle)
        
        var linkSuccess: GLint = 0
        glGetProgramiv(programHandle, GLenum(GL_LINK_STATUS), &linkSuccess)
        
        if(linkSuccess == GL_FALSE) {
            let stringBuffer: UnsafeMutablePointer<GLchar> = UnsafeMutablePointer<GLchar>(malloc(UInt(sizeof(UInt8)) * 256))

            print("Got an error with program linking: \(stringBuffer)")
            free(stringBuffer)
            exit(1)
        }
        
        return programHandle
    }
    
    func buildShader(source: String, type: GLenum) -> GLuint {
        let shaderHandle = glCreateShader(type)
        var cStringSource = (source as NSString).UTF8String
        let stringfromutf8string = String.fromCString(cStringSource)
        glShaderSource(shaderHandle, 1, &cStringSource, nil)
        glCompileShader(shaderHandle)

        var compileSuccess: GLint = 0
        glGetShaderiv(shaderHandle, GLenum(GL_COMPILE_STATUS), &compileSuccess)
        if(compileSuccess == GL_FALSE) {
            var stringBuffer: UnsafeMutablePointer<GLchar> = UnsafeMutablePointer<GLchar>(malloc(UInt(sizeof(UInt8)) * 256))
            glGetShaderInfoLog(shaderHandle, 256, nil, stringBuffer)
            let errorLog = String.fromCString(stringBuffer)!
            println("Error compiling shader: \(errorLog)")
            free(stringBuffer)
            exit(1)
        }
        return shaderHandle
    }
    
    func applyOrtho(maxX: Float, maxY: Float) {
        let a = 1/maxX
        let b = 1 / maxY
        var swiftOrtho: [GLfloat] = [
            a, 0,  0, 0,
            0, b,  0, 0,
            0, 0, -1, 0,
            0, 0,  0, 1]
        
        let projectionUniform = glGetUniformLocation(self.program, "Projection")
        glUniformMatrix4fv(projectionUniform, 1, GLboolean(0), swiftOrtho)
        
    }
    
    func applyRotation(degrees: Float) {
        let radians = degrees * 3.14159 / 180
        let s = sin(radians)
        let c = cos(radians)
        let swiftZRotation: [GLfloat] = [
         c, s, 0, 0,
        -s, c, 0, 0,
         0, 0, 1, 0,
         0, 0, 0, 1]
        
        let modelviewUniform = glGetUniformLocation(self.program, "Modelview")
        glUniformMatrix4fv(modelviewUniform, 1, GLboolean(0), swiftZRotation)
    }
    
    func render2() {
        glClearColor(0.5, 0.5, 0.5, 1)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        applyRotation(self.currentAngle)
        
        let positionSlot = GLuint(glGetAttribLocation(self.program, "Position"))
        let colorSlot = GLuint(glGetAttribLocation(self.program, "SourceColor"))
        
        glEnableVertexAttribArray(positionSlot)
        glEnableVertexAttribArray(colorSlot)
        
        glVertexAttribPointer(positionSlot, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, self.vertexBuffer)

        glVertexAttribPointer(colorSlot, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, self.colorBuffer)
        
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 6)
        
        glDisableVertexAttribArray(positionSlot)
        glDisableVertexAttribArray(colorSlot)
    }
    
    
}



