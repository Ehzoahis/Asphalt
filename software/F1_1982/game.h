#ifndef GAME_MODE_VGA_COLOR_H_
#define GAME_MODE_VGA_COLOR_H_

#define WINDOW_W 640
#define WINDOW_H 480
#define N_TRACK_SEC 10
#define MAX(a,b) (((a)>(b))?(a):(b))

#include <system.h>
#include <alt_types.h>

struct GAME_VGA_STRUCT {
	alt_u32 VRAM [WINDOW_H]; 
};

struct TRACK {
    float curve;
    float length;
};

struct COLOR{
	char name [20];
	alt_u8 red;
	alt_u8 green;
	alt_u8 blue;
};

typedef struct gameInfo{
    float fTrackDistance;
    float fTrackCurvature;
    float fCurvature;
    float fDistance;
    float fSpeed;
    float fPlayerCurvature;
    float fCarPos;
    float fLapTime;
    float fFastestLapTime;
} GameInfo;


//you may have to change this line depending on your platform designer
static volatile struct GAME_VGA_STRUCT* vga_ctrl = VGA_GAME_MODE_CONTROLLER_0_BASE;

//CGA colors with names
static struct COLOR colors[]={
    {"black",          0x0, 0x0, 0x0},
	{"blue",           0x0, 0x0, 0xa},
    {"green",          0x0, 0xa, 0x0},
	{"cyan",           0x0, 0xa, 0xa},
    {"red",            0xa, 0x0, 0x0},
	{"magenta",        0xa, 0x0, 0xa},
    {"brown",          0xa, 0x5, 0x0},
	{"light gray",     0xa, 0xa, 0xa},
    {"dark gray",      0x5, 0x5, 0x5},
	{"light blue",     0x5, 0x5, 0xf},
    {"light green",    0x5, 0xf, 0x5},
	{"light cyan",     0x5, 0xf, 0xf},
    {"light red",      0xf, 0x5, 0x5},
	{"light magenta",  0xf, 0x5, 0xf},
    {"yellow",         0xf, 0xf, 0x5},
	{"white",          0xf, 0xf, 0xf}
};

static struct TRACK TrackSec[N_TRACK_SEC] = {
    {0.0,   10.0},
    {0.0,   200.0},
    {0.2,   200.0},
    {0.0,   400.0},
    {-1.0,  100.0},
    {0.0,   200.0},
    {1.0,   200.0},
    {0.0,   200.0},
    {0.2,   500.0},
    {0.0,   100.0}
};

void gameVGAColorClr();
void gameVGADrawColorGAME(char* str, int x, int y, alt_u8 background, alt_u8 foreground);
void setColorPalette (alt_u8 color, alt_u8 red, alt_u8 green, alt_u8 blue); //Fill in this code


void gameInitGame(GameInfo* game);
void gameVAGScreenGenerater(float fElapsedTime, GameInfo* game);
void gameVGAScreenSaver(); //Call this for your demo

#endif /* GAME_MODE_VGA_COLOR_H_ */
