#include "TimeLib.h"
#include <Servo.h>

Servo myservo;

int state = 0;

// Servo position where the rotor hole is aligned with the bottom hole
int pos_release = 83;

// Servo position where the rotor hole is aligned with the top hole
int pos_take = 35;

// Number of doses given each time the feeder fires
int n_portions = 1;


void setup() {
  Serial.begin(9600);
  pinMode(13, OUTPUT);
  myservo.attach(9);
  myservo.write(pos_take);
}

void turnDatShit() {
  myservo.write(pos_take);
  delay(1000);
  myservo.write(pos_release);
  delay(1000);
}

// You may want to change this to your custom schedule.
// The time starts at 0 when you power the arduino on.
int shouldDistribute() {
  return second() == 0 && minute() == 10 && (
    hour() == 0 ||
    hour() == 14
  );
}

void printDigits(int digits){
  // utility function for digital clock display: prints preceding colon and leading 0
  Serial.print(":");
  if(digits < 10)
    Serial.print('0');
  Serial.print(digits);
}

void printTime() {  
  // digital clock display of the time
  Serial.print(hour());
  printDigits(minute());
  printDigits(second());
  Serial.print(" ");
  Serial.print(day());
  Serial.print(" ");
  Serial.print(month());
  Serial.print(" ");
  Serial.print(year()); 
  Serial.println(); 
}

void loop(){
  if (shouldDistribute()) {
    for (int i = 0 ; i < n_portions ; i++) {
      turnDatShit();
    }
    delay(1001); // Makes sure we don't double spend
  }
  if (timeStatus() == timeSet) {
    digitalWrite(13, HIGH); // LED on if synced
  } else {
    digitalWrite(13, LOW);  // LED off if needs refresh
  }
  delay(500);
  printTime();
}
