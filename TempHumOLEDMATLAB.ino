/**********************************
   Temperature and humidity display
   Use a DHT22 sensor to acquire data
   about room relative humidity and
   temperature and display the values
   on a 0.96" OLED screen. Also log
   data on MATLAB.
***********************************/

// Libraries
#include <SPI.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <DHT.h>

#define OLED_RESET 4
Adafruit_SSD1306 display(OLED_RESET);

#if (SSD1306_LCDHEIGHT != 64)
#error("Height incorrect, please fix Adafruit_SSD1306.h!");
#endif

// Initialize DHT sensor for normal 16mhz Arduino
DHT dht(2, DHT22);

// Variables
float hum;                    // Stores humidity value
float temp;                   // Stores temperature value
float humidex;                // Stores humidex index value
unsigned int interval = 10;   // Time between logging in seconds

void setup() {
  Serial.begin(9600);

  // sensor init
  dht.begin();

  // by default, we'll generate the high voltage from the 3.3v line internally! (neat!)
  display.begin(SSD1306_SWITCHCAPVCC, 0x3C);  // initialize with the I2C addr 0x3D (for the 128x64)
  // init done

  // Show image buffer on the display hardware
  // Since the buffer is intialized with an Adafruit splashscreen
  // internally, this will display the splashscreen
  display.display();
  delay(2000);

  // Clear the buffer
  display.clearDisplay();

  // Convert interval in milliseconds
  interval = interval * 1000;
}

void loop() {

  // Read humidity and temperature
  hum = dht.readHumidity();
  Serial.print(hum,1);
  Serial.print(":");

  temp = dht.readTemperature();
  Serial.print(temp,1);
  Serial.print(":");

  // Display values on screen
  display.setTextSize(2);
  display.setTextColor(WHITE);
  display.setCursor(0, 0);
  display.println("Room data");
  display.print("Tmp: ");
  display.print(temp,1);
  display.println("C");

  display.print("Hum: ");
  display.print(hum,1);
  display.println("%");
  //display.display();

  // Calculates humidex index and display its status
  humidex = temp + (0.5555 * (0.06 * hum * pow(10,0.03*temp) -10));
  Serial.println(humidex,1);

  // Humidex category
  if (humidex < 20){
//    Serial.println("No index");
    display.println("No index");
  }
  else if (humidex >= 20 && humidex < 27){
//    Serial.println("Comfort");
    display.println("Comfort");
  }
  else if (humidex >= 27 && humidex < 30){
//    Serial.println("Caution");
    display.println("Caution");
  }
  else if (humidex >= 30 && humidex < 40){
//    Serial.println("Extreme caution");
    display.println("CAUTION");
  }
  else if (humidex >= 40 && humidex < 55){
//    Serial.println("Danger");
    display.println("Danger");
  }
  else {
//    Serial.println("Extreme danger");
    display.println("DANGER");
  }

  display.display();

  delay(interval);
  display.clearDisplay();

}
