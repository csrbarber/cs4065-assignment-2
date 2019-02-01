import de.voidplus.dollar.*;
import javax.swing.JOptionPane;

String[] SHAPES = {"FFLINE", "LINE", "RECT", "OVAL"};
color[] COLORS = {color(0, 0, 0), color(255, 0, 0), color(255, 255, 0), color(0, 0, 255)};
int[] WEIGHTS = {1, 5, 9};
boolean DEBUG = false;

float startX, startY, endX, endY;
ArrayList<Shape> shapes;
int startTime, activeWeight, shapeIndex, colorIndex, weightIndex;
String activeShape, activeMouse;
int scheme;
color activeColor;
OneDollar one;

//Debugging
Button ffLineButton, lineButton, rectButton, ovalButton, blackButton, redButton, yellowButton, blueButton, thinButton, mediumButton, thickButton;
ArrayList<Button> buttons;

void setup() {
  size(800, 800);
  background(100);
  scheme = Integer.parseInt(JOptionPane.showInputDialog("Please scheme number (0 or 1)\n" + 
  "0: 1 gesture per command\n1: 3 gestures total\n"));

  shapes = new ArrayList<Shape>();
  activeShape = SHAPES[0];
  activeColor = COLORS[0];
  activeWeight = WEIGHTS[0];
  shapeIndex = colorIndex = weightIndex = 0;
  startTime = -1;
  activeMouse = null;
  
  one = new OneDollar(this);
  if (scheme == 0) {
    OneDollarWrapper.learnShapeGestures(one);
    OneDollarWrapper.learnColorGestures(one);
    OneDollarWrapper.learnWeightGestures(one);
    OneDollarWrapper.bindScheme0(one);
  } else {
    OneDollarWrapper.learnScheme1Gestures(one);
    OneDollarWrapper.bindScheme1(one);
  }
  
  // Debugging
  if (DEBUG) {
    instantiateDebugButtons();
  }
}

/*
Background called every frame to wipe artifacts of the active shape 
and we draw the existing shapes on top of the background in order.
*/
void draw() {
  background(100);
  for (Shape shape : shapes) {
    shape.display();
  }
  
  // Debugging
  if (DEBUG) {
    for (Button button : buttons) {
      button.display();
    }  
  }

  updateLegend();
    
  if (mousePressed) {
    if (mouseButton == LEFT) {
      // The stroke of lines is the color
      if (activeShape.equals(SHAPES[0]) || activeShape.equals(SHAPES[1])) {
        stroke(activeColor);
        strokeWeight(activeWeight);
      } else {
        stroke(0);
        strokeWeight(activeWeight);
      }
  
      fill(activeColor);
      drawActiveShape();
    } else if (mouseButton == RIGHT) {
      activeMouse = "RIGHT";
      stroke(0, 255, 0);
      strokeWeight(4);
      one.track(mouseX, mouseY);
      shapes.add(new FFLine(pmouseX, pmouseY, mouseX, mouseY, color(0, 255, 0), 4, startTime));
    }
  }
}

void mousePressed() {
  // startTime used for tracking FFLine sequences
  if (startTime == -1) {
    startTime = millis();
  }
  
  if (mouseButton == LEFT) {
    // Track activeMouse to ensure we are performing the correct action on mouseReleased
    activeMouse = "LEFT";
    startX = mouseX;
    startY = mouseY;
    
    if (DEBUG) {
      detectDebugButtonPress();
    }
  }
}

void mouseReleased() {
  if (activeMouse.equals("LEFT")) {
    endX = mouseX;
    endY = mouseY;
    
    // Add new instance of active shape drawn on mouse release to make sure it is not covered by the
    // background calls every frame.
    // FFLines have already been added to shapes at this point,
    // because there is no resizing FFLines
    if (activeShape.equals(SHAPES[1])) {
      shapes.add(new Line(startX, startY, endX, endY, activeColor, activeWeight));
    } else if (activeShape.equals(SHAPES[2])) {
      shapes.add(new Rectangle(startX, startY, endX, endY, activeColor, activeWeight));
    } else if (activeShape.equals(SHAPES[3])) {
      shapes.add(new Ellipse(startX, startY, endX, endY, activeColor, activeWeight));
    }
  } else if (activeMouse.equals("RIGHT")) {
    removeLastFFLineSequence();
  }
  
  activeMouse = null;
  startTime = -1; //<>//
}

void keyPressed() {
  if (key == BACKSPACE) {
    if (shapes.size() > 0) {
        if (shapes.get(shapes.size() - 1) instanceof FFLine) {
          removeLastFFLineSequence();
        } else {
          shapes.remove(shapes.size() - 1);
        }
    } //<>//
  }
}

/*
The active shape is drawn every frame , but is not added to the shapes list until mouse release,
(except for FFLines since they are cannot be resized). This is how we achieve continuous
feedback of the shape being drawn since background is called every frame to wipe out active shape artifacts.
*/
void drawActiveShape() {
  if (activeShape.equals(SHAPES[0])) {
    shapes.add(new FFLine(pmouseX, pmouseY, mouseX, mouseY, activeColor, activeWeight, startTime));
  } else if (activeShape.equals(SHAPES[1])) {
    line(startX, startY, mouseX, mouseY);
  } else if (activeShape.equals(SHAPES[2])) {
    rectMode(CORNERS);
    rect(startX, startY, mouseX, mouseY);
  } else {
    ellipseMode(CORNERS);
    ellipse(startX, startY, mouseX, mouseY);
  }
}

void printGestureNameSimilarity(String gestureName, float percentOfSimilarity) {
  print("Gesture: " + gestureName + " Similarity: " + percentOfSimilarity + "\n");
}

void setShapeFFLine(String gestureName, float percentOfSimilarity, int startX, int startY, int centroidX, int centroidY, int endX, int endY){
  activeShape = SHAPES[0];
  printGestureNameSimilarity(gestureName, percentOfSimilarity);
}

void setShapeLine(String gestureName, float percentOfSimilarity, int startX, int startY, int centroidX, int centroidY, int endX, int endY){
  activeShape = SHAPES[1];
  printGestureNameSimilarity(gestureName, percentOfSimilarity);
}

void setShapeRect(String gestureName, float percentOfSimilarity, int startX, int startY, int centroidX, int centroidY, int endX, int endY){
  activeShape = SHAPES[2];
  printGestureNameSimilarity(gestureName, percentOfSimilarity);
}

void setShapeEllipse(String gestureName, float percentOfSimilarity, int startX, int startY, int centroidX, int centroidY, int endX, int endY){
  activeShape = SHAPES[3];
  printGestureNameSimilarity(gestureName, percentOfSimilarity);
}

void setColorBlack(String gestureName, float percentOfSimilarity, int startX, int startY, int centroidX, int centroidY, int endX, int endY){
  activeColor = COLORS[0];
  printGestureNameSimilarity(gestureName, percentOfSimilarity);
}

void setColorRed(String gestureName, float percentOfSimilarity, int startX, int startY, int centroidX, int centroidY, int endX, int endY){
  activeColor = COLORS[1];
  printGestureNameSimilarity(gestureName, percentOfSimilarity);
}

void setColorYellow(String gestureName, float percentOfSimilarity, int startX, int startY, int centroidX, int centroidY, int endX, int endY){
  activeColor = COLORS[2];
  printGestureNameSimilarity(gestureName, percentOfSimilarity);
}

void setColorBlue(String gestureName, float percentOfSimilarity, int startX, int startY, int centroidX, int centroidY, int endX, int endY){
  activeColor = COLORS[3];
  printGestureNameSimilarity(gestureName, percentOfSimilarity);
}

void setWeightThin(String gestureName, float percentOfSimilarity, int startX, int startY, int centroidX, int centroidY, int endX, int endY){
  activeWeight = WEIGHTS[0];
  printGestureNameSimilarity(gestureName, percentOfSimilarity);
}

void setWeightMedium(String gestureName, float percentOfSimilarity, int startX, int startY, int centroidX, int centroidY, int endX, int endY){
  activeWeight = WEIGHTS[1];
  printGestureNameSimilarity(gestureName, percentOfSimilarity);
}

void setWeightThick(String gestureName, float percentOfSimilarity, int startX, int startY, int centroidX, int centroidY, int endX, int endY){
  activeWeight = WEIGHTS[2];
  printGestureNameSimilarity(gestureName, percentOfSimilarity);
}

void cycleShape(String gestureName, float percentOfSimilarity, int startX, int startY, int centroidX, int centroidY, int endX, int endY){
  shapeIndex++;
  if (shapeIndex == SHAPES.length) {
    shapeIndex = 0;
  }
  activeShape = SHAPES[shapeIndex];
  printGestureNameSimilarity(gestureName, percentOfSimilarity);
}

void cycleColor(String gestureName, float percentOfSimilarity, int startX, int startY, int centroidX, int centroidY, int endX, int endY){
  colorIndex++;
  if (colorIndex == COLORS.length) {
    colorIndex = 0;
  }
  activeColor = COLORS[colorIndex];
  printGestureNameSimilarity(gestureName, percentOfSimilarity);
}

void cycleWeight(String gestureName, float percentOfSimilarity, int startX, int startY, int centroidX, int centroidY, int endX, int endY){
  weightIndex++;
  if (weightIndex == WEIGHTS.length) {
    weightIndex = 0;
  }
  activeWeight = WEIGHTS[weightIndex];
  printGestureNameSimilarity(gestureName, percentOfSimilarity);
}

/*
To remove the last FFLine sequence (from mouse press to mouse release)
remove all instances of FFLine in shapes with the start time of the last FFLine in shape.
FFLine startTime is the millis() of when the FFLine sequence began.
*/
void removeLastFFLineSequence() {
  FFLine lastFFLine = (FFLine) shapes.get(shapes.size() - 1);
  int lastFFLineTime = lastFFLine.getStartTime();
  
  // Not the most efficient
  ArrayList<Shape> toRemove = new ArrayList<Shape>();
  for (Shape shape : shapes) {
     if (shape instanceof FFLine) {
       FFLine castedObject = (FFLine) shape;
       if (castedObject.startTime == lastFFLineTime) {
         toRemove.add(shape);
       }
     }
  }
  
  shapes.removeAll(toRemove);
}

//Update legend of active shape, color, and weight
void updateLegend() {
  textSize(15);
  fill(activeColor);
  text("Color", 750, 20); 
  fill(0);
  stroke(activeColor);
  text("Weight: " + activeWeight, 700, 35); 
  strokeWeight(activeWeight);
  line(780, 30, 790, 30);
  text("Shape: " + activeShape, 695, 50);  
}

//DEBUGGING FUNCTIONS BELOW

//Instantiate buttons and add to group (for display)
void instantiateDebugButtons() {
  buttons = new ArrayList<Button>();
  ffLineButton = new Button(0, 0, 100, 50, "FFLine");
  lineButton = new Button(0, 50, 100, 100, "Line");
  rectButton = new Button(0, 100, 100, 150, "Rect");
  ovalButton = new Button(0, 150, 100, 200, "Oval");
  blackButton = new Button(0, 200, 100, 250, "black");
  redButton = new Button(0, 250, 100, 300, "red");
  yellowButton = new Button(0, 300, 100, 350, "yellow");
  blueButton = new Button(0, 350, 100, 400, "blue");
  thinButton = new Button(0, 400, 100, 450, "THIN");
  mediumButton = new Button(0, 450, 100, 500, "MEDIUM");
  thickButton = new Button(0, 500, 100, 550, "THICK");
  buttons.add(ffLineButton);
  buttons.add(lineButton);
  buttons.add(rectButton);
  buttons.add(ovalButton);
  buttons.add(blackButton);
  buttons.add(redButton);
  buttons.add(yellowButton);
  buttons.add(blueButton);
  buttons.add(thinButton);
  buttons.add(mediumButton);
  buttons.add(thickButton);
}

void detectDebugButtonPress() {
  //Shape
  if (ffLineButton.overButton()) {
    activeShape = SHAPES[0];
  } else if (lineButton.overButton()) {
    activeShape = SHAPES[1];
  } else if (rectButton.overButton()) {
    activeShape = SHAPES[2];
  } else if (ovalButton.overButton()) {
    activeShape = SHAPES[3];
  }
  
  //Color
  if (blackButton.overButton()) {
    activeColor = COLORS[0];
  } else if (redButton.overButton()) {
    activeColor = COLORS[1];
  } else if (yellowButton.overButton()) {
    activeColor = COLORS[2];
  } else if (blueButton.overButton()) {
    activeColor = COLORS[3];
  }
  
  //Weight
  if (thinButton.overButton()) {
    activeWeight = WEIGHTS[0];
  } else if (mediumButton.overButton()) {
    activeWeight = WEIGHTS[1];
  } else if (thickButton.overButton()) {
    activeWeight = WEIGHTS[2];
  }
}
