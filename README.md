# TempHumOLEDMATLAB
Temperature, humidity and humidex display. Use a DHT22 sensor to acquire data about room relative humidity and temperature and display the values on a 0.96" OLED screen. It may also log data with MATLAB.

## More details
Connect an Arduino with a DHT22 sensor and a SSD1306 0.96" display to show temperature, humidity and humidex in real time. Data are also sent via serial port, allowing logging data with MATLAB for a given time period and live plotting the last 10 minutes of data. At the end of the acquisition time, final charts with data points, smoothed curves and accuracy boundaries are shown. The entire data set is also written on a spreadsheet file. See the [example folder](example/).

The device works also alone, just displaying live values of temperature, humidity and humidex on the OLED screen. Default acquisition rate is 10 seconds.

As concern the main file `TempHumOLEDMATLAB.ino` check the following lines:
- line 41 `unsigned int interval` for the interval between data acquisition and display update
- line 49 `display.begin(SSD1306_SWITCHCAPVCC, 0x3C)` for the display I2C address
- from line 94 the serial write of the humidex text strings is disabled to allow MATLAB read data values from the serial port. If not interested in MATLAB, but want to show those text strings, uncomment those lines.

As concern the MATLAB file for log and plot `TempHumOLEDMATLAB.m` check the follwing lines:
- line 24 `waitTime` for the recording time
- line 29 `s = serial('/address/to/serialPort','BAUD',9600)` for the serial port address and baud rate

Again, connection to MATLAB is not mandatory.
