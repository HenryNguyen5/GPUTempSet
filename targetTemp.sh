#!/bin/bash
sudo apt-get -y install tree
clear
cd /sys/class/hwmon

echo "Reading temperatures and fan speeds..."
numDir=$(tree -L 1 | tail -1 | cut -c 1)
numDir=$[ numDir - 1 ]
echo
echo "There are currently $numDir gpus detected!"
echo
echo "What target temperature do you want to set? (0-100)"
read targetTmp

gpuTmp=""
gpuFan=""
maxFan="255"
minFan="0"
while true;
do
    i="0"
    while [ "$i" -lt "$numDir" ]
    do
        cd "/sys/class/hwmon/hwmon$i"
        gpuTmp=$(cat ./temp1_input)
        gpuFan=$(cat ./pwm1)
        gpuTmp=$[ gpuTmp / 1000 ]
        printf "  Gpu$i Tmp: $gpuTmp  "
        if [ $gpuTmp -gt $targetTmp ] ;
        then
            if [ $gpuFan -lt $maxFan ] ;
            then
                gpuFan=$[ gpuFan + 7 ]
                echo "$gpuFan" | sudo tee ./pwm1 > /dev/null
            fi
        fi
        if [ $gpuTmp -lt $targetTmp ] ;
        then
            if [ $gpuFan -gt $minFan ] ;
            then
                gpuFan=$[ gpuFan - 1 ]
                echo "$gpuFan" | sudo tee ./pwm1 > /dev/null
            fi
        fi

        i=$[ i + 1 ]
    done
    echo


    i="0"
    while [ "$i" -lt "$numDir" ]
    do
        cd "/sys/class/hwmon/hwmon$i"
        gpuFan=$(cat ./pwm1)
        printf "  Gpu$i Fan: $gpuFan  "
        i=$[ i + 1 ]
    done
    echo
    echo
    sleep 10
done
