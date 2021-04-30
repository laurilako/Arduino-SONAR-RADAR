#include <Servo.h>
#include <SoftwareSerial.h>

#define pinServo 7
#define pinTrig1 11
#define pinEcho1 10
#define pinTrig2 13
#define pinEcho2 12
SoftwareSerial MyBlue(2, 3);
int flag = 0;

Servo servo;
int scanAngle = 0;
int scanDirection = 1;
unsigned long etaisyys1, etaisyys2;

void setup()
{
  servo.attach(pinServo);
  Serial.begin(9600);
  MyBlue.begin(9600);
  pinMode(pinServo, OUTPUT);
  pinMode(pinTrig1, OUTPUT);
  pinMode(pinEcho1, INPUT);
  pinMode(pinTrig2, OUTPUT);
  pinMode(pinEcho2, INPUT);

}

unsigned long haeEtaisyys(int pinTrigger, int pinEcho, int kesto)
{
  digitalWrite(pinTrigger, HIGH);
  delayMicroseconds(kesto);
  digitalWrite(pinTrigger, LOW);
  return pulseIn(pinEcho, HIGH) / 29 / 2;
}

void loop()
{
  servo.write(scanAngle); delay (100);

  etaisyys1 = haeEtaisyys(pinTrig1, pinEcho1, 10);
  etaisyys2 = haeEtaisyys(pinTrig2, pinEcho2, 10);

  MyBlue.println(String() + scanAngle + "a" + etaisyys1 + "b" + etaisyys2 + "c");

  if (scanAngle + scanDirection == 180 || scanAngle + scanDirection == -1)
    scanDirection *= -1;
  scanAngle = scanAngle + scanDirection;
}
