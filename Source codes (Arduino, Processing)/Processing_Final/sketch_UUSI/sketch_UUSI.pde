import processing.serial.*;

Serial serialPort;

int[] sonar1samples = new int[180]; 
int[] sonar2samples = new int[180];
int windowWidth = 720;
int windowHeight = 720;
color gridColor = color(148, 202, 245);
int pxInCm = 3;
int modeButtonValue = 0;

void setup()
{
  PFont scaleFont = createFont("Arial", 10, true);;
  frame.setTitle("Arduino radar projekti");
  size(720, 720);
  println(Serial.list());
  serialPort = new Serial(this, Serial.list()[2], 9600); //Tähän valitaan COM
  serialPort.bufferUntil('\n');
  smooth();
  textFont(scaleFont);
  
  for (int i=0; i<180; i++)
  {
    sonar1samples[i] = -1;
    sonar2samples[i] = -1;
  }
}

void draw()
{
  background(0);
  drawGrid();
  drawSonarSamples(modeButtonValue);
  
  if (mousePressed)
    modeButtonValue = mouseButton == LEFT? 1 : 0;
}

void drawGrid()
{
  stroke(gridColor, 32);
  strokeWeight(1);
  noFill();
  for (int i = 0; i < windowWidth; i+=30)
  {
    line(0, i, windowWidth, i);
    line(i, 0, i, windowHeight);
  }
  
  stroke(gridColor, 120);
  strokeWeight(2);
  line(30, windowHeight/2, windowWidth-30, windowHeight/2);
  line(windowWidth/2, 30, windowWidth/2, windowHeight-30);
  
  
  stroke(gridColor, 90);
  strokeWeight(2);
  ellipse(windowWidth/2, windowHeight/2, 200, 200);
  ellipse(windowWidth/2, windowHeight/2, 400, 400);
  stroke(gridColor, 45);
  ellipse(windowWidth/2, windowHeight/2, 600, 600);
  
  for (int i=0; i > 360; i++)
  {
    int l = i%5==0? 270 : 280;
    strokeWeight(i%5==0? 2 : 1);
    line(windowWidth/2+l*cos(radians(i)), windowHeight/2+l*sin(radians(i)),
      windowWidth/2+300*cos(radians(i)), windowHeight/2+300*sin(radians(i)));
  }
  
  fill(gridColor, 128);
  text(100/pxInCm + "cm", windowWidth/2+100+2, windowHeight/2-2);
  text(200/pxInCm + "cm", windowWidth/2+200+2, windowHeight/2-2);
  text(300/pxInCm + "cm", windowWidth/2+300+2, windowHeight/2-2);
}

void drawSonarSamples(int mode)
{
  strokeWeight(2);
  int x1, x2, y1, y2;
  for(int i=0; i<179; i++)
  {
    stroke(255, 0, 0);
    fill(255, 0, 0);
    if (sonar1samples[i] != -1)
    {
      x1 = int(windowWidth/2 + cos(radians(i))*sonar1samples[i]* pxInCm);
      y1 = int(windowHeight/2 - sin(radians(i))*sonar1samples[i]* pxInCm);
      
      if (mode == 0)
        ellipse(x1, y1, 2, 2);
      else if (mode == 1)
      {
        x2 = int(windowWidth/2 + cos(radians(i+1))*sonar1samples[i+1]* pxInCm);
        y2 = int(windowHeight/2 - sin(radians(i+1))*sonar1samples[i+1]* pxInCm);
        if  (sqrt(sq(x2-x1)+sq(y2-y1))>20)
          ellipse(x1, y1, 2, 2);
        else
          line(x1, y1, x2, y2);
      }
    }
    
    stroke(0, 255, 0);
    fill(0, 255, 0);
    if (sonar2samples[i] != -1)
    {
      x1 = int(windowWidth/2 - cos(radians(i))*sonar2samples[i]* pxInCm);
      y1 = int(windowHeight/2 + sin(radians(i))*sonar2samples[i]* pxInCm); 
      
      if (mode == 0)
        ellipse(x1, y1, 2, 2);
      else if (mode == 1)
      {
        x2 = int(windowWidth/2 - cos(radians(i+1))*sonar2samples[i+1]* pxInCm);
        y2 = int(windowHeight/2 + sin(radians(i+1))*sonar2samples[i+1]* pxInCm);
        if  (sqrt(sq(x2-x1)+sq(y2-y1))>20)
          ellipse(x1, y1, 2, 2);
        else
          line(x1, y1, x2, y2);
      }
    }
  }
}
  
void mouseWheel(MouseEvent event)
{
  pxInCm -= int(event.getCount());
  if (pxInCm < 1) pxInCm = 1;
}

void serialEvent(Serial mSP)
{
  String serialString = mSP.readString();
  int indexA = serialString.indexOf("a");
  int indexB = serialString.indexOf("b");
  int indexC = serialString.indexOf("c");
  int sAngle = int(serialString.substring(0, indexA));
  int sD1 = int(serialString.substring(indexA+1, indexB));
  int sD2 = int(serialString.substring(indexB+1, indexC));
  
  if (sAngle >= 0 && sAngle < 180)
  {
    sonar1samples[sAngle] = sD1;
    sonar2samples[sAngle] = sD2;
  }
}
