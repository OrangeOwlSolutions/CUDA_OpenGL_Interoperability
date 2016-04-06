#ifndef INTERACTIONS_H
#define INTERACTIONS_H
#define W 600					// --- Image width
#define H 600					// --- Image height
#define DELTA 5 				// --- Pixel increment for arrow keys
#define TITLE_STRING "flashlight: distance image display app"
int2 loc = {W/2, H/2};			// --- Initial reference location at {W/2, H/2}, the center of the image.
bool dragMode = false; // mouse tracking mode

/**********************************/
/* KEYBOARD INTERACTIONS FUNCTION */
/**********************************/
void keyboard(unsigned char key, int x, int y) {
	if (key == 'a') dragMode = !dragMode; // --- Pressing a toggles between tracking mouse motions and
										  //     tracking mouse drags (with the mouse button pressed),
	if (key == 27)  exit(0);			  // --- The ASCII code 27 corresponds to the Esc key. Pressing Esc 
										  //     closes the graphics window.
	glutPostRedisplay();				  // --- glutPostRedisplay() is called at the end of each callback
										  //     function telling to compute a new image for display
	                                      //     (by calling the display function) based on the interactive
	                                      //     input
}

/******************************************/
/* SPECIAL KEYBOARD INTERACTIONS FUNCTION */
/******************************************/
// --- Specifies the response to special keys with defined actions (arrow keys)
//     Sepressing the arrow keys moves the reference location DELTA pixels in the desired direction.
void handleSpecialKeypress(int key, int x, int y) {
	if (key == GLUT_KEY_LEFT)  loc.x -= DELTA;
	if (key == GLUT_KEY_RIGHT) loc.x += DELTA;
	if (key == GLUT_KEY_UP)    loc.y -= DELTA;
	if (key == GLUT_KEY_DOWN)  loc.y += DELTA;
	glutPostRedisplay();
}

/************************************/
/* MOUSE MOVE INTERACTIONS FUNCTION */
/************************************/
void mouseMove(int x, int y) {
	if (dragMode) return;				  // --- When dragMode is true, no action is taken
	loc.x = x;							  // --- When dragMode is false, the components of the reference
	                                      //     location are set to be equal to the x and y coordinates of the
	                                      //     mouse before computing and displaying an updated image
	                                      //     (via glutPostRedisplay()).
	loc.y = y;
	glutPostRedisplay();				  // --- See keyboard function
}

/************************************/
/* MOUSE DRAG INTERACTIONS FUNCTION */
/************************************/
void mouseDrag(int x, int y) {
	if (!dragMode) return;				  // --- When dragMode is false, no action is taken
	loc.x = x;							  // --- When dragMode is true, the reference location is reset to
										  //     the last location of the mouse while the mouse was clicked
	loc.y = y;
	glutPostRedisplay();				  // --- See keyboard function
}

/******************************/
/* PRINTINSTRUCTIONS FUNCTION */
/******************************/
// --- Prints instructions through the console
void printInstructions() {
  printf("flashlight interactions\n");
  printf("a: toggle mouse tracking mode\n");
  printf("arrow keys: move ref location\n");
  printf("esc: close graphics window\n");
}

#endif
