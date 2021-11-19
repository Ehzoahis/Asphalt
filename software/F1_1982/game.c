#include <system.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>
#include <alt_types.h>
#include "game.h"

void gameInitGame(GameInfo* game)  
{
    float track_length = 0.0;
    for (int s = 0; s < N_TRACK_SEC; s++) {
        track_length += TrackSec[s].length;
    }
    game->fTrackDistance = track_length;
    game->fTrackCurvature = 0.0;
    game->fCurvature = 0.0;
    game->fDistance = 0.0;
    game->fSpeed = 1.0;
    game->fPlayerCurvature = 0.0;
    game->fCarPos = 0.0;
    game->fLapTime = 0.0;
    game->fFastestLapTime = 0.0;
}

void gameVGAScreenSaver()   
{   
    GameInfo* game = (GameInfo*) malloc(sizeof(GameInfo));
    gameInitGame(game);
    float fElapsedTime = 1.0 / 60.0;
    // clock_t before = clock ();
    while(1) {
        gameVAGScreenGenerater(fElapsedTime, game);
        // clock_t after = clock ();
        // fElapsedTime = (after - before) / CLOCKS_PER_SEC;
        // before = after;
    }
}

void gameVAGScreenGenerater(float fElapsedTime, GameInfo* game)
{   
    game->fDistance += (70.0 * game->fSpeed) * fElapsedTime;
    game->fLapTime += fElapsedTime;
	if (game->fDistance >= game->fTrackDistance)
    {
        game->fDistance -= game->fTrackDistance;
        if (game->fLapTime < game->fFastestLapTime || game->fFastestLapTime == 0.0) 
            game->fFastestLapTime = game->fLapTime;
        game->fLapTime = 0.0;
    }
    // Get Point on track
    float fOffset = 0;
    int nTrackSection = 0;

    while (nTrackSection < N_TRACK_SEC && fOffset <= game->fDistance)
    {			
        fOffset += TrackSec[nTrackSection].length;
        nTrackSection++;
    }

    float fTargetCurvature = TrackSec[nTrackSection - 1].curve;
	float fTrackCurveDiff = (fTargetCurvature - game->fCurvature) * fElapsedTime * game->fSpeed;

    game->fCurvature += fTrackCurveDiff;

    // Accumulate track curvature
    game->fTrackCurvature += (game->fCurvature) * fElapsedTime * game->fSpeed;

    for (int y = 0; y < WINDOW_H / 2; y++) {
        // Perspective is used to modify the width of the track row segments
        float fPerspective = (float)y / (WINDOW_H/2.0);
        float fRoadWidth = 0.1 + fPerspective * 0.8; // Min 10% Max 90%
        float fClipWidth = fRoadWidth * 0.15;
        fRoadWidth *= 0.5;	// Halve it as track is symmetrical around center of track, but offset...

        // ...depending on where the middle point is, which is defined by the current
        // track curvature.
        float fMiddlePoint = 0.5 + game->fCurvature * powf((1.0 - fPerspective), 3);

        // Work out segment boundaries
        int nLeftGrass = MAX((fMiddlePoint - fRoadWidth - fClipWidth) * WINDOW_W, 0);
        int nLeftClip = MAX((fMiddlePoint - fRoadWidth) * WINDOW_W, 0);
        int nRightClip = (fMiddlePoint + fRoadWidth) * WINDOW_W;
        int nRightGrass = (fMiddlePoint + fRoadWidth + fClipWidth) * WINDOW_W;
        
        // int nRow = WINDOW_H / 2;

        // // Using periodic oscillatory functions to give lines, where the phase is controlled
        // // by the distance around the track. These take some fine tuning to give the right "feel"
        // int nGrassColour = sinf(20.0 *  powf(1.0 - fPerspective,3) + fDistance * 0.1f) > 0.0f ? FG_GREEN : FG_DARK_GREEN;
        char nClipColour = sinf(80.0 *  powf(1.0 - fPerspective, 2) + game->fDistance) > 0.0 ? 1 : 0;
        
        // // Start finish straight changes the road colour to inform the player lap is reset
        // int nRoadColour = (nTrackSection-1) == 0 ? FG_WHITE : FG_GREY;
        
        vga_ctrl -> VRAM[y] = nClipColour << 31 | nLeftGrass << 10 | nLeftClip;
        vga_ctrl -> VRAM[y + WINDOW_H / 2] =  nClipColour << 31 | nRightClip << 10 | nRightGrass;
    }
}
