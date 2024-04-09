/**
Depei Wang-9.4.2024
This program is a transform of star field from Processing code and displayed on a
128*64 i2c screen, and the "flying" speed could change by attach the wire to pin
13 or 8.
*/
#include <Adafruit_GFX.h>
#include <Adafruit_SH110X.h>

#define i2c_Address 0x3c //initialize with the I2C addr 0x3C Typically eBay OLED's
#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
#define NUM_STARS 250

// Initialize with the I2C addr 0x3C (for the 128x64)
Adafruit_SH1106G display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1);

int buttonState = 0;
unsigned long startScan = 0UL;
const unsigned long intervalON = 500UL;//how long one scan last
bool buttonError = false;
float speed;
class Star {
public:
  float x, y, z;

  Star() {
    reset(true);
  }

  void update() {
    z -= speed;
    if (z <= 20) reset(false);// Only reset position, not speed
  }

  // void reset() {
  //   x = random(-2000, 2000);
  //   y = random(-3000, 3000);
  //   z = 2000.0;
  // }

  void reset(bool init = false) {
    x = random(-2000, 2000);
    y = random(-3000, 3000);
    z = random(1000, 2000); // Vary the starting z to make the field more dynamic
    if (init) speed = random(10, 60); // Initialize speed only once
  }

  void draw() {
    float offsetX = 100.0 * (x / z) + SCREEN_WIDTH / 2;
    float offsetY = 100.0 * (y / z) + SCREEN_HEIGHT / 2;
    float scaleZ = 0.0001 * (2000.0 - z);

    display.fillCircle(offsetX, offsetY, scaleZ * 17, SH110X_WHITE); //Old version
    // int brightness = map(z, 20, 2000, 0, 255); // Use the z value to scale brightness
    // display.drawPixel(offsetX, offsetY, display.color565(brightness, brightness, brightness));
  }
};

Star stars[NUM_STARS];

void button(){//Detect pin voltage change for 0.5s, filter out unwanted signal
  
  switch(buttonState){
    case 0:
      startScan = millis();
      buttonState = 1;
    break;
    case 1:
     if(digitalRead(13) == HIGH){buttonState = 2;}
     if(digitalRead(8) == HIGH){buttonState = 3;}
    break;
    case 2:
      if(millis()-startScan > intervalON){
        if(digitalRead(13) == HIGH){
          Serial.write(1);
          speed += 10;
        }else{buttonState = 0;}
      }
      buttonState = 0;
    break;
    case 3:
    if(millis()-startScan > intervalON){
        if(digitalRead(8) == HIGH){
          Serial.write(3);
          if(speed > 2){speed -= 10;}
        }else{buttonState = 0;}
      }
      buttonState = 0;
    break;
    default: buttonError = true;
  }
}

void setup() {
  Serial.begin(9600);
  pinMode(13,INPUT);
  pinMode(8,INPUT);
  //display.begin(SH1106G_SWITCHCAPVCC, 0x3C);
  display.begin(i2c_Address, true); // Address 0x3C default
  display.display();
  delay(1000);
  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(SH110X_WHITE);
  for (int i = 0; i < NUM_STARS; i++) stars[i] = Star();
}

void loop() {
  display.clearDisplay();
  button();//Detect wether button is pressed
  for (int i = 0; i < NUM_STARS; i++) {//draw and update stars
    stars[i].update();
    stars[i].draw();
  }

  display.display();
  delay(30);
}
