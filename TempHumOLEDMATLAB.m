% Script to log data from a DHT22 sensors with an Arduino (Nano)
% microcontroller. Acquire data from the sensors until a time limit is
% reached. Plot last 10 minutes of live data during acquisition, the entire
% data set after the acquisition, and save these data on a spreadsheet.

close all
instrreset
clear
clc

% Acquisition time (min)
waitTime = 60;

%% Acquire and display live data

% Open serial communication
s = serial('/dev/cu.wchusbserial410','BAUD',9600);

figure
yyaxis left
h(1) = animatedline('LineWidth',2,'Color',[0, 0.4470, 0.7410]);
axh = gca;
axh.YLim = [30 80];
xlabel('Time')
ylabel('Humidity (%)')

yyaxis right
h(2) = animatedline('LineWidth',2,'Color',[0.8500, 0.3250, 0.0980]);
axt = gca;
axt.YLim = [10 40];
xlabel('Time')
ylabel('Temperature (\circC)')

h(3) = animatedline('LineWidth',2,'Color','r','LineStyle','--');

legend('Humidty','Temperature','Humidex')

waitTime = duration(0,waitTime,0);
startTime = datetime('now');
t = datetime('now') - startTime;

while t < waitTime
    
    % Read data from serial port
    fopen(s);
    idn = fscanf(s);
    fclose(s);
    
    % Separate data
    C = strsplit(idn,':');
    
    % Display data in MATLAB command window
    disp(str2double(C))
    
    % Get current time
    t = datetime('now') - startTime;
    
    yyaxis left
    addpoints(h(1),datenum(t),str2double(C{1}))
    
    yyaxis right
    addpoints(h(2),datenum(t),str2double(C{2}))
    addpoints(h(3),datenum(t),str2double(C{3}))
       
    % Update axes
    axh.XLim = datenum([t-seconds(600) t]);
    datetick('x','keeplimits')
    drawnow
    
end

%% Plot the recorded data

[~,humLogs] = getpoints(h(1));
[~,tempLogs] = getpoints(h(2));
[timeLogs,huxLogs] = getpoints(h(3));
timeSecs = (timeLogs-timeLogs(1))*24*3600;

%% Summary charts with original data, averaged data, and uncertainty

% Smooth out readings with moving average filter
smoothHum = smooth(humLogs,25);
smoothTemp = smooth(tempLogs,25);
smoothHux = smooth(huxLogs,25);

% Typical accuracy of the humidity sensor
humMax = 1.02 * smoothHum;
humMin = 0.98 * smoothHum;

% Worst accuracy of the humidity sensor
humMaxW = 1.05 * smoothHum;
humMinW = 0.95 * smoothHum;

% Accuracy of the temperature sensor
tempMax = smoothTemp + 0.5;
tempMin = smoothTemp - 0.5;

figure
subplot(1,2,1), hold on
p(1) = plot(timeSecs,humLogs,'+','Color',[0, 0.4470, 0.7410],'LineWidth',2);
p(2) = plot(timeSecs,smoothHum,'b-','LineWidth',1);
p(3) = plot(timeSecs,humMin,'--','Color',[0, 0.4470, 0.7410],'LineWidth',2);
plot(timeSecs,humMax,'--','Color',[0, 0.4470, 0.7410],'LineWidth',2)
p(4) = plot(timeSecs,humMinW,'b--','LineWidth',1);
plot(timeSecs,humMaxW,'b--','LineWidth',1)
hold off, grid on, ylim([round(min(humMinW))-2, round(max(humMaxW))+2])
xlabel('Elapsed time (s)')
ylabel('Humidity (%)')
title('Humidity data with moving average and uncertainty')
legend(p,'Logged data','Averaged data','2% accuracy','5% accuracy')

clear p

subplot(1,2,2), hold on
p(1) = plot(timeSecs,tempLogs,'+','Color',[0.8500, 0.3250, 0.0980],'LineWidth',2);
p(2) = plot(timeSecs,smoothTemp,'r-','LineWidth',1);
p(3) = plot(timeSecs,tempMin,'r--','LineWidth',2);
plot(timeSecs,tempMax,'r--','LineWidth',2)
p(4) = plot(timeSecs,smoothHux,'k-.','LineWidth',2);
hold off, grid on, ylim([round(min(tempMin))-2, round(max(tempMax))+2])
xlabel('Elapsed time (s)')
ylabel('Temperature (\circC)')
title('Temperature data with moving average and uncertainty')
legend(p,'Logged data','Averaged data','\pm0.5\circC accuracy','Humidex')

%% Save results to a file

T = table(timeSecs',humLogs',tempLogs',huxLogs','VariableNames',...
    {'Time_s','Relative_Humidity','Temperature_C','Humidex'});
filename = 'Humidity_and_Temperature_Data.xls';

% Write table to file
writetable(T,filename)

% Print confirmation to command line
fprintf('Results table with %g humidity and temperature measurements saved to file %s\n',...
    length(timeSecs),filename)