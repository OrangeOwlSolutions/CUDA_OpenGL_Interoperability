#include "CUDA_Processing.cuh"
#include <stdio.h>
#include <stdlib.h>
#ifdef _WIN32
#define WINDOWS_LEAN_AND_MEAN
#define NOMINMAX
#include <windows.h>
#include <GL\glew.h>
#include <GL\freeglut.h>
#elif __linux__
#include <GL/glew.h>
#include <GL/freeglut.h>
#else // --- APPLE
#include <GLUT/glut.h>
#endif

#include <cuda_runtime.h>
#include <cuda_gl_interop.h>
#include "OpenGL_Keyboard_Mouse.h"

// texture and pixel objects
GLuint pbo = 0;     // OpenGL pixel buffer object
GLuint tex = 0;     // OpenGL texture object
struct cudaGraphicsResource *cuda_pbo_resource;

/*******************/
/* RENDER FUNCTION */
/*******************/
// --- Computes new pixel values launching the CUDA kernel
void render() {
	uchar4 *d_out = 0;
	cudaGraphicsMapResources(1, &cuda_pbo_resource, 0);
	cudaGraphicsResourceGetMappedPointer((void **)&d_out, NULL, cuda_pbo_resource);
	kernelLauncher(d_out, W, H, loc);
	cudaGraphicsUnmapResources(1, &cuda_pbo_resource, 0);
}

/************************/
/* DRAWTEXTURE FUNCTION */
/************************/
// --- Sets up a 2D OpenGL texture image, creates a single quadrangle graphics primitive with
//     texture coordinates (0.0f, 0.0f), (0.0f, 1.0f), (1.0f, 1.0f), and (1.0f, 0.0f); that is,
//     the corners of the unit square, corresponding with the pixel coordinates (0, 0), (0, H), (W, H),
//     and (W, 0).
void drawTexture() {
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, W, H, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
	glEnable(GL_TEXTURE_2D);
	glBegin(GL_QUADS);
	glTexCoord2f(0.0f, 0.0f); glVertex2f(0, 0);
	glTexCoord2f(0.0f, 1.0f); glVertex2f(0, H);
	glTexCoord2f(1.0f, 1.0f); glVertex2f(W, H);
	glTexCoord2f(1.0f, 0.0f); glVertex2f(W, 0);
	glEnd();
	glDisable(GL_TEXTURE_2D);
}

/********************/
/* DISPLAY FUNCTION */
/********************/
void display() {
	render();				// --- Computes new pixel values
	drawTexture();			// --- Draws the OpenGL texture
	glutSwapBuffers();	// --- Swap the read/write buffers
}

/********************************/
/* GLUT INITIALIZATION FUNCTION */
/********************************/
void initGLUT(int *argc, char **argv) {
	glutInit(argc, argv);
	glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE);
	glutInitWindowSize(W, H);
	glutCreateWindow(TITLE_STRING);
#ifndef __APPLE__
	glewInit();
#endif
}

/****************************/
/* INITPIXELBUFFER FUNCTION */
/****************************/
// --- Initializes the pixel buffer.
void initPixelBuffer() {
	glGenBuffers(1, &pbo);
	glBindBuffer(GL_PIXEL_UNPACK_BUFFER, pbo);
	glBufferData(GL_PIXEL_UNPACK_BUFFER, 4 * W*H*sizeof(GLubyte), 0,
		GL_STREAM_DRAW);
	glGenTextures(1, &tex);
	glBindTexture(GL_TEXTURE_2D, tex);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	// --- \u201cRegisters\u201d the OpenGL buffer with CUDA.
	cudaGraphicsGLRegisterBuffer(&cuda_pbo_resource, pbo, cudaGraphicsMapFlagsWriteDiscard);
}

/*****************/
/* EXIT FUNCTION */
/*****************/
// --- Undoes the resource registration and deletes the OpenGL pixel buffer and texture before zero is
//     returned to indicate completion of main().
void exitfunc() {
	if (pbo) {
		cudaGraphicsUnregisterResource(cuda_pbo_resource);
		glDeleteBuffers(1, &pbo);
		glDeleteTextures(1, &tex);
	}
}

/********/
/* MAIN */
/********/
int main(int argc, char** argv) {
	printInstructions();
	// --- Initializes the GLUT library and sets up the specifications for the graphics window,
	//     including the display mode (RGBA), the buffering (double), size (W x H), and title.
	initGLUT(&argc, argv);
	gluOrtho2D(0, W, H, 0);					// --- Establishes the viewing transform (simple orthographic projection)
	glutKeyboardFunc(keyboard);				// --- Keyboard interactions are specified by the function keyboard
	glutSpecialFunc(handleSpecialKeypress);	// --- Special keyboard interactions are specified by the function handleSpecialKeypress
	glutPassiveMotionFunc(mouseMove);			// --- Mouse move interactions are specified by the function mouseMove
	glutMotionFunc(mouseDrag);					// --- Mouse drag interactions are specified by the function mouseMove
	glutDisplayFunc(display);					// --- Says that what is to be shown in the window is determined by the function display
	initPixelBuffer();							// --- Initializes the pixel buffer
	glutMainLoop();							// --- Repeatedly checks for input and calls for computation of updated images
	atexit(exitfunc);							// --- Final clean up
	return 0;
}
