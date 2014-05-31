/**
 * Laser Projector Mk1
 * By Pierre Paslier - 2014
 * Thx to Andreas Schlegel, 2012
 */


import controlP5.*;
import processing.serial.*;
import cc.arduino.*;
Serial myPort;
Arduino arduino;
int [] data;
int x=0;
int y=0;
int xprev;
int yprev;
int deltax;
int deltay;
int myspeed = 600000; //delay of step in ns
int initiateSpeed = 300000;

int xmultiplier = 1;
int ymultiplier = 1;
int st1 = 10;
int dir1 = 9;
int enablePin1 = 11;

int st2 = 7;
int dir2 = 6;
int enablePin2 = 8;

int micro1 = 2;
int laser = 3;

Table table;
int temps;
int l;
int m1;
int m2;
int endstop1 = 0;
int endstop2 = 1;

int xcenter=1700; //x-
int ycenter=2500; //y+
int letterSpacing=12;

ControlP5 cp5;

String text = "";

void setup() {
  size(700, 400);

  PFont font = createFont("arial", 20);

  cp5 = new ControlP5(this);

  cp5.addTextfield("text")
    .setPosition(20, 170)
      .setSize(200, 40)
        .setFont(createFont("arial", 20))
          .setAutoClear(false)
            .setFocus(true)
              ;

  cp5.addBang("clear")
    .setPosition(240, 170)
      .setSize(80, 40)
        .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
          ;   

  cp5.addBang("initialize")
    .setPosition(240, 240)
      .setSize(80, 40)
        .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
          ; 

  cp5.addBang("laser")
    .setPosition(240, 100)
      .setSize(80, 40)
        .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
          ;    



  textFont(font);

  //Laser setup

  println(Arduino.list());
  arduino = new Arduino(this, Arduino.list() [3], 57600);
  arduino.pinMode(dir1, Arduino.OUTPUT); // Dir
  arduino.pinMode(st1, Arduino.OUTPUT); // Step
  arduino.pinMode(enablePin1, Arduino.OUTPUT); // Enable
  arduino.pinMode(dir2, Arduino.OUTPUT);//dir
  arduino.pinMode(st2, Arduino.OUTPUT);//step
  arduino.pinMode(enablePin2, Arduino.OUTPUT);//enable
  arduino.pinMode(laser, Arduino.OUTPUT);//laser
  arduino.pinMode(micro1, Arduino.OUTPUT);//Microstepping

  //steppers setup
  arduino.digitalWrite (enablePin1, Arduino.HIGH);
  arduino.digitalWrite (enablePin2, Arduino.HIGH);
  arduino.digitalWrite (micro1, Arduino.HIGH);


  //initiate();
}

void draw() {
  background(0);
  fill(255);
  //text(cp5.get(Textfield.class, "input").getText(), 360, 130);
  text(text, 360, 180);
  text("Laser Projector Mk1", 100, 45);
  //String mytext=cp5.get(Textfield.class, "input").getText();
  //println(mytext);
}

public void clear() {
  cp5.get(Textfield.class, "text").clear();
}

public void initialize() {
  initiate();
}

public void laser() {
  println ("BOOM");
  println (text);
  drawString(text);
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isAssignableFrom(Textfield.class)) {
    println("controlEvent: accessing a string from controller '"
      +theEvent.getName()+"': "
      +theEvent.getStringValue()
      );
  }
}


public void input(String theText) {
  // automatically receives results from controller input
  println("a textfield event for controller 'input' : "+theText);
}

void delay(int delay)
{
  long t1 = System.nanoTime();
  while (System.nanoTime () - t1 <= delay);
}

void initiate() {
  arduino.digitalWrite (enablePin1, Arduino.LOW);
  arduino.digitalWrite (enablePin2, Arduino.LOW);
  while (arduino.analogRead (endstop2) > 800) {
    println(arduino.analogRead(endstop2));
    arduino.digitalWrite (dir2, Arduino.HIGH);
    arduino.digitalWrite (st2, Arduino.HIGH);
    arduino.digitalWrite (st2, Arduino.LOW);
    delay(initiateSpeed);
  }

  while (arduino.analogRead (endstop1) > 800) {
    println(arduino.analogRead(endstop1));
    arduino.digitalWrite (dir1, Arduino.LOW);
    arduino.digitalWrite (st1, Arduino.HIGH);
    arduino.digitalWrite (st1, Arduino.LOW);    
    delay(initiateSpeed);
  }

  for (int i=0; i<xcenter; i++)
  {
    arduino.digitalWrite (dir1, Arduino.HIGH);
    arduino.digitalWrite (st1, Arduino.HIGH);
    arduino.digitalWrite (st1, Arduino.LOW);
    delay(initiateSpeed);
  }

  for (int i=0; i<ycenter; i++) {
    arduino.digitalWrite (dir2, Arduino.LOW);
    arduino.digitalWrite (st2, Arduino.HIGH);
    arduino.digitalWrite (st2, Arduino.LOW);
    delay(initiateSpeed);
  }
  arduino.digitalWrite (enablePin1, Arduino.HIGH);
  arduino.digitalWrite (enablePin2, Arduino.HIGH);
} 

void drawString (String myword) {

  for (int index= 0; index<myword.length(); index++) {
    String currentChar = String.valueOf(myword.charAt(index));
    drawFile(currentChar);
    arduino.digitalWrite (enablePin1, Arduino.LOW);
    arduino.digitalWrite (enablePin2, Arduino.LOW);
    for (int i=0; i<letterSpacing*xmultiplier; i++)
    {
      arduino.digitalWrite (dir1, Arduino.LOW);
      arduino.digitalWrite (st1, Arduino.HIGH);
      delay(100000);
      arduino.digitalWrite (st1, Arduino.LOW);
    }
    arduino.digitalWrite (enablePin1, Arduino.HIGH);
    arduino.digitalWrite (enablePin2, Arduino.HIGH);
  }
  arduino.digitalWrite (enablePin1, Arduino.LOW);
  arduino.digitalWrite (enablePin2, Arduino.LOW);
  for (int i=0; i<letterSpacing*xmultiplier*myword.length(); i++)
  {
    arduino.digitalWrite (dir1, Arduino.HIGH);
    arduino.digitalWrite (st1, Arduino.HIGH);
    delay(100000);
    arduino.digitalWrite (st1, Arduino.LOW);
  }
  arduino.digitalWrite (enablePin1, Arduino.HIGH);
  arduino.digitalWrite (enablePin2, Arduino.HIGH);
}
void drawFile (String filename) {


  filename = filename + ".txt";
  arduino.digitalWrite (enablePin1, Arduino.LOW);
  arduino.digitalWrite (enablePin2, Arduino.LOW);
  table = loadTable(filename, "tsv" );  
  println(table.getRowCount() + " total rows in table");
  // for each line of the text file
  for (int i = 0; i < table.getRowCount(); i++) {
    //arduino.digitalWrite (laser, Arduino.LOW); //turn laser off
    //delay(1000000000);
    //arduino.digitalWrite (laser, Arduino.HIGH); //turn laser off    
    TableRow row = table.getRow(i);  

    String ligne = row.getString(0);
    data = int(split(ligne, ',')); //get the values from the line
    //print("dl");

    for (int j = 0; j < data.length/2; j++) { //for each point
      //  println(data.length/2);

      xprev=x;
      yprev=y;
      x=data[j*2];
      y=data[j*2+1];
      //point(x, y);

      deltax= (x - xprev)*xmultiplier;
      println(deltax);
      deltay= (y - yprev)*ymultiplier;
      println(deltay);

      if (j==0 || j>=(data.length/2)-2) {
        arduino.digitalWrite (laser, Arduino.LOW); //turn laser off for first and last movement
      }
      else {
        arduino.digitalWrite (laser, Arduino.HIGH); //turn laser on
      }

      if (deltax > 0) {
        arduino.digitalWrite (dir1, Arduino.LOW);
        for (int steps=0; steps<abs(deltax); steps++)
        {
          arduino.digitalWrite (st1, Arduino.HIGH);
          delay(myspeed);
          arduino.digitalWrite (st1, Arduino.LOW);
          delay(myspeed);
        }
      }

      else if (deltax < 0) {
        arduino.digitalWrite (dir1, Arduino.HIGH);
        for (int steps=0; steps<abs(deltax); steps++)
        {
          arduino.digitalWrite (st1, Arduino.HIGH);
          delay(myspeed);
          arduino.digitalWrite (st1, Arduino.LOW);
          delay(myspeed);
        }
      }

      if (deltay < 0) {
        arduino.digitalWrite (dir2, Arduino.LOW);
        for (int steps=0; steps<abs(deltay); steps++)
        {
          arduino.digitalWrite (st2, Arduino.HIGH);
          delay(myspeed);
          arduino.digitalWrite (st2, Arduino.LOW);
          delay(myspeed);
        }
      }

      else if (deltay > 0) {
        arduino.digitalWrite (dir2, Arduino.HIGH);
        for (int steps=0; steps<abs(deltay); steps++)
        {
          arduino.digitalWrite (st2, Arduino.HIGH);
          delay(myspeed);
          arduino.digitalWrite (st2, Arduino.LOW);
          delay(myspeed);
        }
      }



      /*if (deltax==0 && deltay==0)
       {println("delta at 0");
       }
       else {
       int max = max(abs(deltax), abs(deltay));
       int v=abs(deltax)/max;
       int w=abs(deltay)/max;
       int px=0;
       int py=0;
       if (v==0) px = 1;
       if (w==0) py = 1;
       for (int k=0; k<max; k++) {
       if (v*k>=px) {
       arduino.digitalWrite (st1, Arduino.HIGH);
       delay(myspeed);
       arduino.digitalWrite (st1, Arduino.LOW);
       delay(myspeed);
       px++;
       }
       if (w*k>=py) {
       arduino.digitalWrite (st2, Arduino.HIGH);
       delay(myspeed);
       arduino.digitalWrite (st2, Arduino.LOW);
       delay(myspeed);
       py++;
       }
       }
       }*/
      //arduino.digitalWrite (laser, Arduino.HIGH); //turn laser off
    }//all points of the line have been drawn
    arduino.digitalWrite (laser, Arduino.LOW); //turn laser off
  }//all lines have been drawn
  arduino.digitalWrite (enablePin1, Arduino.HIGH);
  arduino.digitalWrite (enablePin2, Arduino.HIGH);
}


/*
a list of all methods available for the Textfield Controller
 use ControlP5.printPublicMethodsFor(Textfield.class);
 to print the following list into the console.
 
 You can find further details about class Textfield in the javadoc.
 
 Format:
 ClassName : returnType methodName(parameter type)
 
 controlP5.Textfield : String getText() 
 controlP5.Textfield : Textfield clear() 
 controlP5.Textfield : Textfield keepFocus(boolean) 
 controlP5.Textfield : Textfield setAutoClear(boolean) 
 controlP5.Textfield : Textfield setFocus(boolean) 
 controlP5.Textfield : Textfield setFont(ControlFont) 
 controlP5.Textfield : Textfield setFont(PFont) 
 controlP5.Textfield : Textfield setFont(int) 
 controlP5.Textfield : Textfield setText(String) 
 controlP5.Textfield : Textfield setValue(String) 
 controlP5.Textfield : Textfield setValue(float) 
 controlP5.Textfield : boolean isAutoClear() 
 controlP5.Textfield : int getIndex() 
 controlP5.Textfield : void draw(PApplet) 
 controlP5.Textfield : void keyEvent(KeyEvent) 
 controlP5.Textfield : void setInputFilter(int) 
 controlP5.Textfield : void setPasswordMode(boolean) 
 controlP5.Controller : CColor getColor() 
 controlP5.Controller : ControlBehavior getBehavior() 
 controlP5.Controller : ControlWindow getControlWindow() 
 controlP5.Controller : ControlWindow getWindow() 
 controlP5.Controller : ControllerProperty getProperty(String) 
 controlP5.Controller : ControllerProperty getProperty(String, String) 
 controlP5.Controller : Label getCaptionLabel() 
 controlP5.Controller : Label getValueLabel() 
 controlP5.Controller : List getControllerPlugList() 
 controlP5.Controller : PImage setImage(PImage) 
 controlP5.Controller : PImage setImage(PImage, int) 
 controlP5.Controller : PVector getAbsolutePosition() 
 controlP5.Controller : PVector getPosition() 
 controlP5.Controller : String getAddress() 
 controlP5.Controller : String getInfo() 
 controlP5.Controller : String getName() 
 controlP5.Controller : String getStringValue() 
 controlP5.Controller : String toString() 
 controlP5.Controller : Tab getTab() 
 controlP5.Controller : Textfield addCallback(CallbackListener) 
 controlP5.Controller : Textfield addListener(ControlListener) 
 controlP5.Controller : Textfield bringToFront() 
 controlP5.Controller : Textfield bringToFront(ControllerInterface) 
 controlP5.Controller : Textfield hide() 
 controlP5.Controller : Textfield linebreak() 
 controlP5.Controller : Textfield listen(boolean) 
 controlP5.Controller : Textfield lock() 
 controlP5.Controller : Textfield plugTo(Object) 
 controlP5.Controller : Textfield plugTo(Object, String) 
 controlP5.Controller : Textfield plugTo(Object[]) 
 controlP5.Controller : Textfield plugTo(Object[], String) 
 controlP5.Controller : Textfield registerProperty(String) 
 controlP5.Controller : Textfield registerProperty(String, String) 
 controlP5.Controller : Textfield registerTooltip(String) 
 controlP5.Controller : Textfield removeBehavior() 
 controlP5.Controller : Textfield removeCallback() 
 controlP5.Controller : Textfield removeCallback(CallbackListener) 
 controlP5.Controller : Textfield removeListener(ControlListener) 
 controlP5.Controller : Textfield removeProperty(String) 
 controlP5.Controller : Textfield removeProperty(String, String) 
 controlP5.Controller : Textfield setArrayValue(float[]) 
 controlP5.Controller : Textfield setArrayValue(int, float) 
 controlP5.Controller : Textfield setBehavior(ControlBehavior) 
 controlP5.Controller : Textfield setBroadcast(boolean) 
 controlP5.Controller : Textfield setCaptionLabel(String) 
 controlP5.Controller : Textfield setColor(CColor) 
 controlP5.Controller : Textfield setColorActive(int) 
 controlP5.Controller : Textfield setColorBackground(int) 
 controlP5.Controller : Textfield setColorCaptionLabel(int) 
 controlP5.Controller : Textfield setColorForeground(int) 
 controlP5.Controller : Textfield setColorValueLabel(int) 
 controlP5.Controller : Textfield setDecimalPrecision(int) 
 controlP5.Controller : Textfield setDefaultValue(float) 
 controlP5.Controller : Textfield setHeight(int) 
 controlP5.Controller : Textfield setId(int) 
 controlP5.Controller : Textfield setImages(PImage, PImage, PImage) 
 controlP5.Controller : Textfield setImages(PImage, PImage, PImage, PImage) 
 controlP5.Controller : Textfield setLabelVisible(boolean) 
 controlP5.Controller : Textfield setLock(boolean) 
 controlP5.Controller : Textfield setMax(float) 
 controlP5.Controller : Textfield setMin(float) 
 controlP5.Controller : Textfield setMouseOver(boolean) 
 controlP5.Controller : Textfield setMoveable(boolean) 
 controlP5.Controller : Textfield setPosition(PVector) 
 controlP5.Controller : Textfield setPosition(float, float) 
 controlP5.Controller : Textfield setSize(PImage) 
 controlP5.Controller : Textfield setSize(int, int) 
 controlP5.Controller : Textfield setStringValue(String) 
 controlP5.Controller : Textfield setUpdate(boolean) 
 controlP5.Controller : Textfield setValueLabel(String) 
 controlP5.Controller : Textfield setView(ControllerView) 
 controlP5.Controller : Textfield setVisible(boolean) 
 controlP5.Controller : Textfield setWidth(int) 
 controlP5.Controller : Textfield show() 
 controlP5.Controller : Textfield unlock() 
 controlP5.Controller : Textfield unplugFrom(Object) 
 controlP5.Controller : Textfield unplugFrom(Object[]) 
 controlP5.Controller : Textfield unregisterTooltip() 
 controlP5.Controller : Textfield update() 
 controlP5.Controller : Textfield updateSize() 
 controlP5.Controller : boolean isActive() 
 controlP5.Controller : boolean isBroadcast() 
 controlP5.Controller : boolean isInside() 
 controlP5.Controller : boolean isLabelVisible() 
 controlP5.Controller : boolean isListening() 
 controlP5.Controller : boolean isLock() 
 controlP5.Controller : boolean isMouseOver() 
 controlP5.Controller : boolean isMousePressed() 
 controlP5.Controller : boolean isMoveable() 
 controlP5.Controller : boolean isUpdate() 
 controlP5.Controller : boolean isVisible() 
 controlP5.Controller : float getArrayValue(int) 
 controlP5.Controller : float getDefaultValue() 
 controlP5.Controller : float getMax() 
 controlP5.Controller : float getMin() 
 controlP5.Controller : float getValue() 
 controlP5.Controller : float[] getArrayValue() 
 controlP5.Controller : int getDecimalPrecision() 
 controlP5.Controller : int getHeight() 
 controlP5.Controller : int getId() 
 controlP5.Controller : int getWidth() 
 controlP5.Controller : int listenerSize() 
 controlP5.Controller : void remove() 
 controlP5.Controller : void setView(ControllerView, int) 
 java.lang.Object : String toString() 
 java.lang.Object : boolean equals(Object) 
 
 
 */
