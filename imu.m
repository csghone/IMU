clc
clear all
close all
hold all
acclIndex = 1;
gyroIndex = 1;
fid = fopen ("baseline.csv", "r");

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

for i = 1:1:3
    window = 10;
    accl_filt(i,:) = filter(ones(window,1)/window, 1, medfilt1(accl(i,:), window/2));
    gyro_filt(i,:) = filter(ones(window,1)/window, 1, medfilt1(gyro(i,:), window/2));
end

accl_filt(4,:) = 0;
gyro_filt(4,:) = 0;
for i = 1:1:3
    accl_filt(4,:) += accl_filt(i,:) .* accl_filt(i,:);
    gyro_filt(4,:) += gyro_filt(i,:) .* gyro_filt(i,:);
end
accl_filt(4,:) = sqrt(accl_filt(4,:));
gyro_filt(4,:) = sqrt(gyro_filt(4,:));

for i = 1:1:3
    plot (tsAccl, accl_filt(i,:));
end

figure
hold on
for i = 1:1:3
    plot (tsAccl, gyro_filt(i,:));
end

hold
