import processing.serial.*; 
import processing.net.*;

Server myServer;
Client c;
String data;
String[] a;
int end = 10;    // the number 10 is ASCII for linefeed (end of serial.println), later we will look for this to break up individual messages
String serial;   // declare a new string called 'serial' . A string is a sequence of characters (data type know as "char")
String val;     // Data received from the serial port
int cont;
Serial myPort;  // The serial port, this is a new instance of the Serial class (an Object)

void setup()
{
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
}

void draw()
{
  //if (cont == 0) {
  //  delay(2000);
  //  myPort.write("1,0");
  //  cont = 1;
  //}
  
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
