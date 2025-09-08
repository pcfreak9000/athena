set terminal png size 1000,1000
set output 'plot_dshapes.png'
set xrange[0:60]
set yrange[0:60]
plot "dshape0.3.csv", "dshape0.2.csv", "dshape0.1.csv", "dshape0.02.csv", "dshape0.01.csv"
