//
//  vertices.h
//  HelloArrow2
//
//  Created by Dan Carter on 2014-11-04.
//  Copyright (c) 2014 Dan Carter. All rights reserved.
//

#ifndef HelloArrow2_vertices_h
#define HelloArrow2_vertices_h

#import <OpenGLES/ES2/gl.h>

struct Vertex {
    float position[2];
    float color[4];
};

const struct Vertex vertices [];

const void * vertexPointer;
const void * colorPointer;

const GLfloat *orthoPointer;
const GLfloat *rotationPointer;

GLfloat ortho [];

GLfloat zRotation[];
    
#endif
