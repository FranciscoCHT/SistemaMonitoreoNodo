#include <avr/sleep.h> //Contiene los metodos que controlan los modos sleep
#include <avr/power.h>
#include <SoftwareSerial.h>
SoftwareSerial mySerial(3, 2); // RX, TX
const int ledPin =  LED_BUILTIN;
const int idNodo = 6;
 
String val;

void setup()
{
  Serial.begin(9600);
  mySerial.begin(9600);
  pinMode(ledPin, OUTPUT);
  digitalWrite(ledPin, HIGH);
  power_all_enable();
}
 
void loop()
{
  if (mySerial.available()) 
  { // If data is available to read,
    val = mySerial.readStringUntil('\n'); // read it and store it in val
    
    if (val == "E," + idNodo) {
      //mySerial.print("Serial: Entering Sleep mode");
      delay(100);     // this delay is needed, the sleep
                      //function will provoke a Serial error otherwise!!
      goToSleep();
    } else if (val == "A," + idNodo) {
      //mySerial.print("Serial: Entering Sleep mode");
      delay(100);     // this delay is needed, the sleep
                      //function will provoke a Serial error otherwise!!
      goToSleep();
    } else {
      //mySerial.print("Serial: Entering Sleep mode");
      delay(100);     // this delay is needed, the sleep
                      //function will provoke a Serial error otherwise!!
      goToSleep();
    }
  }
}

void goToSleep()
{
  /* Now is the time to set the sleep mode. In the Atmega8 datasheet
  * http://www.atmel.com/dyn/resources/prod_documents/doc2486.pdf on page 35
  * there is a list of sleep modes which explains which clocks and
  * wake up sources are available in which sleep modus.
  *
  * In the avr/sleep.h file, the call names of these sleep modus are to be found:
  *
  * The 5 different modes are:
  * SLEEP_MODE_IDLE -the least power savings
  * SLEEP_MODE_ADC
  * SLEEP_MODE_PWR_SAVE
  * SLEEP_MODE_STANDBY
  * SLEEP_MODE_PWR_DOWN -the most power savings
  *
  */

  set_sleep_mode(SLEEP_MODE_IDLE); // sleep mode is set here

  sleep_enable(); // enables the sleep bit in the mcucr register
  // so sleep is possible. just a safety pin

  power_adc_disable();
  power_spi_disable();
  power_timer0_disable();
  power_timer1_disable();
  power_timer2_disable();
  power_twi_disable();

  digitalWrite(ledPin, LOW);

  sleep_mode(); // here the device is actually put to sleep!!

  // THE PROGRAM CONTINUES FROM HERE AFTER WAKING UP
  
  sleep_disable(); // first thing after waking from sleep:
  // disable sleep...
  digitalWrite(ledPin, HIGH);

  power_all_enable();

}
