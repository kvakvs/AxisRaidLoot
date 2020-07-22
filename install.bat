
SET DST="X:\SSDGames\World of Warcraft\_classic_\Interface\AddOns"
rd /s /q %DST%\AxisRaidLoot
mkdir %DST%\AxisRaidLoot
cd ..
xcopy /e AxisRaidLoot %DST%\AxisRaidLoot