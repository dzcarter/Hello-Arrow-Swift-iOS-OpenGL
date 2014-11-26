//
//  GLView.swift
//  HelloArrowSwift
//
//  Created by Dan Carter on 2014-10-20.
//  Copyright (c) 2014 Dan Carter. All rights reserved.
//

import UIKit
import OpenGLES
class GLView: UIView {
    var context : EAGLContext!
    let renderingEngine : RenderingEngine
    var timestamp : Double
    
    let api = EAGLRenderingAPI.OpenGLES2
    
    
    override init(frame: CGRect) {
        //Create and configure context
        self.context = EAGLContext(API: api)
        
        if(self.context? == nil) {
            println("Context failed to initialize")
            exit(1)
        }
        
        if(EAGLContext.setCurrentContext(context) == false)
        {
            println("Failed to set current context")
            exit(1)
        }
        
        self.renderingEngine = RenderingEngine(width: GLsizei(frame.width), height: GLsizei(frame.height), api: api)
        
        self.timestamp = CACurrentMediaTime() as Double
        
        super.init(frame: frame)
        
        // configure layer
        let layer = self.layer as CAEAGLLayer
        layer.opaque = true
        
        self.context.renderbufferStorage(Int(GL_RENDERBUFFER_OES), fromDrawable: layer)
        
        self.drawView()
        
        let displayLink = CADisplayLink(target: self, selector: "drawView:")
        displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override class func layerClass() -> AnyClass {
        return CAEAGLLayer.self
    }
    
    
    func drawView(displayLink : CADisplayLink) {
        let elapsedSeconds = displayLink.timestamp - self.timestamp
        self.timestamp = displayLink.timestamp
        self.renderingEngine.updateAnimationWithTimeStep(Float(elapsedSeconds))
        
        self.drawView()
    }
    
    
    func drawView() {
        self.renderingEngine.render()
        self.context.presentRenderbuffer(Int(GL_RENDERBUFFER_OES))
    }
    
    
    func updateForNewOrientation(orientation: UIDeviceOrientation, animated: Bool) {
        self.renderingEngine.updateForNewOrientation(orientation, animated: animated)
    }
    
    
    deinit {
        EAGLContext.setCurrentContext(nil)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
