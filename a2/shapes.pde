abstract class Shape {
  float startX, startY, endX, endY;
  color c;
  int w;

  Shape(float startX, float startY, float endX, float endY, color c, int w) {
    this.startX = startX;
    this.startY = startY;
    this.endX = endX;
    this.endY = endY;
    this.c = c;
    this.w = w;
  }
  
  abstract void display();
}

class FFLine extends Line {
  int startTime;
  
  FFLine(float startX, float startY, float endX, float endY, color c, int w, int startTime) {
    super(startX, startY, endX, endY, c, w);
    this.startTime = startTime;
  }

  int getStartTime() {
    return startTime;
  }
}

class Line extends Shape {
  Line(float startX, float startY, float endX, float endY, color c, int w) {
    super(startX, startY, endX, endY, c, w);
  }
  
  void display() {
    stroke(c);
    strokeWeight(w);
    line(startX, startY, endX, endY);
  }
}

class Rectangle extends Shape {
  Rectangle(float startX, float startY, float endX, float endY, color c, int w) {
    super(startX, startY, endX, endY, c, w); //<>//
  }

  void display() {
    stroke(0);
    strokeWeight(w);
    fill(c);
    rectMode(CORNERS);
    rect(startX, startY, endX, endY);
  }
}

class Ellipse extends Shape {
  Ellipse(float startX, float startY, float endX, float endY, color c, int w) {
    super(startX, startY, endX, endY, c, w);
  }
  
  void display() {
    stroke(0);
    strokeWeight(w);
    fill(c);
    ellipseMode(CORNERS);
    ellipse(startX, startY, endX, endY);
  }
}
