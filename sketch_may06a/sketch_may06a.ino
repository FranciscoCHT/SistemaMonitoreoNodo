#include <SoftwareSerial.h>
SoftwareSerial mySerial(3, 2); // RX, TX
void setup()
{
 Serial.begin(9600);
 mySerial.begin(9600);
 pinMode(8, INPUT);
}
void loop()
{
 if(mySerial.available() > 0)
 {
 int dato = mySerial.read();
 if(dato == 's')
 {
 boolean value = digitalRead(8);
 mySerial.print("Estado del pin 8: ");
 if(value == LOW)
 {
 mySerial.println("LOW");
 }
 else if(value == HIGH)
 {
 mySerial.println("HIGH");
 }
 }
 else
 {
 mySerial.println("Caracter no valido");
 }
 }
}
