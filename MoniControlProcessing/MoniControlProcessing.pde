import de.bezier.data.sql.*;
import de.bezier.data.sql.mapper.*;
import processing.serial.*; 
import processing.net.*;

MySQL msql;      //Create MySQL Object
String[] a;
int end = 10;    // the number 10 is ASCII for linefeed (end of serial.println), later we will look for this to break up individual messages
String serial;   // declare a new string called 'serial' . A string is a sequence of characters (data type know as "char")
String val;     // Data received from the serial port
int cont;
Serial myPort;  // The serial port, this is a new instance of the Serial class (an Object)
Server myServer;
Client c;
int time;
int wait = 15000;

void setup()
{
  String user     = "admin";
  String pass     = "admin";
  String database = "bdsistemamce";
  msql = new MySQL( this, "localhost", database, user, pass );

  size(200, 200);
  myServer = new Server(this, 5204, "192.168.0.3");
  
  // I know that the first port in the serial list on my mac
  // is Serial.list()[0].
  // On Windows machines, this generally opens COM1.
  // Open whatever port is the one you're using.
  String portName = Serial.list()[1]; //change the 0 to a 1 or 2 etc. to match your port
  myPort = new Serial(this, portName, 9600);
  //myPort.clear();  // function from serial library that throws out the first reading, in case we started reading in the middle of a string from Arduino
  //val = myPort.readStringUntil(end); // function that reads the string from serial port until a println and then assigns string to our string variable (called 'serial')
  //val = null; // initially, the string will be null (empty)
  cont = 0;
  
  time = millis();//store the current time
}

void draw()
{
  if (cont == 0) {
    delay(2000);
    myPort.write("1.0");
    cont = 1;
  }

  //println(myPort.available());
  if(millis() - time >= wait){
    println("tick");//if it is, do something
    time = millis();//also update the stored time
    myPort.write("1.0");
    println("writing 1"); //Precio por Kwh calculado de la lectura actual
  }
  
  if ( myPort.available() > 0) 
  {  // If data is available,
    val = myPort.readStringUntil('\n');         // read it and store it in val
    //println(val);

    if (val != null) {
      a = split(val, ',');  //a new array (called 'a') that stores values into separate cells (separated by commas specified in your Arduino program)
      println(a[1]); //Corriente eficaz (Irms: intensidad) de la lectura actual. Valor usado para calcular la potencia (Potencia = Voltaje * Irms)
      println(a[2]); //ID del nodo de los datos entrantes
      println(a[3]); //Potencia en watts de la lectura actual
      println(a[4]); //Kwh calculado de la lectura actual
      println(a[5]); //Precio por Kwh calculado de la lectura actual
      sendData();
      //val = null;
      //delay(9000);
    }
  }
  
  // Get the next available client
  Client thisClient = myServer.available();
  // If the client is not null, and says something, display what it said
  if (thisClient !=null) {
    String whatClientSaid = thisClient.readString();
    if (whatClientSaid != null) {
      a = split(whatClientSaid, '?');
      a[0] = "";
      println(a[1]); //Dato entrante
      myPort.write(a[1]);
      //println(thisClient.ip() + " " + whatClientSaid);
    } 
    thisClient.write("HTTP/1.1 200 OK\r\nContent-Length: 2\r\n\r\nOK\r\n");
    //println(thisClient.ip() + " ha sido desconectado");
  } 
}

void sendData()
{
  if ( msql.connect() )
    {
      //msql.query( "insert into lectura(Irms, FechaHora, Nodo_ID, Watt, Kwh, Precio)values(" + a[1] + "," + "now()" + "," + a[2] + "," + a[3] + "," + a[4] + "," + a[5] + ")" );
    } 
  else
    {
      // connection failed !
    }
    msql.close();  //Must close MySQL connection after Execution
}
