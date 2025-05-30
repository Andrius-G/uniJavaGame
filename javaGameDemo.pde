/**
Autorius: Andrius Gasiukevičius
**/
import processing.core.PApplet;
import processing.core.PApplet;
import processing.core.PImage;
import processing.sound.*;
import javax.swing.*;
import javax.swing.filechooser.*;
import java.awt.*;
import java.util.*;

public class javaGameDemo extends PApplet 
{
  boolean developingMode = true; //determines where custom levels are saved
  public int SCALE = 1;
  class Time {
    long t;
    long dt;
    Time()
    {
      t=0;
    }
    float deltaTime()
    {
      return (float)dt/1000;
    }
    void advanceTime()
    {
      dt = millis()-t;
      t  = millis();
    }
  }
  class counter {
    int max;
    int t;
    counter(int mx)
    {
      max=mx;
    }
    void inc()
    {
      t++;
      if(t>=max)
      {
        t=0;
      }
    }
  }
  String path;
  
  PImage img;
  PImage temp;
  PImage[] images;
  PImage[] player_anims;
  PImage[] player_anims_left;
  
  JSONObject levelData;
  
  SoundFile music;
  SoundFile editorOST;
  SoundFile sfx_Jump, sfx_Land, sfx_Attack;
  
  counter[] anim_counts;
  counter[] anim_counts_left;
  counter animate_fps;
  counter sleep_timer;
  int animationState=0;
  int animationStates=4;
  int framesPerState=4;
  //0 - static
  //1 - jumping
  //2 - walking
  //3 - sleepy / ^^
  
  int[] animatedTiles=
  {
     0,  0,  0,  0,  0,  0, 12, 12, 12,  5,  0,  0,  0,  0,  0,  0, 
     0,  0,  0,  0,  0,  0,  4,  4,  4,  4,  0,  0,  0,  0,  0,  0, 
     0,  0,  0,  0,  0,  0,  0,  0,  0,  4,  0,  0,  0,  0,  0,  0, 
    
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 
    
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 
    
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 
    
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 
     
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
  }; //number of frames
  PImage[][] tileAnimations;
  counter[] currentTileFrame;
  
  int cols = 16;
  int rows = 16;
  
  int tileW;
  int tileH;
  
  ////////////////////////////////////////////////////////////////////////////////////////
  ////////////////              EDITOR VARIABLES                         ////#variables///
  ////////////////////////////////////////////////////////////////////////////////////////
  
  PImage editorBackground;
  PImage editorUI;
  PImage editorUI2;
  PImage editorUICursor;
  
  boolean switchingToEditor = false;
  boolean editor = false;
  
  boolean changingTool = false;
  
  int selectedTileId=0;
  boolean hasSelectedTile = false;
  boolean hasSelectedPlayer = false;
  
  int oldBrushX = -1;
  int oldBrushY = -1;
  int customBoardOffsetX = 0;
  int customBoardOffsetY = 0;
  float customPlayerX = 192;
  float customPlayerY = 192;
  String customLevelMusic = "01_Grasslands.wav";
  String nextLevelAfterCustomLevel = "";
  
  boolean wantToSave = false;
  boolean wantToLoad = false;
  boolean wantToMusic = false;
  boolean wantToLink = false;
  
  int[][][] customMap;
  JSONObject customLevelJSON;
  
  ////////////////////////////////////////////////////////////////////////////////////////
  ////////////////                    ESSENTIALS                         /////#variables//
  ////////////////////////////////////////////////////////////////////////////////////////
  
  boolean asleep;
  int[] tileTypes = 
  {
    01, 01, 01, 01, 01, 01, 03, 03, 03, 00, 02, 02, 00, 00, 00, 99,
    01, 01, 01, 01, 01, 01, 03, 03, 03, 00, 02, 02, 02, 02, 02, 99,
    01, 01, 01, 01, 01, 01, 03, 03, 03, 00, 02, 02, 00, 00, 00, 99,
    
    01, 01, 01, 01, 01, 01, 00, 00, 00, 00, 00, 00, 01, 01, 01, 01,
    01, 01, 01, 01, 01, 01, 00, 00, 00, 00, 01, 01, 01, 01, 01, 01,
    01, 01, 01, 01, 01, 01, 00, 00, 00, 00, 00, 00, 99, 99, 99, 99,
    
    01, 01, 01, 02, 02, 02, 00, 00, 00, 99, 99, 99, 99, 99, 99, 99,
    01, 01, 01, 02, 02, 02, 00, 00, 00, 99, 99, 99, 99, 99, 99, 99,
    01, 01, 01, 02, 02, 02, 00, 00, 04, 99, 99, 99, 99, 99, 99, 99,
    
    01, 01, 01, 00, 00, 00, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99,
    01, 01, 01, 00, 00, 00, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99,
    01, 01, 01, 00, 00, 00, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99,
    
    00, 00, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99,
    00, 06, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99,
    
    99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 00, 00, 00, 00,
     9,  9,  9,  9, 99, 99, 99, 99, 99, 99, 99, 99, 04, 05, 00, 00
  };
  // 00 - transparent
  // 01 - solid
  // 02 - semisolid
  // 03 - liquid
  // 04 - death barrier
  // 05 - goal
  // 06 - portal
  // 07 - climbable semisolid
  //  8 - climbable wall
  //  9 - small square center hurtbox
  // 10 - 
  // 99 - unassigned
  
  Time GameTime;
  
  int selectedTool = 0;
    // 0 - grab/place
    // 1 - brush
    // 2 - select
    // 3 - erase
    // 4 - blank
    // 5 - save
    // 6 - load
    // 7 - erase all
    
  int[][][] map;
  
  //////////////////////////////////////////////////////////////////////////////////////////
  
  float globalGravity = 10f;
  float fluidImpactCoefficient = 0.1f; // 0<c<1
  
  boolean isSolid(float locationX, float locationY, boolean ignoreSemisolids)
  {
    int lx = floor(floor(locationX)/(16*SCALE));
    int ly = floor(floor(locationY)/(16*SCALE));
    if((lx < 0 || ly < 0) || (ly >= map.length || lx >= map[0].length))
    {
      return false;
    }
    for(int i = 0; i < map[ly][lx].length; i++)
    {
        if(tileTypes[map[ly][lx][i]] == 1 || 
           tileTypes[map[ly][lx][i]] == 2) 
          {
            // 1 -- solid
            // 2 -- semisolid
            if((tileTypes[map[ly][lx][i]] == 2 ) && (ignoreSemisolids == true))
            {
              continue;
            }
            return true;
          }
    }
    return false;
  }
  
  //////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////          VVVVVV       GameOBJECT          VVVVVV       /////////#GameObject////
  //////////////////////////////////////////////////////////////////////////////////////////////////
  class GameObject
  {
    boolean hasImage = false;
    boolean hasHitbox = false;
    int gravityDirection = 0;
    
    boolean isJumping = false;
    boolean wantsToJump = false;
    int jumpsLeft = 1;
    int maxJumps = 1;
    boolean last_walked_left = false;
    
    boolean in_motion = false;
    boolean isUnderwater = false;
    boolean decreasedBuoyancy = false;
    
    PImage GOImage;
    
    float x;
    float y;
    
    float terminalVelocityH;
    float terminalVelocityV;
    float terminalLiquidVelocityH;
    float terminalLiquidVelocityV;
    
    float vx;
    float vy;
    
    float accelerationH;
    float decelerationH;
    
    float ox;
    float oy;
    
    float hx1;
    float hy1;
    float hx2;
    float hy2;
    
    GameObject(float X, float Y)
    {
      this.setPosition(X,Y);
      this.setVelocity(0,0);
      this.setAcceleration(0,0);
      this.setOrigin(X+(8*SCALE),Y+(8*SCALE));
    }
    
    void setPosition(float tx, float ty)
    {
      x=tx;
      y=ty;
    }
    
    void setSpeed(float vel)
    {
      terminalVelocityV = 3*vel;
      terminalVelocityH = 2*vel;
      terminalLiquidVelocityV = 0.4*terminalVelocityV;
      terminalLiquidVelocityH = 0.4*terminalVelocityV;
    }
    
    void configureJump(int jNow, int jMax)
    {
      jumpsLeft = jNow;
      maxJumps = jMax;
    }
    
    void setAcceleration (float acc, float deac)
    {
      accelerationH = acc;
      decelerationH = deac;
    }
    
    void setVelocity(float vx1, float vy1)
    {
      if(!isUnderwater)
      {
        if(abs(vx1)<=abs(terminalVelocityH))vx=vx1;
        if(abs(vy1)<=abs(terminalVelocityV))vy=vy1;
      }
      else
      {
        if(abs(vx1)<=abs(terminalLiquidVelocityH))vx=vx1;
        if(abs(vy1)<=abs(terminalLiquidVelocityV))vy=vy1;
      }
    }
    
    private void addVelocity(float dx, float dy)
    {
      if(!isUnderwater)
      {
        if(abs(vx+dx)<=abs(terminalVelocityH))vx+=dx;
        if(abs(vy+dy)<=abs(terminalVelocityV))vy+=dy;
      }
      else
      {
        if(abs(vx+dx)<=abs(terminalLiquidVelocityH))vx+=dx;
        if(abs(vy+dy)<=abs(terminalLiquidVelocityV))vy+=dy;
      }
    }
    
    void addRigidbody()
    {
      gravityDirection=1;
    }
    
    void setImage(PImage img)
    {
      hasImage = true;
      GOImage = img;
    }
    
    void setOrigin(float ox1, float oy1)
    {
      ox=ox1;
      oy=oy1;
    }
    
    void setHitbox(float HX1, float HY1, float HX2, float HY2)
    {
       hasHitbox = true;
       hx1=HX1;
       hy1=HY1;
       hx2=HX2;
       hy2=HY2;
    }
    
    void setSquareHitbox(float radius)
    {
      setHitbox(ox-radius,oy-radius,ox+radius,oy+radius);
    }
    
    private void jump()
    {
        isJumping=true;
        if(jumpsLeft > 0)
        {
          jumpsLeft--;
          if(!isUnderwater)
          {
            addVelocity(0, -4f);
          }
          else
          {
            addVelocity(0, -0.5f);
          }
        }
    }
    
    boolean isGrounded(float dispX, float dispY) 
    {
       return isSolid(ox+dispX, hy2+dispY, false);
    }
    
    boolean underCeiling(float dispX, float dispY)
    {
      return isSolid(ox+dispX, hy1+dispY, true);
    }
    
    boolean facingSolid(float dispX, float dispY)
    {
        if(last_walked_left == true)
        {
          return isSolid(hx1+dispX, oy+dispY, true);
        }
        else
        {
          return isSolid(hx2+dispX, oy+dispY, true);
        }
    }
    private boolean Collide(float locationX, float locationY, int tileTypeID)
    {
      int lx = floor(floor(locationX)/(16*SCALE));
      int ly = floor(floor(locationY)/(16*SCALE));
      if((lx < 0 || ly < 0) || (ly >= map.length || lx >= map[ly].length))
      {
        return false;
      }
      for(int i = 0; i < map[ly][lx].length; i++)
      {
          if(tileTypes[map[ly][lx][i]] == tileTypeID)
          {
            return true;
          }
      }
      return false;
    }
    private void applyGravity()
    {
      addVelocity(0, (globalGravity * gravityDirection * GameTime.deltaTime()));
    }
    private void applyBuoyancy()
    {
      if(decreasedBuoyancy == false)
      {
        addVelocity(0, (-0.96*globalGravity * gravityDirection * GameTime.deltaTime()));
      }
      else
      {
        addVelocity(0, (-0.92*globalGravity * gravityDirection * GameTime.deltaTime()));
      }
    }
    //private void applyFriction(float Mu)
    //{
    //  
    //}
    private void resolveForces()
    {
      if(isGrounded(0,0) == true)
      {
        addVelocity(0,-vy);
        jumpsLeft=maxJumps;
      }
      else
      {
        applyGravity();
      }
      if(Collide(hx1,hy1,3)||Collide(hx2,hy2,3))
      {
        if(isUnderwater==false)
        {
          isUnderwater = true;
          vy*=fluidImpactCoefficient;
          vx*=fluidImpactCoefficient;
        }
        applyBuoyancy();
        jumpsLeft=maxJumps;
      }
      else
      {
        isUnderwater = false;
      }
      if(wantsToJump)
      {
        if(isJumping == false)
        {
          jump();
        }
      }
      if(in_motion)
      {
          if(last_walked_left == false)
          {
            addVelocity(accelerationH * GameTime.deltaTime(), 0);
          }
          else 
          {
            addVelocity(-accelerationH * GameTime.deltaTime(), 0);
          }
      }
      else
      {
        if(vx>0)
        {
          vx = max(vx - (decelerationH * GameTime.deltaTime()), 0);
        }
        else if(vx<0)
        {
          vx = min(vx + (decelerationH * GameTime.deltaTime()), 0);
        }
      }
    }
    
    private void resolveCollisions()
    {
      if(underCeiling(vx,vy))
      {
        System.out.println("Bump");
        addVelocity(0,-vy);
      }
      if(facingSolid(vx,vy))
      {
        addVelocity(-vx,0);
      }
      if(Collide(hx1,hy1,4)||Collide(hx2,hy2,4))
      {
        loadLevel(levelData.getString("thisLevel"),true);
      }
      if(Collide(hx1,hy1,5)||Collide(hx2,hy2,5))
      {
        System.out.println("HERE");
        loadLevel(levelData.getString("nextLevel"),false);
      }
    }
    
    private void Advance()
    {
      resolveForces();
      //if(in_motion)
      //{
        resolveCollisions();
      //}
      x += vx;
      y += vy;
      ox += vx;
      oy += vy;
      hx1 += vx;
      hy1 += vy;
      hx2 += vx;
      hy2 += vy;
    }
  }
  //////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////          ^^^^^^       GameOBJECT          ^^^^^^       /////////#GameObject////
  //////////////////////////////////////////////////////////////////////////////////////////////////
  
  //////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////          VVVVVV         CAMERA            VVVVVV       /////////#camera////////
  //////////////////////////////////////////////////////////////////////////////////////////////////
  class Camera
  {
    GameObject focus;
    
    float ox=160;
    float oy=160;
    
    int cameraLength = 320;
    int cameraHeight = 320;
    
    int cameraActiveLength = 180;
    int cameraActiveHeight = 180;
    
    Camera(int cl, int ch, int cal, int cah, int OX, int OY, GameObject pov)
    {
      cameraLength = cl;
      cameraHeight = ch;
      cameraActiveLength = cal;
      cameraActiveHeight = cah;
      ox=OX;
      oy=OY;
      ShiftFocus(pov);
    }
    void Translate()
    {
      float dx = 0;
      float dy = 0;
      if(abs(focus.ox-this.ox)>cameraActiveLength/2)
      {
        if(focus.ox-this.ox > 0)
        {
          dx += (-(focus.ox - this.ox - (cameraActiveLength/2)));
        }
        else
        {
          dx += (this.ox - (cameraActiveLength/2) - focus.ox);
        }
        ox-=dx;
      }
      if(abs(focus.oy-this.oy)>cameraActiveHeight/2)
      {
        if(focus.oy-this.oy > 0)
        {
          dy += (-(focus.oy - this.oy - (cameraActiveHeight/2)));
        }
        else
        {
          dy += (this.oy - (cameraActiveHeight/2) - focus.oy);
        }
        oy-=dy;
      }
      translate(-ox+(cameraLength/2),-oy+(cameraHeight/2));
    }
    void ShiftFocus(GameObject focusObject)
    {
        focus = focusObject;
        ox = focus.ox;
        oy = focus.oy;
    }
  }
  //////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////          ^^^^^^         CAMERA            ^^^^^^       //////////#camera///////
  //////////////////////////////////////////////////////////////////////////////////////////////////
  
  GameObject Player;
  Camera camcam;
  
  public void settings()
  {
    size(320*SCALE, 320*SCALE);
  }
  /*public void resizePoint(int newX, int newY)
  {
    return;
  }*/
  //////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////          VVVVVV         SETUP             VVVVVV       //#start//#setup////////
  //////////////////////////////////////////////////////////////////////////////////////////////////
  public void setup()
  {
    path = System.getProperty("user.dir").replace("\\","/");
    path += "/javaGameDemo/";
    levelData = loadJSONObject(path+"Assets/Levels/L1.json");
    
    Player = new GameObject(SCALE*levelData.getFloat("playerX"),SCALE*levelData.getFloat("playerY"));
    Player.setSquareHitbox(6*SCALE);
    
    Player.configureJump(levelData.getInt("jumpsLeft"),levelData.getInt("maxJumps"));
    Player.last_walked_left = levelData.getBoolean("lastWalkedLeft");
    
    Player.setVelocity(0,0);
    Player.setAcceleration(50f,50f); 
    Player.setSpeed(3f);
    Player.addRigidbody();
    
    camcam = new Camera(320,320,180,180,160,160,Player);
    
    JSONArray jsonRows = levelData.getJSONArray("levelTiles");
    map = new int[jsonRows.size()][][];
    
    for(int i=0; i<jsonRows.size(); i++)
    {
      JSONArray jsonCells = jsonRows.getJSONArray(i);
      map[i] = new int[jsonCells.size()][];
      for(int j=0; j<jsonCells.size(); j++)
      {
        JSONArray jsonCellTiles = jsonCells.getJSONArray(j);
        map[i][j] = new int[jsonCellTiles.size()];
        for(int k=0; k<jsonCellTiles.size(); k++)
        {
          map[i][j][k]=jsonCellTiles.getInt(k);
        }
      }
    }
    
    music = new SoundFile(this, path+"Assets/Music/"+levelData.getString("backgroundMusic"));
    editorOST = new SoundFile(this, path+"Assets/Music/"+"02_Level Editor.wav");
    music.loop();
    
    GameTime = new Time();
    
    editorBackground = loadImage(path+"Assets/Textures/UI/editor_ui_background.png");
    editorUI = loadImage(path+"Assets/Textures/UI/editor_ui.png");
    editorUI2 = loadImage(path+"Assets/Textures/UI/editor_ui_2.png");
    editorUICursor = loadImage(path+"Assets/Textures/UI/selectedTool.png");
    
    img = loadImage(path+"Assets/Textures/Tilemap/tilemap.png");
    
    //resizePoint(cols*16*SCALE,rows*16*SCALE);
    tileW = img.width / cols;
    tileH = img.height / rows;
    
    images = new PImage[cols * rows];
    
    player_anims = new PImage[animationStates * framesPerState];
    player_anims_left = new PImage[animationStates * framesPerState];
    anim_counts = new counter[4];
    anim_counts_left = new counter[4];
    
    sleep_timer = new counter(60);
    asleep = false;
    
    for(int i=0; i<animationStates; i++)
    {
      anim_counts[i] = new counter(framesPerState);
      anim_counts_left[i] = new counter(framesPerState);
    }
    for(int j = 0; j < rows; j++)
    {
      for(int i = 0; i < cols; i++)
      {
        images[i + j * cols] = img.get(i * tileW, j * tileH, tileW, tileH);
      }
    }
    
    animate_fps = new counter(20);
    
    customMap = new int[1000][1000][0];
    
    temp = loadImage(path+"Assets/Textures/Player/player.png");
    //resizePoint(framesPerState*16*SCALE,animationStates*16*SCALE);
    for(int j = 0; j < animationStates; j++)
    {
      for(int i = 0; i < framesPerState; i++)
      {
        player_anims[i + j * framesPerState] = temp.get(i * tileW, j * tileH, tileW, tileH);
      }
    }
    
    temp = loadImage(path+"Assets/Textures/Player/player_left.png");
    //resizePoint(framesPerState*16*SCALE,animationStates*16*SCALE);
    for(int j = 0; j < animationStates; j++)
    {
      for(int i = 0; i < framesPerState; i++)
      {
        player_anims_left[i + j * framesPerState] = temp.get(i * tileW, j * tileH, tileW, tileH);
      }
    }
    
    /////////////// Animated Tiles Setup ////////////////////
    tileAnimations = new PImage[cols*rows][];
    currentTileFrame = new counter[cols*rows];
    for(int i=0; i < cols * rows; ++i)
    {
      if(animatedTiles[i]>0)
      {
        currentTileFrame[i] = new counter(animatedTiles[i]);
        tileAnimations[i] = new PImage[animatedTiles[i]];
        for(int j=0; j < animatedTiles[i]; ++j)
        {
          tileAnimations[i][j] = loadImage(path+"Assets/Textures/Animated Tiles/"+str(i)+"/"+str(j)+".png");
        }
      }
    }
    /////////////////////////////////////////////////////////
    
    System.out.println("Test");
  }
  //////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////          ^^^^^^         SETUP             ^^^^^^       ///#start//#setup///////
  //////////////////////////////////////////////////////////////////////////////////////////////////
  
  //////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////          VVVVVV         DRAW              VVVVVV       ////#update//#draw//////
  //////////////////////////////////////////////////////////////////////////////////////////////////
  
  public void draw()
  {
    background(125, 175, 225);
    if(editor)
    {
      drawEditor();
    }
    else
    {
      drawGame();
    }
  }
  
  public void loadLevel(String name, boolean loadSameLevel)
  {
    System.out.println(name);
    levelData = loadJSONObject(path+name);
    
    Player = new GameObject(SCALE*levelData.getFloat("playerX"),SCALE*levelData.getFloat("playerY"));
    Player.setSquareHitbox(6*SCALE);
    
    Player.configureJump(levelData.getInt("jumpsLeft"),levelData.getInt("maxJumps"));
    Player.last_walked_left = levelData.getBoolean("lastWalkedLeft");
    
    Player.setVelocity(0,0);
    Player.setAcceleration(50f,50f); 
    Player.setSpeed(3f);
    Player.addRigidbody();
    
    camcam = new Camera(320,320,180,180,160,160,Player);
    
    JSONArray jsonRows = levelData.getJSONArray("levelTiles");
    map = new int[jsonRows.size()][][];
    
    for(int i=0; i<jsonRows.size(); i++)
    {
      JSONArray jsonCells = jsonRows.getJSONArray(i);
      map[i] = new int[jsonCells.size()][];
      for(int j=0; j<jsonCells.size(); j++)
      {
        JSONArray jsonCellTiles = jsonCells.getJSONArray(j);
        map[i][j] = new int[jsonCellTiles.size()];
        for(int k=0; k<jsonCellTiles.size(); k++)
        {
          map[i][j][k]=jsonCellTiles.getInt(k);
        }
      }
    }
    if(loadSameLevel == false)
    {
      music.stop();
      music = new SoundFile(this, path+"Assets/Music/"+levelData.getString("backgroundMusic"));
      //editorOST = new SoundFile(this, path+"Assets/Music/"+"02_Level Editor.wav");
      music.loop();
    }
    
    GameTime = new Time();
  }
  
  //////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////          ^^^^^^         DRAW              ^^^^^^       ////#update///#draw/////
  //////////////////////////////////////////////////////////////////////////////////////////////////
  
  //////////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////       VVVVV     LEVEL EDITOR         VVVVVVV           /////#editor/////////////
  //////////////////////////////////////////////////////////////////////////////////////////////////
  private void drawEditor()
  {
    translate(customBoardOffsetX*tileW,customBoardOffsetY*tileH);
    
    grid(17,0,517,500);
    drawCustomMap(); //layers - selected tile is more important than existing map and UI, while UI is above map
    
    image(player_anims[0], customPlayerX+(17*tileW), customPlayerY, 16, 16); //layers -- player is the most important
    
    //////////// Static UI Elements /////////////////////
    image(editorBackground, -customBoardOffsetX*tileW, -customBoardOffsetY*tileH);
    image(img, -customBoardOffsetX*tileW, -customBoardOffsetY*tileH);
    image(editorUI,(4*tileW)-(customBoardOffsetX*tileW),(17*tileH)-(customBoardOffsetY*tileH),tileW*8,tileH);
    image(editorUI2,(4*tileW)-(customBoardOffsetX*tileW),(18*tileH)+4-(customBoardOffsetY*tileH),tileW*8,tileH);
    grid(-customBoardOffsetX,-customBoardOffsetY,-customBoardOffsetX+16,-customBoardOffsetY+16);
    //////////////////////////////////////////////////////
    
    //////////// Click on Tool to Select /////////////////
    if(changingTool==false&&mousePressed&&((mouseX>=(4*tileW)&&mouseX<12*tileW)&&(mouseY>=(17*tileH)&&mouseY<(19*tileH)+(tileH/4))))
    {
      changingTool=true;
      if(17*tileH<=mouseY&&mouseY<18*tileH)
      {
        selectedTool=(mouseX/tileW) - 4;
        hasSelectedTile=false;
        hasSelectedPlayer = false;
        oldBrushX=-1;
        oldBrushY=-1;
      }
      else if((18*tileH)+(tileH/4)<=mouseY&&mouseY<(19*tileH)+(tileH/4))
      {
        selectedTool=(mouseX/tileW) - 4 + 8;
        hasSelectedTile=false;
        hasSelectedPlayer = false;
        oldBrushX=-1;
        oldBrushY=-1;
      }
    }
    if(changingTool==true)
    {
      if(!mousePressed)changingTool = false;
      else return;
    }
    //////////////////////////////////////////////////////
    
    if(selectedTool == 0)             ///////// GRAB TOOL //////////////
    {
      image(editorUICursor, (4 * tileW)-1 - (customBoardOffsetX*tileW),(17*tileH)-1 - (customBoardOffsetY*tileH),tileW+2,tileH+2);
      if(mousePressed&&!hasSelectedTile)
      {
        int x = mouseX / tileW;
        int y = mouseY / tileH;
        if((x>=0&&x<=15) && (y>=0&&y<=15))
        {
            hasSelectedTile=true;
            selectedTileId=x+y*cols;
            image(images[x+(y*cols)], mouseX - (tileW/2) - (customBoardOffsetX*tileW), mouseY - (tileH/2) - (customBoardOffsetY*tileH), 16, 16);
        }
      }
      if(!mousePressed&&hasSelectedTile) // mouse released
      {
          int x = (mouseX / tileW) - 17 - customBoardOffsetX;
          int y = (mouseY / tileH) - customBoardOffsetY;
          hasSelectedTile=false;
          if((x>=0&&y>=0)&&(mouseX>=17*tileW))
          {
            int[] customMapListTemp = customMap[y][x];
            customMap[y][x] = new int[customMap[y][x].length + 1];
            for(int i=0; i<customMap[y][x].length - 1; i++)
            {
                customMap[y][x][i] = customMapListTemp[i];
            }
            customMap[y][x][customMap[y][x].length-1]=selectedTileId;
          }
      }
      if(mousePressed&&hasSelectedTile)
      {
          image(images[selectedTileId], mouseX - (tileW/2) - (customBoardOffsetX*tileW), mouseY - (tileH/2) - (customBoardOffsetY*tileH), 16, 16);
      }
    }
    else if(selectedTool == 1)  ///////// BRUSH //////////////
    {
      image(editorUICursor, (5 * tileW)-1 - (customBoardOffsetX*tileW),(17*tileH)-1 - (customBoardOffsetY*tileH),tileW+2,tileH+2);
      if(mousePressed&&!hasSelectedTile)
      {
        int x = mouseX / tileW;
        int y = mouseY / tileH;
        if((x>=0&&x<=15) && (y>=0&&y<=15))
        {
            hasSelectedTile=true;
            selectedTileId=x+y*cols;
            image(images[x+(y*cols)], mouseX - (tileW/2) - (customBoardOffsetX*tileW), mouseY - (tileH/2) - (customBoardOffsetY*tileH), 16, 16);
        }
      }
      if(mousePressed&&hasSelectedTile)
      {
          image(images[selectedTileId], mouseX - (tileW/2) - (customBoardOffsetX*tileW), mouseY - (tileH/2) - (customBoardOffsetY*tileH), 16, 16);
          int x = (mouseX / tileW) - 17 - customBoardOffsetX;
          int y = (mouseY / tileH) - customBoardOffsetY;
          if((x>=0&&y>=0)&&!(x==oldBrushX&&y==oldBrushY)&&(mouseX>=17*tileW)) //brush fill a new tile
          {
            oldBrushX=x;
            oldBrushY=y;
            int[] customMapListTemp = customMap[y][x];
            customMap[y][x] = new int[customMap[y][x].length + 1];
            for(int i=0; i<customMap[y][x].length - 1; i++)
            {
                customMap[y][x][i] = customMapListTemp[i];
            }
            customMap[y][x][customMap[y][x].length-1]=selectedTileId;
          }
          else if((y+customBoardOffsetY<=15 && y+customBoardOffsetY>=0) && (x+customBoardOffsetX >= -17 && x+customBoardOffsetX < -1)) //change tiles (pipette)
          {
            x+=17;
            x+=customBoardOffsetX;
            y+=customBoardOffsetY;
            
            oldBrushX=-1;
            oldBrushY=-1;
            
            selectedTileId=x+y*cols;
            image(images[x+(y*cols)], mouseX - (tileW/2) - (customBoardOffsetX*tileW), mouseY - (tileH/2) - (customBoardOffsetY*tileH), 16, 16);
          }
      }
      if(!mousePressed&&hasSelectedTile)
      {
        image(images[selectedTileId], mouseX - (tileW/2) - (customBoardOffsetX*tileW), mouseY - (tileH/2) - (customBoardOffsetY*tileH), 16, 16);
      }
    }
    else if(selectedTool == 2) ///////// ERASER //////////////
    {
      //erase tile
      image(editorUICursor, (6 * tileW)-1 - (customBoardOffsetX*tileW),(17*tileH)-1 - (customBoardOffsetY*tileH),tileW+2,tileH+2);
      if(mousePressed)
      {
          int x = (mouseX / tileW) - 17 - customBoardOffsetX;
          int y = (mouseY / tileH) - customBoardOffsetY;
          if((x>=0&&y>=0)&&(mouseX>=17*tileW))
          {
            customMap[y][x] = new int[0];
          }
      }
    }
    else if(selectedTool == 3) ///////// SELECT TOOL //////////////
    {
      image(editorUICursor, (7 * tileW)-1 - (customBoardOffsetX*tileW),(17*tileH)-1 - (customBoardOffsetY*tileH),tileW+2,tileH+2);
      //select tool -- unfinished, wouldn't really be useful atm
    }
    else if(selectedTool == 4)  ///////// MOVE TOOL //////////////
    {
      image(editorUICursor, (8 * tileW)-1 - (customBoardOffsetX*tileW),(17*tileH)-1 - (customBoardOffsetY*tileH),tileW+2,tileH+2);
    }
    else if(selectedTool == 5) ///////// PLAYER POS //////////////
    {
      image(editorUICursor, (9 * tileW)-1 - (customBoardOffsetX*tileW),(17*tileH)-1 - (customBoardOffsetY*tileH),tileW+2,tileH+2);
      //set player pos
      if(mousePressed&&!hasSelectedPlayer)
      {
            hasSelectedPlayer = true;
            image(player_anims[0], mouseX - (tileW/2) - (customBoardOffsetX*tileW), mouseY - (tileH/2) - (customBoardOffsetY*tileH), 16, 16);
      }
      if(!mousePressed&&hasSelectedPlayer) // mouse released
      {
          int x = mouseX - (17*tileW) - (customBoardOffsetX*tileW);
          int y = mouseY - (customBoardOffsetY*tileH);
          hasSelectedPlayer=false;
          if((x>=0&&y>=0)&&(mouseX>=17*tileW))
          {
            customPlayerX = x;
            customPlayerY = y;
          }
      }
      if(mousePressed&&hasSelectedPlayer)
      {
          image(player_anims[0], mouseX - (tileW/2) - (customBoardOffsetX*tileW), mouseY - (tileH/2) - (customBoardOffsetY*tileH), 16, 16);
      }
    }
    else if(selectedTool == 6) ///////// SAVE LEVEL //////////////
    {
      //save
      image(editorUICursor, (10 * tileW)-1 - (customBoardOffsetX*tileW),(17*tileH)-1 - (customBoardOffsetY*tileH),tileW+2,tileH+2);
      if(mousePressed)
      {
        wantToSave = true;
      }
      if(!mousePressed && wantToSave) // mouse released
      {
        JFileChooser chooseFile = new JFileChooser();
        File currentDirectory;
        if(developingMode==true)
        {
          currentDirectory = new File(path+"Assets/Levels");
        }
        else
        {
          currentDirectory = new File(path+"Custom Levels");
        }
        chooseFile.setCurrentDirectory(currentDirectory);
        chooseFile.setDialogTitle("Save Level");
        chooseFile.setFileFilter(new FileFilter() {
          
          public String getDescription()
          {
            return "JSON Source File (*.json)";
          }
          public boolean accept(File thisFile)
          {
            if(thisFile.isDirectory())
            {
              return true;
            }
            else
            {
              String filename = thisFile.getName().toLowerCase();
              return filename.endsWith(".json");
            }
          }
        });
        chooseFile.setCurrentDirectory(currentDirectory);
        int returnValue = chooseFile.showOpenDialog(null);
        if(returnValue == JFileChooser.APPROVE_OPTION)
        {
          File selectedFile = chooseFile.getSelectedFile();
          fileSelected(selectedFile);
        }
        else
        {
          fileSelected(null);
        }
        //selectInput("Choose where you want to save your level: ", "fileSelected");
      }
    }
    else if(selectedTool == 7) ///////// LOAD LEVEL //////////////
    {
      //load
      image(editorUICursor, (11 * tileW)-1 - (customBoardOffsetX*tileW),(17*tileH)-1 - (customBoardOffsetY*tileH),tileW+2,tileH+2);
      if(mousePressed)
      {
        wantToLoad = true;
      }
      if(!mousePressed && wantToLoad) // mouse released
      {
        JFileChooser chooseFile = new JFileChooser();
        File currentDirectory;
        if(developingMode==true)
        {
          currentDirectory = new File(path+"Assets/Levels");
        }
        else
        {
          currentDirectory = new File(path+"Custom Levels");
        }
        chooseFile.setCurrentDirectory(currentDirectory);
        chooseFile.setDialogTitle("Load Level");
        chooseFile.setFileFilter(new FileFilter() {
          
          public String getDescription()
          {
            return "JSON Source File (*.json)";
          }
          public boolean accept(File thisFile)
          {
            if(thisFile.isDirectory())
            {
              return true;
            }
            else
            {
              String filename = thisFile.getName().toLowerCase();
              return filename.endsWith(".json");
            }
          }
        });
        int returnValue = chooseFile.showOpenDialog(null);
        if(returnValue == JFileChooser.APPROVE_OPTION)
        {
          File selectedFile = chooseFile.getSelectedFile();
          fileSelected(selectedFile);
        }
        else
        {
          fileSelected(null);
        }
        //selectInput("Select the level you want to load: ", "fileSelected");
      }
    }
    else if(selectedTool == 8)    ///////// MUSIC TOOL //////////////
    {
      //choose music
      image(editorUICursor, (4 * tileW)-1 - (customBoardOffsetX*tileW),(17*tileH)-1+20 - (customBoardOffsetY*tileH),tileW+2,tileH+2);
      if(mousePressed)
      {
        wantToMusic = true;
      }
      if(!mousePressed && wantToMusic) //mouse released
      {
        JFileChooser chooseMusic = new JFileChooser();
        File currentDirectory = new File(path+"Assets/Music");
        chooseMusic.setCurrentDirectory(currentDirectory);
        chooseMusic.setDialogTitle("Select Music for Level");
        chooseMusic.setFileFilter(new FileFilter() {
          
          public String getDescription()
          {
            return "Music file (*.wav, *.mp3)";
          }
          public boolean accept(File thisFile)
          {
            if(thisFile.isDirectory())
            {
              return true;
            }
            else
            {
              String filename = thisFile.getName().toLowerCase();
              return filename.endsWith(".wav")||filename.endsWith(".mp3");
            }
          }
        });
        int returnValue = chooseMusic.showOpenDialog(null);
        if(returnValue == JFileChooser.APPROVE_OPTION)
        {
          File selectedFile = chooseMusic.getSelectedFile();
          fileSelected(selectedFile);
        }
        else
        {
          fileSelected(null);
        }
      }
    }
    else if(selectedTool == 9)    ///////// LINKER TOOL //////////////
    {
      //link levels
      image(editorUICursor, (5 * tileW)-1 - (customBoardOffsetX*tileW),(17*tileH)-1+20 - (customBoardOffsetY*tileH),tileW+2,tileH+2);
      if(mousePressed)
      {
        wantToLink = true;
      }
      if(!mousePressed && wantToLink)
      {
        JFileChooser chooseFile = new JFileChooser();
        File currentDirectory;
        if(developingMode==true)
        {
          currentDirectory = new File(path+"Assets/Levels");
        }
        else
        {
          currentDirectory = new File(path+"Custom Levels");
        }
        chooseFile.setCurrentDirectory(currentDirectory);
        chooseFile.setDialogTitle("Select the SUCCESSOR of the current level");
        chooseFile.setFileFilter(new FileFilter() {
          
          public String getDescription()
          {
            return "JSON Source File (*.json)";
          }
          public boolean accept(File thisFile)
          {
            if(thisFile.isDirectory())
            {
              return true;
            }
            else
            {
              String filename = thisFile.getName().toLowerCase();
              return filename.endsWith(".json");
            }
          }
        });
        int returnValue = chooseFile.showOpenDialog(null);
        if(returnValue == JFileChooser.APPROVE_OPTION)
        {
          File selectedFile = chooseFile.getSelectedFile();
          fileSelected(selectedFile);
        }
        else
        {
          fileSelected(null);
        }
      }
    }
    else if(selectedTool == 10)
    {
      image(editorUICursor, (6 * tileW)-1 - (customBoardOffsetX*tileW),(17*tileH)-1+20 - (customBoardOffsetY*tileH),tileW+2,tileH+2);
    }
    else if(selectedTool == 11)
    {
      image(editorUICursor, (7 * tileW)-1 - (customBoardOffsetX*tileW),(17*tileH)-1+20 - (customBoardOffsetY*tileH),tileW+2,tileH+2);
    }
    else if(selectedTool == 12)
    {
      image(editorUICursor, (8 * tileW)-1 - (customBoardOffsetX*tileW),(17*tileH)-1+20 - (customBoardOffsetY*tileH),tileW+2,tileH+2);
    }
    else if(selectedTool == 13)
    {
      image(editorUICursor, (9 * tileW)-1 - (customBoardOffsetX*tileW),(17*tileH)-1+20 - (customBoardOffsetY*tileH),tileW+2,tileH+2);
    }
    else if(selectedTool == 14)
    {
      image(editorUICursor, (10 * tileW)-1 - (customBoardOffsetX*tileW),(17*tileH)-1+20 - (customBoardOffsetY*tileH),tileW+2,tileH+2);
    }
    else if(selectedTool == 15)  ///////// ERASE ALL TILES //////////////
    {
      //erase all
      image(editorUICursor, (11 * tileW)-1 - (customBoardOffsetX*tileW),(17*tileH)-1+20 - (customBoardOffsetY*tileH),tileW+2,tileH+2);
      if(mousePressed)
      {
         customMap = new int[1000][1000][0];
      }
    }
  }
  //////////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////     ^^^^^^^^     LEVEL EDITOR        ^^^^^             ////////#editor//////////
  //////////////////////////////////////////////////////////////////////////////////////////////////
  
  //////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////          VVVVVV     EDITOR FUNCTIONS      VVVVVV       ///////#editor//////////
  //////////////////////////////////////////////////////////////////////////////////////////////////
  void grid(int xi, int yi, int xf, int yf)
  {
    noFill();
    for(int j = yi; j < yf; j++)
    {
      for(int i = xi; i < xf; i++)
      {
        rect(i * tileW, j * tileH, tileW, tileH);
      }
    }
  }
  private void drawCustomMap()
  {
    for(int i = 0; i < customMap.length; i++)
    {
      for(int j = 0; j < customMap[i].length; j++)
      {
        for(int k=0; k<customMap[i][j].length; k++)
        {
          image(images[customMap[i][j][k]], (j+17) * tileH, i * tileW, tileW, tileH);
        }
      }
    }
  }
  void fileSelected(File selection)
  {
      if(wantToSave)
      {
        customLevelJSON = new JSONObject();
        customLevelJSON.put("jumpsLeft", 1);
        customLevelJSON.put("maxJumps", 1);
        
        customLevelJSON.put("lastWalkedLeft", false);
        
        customLevelJSON.put("playerX", customPlayerX);
        customLevelJSON.put("playerY", customPlayerY);
        
        customLevelJSON.put("backgroundMusic",customLevelMusic);
        
        String levelName;
        if(selection != null)levelName = selection.getAbsolutePath();
        else 
        {
          System.out.println("Saving level as 'Custom Levels/my_level.json'");
          selection = new File("Custom Levels/my_level.json");
          levelName = "my_level.json";
        }
        
        if(!levelName.endsWith(".json"))
        {
          levelName += ".json";
          selection = new File(levelName);
        }
        levelName = selection.getName();
        
        if(developingMode == true)levelName = "Assets/Levels/" + levelName;
        else levelName = "Custom Levels/" + levelName;
        
        if(nextLevelAfterCustomLevel.equals(""))
        {
          nextLevelAfterCustomLevel=levelName;
        }
        
        customLevelJSON.put("thisLevel", levelName);
        customLevelJSON.put("nextLevel", nextLevelAfterCustomLevel);
        
        customLevelJSON.put("levelTiles",customMap);
        
        saveJSONObject(customLevelJSON, selection.getAbsolutePath());
        
        System.out.println("Saved to " + levelName);
        
        wantToSave = false;
      }
      else if(wantToLoad)
      {
        wantToLoad = false;
        if(selection != null)
        {
          customLevelJSON = loadJSONObject(selection.getAbsolutePath());
        }
        else
        {
          //customLevelJSON = loadJSONObject(path + "Assets/Levels/L1.json");
          System.out.println("Could not load level");
          return;
        }
        Player.configureJump(customLevelJSON.getInt("jumpsLeft"),customLevelJSON.getInt("maxJumps"));
        
        customPlayerX = customLevelJSON.getFloat("playerX");
        customPlayerY = customLevelJSON.getFloat("playerY");
        
        nextLevelAfterCustomLevel = customLevelJSON.getString("nextLevel");
        
        music = new SoundFile(this, path+"Assets/Music/"+customLevelJSON.getString("backgroundMusic"));
        //music.loop();
        
        JSONArray jsonRows = customLevelJSON.getJSONArray("levelTiles");
        customMap = new int[jsonRows.size()][][];
        
        for(int i=0; i<jsonRows.size(); i++)
        {
          JSONArray jsonCells = jsonRows.getJSONArray(i);
          customMap[i] = new int[jsonCells.size()][];
          for(int j=0; j<jsonCells.size(); j++)
          {
            JSONArray jsonCellTiles = jsonCells.getJSONArray(j);
            customMap[i][j] = new int[jsonCellTiles.size()];
            for(int k=0; k<jsonCellTiles.size(); k++)
            {
              customMap[i][j][k]=jsonCellTiles.getInt(k);
            }
          }
        }
      }
      else if(wantToMusic)
      {
        wantToMusic = false;
        if(selection != null)
        {
          customLevelMusic = selection.getName();
          System.out.println("Music track changed to '" + customLevelMusic + "'");
        }
        else
        {
          System.out.println("Could not load music track");
          return;
        }
      }
      else if(wantToLink)
      {
        wantToLink = false;
        if(selection != null)
        {
          String parentDirectory = selection.getParentFile().getName();
          if(parentDirectory.equals("Custom Levels"))
          {
            nextLevelAfterCustomLevel = "Custom Levels" + selection.getName();
            System.out.println("Linked successfully");
          }
          else if(parentDirectory.equals("Levels")&&developingMode==true)
          {
            nextLevelAfterCustomLevel = "Assets/Levels/" + selection.getName();
            System.out.println("Successfully linked main levels");
          }
          else
          {
            System.out.println("The selected successor level file '" + selection.getName() + "' is placed in an invalid directory.\nPlease move it to 'Custom Levels' for user-created levels or 'Assets/Levels' for main levels.");
            return;
          }
        }
        else
        {
          System.out.println("Could not link levels");
          return;
        }
      }
  }
  //////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////          ^^^^^^     EDITOR FUNCTIONS      ^^^^^^       ////////#editor/////////
  //////////////////////////////////////////////////////////////////////////////////////////////////
  
  //////////////////////////////////////////////////////////////////////////////////////////////////
  ///#game//////////          VVVVVV       GAME LOOP        VVVVVV          ///#draw////#update/////
  //////////////////////////////////////////////////////////////////////////////////////////////////
  private void drawGame()
  {
    animate_fps.inc();
    camcam.Translate();
    drawMap();
    drawPlayer();
    GameTime.advanceTime();
  }
  private void drawPlayer()
  {
    ////////Sprite Animation
    animationState = 0;
    sleep_timer.inc();
    if(sleep_timer.t==0||asleep)
    {
      asleep=true;
      animationState=3;
    }
    if(!Player.last_walked_left)
    {
      if(animate_fps.t==0)
      {
        anim_counts[animationState].inc();
      }
      image(player_anims[(animationState*framesPerState)+anim_counts[animationState].t], Player.x, Player.y, tileW, tileH);
    }
    else
    {
      if(animate_fps.t==0)
      {
        anim_counts_left[animationState].inc();
      }
      image(player_anims_left[(animationState*framesPerState)+anim_counts_left[animationState].t], Player.x, Player.y, tileW, tileH);
    }
    
    ///////Physics
    Player.Advance();
  }
  private void drawMap()
  {
    if(animate_fps.t==0)
    {
      for(int i = 0; i < rows * cols; ++i)
      {
        if(animatedTiles[i] > 0)
        {
          currentTileFrame[i].inc();
        }
      }
    }
    for(int i = 0; i < map.length; i++)
    {
      for(int j = 0; j < map[i].length; j++)
      {
        for(int k=0; k<map[i][j].length; k++)
        {
          if(animatedTiles[map[i][j][k]]>0)
          {
            image(tileAnimations[map[i][j][k]][currentTileFrame[map[i][j][k]].t], j * tileW, i * tileH, tileW, tileH);
          }
          else
          {
            image(images[map[i][j][k]], j * tileW, i * tileH, tileW, tileH);
          }
        }
      }
    }
  }
  //////////////////////////////////////////////////////////////////////////////////////////////////
  ////#game/////////          ^^^^^^       GAME LOOP        ^^^^^^          ///////#draw//#update///
  //////////////////////////////////////////////////////////////////////////////////////////////////
  
  //////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////          VVVVVV         INPUT          VVVVVV          ////////#input//////////
  //////////////////////////////////////////////////////////////////////////////////////////////////
  public void keyPressed()
  {
    if(key =='w'||keyCode==UP)
    {
      if(editor == false)
      {
        asleep = false;
        Player.wantsToJump = true;
      }
      else
      {
        customBoardOffsetY=min(0,customBoardOffsetY+1);
      }
    }
    else if (key == 'a'||keyCode==LEFT)
    {
      if(editor == false)
      {
        Player.last_walked_left=true;
        Player.in_motion = true;
        asleep = false;
        animationState = 1;
      }
      else
      {
        customBoardOffsetX=min(0,customBoardOffsetX+1);
      }
    }
    else if (key == 'd'||keyCode==RIGHT)
    {
      if(editor == false)
      {
        Player.last_walked_left=false;
        Player.in_motion = true;
        asleep = false;
        animationState = 1;
      }
      else
      {
        customBoardOffsetX=max(-517+64,customBoardOffsetX-1);
      }
    }
    else if(key == 's' || keyCode==DOWN)
    {
      if(editor == false)
      {
        Player.decreasedBuoyancy = true;
      }
      else
      {
        customBoardOffsetY=max(-500+32,customBoardOffsetY-1);
      }
    }
    else if(key == 'e'||keyCode==TAB) //switch to editor mode
    {
      if(switchingToEditor == false)
      {
        switchingToEditor = true;
        if(editor)
        {
          editorOST.stop();
          music.loop();
          editor=false;
          windowResize(320*SCALE, 320*SCALE);
          background(125, 175, 225);
        }
        else
        {
          music.stop();
          editorOST.loop();
          editor=true;
          windowResize(16*(64)*SCALE, 16*(32)*SCALE);
          background(125, 175, 225);
        }
      }
    }
    else if(key == 'r')
    {
        loadLevel(levelData.getString("thisLevel"),true);
    }
  }
  public void mouseWheel(MouseEvent roll_down)
  {
    float value = roll_down.getCount();
    if(value < 0)
    {
      selectedTool--;
      if(selectedTool==-1)selectedTool=15;
    }
    else
    {
      selectedTool++;
      if(selectedTool==16)selectedTool=0;
    }
    hasSelectedTile=false;
    hasSelectedPlayer = false;
    oldBrushX=-1;
    oldBrushY=-1;
  }
  public void keyReleased() 
  {
    if(key=='a'||key=='d'||keyCode==LEFT||keyCode==RIGHT)
    {
      if(editor==false)
      {
        Player.in_motion = false;
      }
    }
    if(key=='w'||keyCode==UP)
    {
      if(editor==false)
      {
        Player.wantsToJump = false;
        Player.isJumping = false;
      }
    }
    if(key=='s'||keyCode==DOWN)
    {
      if(editor==false)
      {
        Player.decreasedBuoyancy = false;
      }
    }
    if(key == 'e'||keyCode==TAB)
    {
      switchingToEditor=false;
    }
    if(keyCode==123||keyCode==113) // F12 and F2
    {
      //save screenshot
      Calendar C = Calendar.getInstance();
      String name = "";
      name += C.get(Calendar.YEAR);
      name += "-";
      name += String.format("%02d",C.get(Calendar.MONTH)+1);
      name += "-";
      name += C.get(Calendar.DAY_OF_MONTH);
      name += "_";
      name += C.get(Calendar.HOUR_OF_DAY);
      name += C.get(Calendar.MINUTE);
      name += C.get(Calendar.SECOND);
      save(path+"screenshots/"+name+".jpg");
    }
  }
  //////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////          ^^^^^^         INPUT          ^^^^^^          /////////#input/////////
  //////////////////////////////////////////////////////////////////////////////////////////////////
  public static void main(String[] args)
  {
    PApplet.main("javaGameDemo");
  }
}
