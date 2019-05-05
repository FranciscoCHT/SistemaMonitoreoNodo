// Include Emon Library
#include "EmonLib.h"
//#include <avr/sleep.h> //Contiene los metodos que controlan los modos sleep
 
// Crear una instancia EnergyMonitor
EnergyMonitor energyMonitor;
 
// Voltaje de nuestra red eléctrica
float voltajeRed = 220.0; // Voltaje red
float nLecturas = 900; // Lecturas cada x segundos
float sec = 3600; //Segundos para todas las lecturas (1 hora = KwH = 3600 segundos)
float precioKwh = 74.975;  // Precio por kwh
char val;

//Formula Calculo Kwh
//    Kwh = voltajeRed * Irms * (1/sec) * nLecturas
//          -------------------------------------------       // Potencia = voltajeRed * Irms
//                            1000 
 
void setup()
{
  Serial.begin(9600);
  
  // Iniciamos la clase indicando
  // Número de pin: donde tenemos conectado el SCT-013
  // Valor de calibración: valor obtenido de la calibración teórica
  energyMonitor.current(0, 2.6);
}
 
void loop()
{
  if (Serial.available()) 
  { // If data is available to read,
    val = Serial.read(); // read it and store it in val

    if (val == '1') {
      // Obtenemos el valor de la corriente eficaz
      // Pasamos el número de muestras que queremos tomar
      double Irms = energyMonitor.calcIrms(1484);
     
      // Calculamos la potencia aparente (watt)
      double potencia =  Irms * voltajeRed;
    
      // Calculamos el Kilowatt Hora
      // Se utiliza la formula de Kwh, sustituyendo Potencia = voltajeRed * Irms
      double kwh = (potencia * (1/sec) * nLecturas) / 1000;
    
      // Calcuamos el precio por Kwh de la lectura actual
      double precio = kwh * precioKwh;
      
      // Mostramos la información por el monitor serie
      //Serial.print("Potencia = ");
      Serial.print(Irms, 7);
      Serial.print(",");
      Serial.print(potencia, 7);
      Serial.print(",");
      Serial.print(kwh, 7);
      Serial.print(",");
      Serial.println(precio, 7);
      //delay(10000);  
    }
  }
}
/*
void Going_To_Sleep {
  sleep_enable();
  set_sleep_mode(SLEEP_MODE_PWR_DOWN);
  delay(1000);
  sleep_cpu();
}*/
