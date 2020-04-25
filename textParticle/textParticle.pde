import gifAnimation.*;

GifMaker gifExport;

String[] contexts = {"平成","令和"};
float FontSize = 395;

PImage[] Image = new PImage[contexts.length];

int xSkip = 7;
int ySkip = 8;
color AlphaCol = #000000;

TextParticleSystem textParticle ;

void setup(){
  size(900,720);
  background(0);
  colorMode(HSB);
  blendMode(ADD);
  
  for(int i = 0;i < contexts.length; i++){
    Image[i] = GenerateTextImage(contexts[i],FontSize);
  }
  textParticle = new TextParticleSystem(Image[0],xSkip,ySkip,AlphaCol);
  
  
  gifExport = new GifMaker(this,"export.gif");
  gifExport.setRepeat(0);
  gifExport.setQuality(20);
  gifExport.setDelay(30);
}

boolean record = false;

void draw(){
    background(0);
    textParticle.Update(); 
    
    //saveFrame("Image/X####.png");
    if(record){
     gifExport.addFrame();
    }
}
int pressed = 0;
void mousePressed(){
  pressed ++;
  pressed = pressed%contexts.length;
  textParticle.ChangeText(Image[pressed]);
}

void keyPressed(){
  record = true;
}

void keyReleased(){
  gifExport.finish();
}

PImage GenerateTextImage(String contexts,float size){
  PFont font = createFont("SpicaNeue-Bold",size);
  PGraphics g = createGraphics(width,height);
  g.beginDraw();
  g.fill(255);
  g.textSize(size);
  g.textFont(font);
 float textHeight = g.textAscent() + g.textDescent();
  int newLines = floor(g.textWidth(contexts)/g.width) + contexts.split("\n").length;
  g.textAlign(CENTER);
  g.background(0);
  g.rectMode(CENTER);
  g.text(contexts, g.width/2, g.height/2, g.width, textHeight * 1.2 * max(1, newLines));
  g.endDraw();
  return g.get();
}

class Particle{
  PVector mStart,mAnchor,mEnd;
  PVector mCurrent = new PVector();
  float mDegreeOfProgress = 0;
  float mSize;
  float mDuration ;
  int count = 0;
  public color mCol;
  
  public Particle(float sx,float sy,float ex,float ey, float size,float duration,color col){
    mStart = new PVector(sx,sy);
    mEnd = new PVector(ex,ey);
    
    mAnchor = new PVector(random(0,width),random(0,height));
    
    mSize = size;
    mDuration = duration;
    mCol = col;
  }
  
  public void Update(float delta){
    if(mDegreeOfProgress >= 1){
      mDegreeOfProgress = 1;
      return;
    }
    
    mDegreeOfProgress += delta/mDuration;
    if(mDegreeOfProgress >= 1){
      mDegreeOfProgress = 1;
      count++;
      //if(count >= 2)mCol = color(1,255,255);
    }
    SetCurrentPostion(mDegreeOfProgress);
  }
  
  public void Draw(){
    
    noStroke();
    fill(mCol);
    ellipse(mCurrent.x,mCurrent.y,mSize + 30 * sin(mDegreeOfProgress * PI) ,mSize + 30 *sin(mDegreeOfProgress * PI)); 
    
   // stroke(mCol);
    //strokeWeight(mSize);
   // point(mCurrent.x,mCurrent.y);
    
  }
  
  public void SetEndPosition(float ex,float ey){
    mStart.set(mEnd.x,mEnd.y);
    mEnd.set(ex,ey);
    mAnchor.set(random(-5*width,5*width),random(-5*height,5*height));
    mDegreeOfProgress = 0;
  }
  
  private void SetCurrentPostion(float DoP){
    float fi = interpolate(DoP);
    float cx = lerp(lerp(mStart.x, mAnchor.x, fi), lerp(mAnchor.x, mEnd.x, fi), fi);
    float cy = lerp(lerp(mStart.y, mAnchor.y, fi), lerp(mAnchor.y, mEnd.y, fi), fi);
    
    mCurrent.set(cx,cy);
  }
  
  private float interpolate(float f) {
    return 1 - pow(1 - f, 2);
  }
  

  
}

class TextParticleSystem{
  ArrayList<Particle> mParticles = new ArrayList<Particle>();
  ArrayList<PVector> mPositions = new ArrayList<PVector>();
  
  float mSize = 5;
  float mDuration  = 4;
  color mCol = #ffffff;
  
  int mSkipX;
  int mSkipY;
 
  color mAlphaCol ;
  
  public TextParticleSystem(PImage image,int skipx,int skipy, color AlphaCol){
    mSkipX =skipx;
    mSkipY = skipy;
    mAlphaCol = AlphaCol;
    SetParticles(image);
  }
  
  public void Update(){
    for(Particle p: mParticles ){
      p.Update(1f/60);
      p.Draw();
    }
  }
  
  //パーティクルの数を変えない
  public void ChangeText(PImage image){
    SetPositions(image);
    if(mPositions.size() > mParticles.size()){
      for(int i = 0; i< mParticles.size();i++){
        mParticles.get(i).SetEndPosition(mPositions.get(i).x,mPositions.get(i).y);
      }
    }else{
      for(int i = 0; i< mPositions.size();i++){
        mParticles.get(i).SetEndPosition(mPositions.get(i).x,mPositions.get(i).y);
      }
      for(int i = mPositions.size();i < mParticles.size();i++){
         mParticles.get(i).SetEndPosition(mPositions.get(i%mPositions.size()).x,mPositions.get(i%mPositions.size()).y);
      }
    }
  
  
  }
  
  private void SetPositions(PImage image){
    mPositions.clear();
    int mStartX = 0;
    int mStartY = 0;
    int mEndX = image.width;
    int mEndY = image.height;
    
    if(mEndX * mEndY == 0){
      println("image is not EXSIST");
    }
    for(int x = mStartX; x < mEndX;x += mSkipX){
      for(int y = mStartY; y < mEndY;y += mSkipY){
        color col = image.get(x,y);
        if(col != mAlphaCol){
          mPositions.add(new PVector(x,y));
        }
      }
    }
  }
  
  private void SetParticles(PImage image ){
    SetPositions(image);
    for(int i = 0;i < mPositions.size(); i++){
      mCol = color(random(0,255),255,255);
      mSize = random(7,12);
      mParticles.add(new Particle(width/2,height/2,mPositions.get(i).x,mPositions.get(i).y,mSize,mDuration,mCol));
    }
  }
}
