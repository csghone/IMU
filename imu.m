clc
clear all
close all

function [tsAccl, accl, tsGyro, gyro] = readData (filename)
  acclIndex = 1;
  gyroIndex = 1;
  fid = fopen (filename, "r");
  while(true)
      [ts, type, x, y, z, count, errorMsg] = fscanf(fid, "%g, %s %g, %g, %g", "C");
      if(count == 0)
          acclIndex
          gyroIndex
          break;
      endif
      if (type == "ACCL,")
          tsAccl(acclIndex) = ts;
          accl(1,acclIndex) = x;
          accl(2,acclIndex) = y;
          accl(3,acclIndex) = z;
          acclIndex++;
      endif
      if (type == "GYRO,")
          tsGyro(gyroIndex) = ts;
          gyro(1,gyroIndex) = x;
          gyro(2,gyroIndex) = y;
          gyro(3,gyroIndex) = z;
          gyroIndex++;
      endif
  endwhile
  printf "Done\n"
  fclose(fid)
  tsAccl = tsAccl - tsAccl(1);
  tsGyro = tsGyro - tsGyro(1);
endfunction

function [accl_filt] = filterData(accl)
  window = 10;
  for i = 1:1:size(accl, 1)
      accl_filt(i,:) = filter(ones(window,1)/window, 1, medfilt1(accl(i,:), window/2));
  end
  accl_filt(4,:) = 0;
  for i = 1:1:size(accl, 1)
      accl_filt(4,:) += accl_filt(i,:) .* accl_filt(i,:);
  end
  accl_filt(4,:) = sqrt(accl_filt(4,:));
endfunction

function plotData(tsAccl, accl_filt)
  figure
  hold on
  for i = 1:1:size(accl_filt, 1)
      plot (tsAccl, accl_filt(i,:));
  end
endfunction

[tsAccl1, accl1, tsGyro1, gyro1] = readData("baseline 1.csv");
[tsAccl2, accl2, tsGyro2, gyro2] = readData("slide 1.csv");

[accl_filt1] = filterData(accl1);
[accl_filt2] = filterData(accl2);

[gyro_filt1] = filterData(gyro1);
[gyro_filt2] = filterData(gyro2);

plotData(tsAccl1, accl_filt1);
plotData(tsAccl2, accl_filt2);

hold
accl_filt1(4,100:120)
