/*** 
Depei Wang-9.4.2.24
This project was inspired by Daniel Shiffman's Code from: https://youtu.be/17WoOqgXsRM.And on the top of that
I added serial interface to change speed and made it full screen display, also made it run on the Arduino.
**/

import processing.serial.*;
// I create an array named "stars",
// it will be filled with 800 elements made with the Star() class.
Star[] stars = new Star[800];
// The serial port:
Serial myPort;
// List all the available serial ports:

// I create a variable "speed", it'll be useful to control the speed of stars.
float speed;

// I create a "Star" Class.
class Star {
  // I create variables to specify the x and y of each star.
  float x;
  float y;
  // I create "z", a variable I'll use in a formula to modify the stars position.
  float z;

  // I create an other variable to store the previous value of the z variable.
  // (the value of the z variable at the previous frame).
  float pz;

  Star() {
    // I place values in the variables
    x = random(-width/2, width/2);
    // note: height and width are the same: the canvas is a square.
    y = random(-height/2, height/2);
    // note: the z value can't exceed the width/2 (and height/2) value,
    // beacuse I'll use "z" as divisor of the "x" and "y",
    // whose values are also between "0" and "width/2".
    z = random(width/2);
    // I set the previous position of "z" in the same position of "z",
    // which it's like to say that the stars are not moving during the first frame.
    pz = z;
  }

  void update() {
    // In the formula to set the new stars coordinates
    // I'll divide a value for the "z" value and the outcome will be
    // the new x-coordinate and y-coordinate of the star.
    // Which means if I decrease the value of "z" (which is a divisor),
    // the outcome will be bigger.
    // Wich means the more the speed value is bigger, the more the "z" decrease,
    // and the more the x and y coordinates increase.
    // Note: the "z" value is the first value I updated for the new frame.
    z = z - speed;
    // when the "z" value equals to 1, I'm sure the star have passed the
    // borders of the canvas( probably it's already far away from the borders),
    // so i can place it on more time in the canvas, with new x, y and z values.
    // Note: in this way I also avoid a potential division by 0.
    if (z < 1) {
      z = width/2;
      x = random(-width/2, width/2);
      y = random(-height/2, height/2);
      pz = z;
    }
  }

  void show() {
    fill(255);
    noStroke();

    // with theese "map", I get the new star positions
    // the division x / z get a number between 0 and a very high number,
    // we map this number (proportionally to a range of 0 - 1), inside a range of 0 - width/2.
    // In this way we are sure the new coordinates "sx" and "sy" move faster at each frame
    // and which they finish their travel outside of the canvas (they finish when "z" is less than a).

    float sx = map(x / z, 0, 1, 0, width/2);
    float sy = map(y / z, 0, 1, 0, height/2);

    // I use the z value to increase the star size between a range from 0 to 16.
    float r = map(z, 0, width/2, 10, 0);
    ellipse(sx, sy, r, r);

    // Here i use the "pz" valute to get the previous position of the stars,
    // so I can draw a line from the previous position to the new (current) one.
    float px = map(x / pz, 0, 1, 0, width/2);
    float py = map(y / pz, 0, 1, 0, height/2);

    // Placing here this line of code, I'm sure the "pz" value are updated after the
    // coordinates are already calculated; in this way the "pz" value is always equals
    // to the "z" value of the previous frame.
    pz = z;

    stroke(255);
    line(px, py, sx, sy);

  }
}

void setup() {
  //size(1000, 800);
  fullScreen();
  printArray(Serial.list());
  myPort = new Serial(this, Serial.list()[0], 9600);
  // I fill the array with a for loop;
  // running 800 times, it creates a new star using the Star() class.
  for (int i = 0; i < stars.length; i++) {
    stars[i] = new Star();
  }
  speed = 0.5;//intial speed 0.5
}

void draw() {
  //Changing speed according to button pressed
  while (myPort.available() > 0) {
    int inByte = myPort.read();
    //println(inByte);
    //pin 13 was pressed speed increase 2
    if (inByte == 1){speed += 2; println("speed:" ,speed); inByte = 0;}
    //pin 8 was pressed and if speed greater than 2 then spped decrease 2
    if (inByte == 3){if(speed >2){speed -= 2; println("speed:" ,speed); inByte = 0;}}
  }
  //speed = map(mouseX, 0.1, width, 0.5, 23); //Conflict with serial interface
  background(0);
  // I shift the entire composition,
  // moving its center from the top left corner to the center of the canvas.
  translate(width/2, height/2);
  // I draw each star, running the "update" method to update its position and
  // the "show" method to show it on the canvas.
  for (int i = 0; i < stars.length; i++) {
    stars[i].update();
    stars[i].show();
  }
}
