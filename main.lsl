// Script Created by Hailey Enfield
// Site: https://links.hails.cc
// Github: https://github.com/Hailey-Ross/hails.Smooth-Keyframe-Anim/
// PLEASE LEAVE ALL CREDITS/COMMENTS INTACT

//CONFIG
integer DEBUG = FALSE;

//Enter the Highest and lowest Z Coordinate you would like to move between.
float CONFIG_Z_1 = 27.5384; //Your Values HERE
float CONFIG_Z_2 = 31.0051; //Your Values HERE

float TIME_MIN = 8.0; //Float, use whole numbers
float TIME_MAX = 33.0; //Float, use whole numbers

float PAUSE_BOTTOM = 5.5; //Time spent waiting at Bottom
float PAUSE_TOP    = 10.5; //Time spent waiting at Top


// DO NOT TOUCH
integer LOOP_FOREVER = TRUE;
integer START_ON_REZ = TRUE;
integer TOUCH_TOGGLE = TRUE;

float gTopZ;
float gBottomZ;

float DOWN_TIME;
float UP_TIME;
float DOWN_TIME_MIN = TIME_MIN;
float DOWN_TIME_MAX = TIME_MAX;
float UP_TIME_MIN   = TIME_MIN;
float UP_TIME_MAX   = TIME_MAX;

list   gPath;
integer gRunning   = FALSE;
integer gInitDone  = FALSE;

initHeights()
{
    gTopZ    = CONFIG_Z_2;
    gBottomZ = CONFIG_Z_1;
}

snapToTop()
{
    vector pos = llGetPos();
    vector target = <pos.x, pos.y, gTopZ>;
    llSetRegionPos(target);
}

buildPath()
{
    rotation rot = llGetRot();
    float dz = gBottomZ - gTopZ;
    vector worldDown = <0.0, 0.0, dz>;
    vector localDown = worldDown / rot;
    vector localUp   = -localDown;

    list path = [];
    path += [localDown, DOWN_TIME];

    if (PAUSE_BOTTOM > 0.0)
        path += [ZERO_VECTOR, PAUSE_BOTTOM];

    path += [localUp, UP_TIME];

    if (PAUSE_TOP > 0.0)
        path += [ZERO_VECTOR, PAUSE_TOP];

    gPath = path;
}

startMotion()
{
    llSetKeyframedMotion([], []);
    gRunning = FALSE;

    initHeights();
    snapToTop();

    integer dMin = (integer)DOWN_TIME_MIN;
    integer dMax = (integer)DOWN_TIME_MAX;
    integer uMin = (integer)UP_TIME_MIN;
    integer uMax = (integer)UP_TIME_MAX;

    DOWN_TIME = (float)((integer)llFrand((float)(dMax - dMin + 1)) + dMin);
    UP_TIME   = (float)((integer)llFrand((float)(uMax - uMin + 1)) + uMin);

    float cycleTime = DOWN_TIME + UP_TIME;
    if (PAUSE_BOTTOM > 0.0) cycleTime += PAUSE_BOTTOM;
    if (PAUSE_TOP    > 0.0) cycleTime += PAUSE_TOP;

    if (DEBUG)
    {
        llOwnerSay("Down time = " + (string)((integer)DOWN_TIME));
        llOwnerSay("Up time   = " + (string)((integer)UP_TIME));
        llOwnerSay("Cycle time = " + (string)cycleTime);
    }

    buildPath();

    llSetKeyframedMotion(
        gPath,
        [KFM_DATA, KFM_TRANSLATION,
         KFM_MODE, KFM_FORWARD]
    );

    gRunning = TRUE;

    llSetTimerEvent(cycleTime + 0.1);
}

stopMotion()
{
    llSetKeyframedMotion([], []);
    llSetTimerEvent(0.0);
    gRunning = FALSE;
}

default
{
    state_entry()
    {
        llSetStatus(STATUS_PHYSICS, FALSE);
        llSetLinkPrimitiveParamsFast(
            LINK_THIS,
            [PRIM_PHYSICS_SHAPE_TYPE, PRIM_PHYSICS_SHAPE_CONVEX]
        );

        gInitDone = FALSE;
        llSetTimerEvent(0.5);
    }

    timer()
    {
        if (!gInitDone)
        {
            gInitDone = TRUE;
            llSetTimerEvent(0.0);

            if (START_ON_REZ)
                startMotion();

            return;
        }

        llSetTimerEvent(0.0);

        if (gRunning)
            gRunning = FALSE;

        if (LOOP_FOREVER)
            startMotion();
    }

    on_rez(integer start_param)
    {
        llResetScript();
    }

    touch_start(integer total_number)
    {
        if (!TOUCH_TOGGLE)
            return;

        if (llDetectedKey(0) != llGetOwner())
            return;

        if (gRunning)
            stopMotion();
        else
            startMotion();
    }
}
