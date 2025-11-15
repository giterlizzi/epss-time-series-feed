input_file  = sprintf('%s.epss', cve_id)
output_file = sprintf('%s-epss.png', cve_id)
title_text  = sprintf('EPSS for %s', cve_id)

set terminal png size 1024,768
set output output_file

set title title_text

set xlabel 'Date'
set ylabel 'Value'

set xdata time
set timefmt '%Y-%m-%d'
set format x '%Y-%m-%d'

set style data linespoints
set grid

set datafile separator ','
set datafile missing 'NaN'

plot input_file using 1:3 with lines title 'EPSS', \
     input_file using 1:4 with lines title 'Percentile'
