#!/bin/bash
TIME="$(date +"%H:%M:%S %m/%d/%Y")"

LoadAvg=($(uptime | grep -P '\d+\.\d+' -o))
LoadAvg1=${LoadAvg[0]}
LoadAvg5=${LoadAvg[1]}
LoadAvg15=${LoadAvg[2]}

IOStat=$(iostat | tail -n +6 | head -n -1 | sed 's/$/<br>/g')

interfaces=($(ls /sys/class/net | grep -v lo))
EthStat=""
for interface in "${interfaces[@]}"
do
   name="<p>     <b>$interface</b></p>"
   stat=$(ethtool -S $interface | tail -n +2 | head -n +13| sed 's/$/<br>/g')
   EthStat=$EthStat$name$stat"<br>"
done

SocStat=$(netstat -tunl | tail -n +3 | grep LISTEN | sed 's/$/<br>/g')
TCPStat=$(netstat -ant | tail -n +3 | awk '{print $6}' | sort | uniq -c | sort -n | sed 's/$/<br>/g')
CPUStat=$(vmstat | tail -n +2 | cut -c$(vmstat | head -n2 | tail -n1 | grep -aob 'us' | grep -oE '[0-9]+')- | sed 's/$/<br>/g')

CpuData=$(tail -n1 /home/yuldashev/balinux/cpu)

CpuUs=$(echo $CpuData | awk '{print $13}')
CpuSy=$(echo $CpuData | awk '{print $14}')
CpuId=$(echo $CpuData | awk '{print $15}')
CpuIO=$(echo $CpuData | awk '{print $16}')

DiskFree=$(df -h | grep -v tmpfs | grep -v '\/\(dev\|sys\|proc\)[\/[1-9a-z]*]*$' | sed 's/$/<br>/g')
DiskIFree=$(df -ih | grep -v tmpfs | grep -v '\/\(dev\|sys\|proc\)[\/[1-9a-z]*]*$' | sed 's/$/<br>/g')

STYLES="
body {background: black; color: white; font-family: 'Courier New', Courier, monospace;}
table, td {border: 1px solid DimGray; white-space: pre;}
td {padding: 8px; font-size: 14px;  line-height: 0.7;}
tr td:first-child {font-weight: bold; font-size: 16px;}
ul {margin: 0}
"

echo "Content-type: text/html

<html>
  <head>
    <title>BALINUX</title>
    <style type='text/css'>$STYLES</style>
    <meta http-equiv='Content-Type' content='text/html;charset=UTF8'>
  </head>

  <body>
    <h3>BALINUX</h3>
    <p>Страница сгенерирована <i>$TIME</i></p>

    <table cellpadding=0 cellspacing=0>
      <tr>
        <td>IP клиента</td>
        <td>$REMOTE_PORT</i></td>
      </tr>
      <tr>
        <td>Port клиента</td>
        <td>$REMOTE_ADDR</i></td>
      </tr>
      <tr>
        <td>Средняя загрузка</td>
        <td>$LoadAvg1, $LoadAvg5, $LoadAvg15</i></td>
      </tr>
      <tr>
        <td>Загрузка дисков</td>
        <td>$IOStat</td>
      </tr>
      <tr>
        <td>Загрузка сети</td>
        <td>$EthStat</td>
      </tr>
      <tr>
        <td>Статистика по сетевым соединениям</td>
        <td><ul>
          <li>Слушающие сокеты: <br><br>$SocStat<br></li>
          <li>TCP состояния: <br><br>$TCPStat</li>
        </ul></td>
      </tr>
      <tr>
        <td>Средняя загрузка CPU</td>
        <td>USER: <i>$CpuUs%</i>, SYSTEM: <i>$CpuSy%</i>, IDLE: <i>$CpuId%</i>, IOWAIT: <i>$CpuIO%</i></td>
      </tr>
      <tr>
        <td>Информация о дисках</td>
        <td>$DiskFree<br><br>$DiskIFree</td>
      </tr>
    </table>
  </body>

</html>
"

#       <li>Загрузка сети</li>
#       <li>Top talkers по сети <i>(сортировка по убыванию)</i><ul>
#         "<li><i>по протоколам (proto, bytes, %от последней минуты), сортируем по %%</i></li>"
#         "<li><i>по пакетам (src/dst ip, proto, src/port, pps), сортируем по pps внутри сессии (направление не важно)</i></li>"
#         "<li><i>по трафику (src/dst ip, proto, src/port, bps), сортируем по bps внутри сессии (направление не важно)</i></li>"
#       "<li>Информациф о дисках <i>(%Free space, %free inodes)</i> по каждой файловой системе кроме служебных <i>(/sys, /proc, /dev)</i></li>"
