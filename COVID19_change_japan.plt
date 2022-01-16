reset

# -------------------- Functions ------------------- #
# Convert unix_time to date
unix2date(unix_time) = strftime("%Y/%m/%d", unix_time)
# Convert day to sec
day2sec(t_day) = 3600*24*t_day
# Convert sec to day
sec2day(t_sec) = t_sec/(3600*24)
# Round up at the i-th digit
ceil_i(x, i) = ceil(x/10.**(i-1))*10.**(i-1)

# -------------------- Setting ------------------- #
set term pngcairo enhanced size 1920, 1080 font ', 26'
folderName = 'image'
system sprintf("mkdir %s", folderName)  # Make the folder

# Open data
# Source: NHK (Japan Broadcasting Corporation) 
# → https://www3.nhk.or.jp/news/special/coronavirus/data-all/
data_txt = "nhk_news_covid19_domestic_daily_data.csv"
set timefmt "%Y/%m/%d"
set datafile separator ","  # for csv file

# Calculate UTC using UNIX time
date0_p = "2020/01/16"                          # First day of the positive
date0_p_unix = strptime("%Y/%m/%d", date0_p)    # UNIX time [s]

# Calculate date lag between the positive and the death
date0_d = "2020/02/13"                          # First day of the death
date0_d_unix = strptime("%Y/%m/%d", date0_d)    # UNIX time [s]
date_lag = sec2day(date0_d_unix - date0_p_unix)

# Get number and maximum of data
stat data_txt using 2 nooutput
data_num = STATS_records
data1_ymax = STATS_max
stat data_txt using 5 nooutput
data2_ymax = STATS_max

# Set the range of the y-axis by comparing the maximum value of each of the two data
data_ymax_sup = data1_ymax
if(data1_ymax < data2_ymax) {
  data_ymax_sup = data2_ymax
}

# Calculate the last day using the number of data in the csv file
X_MAX_unix = date0_p_unix + day2sec(data_num-1) # Last day
X_MAX = unix2date(X_MAX_unix)
Y_MAX = data_ymax_sup

set grid
set key left top Left box width -5 spacing 1.3 reverse
set xlabel "Date" offset 0, 1.7
set ylabel "Number of people"
set timefmt "%Y/%m/%d"
set xdata time
set format x "%Y/%m/%d"
set xtics "2020/1/16", day2sec(30) offset -0.7, 0.2 rotate by -70 font ", 22"
set ytics offset 0, 0.3
set xrange["2020/1/16":X_MAX]
set yrange[0:ceil_i(Y_MAX, 4)]
set style fill solid

# -------------------- Update and output images ------------------- #
do for[i=1:data_num]{
    set output sprintf("%s/img_%04d.png", folderName, i)
    set title sprintf("%s", unix2date(date0_p_unix + 86400*(i-1))) font ', 28'

    plotCommand = 'plot '
    plotCommand = plotCommand."data_txt every ::1::i using 1:2 with boxes fc rgb 'royalblue' title 'Positive PCR test cases (daily)'"

    if(i > date_lag){
      plotCommand = plotCommand.", data_txt every ::date_lag::i using 1:5 w l lw 2 lc rgb 'red' title 'Death (total)' "
      plotCommand = plotCommand.", data_txt every ::i::i using 1:5 w p ps 0.5 pt 7 lc rgb 'red' notitle"
    }

    eval plotCommand
    set output
}
