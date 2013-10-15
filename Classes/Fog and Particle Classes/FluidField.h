/*
 *  FluidField.h
 *  Fog
 *
 *  Created by Robert Bergkvist on 2010-11-03.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */
#pragma once
//#define GRID_COLUMNS 64
//#define FIELD_COLUMNS 66	// GRID_COUNT + 2
//#define GRID_SIZE 4096	// GRID_COUNT * GRID_COUNT
//#define FIELD_SIZE 4356		// FIELD_SIZE * FIELD_SIZE
//#define HALF_GRID_COLUMNS (0.5f/64.0f)
#include "ofxSimplex.h"
class FluidField {
public:
	FluidField();
	~FluidField();
	bool init();
	bool setGridSize(int w, int h);
	void setDensity(float density);
	void setDisplaySize(int w, int h);
	void setScrollDirection(float x, float y);
	void setNoiseScale(float sx, float sy);
	void setBorder(int border);
	void setLeftBorder(int border);
	void setTopBorder(int topborder);
	void setBottomBorder(int bottomborder);
	void setRightBorder(int border);
	void setSpawnArea(int start, int stop);
	void setTurbulence(float t);
	void setWindSpeed(float speed);
	void setForce(float newforce);
	void setViscosity(float viscosity);
	void clear();
	void update();
	void draw();
	void release();
	unsigned char* getData(float dt);
	void mouseDown(int x, int y);
	void mouseMove(int x, int y);
	void mouseUp(int x, int y);
	void add_source (float * x, float * s, float dt);
	void lin_solve (int b, float * x, float * x0, float a, float c );
	void diffuse (int b, float * x, float * x0, float diff, float dt );
	void advect (int b, float * d, float * d0, float * u, float * v, float dt );
	void project (float * u, float * v, float * p, float * div );
	void densityStep (float * x, float * x0, float * u, float * v, float diff, float dt );
	void velocityStep (float * u, float * v, float * u0, float * v0, float visc, float dt );
	void get_from_UI ( float * d, float * u, float * v );
	int getHeight();
	int getWidth();
	void setThickness(float thickness);
protected:
private:
	ofxSimplex *_noise;
	float _offsetX;
	int _topBorder;
	int _bottomBorder;
	int _leftBorder;
	int _rightBorder;
	
	float _topRamp;
	float _bottomRamp;
	float _leftRamp;
	float _rightRamp;
	
	int _gridColumns;
	int _gridRows;
	int _fieldColumns;
	int _fieldRows;
	int _gridSize;
	int _fieldSize;
	
	int _startSpawn;
	int _endSpawn;
	float _halfGridColumns;
	float _noiseScaleX;
	float _noiseScaleY;
	float _density;
	float _turbulence;
	
	float _scrollX;
	float _scrollY;
	
	float _noiseOffset;
	bool mouseIsDown;
	float dt, diff, visc;
	float force, source;
	int dvel;
	
	float * u, * v, * u_prev, * v_prev;
	float * dens, * dens_prev;
	unsigned char* data;
	int win_id;
	int win_x, win_y;
	int mouse_down[3];
	int omx, omy, mx, my;
	float timeElapsed;
	float frameTime;
	float thickness;
	
	void drawColumn(int index);
};