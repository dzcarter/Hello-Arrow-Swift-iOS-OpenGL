//
//  vertices.m
//  HelloArrow2
//
//  Created by Dan Carter on 2014-11-04.
//  Copyright (c) 2014 Dan Carter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "vertices.h"

#define STRINGIFY(A) #A

const struct Vertex vertices [] =   {
    {{-0.5, -0.866}, {1, 1, 0.5f, 1}},
    {{0.5, -0.866}, {1, 1, 0.5f, 1}},
    {{0, 1}, {1, 1, 0.5f, 1}},
    {{-0.5, -0.866}, {0.5, 0.5, 0.5f, 1}},
    {{0.5, -0.866}, {0.5, 0.5, 0.5f, 1}},
    {{0, -0.4f}, {0.5, 0.5, 0.5f, 1}}};

const void * vertexPointer = &vertices[0].position[0];
const void * colorPointer = &vertices[0].color[0];

GLfloat ortho[] = {
    1.0/2.0, 0, 0, 0,
    0, 1.0/3.0, 0, 0,
    0, 0, -1, 0,
    0, 0, 0, 1
};

GLfloat zRotation[] = {
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1
};

const GLfloat *orthoPointer = &ortho[0];
const GLfloat *rotationPointer = &zRotation[0];