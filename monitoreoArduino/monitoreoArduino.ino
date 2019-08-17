// Include Emon Library
#include "EmonLib.h"
#include <avr/sleep.h> //Contiene los metodos que controlan los modos sleep
#include <avr/power.h>
#include <SoftwareSerial.h>
SoftwareSerial mySerial(3, 2); // RX, TX
const int ledPin =  LED_BUILTIN;
const int idNodo = 7;
 
// Crear una instancia EnergyMonitor
EnergyMonitor energyMonitor;
 
// Voltaje de nuestra red eléctrica
float voltajeRed = 220.0; // Voltaje red
float nLecturas = 900; // Lecturas cada x segundos
float sec = 3600; //Segundos para todas las lecturas (1 hora = KwH = 3600 segundos)
float precioKwh = 74.975;  // Precio por kwh
String val;
float fcalibracion = 0;

//Formula Calculo Kwh
//    Kwh = voltajeRed * Irms * (1/sec) * nLecturas
//          -------------------------------------------       // Potencia = voltajeRed * Irms
//                            1000 
 
void setup()
{
  Serial.begin(9600);
  mySerial.begin(9600);
  pinMode(ledPin, OUTPUT);
  digitalWrite(ledPin, HIGH);
  power_all_enable();
  // Iniciamos la clase indicando
  // Número de pin: donde tenemos conectado el SCT-013
  // Valor de calibración: valor obtenido de la calibración teórica
  // energyMonitor.current(0, 2.65);
}
 
void loop()
{
  if (mySerial.available() && fcalibracion != 0) 
  { // If data is available to read,
    val = mySerial.readStringUntil('\n'); // read it and store it in val

    if (val == "1.0") {
      // Obtenemos el valor de la corriente eficaz
      // Pasamos el número de muestras que queremos tomar
      double Irms = energyMonitor.calcIrms(1484);
     
      // Calculamos la potencia aparente (watt)
      //double potencia =  Irms * voltajeRed;
    
      // Calculamos el Kilowatt Hora
      // Se utiliza la formula de Kwh, sustituyendo Potencia = voltajeRed * Irms
      //double kwh = (potencia * (1/sec) * nLecturas) / 1000;
    
      // Calcuamos el precio por Kwh de la lectura actual
      //double precio = kwh * precioKwh;
      
      // Mostramos la información por el monitor serie
      //Serial.print("Potencia = ");
      mySerial.print(",");
      mySerial.print(Irms, 3);
      mySerial.print(",");
      mySerial.println(idNodo);
      //mySerial.print(",");
      //mySerial.print(potencia, 7);
      //mySerial.print(",");
      //mySerial.print(kwh, 7);
      //mySerial.print(",");
      //mySerial.println(precio, 7);
      mySerial.end();
      mySerial.begin(9600);
      //mySerial.print("Serial: Entering Sleep mode");
      delay(100);     // this delay is needed, the sleep
                      //function will provoke a Serial error otherwise!!
      goToSleep();
      //delay(10000);  
    } else {
      delay(100);
      goToSleep();
    }
  }
  else if (mySerial.available() && fcalibracion == 0)
  {
    fcalibracion = 2.65;
    energyMonitor.current(0, fcalibracion);
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
