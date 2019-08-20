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
float voltajeRed = 220.0; // Voltaje red
int nLecturas = 900; // 900 seg = 15 minutos // Lecturas cada x segundos
float sec = 3600; //Segundos para todas las lecturas (1 hora = KwH = 3600 segundos)
float precioKwh = 74.975;  // Precio por kwh
float potencia = 0;
float kwh = 0;
float precio = 0;

void setup()
{
  String user     = "admin";
  String pass     = "admin";
  String database = "bdsistemamce";
  msql = new MySQL( this, "localhost", database, user, pass );

  size(200, 200);
  myServer = new Server(this, 5204, "192.168.0.2");
  
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
    String[] lines = loadStrings("configuracion.txt");
    String[] valor1 = split(lines[1], ':');
    String[] valor2 = split(lines[3], ':');
    nLecturas = int(trim(valor1[1]));
    precioKwh = float(trim(valor2[1]));
    wait = int(trim(valor1[1]))*1000;
    println(nLecturas);
    println(precioKwh);
    println(wait);
    
    String tablaCalib = "";
    if ( msql.connect() ){
      msql.query("SELECT id, fcalibracion FROM nodo WHERE tipo = 0");
      while (msql.next()){
        int idfcalib = msql.getInt("id");
        float fcalib = msql.getFloat("fcalibracion");
        tablaCalib = tablaCalib + idfcalib + ":" + fcalib + ";";
        // println(tablaCalib);
      }
    } else {
      // connection failed !
    } msql.close();
    
    delay(2000);
    myPort.write("1.0;" + tablaCalib);
    cont = 1;
  }

  //println(myPort.available());
  if(millis() - time >= wait){
    String[] lines = loadStrings("configuracion.txt");
    String[] valor1 = split(lines[1], ':');
    String[] valor2 = split(lines[3], ':');
    nLecturas = int(trim(valor1[1]));
    precioKwh = float(trim(valor2[1]));
    wait = int(trim(valor1[1]))*1000;
    println("\n"+nLecturas);
    println(precioKwh);
    println(wait);
    
    String tablaCalib = "";
    if ( msql.connect() ){
      msql.query("SELECT id, fcalibracion FROM nodo WHERE tipo = 0");
      while (msql.next()){
        int idfcalib = msql.getInt("id");
        float fcalib = msql.getFloat("fcalibracion");
        tablaCalib = tablaCalib + idfcalib + ":" + fcalib + ";";
        // println(tablaCalib);
      }
    } else {
      // connection failed !
    } msql.close();
    
    time = millis();//also update the stored time
    myPort.write("1.0;" + tablaCalib);
    println("writing 1"); 
  }
  
  if ( myPort.available() > 0) 
  {  // If data is available,
    val = myPort.readStringUntil('\n');         // read it and store it in val
    //println(val);

    if (val != null) {
      a = split(val, ',');  //a new array (called 'a') that stores values into separate cells (separated by commas specified in your Arduino program)
      println(a[1].substring(0, a[1].length()-1)); //Corriente eficaz (Irms: intensidad) de la lectura actual. Valor usado para calcular la potencia (Potencia = Voltaje * Irms)
      print(a[2]); //ID del nodo de los datos entrantes
      
      if ( msql.connect() ){
        msql.query("SELECT voltaje FROM nodo WHERE id = " + a[2]);
        msql.next();
        voltajeRed = msql.getFloat("voltaje");
      } else {
        // connection failed !
      } msql.close();

      potencia = float(a[1].substring(0, a[1].length()-1)) * voltajeRed;//println(a[3]); //Potencia en watts de la lectura actual
      println(potencia);
      kwh = (potencia * (1/sec) * nLecturas) / 1000; //println(a[4]); //Kwh calculado de la lectura actual
      println(kwh);
      precio = kwh * precioKwh; //println(a[5]); //Precio por Kwh calculado de la lectura actual
      println(precio);
      sendData();
      myPort.clear();
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
      //msql.query( "insert into lectura(Irms, FechaHora, Nodo_ID, Watt, Kwh, Precio)values(" + a[1] + "," + "now()" + "," + a[2] + "," + potencia + "," + kwh + "," + precio + ")" );
    } 
  else
    {
      // connection failed !
    }
    msql.close();  //Must close MySQL connection after Execution
}
