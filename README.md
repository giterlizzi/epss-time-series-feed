# EPSS Time Series Feed

> [!WARNING]
> The EPSS timeseries for CVEs are now available at https://epss.giterlizzi.dev.
> - **Old URL** `https://raw.githubusercontent.com/giterlizzi/epss-time-series-feed/refs/heads/main`
> - **New URL** `https://epss.giterlizzi.dev`
> Update your scripts to use the new base URL.

This project provides a historical EPSS (Exploit Prediction Scoring System) time series for each CVE.

# About EPSS

> The Exploit Prediction Scoring System (EPSS) is a data-driven effort for estimating the likelihood (probability) that a software vulnerability will be exploited in the wild. Our goal is to assist network defenders to better prioritize vulnerability remediation efforts. While other industry standards have been useful for capturing innate characteristics of a vulnerability and provide measures of severity, they are limited in their ability to assess threat. EPSS fills that gap because it uses current threat information from CVE and real-world exploit data. The EPSS model produces a probability score between 0 and 1 (0 and 100%). The higher the score, the greater the probability that a vulnerability will be exploited.

https://www.first.org/epss/

## Repository structure

Each CVE gets its own EPSS file, e.g., `CVE-1999-0001.epss`. Here, each file is put into a folder layout that first sorts by CVE year identifier part and then by number part. We mask (xx) the last two digits to create easily navigable folders that hold a maximum of 100 EPSS files:

```
.
├── CVE-1999
│   ├── CVE-1999-00xx
│   │   ├── CVE-1999-0001.epss
│   │   ├── CVE-1999-0002.epss
│   │   └── [...]
│   ├── CVE-1999-01xx
│   │   ├── CVE-1999-0101.epss
│   │   └── [...]
│   └── [...]
├── CVE-2000
│   ├── CVE-2000-00xx
│   ├── CVE-2000-01xx
│   └── [...]
└── [...]
```

## Feed file format

The current fields in the EPSS feed:

* `date` : EPSS date
* `model` : EPSS model
* `epss` : the EPSS score representing the probability [0-1] of exploitation in the wild in the next 30 days (following score publication)
* `percentile` : the percentile of the current score, the proportion of all scored vulnerabilities with the same or a lower EPSS score

EPSS Model:

* No scores are available before 2021-04-14
* EPSS v2 (v2022.01.01) started publishing on 2022-02-04, you will see a major shift in most scores on that day
* EPSS v3 (v2023.03.01) started publishing on 2023-03-07, you will see a shift in scores on that day
* EPSS v4 (v2025.03.14) started publishing on 2025-03-17, you will see a shift in scores on that day

### Example

```csv
date,model,epss,percentile
2021-12-11,v1,0.15901,0.9733774053860148
2021-12-12,v1,0.15901,0.9733534890275305
2021-12-13,v1,0.18794,0.9780959326501106
2021-12-14,v1,0.50253,0.9965714431921399
2021-12-15,v1,0.56817,0.9974458194449766
2021-12-16,v1,0.59493,0.9976321116217489
2021-12-17,v1,0.91823,0.99974540455216665
2021-12-18,v1,0.91823,0.99974540455216665
2021-12-19,v1,0.91823,0.99974540455216665
2021-12-20,v1,0.92515,0.9997711525014303
[...]
```

## Usage

### Clone the Repository (without Git History)

```
git clone --depth 1 -b main https://github.com/giterlizzi/epss-time-series-feed.git
```

### Fetch all EPSS data for a single CVE

```
curl https://epss.giterlizzi.dev/CVE-2021/CVE-2021-442xx/CVE-2021-44228.epss
```

### Plot data with Gnuplot

Create or download [epss.gnuplot](https://epss.giterlizzi.dev/doc/epss.gnuplot) file:

```gnuplot
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
```

Download the EPSS data for a specific CVE (e.g. `CVE-2021-44228`):

```
wget https://epss.giterlizzi.dev/CVE-2021/CVE-2021-442xx/CVE-2021-44228.epss
```

Execute `gnuplot` command:

```
gnuplot -e "cve_id='CVE-2021-44228'" epss.gnuplot
```

![CVE-2021-44228](https://epss.giterlizzi.dev/doc/CVE-2021-44228-gnuplot.png)

## DuckDB

Retrieve EPSS values for the last 30 days for a given CVE:

```
SELECT * FROM read_csv_auto('https://epss.giterlizzi.dev/CVE-2021/CVE-2021-442xx/CVE-2021-44228.epss')
WHERE date >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY date;
+------------+---------+---------+------------+
│    date    │  model  │  epss   │ percentile │
│    date    │ varchar │ double  │   double   │
+------------+---------+---------+------------+
│ 2026-01-26 │ v4      │ 0.94358 │    0.99959 │
│ 2026-01-27 │ v4      │ 0.94358 │    0.99959 │
│ 2026-01-28 │ v4      │ 0.94358 │    0.99959 │
│ 2026-01-29 │ v4      │ 0.94358 │    0.99959 │
│ 2026-01-30 │ v4      │ 0.94358 │    0.99959 │
│ 2026-01-31 │ v4      │ 0.94358 │    0.99958 │
│ 2026-02-01 │ v4      │ 0.94358 │     0.9996 │
│ 2026-02-02 │ v4      │ 0.94358 │     0.9996 │
│ 2026-02-03 │ v4      │ 0.94358 │     0.9996 │
│ 2026-02-04 │ v4      │ 0.94358 │    0.99959 │
│ 2026-02-05 │ v4      │ 0.94358 │    0.99959 │
│ 2026-02-06 │ v4      │ 0.94358 │    0.99959 │
│ 2026-02-07 │ v4      │ 0.94358 │    0.99959 │
│ 2026-02-08 │ v4      │ 0.94358 │    0.99959 │
│ 2026-02-09 │ v4      │ 0.94358 │    0.99959 │
│ 2026-02-10 │ v4      │ 0.94358 │    0.99959 │
│ 2026-02-11 │ v4      │ 0.94358 │    0.99959 │
│ 2026-02-12 │ v4      │ 0.94358 │     0.9996 │
│ 2026-02-13 │ v4      │ 0.94358 │     0.9996 │
│ 2026-02-14 │ v4      │ 0.94358 │    0.99959 │
│ 2026-02-15 │ v4      │ 0.94358 │    0.99959 │
│ 2026-02-16 │ v4      │ 0.94358 │    0.99959 │
│ 2026-02-17 │ v4      │ 0.94358 │    0.99959 │
│ 2026-02-18 │ v4      │  0.9445 │     0.9999 │
│ 2026-02-19 │ v4      │  0.9445 │     0.9999 │
│ 2026-02-20 │ v4      │ 0.94358 │    0.99959 │
│ 2026-02-21 │ v4      │ 0.94358 │    0.99959 │
│ 2026-02-22 │ v4      │ 0.94358 │    0.99959 │
│ 2026-02-23 │ v4      │ 0.94358 │    0.99959 │
│ 2026-02-24 │ v4      │ 0.94358 │    0.99959 │
+------------+---------+---------+------------+
│ 30 rows                           4 columns │
+---------------------------------------------+
```

#### Plot data with DuckDB + youlot

DuckDB can be used with CLI graphing tools to quickly pipe input to stdout to graph your data in one line.

[YouPlot](https://github.com/red-data-tools/YouPlot) is a Ruby-based CLI tool for drawing visually pleasing plots on the terminal. It can accept input from other programs by piping data from stdin. It takes tab-separated (or delimiter of your choice) data and can easily generate various types of plots including bar, line, histogram and scatter.

With DuckDB, you can write to the console (stdout) by using the TO `/dev/stdout` command. And you can also write comma-separated values by using `WITH (FORMAT csv, HEADER)`.

```
duckdb -s "COPY (SELECT date, epss FROM read_csv('https://epss.giterlizzi.dev/CVE-2021/CVE-2021-442xx/CVE-2021-44228.epss') ORDER BY date) TO '/dev/stdout' WITH (FORMAT csv, HEADER)"
    | youplot line -d, -H -t "EPSS for CVE-2021-44228"
```

![CVE-2021-44228](https://epss.giterlizzi.dev/doc/CVE-2021-44228-youplot.png)

## Non-Endorsement Clause

This project uses and redistributes data from the EPSS (https://www.first.org/epss/data_stats) but is not endorsed or certified by FIRST.
