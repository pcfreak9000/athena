#!/bin/bash

ath_git_dir="$5"
athdf_dir="$1"
png_dir="$2"
fps="$3"
file_out="$4"
args="$6"
hideprogress="$7"

plotcommand="$ath_git_dir/vis/python/plot_spherical.py"
n_processes=${P9000_WORKER_THREADS:-4}

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
mkdir $png_dir &>/dev/null && echo "Created png directory." || echo "png directory already exists, overriding. Or there is an error..."
open_sem $n_processes
echo "Converting athdf's to png's with $n_processes processes."
files=($athdf_dir/*.athdf)
count_total=${#files[@]}
count=0
for filename in $athdf_dir/*.athdf; do 
    run_with_lock $plotcommand "${filename}" $args $png_dir/$(basename ${filename}).png
    count=$((count + 1))
    percent=$((count * 100 / count_total))
    #echo $percent
    if [ "$hideprogress" = "" ]; then
        printf "\r[%-50s] %d%%" $(head -c $((percent / 2)) < /dev/zero | tr '\0' '#') $percent
    fi
done #| dialog --title "Creating png's from athdf's" --gauge 'Creating pngs...' 6 60 0
echo  
echo "Calling ffmpeg, possibly overriding outputfile."
ffmpeg -framerate $fps -pattern_type glob -i $png_dir/'*.png' \
  -vf "pad=ceil(iw/2)*2:ceil(ih/2)*2" \
  -c:v libx264 -pix_fmt yuv420p -y $file_out 2>/dev/null
echo "Done."

