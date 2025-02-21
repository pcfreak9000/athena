#!/bin/bash

plotcommand="$5/vis/python/plot_spherical.py"
n_processes=20

# initialize a semaphore with a given number of tokens
open_sem(){
    mkfifo pipe-$$
    exec 3<>pipe-$$
    rm pipe-$$
    local i=$1
    for((;i>0;i--)); do
        printf %s 000 >&3
    done
}

# run the given command asynchronously and pop/push tokens
run_with_lock(){
    local x
    # this read waits until there is something to read
    read -u 3 -n 3 x && ((0==x)) || exit $x
    (
     ( "$@"; )
    # push the return code of the command to the semaphore
    printf '%.3d' $? >&3
    )&
}

pwd
mkdir $2 &>/dev/null && echo "Created png directory." || echo "png directory already exists, overriding. Or there is an error..."
open_sem $n_processes
echo "Converting athdf's to png's with $n_processes processes."
files=($1/*.athdf)
count_total=${#files[@]}
count=0
for filename in $1/*.athdf; do 
    if [ -z "${FIELDLINES_STREAM+x}" ]; then 
        run_with_lock $plotcommand --logc "${filename}" rho $2/$(basename ${filename}).png
    else
        run_with_lock $plotcommand --stream Bcc --logc "${filename}" rho $2/$(basename ${filename}).png
    fi
    count=$((count + 1))
    percent=$((count * 100 / count_total))
    #echo $percent
    printf "\r[%-50s] %d%%" $(head -c $((percent / 2)) < /dev/zero | tr '\0' '#') $percent
done #| dialog --title "Creating png's from athdf's" --gauge 'Creating pngs...' 6 60 0
echo  
echo "Calling ffmpeg, possibly overriding outputfile."
ffmpeg -framerate $3 -pattern_type glob -i $2/'*.png' \
  -vf "pad=ceil(iw/2)*2:ceil(ih/2)*2" \
  -c:v libx264 -pix_fmt yuv420p -y $4/out.mp4 2>/dev/null
echo "Done."

