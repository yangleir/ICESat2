REM		GMT EXAMPLE 02
REM
REM Purpose:	Make two color images based gridded data
REM GMT modules:	set, grd2cpt, grdimage, makecpt, colorbar, subplot
REM

rem gmt grdcut -R7200/7500/8800/9050 ssh.nc -Gsmall.nc

gmt begin nanhai png
	gmt set MAP_ANNOT_OBLIQUE 0
	gmt grd2cpt ssh.nc -Cpolar -Z

	gmt grdgradient ssh.nc -Da -Sslope.nc
	gmt grdhisteq slope.nc -Gslope-norm.nc -N
	gmt grdmath slope-norm.nc -0.15 MUL = illum.nc
rem -R7000/8000/8000/9200
	gmt grdimage ssh.nc  -R7200/7500/8800/9050 -JX7/7c -Ba100g50  -Iillum.nc
	gmt colorbar -DJRM+o0.5c/0+mc  -Bx0.5+lEta(m) 
	rem gmt grdimage ssh.nc   -JX7/7c -B200  -I+d -X11c
gmt end show 

del illum.nc slope.nc slope-norm.nc