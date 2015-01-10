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
  fclose(fid);
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

function [accl_avg] = avg(accl_filt)
  len = size(accl_filt, 2);
  ones(len,1)/len;
endfunction

function [output] = intg(x, y)
  idx = 1;
  output(idx) = 0;
  for i=2:1:size(x,2)
    idx++;
    output(idx) = output(idx-1) + (x(i) - x(i-1)) * ((y(i) + y(i-1))/2);
  endfor
endfunction

[tsAccl1, accl1, tsGyro1, gyro1] = readData("baseline 1.csv");
[tsAccl2, accl2, tsGyro2, gyro2] = readData("slide 1.csv");

[accl_filt1] = filterData(accl1);
[accl_filt2] = filterData(accl2);

[gyro_filt1] = filterData(gyro1);
[gyro_filt2] = filterData(gyro2);

#plotData(tsAccl1, accl_filt1);
#plotData(tsAccl2, accl_filt2);

len = min(size(accl_filt1, 2), size(accl_filt2, 2));
diff = accl_filt1(1:3,10:len) .- (sum(accl_filt2(1:3,10:len), 2)/(len-11));

tsAccl1(10:len) = tsAccl1(10:len) .- tsAccl1(10);

[intgOut1] = intg(tsAccl1(10:len), diff(1,:));
[intgOut2] = intg(tsAccl1(10:len), diff(2,:));
[intgOut3] = intg(tsAccl1(10:len), diff(3,:));

plotData(tsAccl1(10:len), diff(1,:));
plotData(tsAccl1(10:len), diff(2,:));
plotData(tsAccl1(10:len), diff(3,:));
plotData(tsAccl1(10:len), intgOut1);
plotData(tsAccl1(10:len), intgOut2);
plotData(tsAccl1(10:len), intgOut3);

#[intgTest] = intg(tsAccl1(10:20), ones(1,11));
#plotData(tsAccl1(10:20), ones(1,11));
#plotData(tsAccl1(10:20), intgTest);
