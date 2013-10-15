#import "FluidField.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define ALPHA_VALUE 255.0f
#define IX(i,j) ((i)+(_fieldColumns)*(j))
#define SWAP(x0,x) {float * tmp=x0;x0=x;x=tmp;}

typedef long freal; 
#define FPP 9 
#define X1_0 (1<<FPP) 
#define I2X(x) ((freal)((x)<<FPP)) 
#define F2X(x) ((freal)((x)*X1_0)) 
#define X2I(x) ((int)((x)>>FPP)) 
#define X2F(x) ((float)(x)/X1_0) 
#define XM(x,y) ((freal)(((x)*(y))>>FPP)) 
#define XD(x,y) ((freal)((((x))<<FPP)/(y)))

#define SAFE_DELETE(x) \
	if(x != NULL) { \
		delete x; \
		x = NULL; \
	}

FluidField::FluidField() {
	dt = 0.1f;
	diff = 0.0f;
	visc = 1.5f;
	force = 5.0f;
	source = 100.0f;	
	omx = mx = 0;
	omy = my = 0;	
	win_x = 1024; 
	win_y = 768;
	_topBorder = _bottomBorder = _leftBorder = _rightBorder = 0;
	_turbulence = 0.06f;
	_noiseScaleX = _noiseScaleY = 0.01f;
	_density = 2.5f;
	_offsetX = 0.0;
	timeElapsed=0;
	frameTime=30;
	thickness=0;
}

FluidField::~FluidField() {
	SAFE_DELETE(u);
	SAFE_DELETE(v);
	SAFE_DELETE(u_prev);
	SAFE_DELETE(v_prev);
	SAFE_DELETE(dens);
	SAFE_DELETE(dens_prev);
	SAFE_DELETE(data);
	SAFE_DELETE(_noise);
}

bool FluidField::init() {
	mouseIsDown = false;	
	_noise = new ofxSimplex;
	return true;	
}

void FluidField::release() {
	SAFE_DELETE(u);
	SAFE_DELETE(v);
	SAFE_DELETE(u_prev);
	SAFE_DELETE(v_prev);
	SAFE_DELETE(dens);
	SAFE_DELETE(dens_prev);
	SAFE_DELETE(data);
}

void FluidField::setDensity(float d) {
	_density = d;
}

void FluidField::setDisplaySize(int w, int h) {
	win_x = w;
	win_y = h;
}

void FluidField::setTurbulence(float t) {
	_turbulence = t;
}

void FluidField::setWindSpeed(float speed){
	frameTime=1.0/speed;
}

void FluidField::setForce(float newforce){
	force=newforce;
}

void FluidField::setViscosity(float viscosity){
	visc=viscosity;
}

bool FluidField::setGridSize(int w, int h) {
	if(_gridColumns != w || _gridRows != h) {
		_gridColumns = w;
		_gridRows = h;
		_gridSize = w * h;
	
		_topBorder=0;
		_bottomBorder=h;
		
		_fieldColumns = _gridColumns + 2;
		_fieldRows = _gridRows + 2;
		_fieldSize = _fieldColumns * _fieldRows;
		_halfGridColumns = 0.5f/(float)w;
		u = new float[_fieldSize];
		v = new float[_fieldSize];
		u_prev = new float[_fieldSize];
		v_prev = new float[_fieldSize];
		dens = new float[_fieldSize];
		dens_prev = new float[_fieldSize];
		data = new unsigned char[_gridSize << 2];
		_noise = new ofxSimplex;
		if ( !u || !v || !u_prev || !v_prev || !dens || !dens_prev ) {
			return false;
		}
	}
	return true;
}

void FluidField::clear() {
	int i;
	
	for ( i=0 ; i<_fieldSize ; i++ ) {
		u[i] = v[i] = u_prev[i] = v_prev[i] = 0.0f;
		dens_prev[i] = dens[i] = 0.0f;
	}
	
	int index = 0;
	
	_noiseOffset = -1;	
	
	for (int j=0;j<_fieldColumns-9;++j){
		index = j;
		drawColumn(index);	
	}
}

void FluidField::setSpawnArea(int start, int end) {
	_startSpawn = start;
	_endSpawn = end;
}

void FluidField::add_source (float * x, float* s, float dt)
{
	for (int i=0 ; i<_fieldSize; i++ )
		x[i] += dt*s[i];
}

void FluidField::setNoiseScale(float sx, float sy) {
	_noiseScaleX = sx;
	_noiseScaleY = sy;
}

void FluidField::lin_solve (int b, float * x, float * x0, float a, float c )
{
	int i, j;
	if(a > -0.0001f && a < 0.0001f) {
		int index = _fieldColumns;
		for (int i=1 ; i<=_gridRows ; i++ ) {
			for ( j=1 ; j<=_gridColumns;j++ ) {
				x[index] = x0[index];
				index++;
			}
			index+= 2;
		}
	} else if(a == 1) {
		int index = _fieldColumns;
		for ( i=1 ; i<=_gridRows ; i++ ) {
			for ( j=1 ; j<=_gridColumns; j++ ) {
				x[index] = (x0[index] + (x[index-1]+x[index+1]+x[index - _fieldColumns]+x[index + _fieldColumns]))/c;
				index++;
			}
			index+= 2;
		}
	}
}

void FluidField::diffuse (int b, float * x, float * x0, float diff, float dt )
{
	lin_solve (b,x,x0,0,1);
}

void FluidField::advect (int b, float * d, float * d0, float * u, float * v, float dt )
{
	int /*i, j,*/ i0, j0, i1, j1;
	float x, y, s0, t0, s1, t1, dt0;
	
	dt0 = dt*(float)_gridColumns;
	int index = _fieldColumns;
	
	for (int col=1 ; col<=_gridColumns ; col++ ) {
		index = _fieldColumns +col;
		for (int row=1 ; row<=_gridRows ; row++ ) {
			x = col-dt0*u[index]; 
			y = row-dt0*v[index];
	
			if (x<0.5f) x=0.5f;
			if (x>_gridColumns+0.5f) x=_gridColumns+0.5f; 
			
			i0=(int)x; 
			i1=i0+1;
		
			if (y<0.5f) y=0.5f;
			if (y>_gridRows+0.5f) 
				y=_gridRows+0.5f;
			
			j0=(int)y;
			j1=j0+1;
		
			s1 = x-i0;
			s0 = 1-s1;
			t1 = y-j0;
			t0 = 1-t1;
			d[index] = s0*(t0*d0[IX(i0,j0)]+t1*d0[IX(i0,j1)])+
					s1*(t0*d0[IX(i1,j0)]+t1*d0[IX(i1,j1)]);
			
			index += _fieldColumns;
		}
	}
}

void FluidField::setTopBorder(int border) {
	_topBorder = border;
	_topRamp = 1.0f/(float)border;
}

void FluidField::setLeftBorder(int border) {
	_leftBorder = border;
	_leftRamp = 1.0f/(float)border;
}

void FluidField::setRightBorder(int border) {
	_rightBorder = border;
	_rightRamp = 1.0f/(float)(_gridColumns-border);
}

void FluidField::setBottomBorder(int bottomborder){
	_bottomBorder=bottomborder;
	_bottomRamp=1.0f/(float)(_gridRows-bottomborder);
}

void FluidField::setBorder(int border) {
	_topBorder = _bottomBorder = _rightBorder = _leftBorder = border;
	_topRamp = _bottomRamp = _rightRamp = _leftRamp = 1.0f/(float)border;
}

unsigned char* FluidField::getData(float dt) {
	int destIndex = 0;
	int i,j;
	int index = _fieldColumns;
	
	unsigned int topDensity=250*thickness;
	unsigned int color=60*thickness;
	if (color>20) {
		color=20;
	}
	for ( i=1 ; i<=_gridRows ; i++ ) {
		for ( j=1 ; j<=_gridColumns ; j++ ) {
			float d = dens[index];
			if(d > 1.0f) d = 1.0f;
			
			unsigned int density = d*ALPHA_VALUE;
			
			if (density<topDensity) {
				density=topDensity;
			}
			
			if(i < _topBorder) density *= (_topRamp * (float)i);
			if(i > _bottomBorder) density *= (_bottomRamp * (float)(_gridRows-i));
			
			//if(j < _leftBorder) density *= (_leftRamp * (float)j);
			//if(j > _rightBorder) density *= (_rightRamp * (float)(_gridColumns - j));
			
			data[destIndex+3] = density;
			data[destIndex+1] = data[destIndex+2] = data[destIndex] = 1+(1-d)*color;
			
			destIndex+=4;
			index++;
		}
		index+=2;
	}

	timeElapsed+=dt;
	if (timeElapsed>=frameTime) {
		timeElapsed-=frameTime;
		memcpy(dens,dens+1,(_fieldSize - 1) * sizeof(float));
		
		index = _fieldColumns-10;	
		drawColumn(index);	
	}
	return data;
}

void FluidField::project (float * u, float * v, float * p, float * div )
{
	int i,j;
	int index = _fieldColumns+1;
	for (int row=1 ; row<=_gridRows ; row++ ) {
		for (int col=1 ; col<=_gridColumns ; col++ ) {
			div[index] = -_halfGridColumns*(u[index+1]-u[index-1]+v[index+_fieldColumns]-v[index-_fieldColumns]);
			p[index] = 0;
			index++;
		}
		index+=2;
	}
	
	lin_solve (  0, p, div, 1, 4 );
	
	index = _fieldColumns+1;
	for ( i=1 ; i<=_gridRows; i++ ) {
		for ( j=1 ; j<=_gridColumns ; j++ ) {
			u[index] -= 0.5f*_gridColumns*(p[index+1]-p[index-1]);
			v[index] -= 0.5f*_gridRows*(p[index+_fieldColumns]-p[index-_fieldColumns]);
			index++;
		}
		index+=2;
	}
}

void FluidField::get_from_UI ( float * d, float * u, float * v )
{
	for (int index=0 ; index<_fieldSize ; index++ ) {
		u[index] = v[index] = d[index] = 0.0f;
	}
	
	if (mouseIsDown) {
		int col = (int)((mx/(float)win_x)*_gridColumns+1);
		int row = (int)((my/(float)win_y)*_gridRows+1);
	
		if ( col>1 && col<_gridColumns && row>1 && row<_gridRows ) {
			u[IX(col,row)] = force * (mx-omx);
			v[IX(col,row)] = force * (omy-my);
			omx = mx;
			omy = my;
		}
	}
}

void FluidField::mouseDown(int x, int y) {
	mouseIsDown = true;

	omx = mx = x;
	omy = my = y;
}


void FluidField::mouseMove( int x, int y )
{
	mx = x;
	my = y;
}

void FluidField::mouseUp(int x, int y) {
	mouseIsDown = false;
	omx = mx = x;
	omy = my = y;
}

void FluidField::update() {
	get_from_UI ( dens_prev, u_prev, v_prev );
	/*u_prev[IX(50,20)] = -100.0f;
	v_prev[IX(50,20)] = -100.0f;	
	
	u_prev[IX(50,21)] = 100.0f;
	v_prev[IX(50,21)] = -100.0f;		
	
	u_prev[IX(51,21)] = 100.0f;
	v_prev[IX(51,21)] = 100.0f;

	u_prev[IX(51,20)] = -100.0f;
	v_prev[IX(51,20)] = 100.0f;	*/
	densityStep( dens, dens_prev, u, v, diff, dt );
	velocityStep( u, v, u_prev, v_prev, visc, dt);
}

void FluidField::densityStep (float * x, float * x0, float * u, float * v, float diff, float dt )
{
	add_source (  x, x0, dt );
	SWAP ( x0, x ); 
	diffuse (  0, x, x0, diff, dt );
	SWAP ( x0, x ); 
	advect (  0, x, x0, u, v, dt );
}

void FluidField::velocityStep (float * u, float * v, float * u0, float * v0, float visc, float dt )
{
	add_source (u,u0, dt );
	add_source (v,v0, dt );
	
	SWAP ( u0, u ); 
	diffuse (  1, u, u0, visc, dt );
	
	SWAP ( v0, v ); 
	diffuse (  2, v, v0, visc, dt );
	project (  u, v, u0, v0 );
	SWAP ( u0, u ); SWAP ( v0, v );
	advect (  1, u, u0, u0, v0, dt );
	advect (  2, v, v0, u0, v0, dt );
	project (  u, v, u0, v0 );
}

int FluidField::getHeight(){
	return win_y;
}

int FluidField::getWidth(){
	return win_x;
}

void FluidField::drawColumn(int index){
	for(int i = 0; i < _fieldRows; i++) {
		if(_startSpawn <= i && _endSpawn > i)
			dens[index] = _noise->noiseuf((float)_noiseOffset*_noiseScaleX,(float)i*_noiseScaleY,5.0f) * _density;		
		else
			dens[index] = 0.0;
		
		if(_offsetX > 1.0f) {
			if(i % 10 == 0)
				v[index] = (_noise->noiseuf((float)_noiseOffset,(float)i)-0.5)*_turbulence;		
		}
		index+= _fieldColumns;
	}
	_noiseOffset--;	
	if(_offsetX > 1.0f)
		_offsetX -= 1.0f;
	
	_offsetX += 0.1;
}

void FluidField::setThickness(float thickness){
	this->thickness=thickness;
}