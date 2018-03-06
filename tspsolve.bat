set PATH=%PATH%;C:\cygwin64\bin
echo %PATH%
glpsol -m tsp\tsp.mod -d tsp\tsp.dat -o tsp\tsp.txt
grep -o 'X\[.*\]\W*\*\W*[01]' tsp\tsp.txt | grep -o '[01]$' > tsp\res.dat
