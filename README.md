
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rectifyr

<!-- badges: start -->

<!-- badges: end -->

## Overview

Spreadsheets as places where data tables are recorded can be
ridiculously messy. All thinkable arrangements of the data may be
encountered, culminating in several non-uniformly formatted tables that
are placed non-systematically within one spreadsheet. In `rectifyr` each
of such individual tables within a spreadsheet is called *cluster*.

A common best practice of building up data tables is that variables are
recorded in columns and observations in rows, so that the data can be
considered *tidy* (Wickham 2014) (see <https://tidyr.tidyverse.org/>)
and normalised at least to the third normal form (Codd 1990). When it
comes to the organisation of data in tables, variables can be
distinguished into two kinds of variables:

1.  Variables that identify the unit for which values have been measured
    (they are called *identifying (or id) variables* here).
2.  Variables that have been measured and that consequently represent
    the target values of that measurement, be they continuous or
    categorical (they are called *measured variables* here).

These two variable types are the target variables in `rectifyr`. The
primary aim of reorganising messy tables lays in determining where those
two kinds of variables are located in each cluster.

# Definitions

*table*: Typically a set of values, but since we also consider data
arrangements here that can’t be regarded as topologically coherent
“chunks” of data, we include in the definition of table also
“spreadsheets” that may contain a very loose organisation of data.

*variable*: A variable is the primary level of aggregation of data. A
variable is always a combination of **name** and **values**. For
variables where the values are character strings, name and values must
be distinguished with care and this is especially important in vastly
disorganised tables.

*long variables*: A variable that is arranged so that the name is at the
top (the column name) and the values are aligned vertically below it.

*wide variables*: A variable that is arranged so that its unique values
(levels) are regarded as names of another variable in seperate columns.

*distinct variable*: A variable that is theoretically part of a table,
but which is topologically not connected to it (i.e., there are several
columns/rows in between the main table and this variable), either
because it is valid for several clusters or simply because it has been
placed in that spot without much thought.

*tidy variable*: see ‘long variable’.

*tidy table*: A table that contains only tidy variables.

*table header*: A table header is the place where the names of variables
are stored. In a tidy table the header is made up of only one row. This
is in contrast to a header of a disorganised table where several
variables are somehow nested so that the header is in several rows.

*cluster*: A coherent set of values in some sort “rectangular form” that
does not have to be tidy and may even be disorganised.

*key*: A variable that treats the name of several other variables as if
they were values.

*messy table*: A general term for tables that contain “non-tidy” data
(has not been defined further).

*disorganised (messy) table*: A table that contains any sort of non-tidy
data, specifically emphasizing that those may also be tables that
contain (messy) clusters or other forms of loosely organised data.

# Setting up schema descriptions

To set up a schema description, the recommended strategy is the
following:

1.  Clarify which are the identifying variables and which are the
    measured variables and create a new entry for each of them in the
    schema. A variable is always a combination of **name** and
    **values**. Names are typically the column names, but in many
    disorganised messy tables also variable names appear to be values.
    Values are typically in the column below that name, but in tables
    with nested headers the values are mostly not in a column with their
    name.

2.  Determine whether there are clusters and find the origin (top left
    cell) of each cluster (Tab. @ref(tab:clusHor), Tab. @ref(tab:clusId)
    & Tab. @ref(tab:clusMeas)). Follow the next steps for each cluster…

3.  Determine which variable identifies clusters and provide that as
    cluster ID. It can also be the case that the data are organised into
    seperate spreadsheets or files according to one of the variables and
    also those cases should be treated as if they were clusters, even if
    each spreadsheet/file contains a topologically coherent table. It
    may be that either an identifying variable, or a measured variable
    identifies clusters:
    
      - in case it is an identifying variable, provide this variables’
        name (and also register its metadata).
      - in case it is a measured variable, provide simply `"measured"`
        as cluster ID. <br><br>

4.  Determine for each identifying variable the following:
    
      - is the variable avaiable at all? This is particularly important
        when the data are split up into subtables that are in different
        spreadsheets or files. Often the variable that splits up the
        data (and thus identifies the clusters) is not explicitly
        available in the spreadsheet anymore. In such a case, provide
        the variables value for this cluster in `value` (Tab.
        @ref(tab:)).
      - are all values of this variable in one column or are they in
        several columns (is it long)?
      - in case the variable is not long, determine the row and columns
        in which its names sit (Tab. @ref(tab:nest2)).
      - whether the variable must be split off of a column (Tab.
        @ref(tab:splitCol)).
      - whether the variable is distinct from the main table (Tab. ).
        <br><br>

5.  Determine for each measured variable the following:
    
      - all columns in which the values of the variable sit (Tab.
        @ref(tab:long)).
      - the unit and conversion factor.
      - in case the variable is not tidy, one of the three following
        cases should apply:
          - in case the variable is nested in a wide identifying
            variable, determine additionally to the columns in which the
            values sit also the rows in which the **variable name** sits
            (Tab. @ref(tab:nest1) & Tab. @ref(tab:nest2)).
          - in case the names of the variable are given as an
            identifying variable (Tab. @ref(tab:wideLong)), give that
            column name as `key` of the values variable, together with
            the respective term (`values`) of the measured variable
            (this indicates that this *key-values pair* must be spread).
          - in case the name of the variable is the ID of clusters,
            specify `key = "cluster"` and in `values` the cluster number
            the variable refers to (Tab. @ref(tab:clusMeas)).

# Table types

The following sections each start with a description of the table that
needs reshaping, followed by a brief description of how this table needs
to be reshaped and the schema description that is used for the
reorganisation. In the first section only the arrangement of clusters is
discussed, while the following sections describe how the contents of
each cluster can be re-arranged. This is most likely not an exhaustive
list of possible table arrangements, but it covers certain basic
building blocks of the most common operations and should be extensible
enough to capture many mutations of the presented tables.

## Spreadsheet contains (several) clusters

Clusters are often of the same arrangement within one spreadsheet, they
can be repeated along rows (horizontally) or along columns (vertically).
A table should be treated like a cluster also when the spreadsheet
contains not only the table, but perhaps also text that may be scattered
across the document and that does not allow the table to start at the
spreadsheet origin in the topmost left cell.

To reorganise the data into tidy form, each cluster is "cut out",
rearranged individually and appended to the end of an output table by
`reorganise()`.

### Horizontal clusters

In case horizontal clusters are sitting right next to each other in the
same origin row (Tab. @ref(tab:clusHor)), it is sufficient to provide
the topmost row and all leftmost columns at which a new cluster starts.
In case there is some arbitrary horizontal space between clusters, also
the width (of each cluster) needs to be provided.

| territories | commodities | harvested | production | commodities | harvested | production |
| :---------- | :---------- | :-------- | :--------- | :---------- | :-------- | :--------- |
|             | year 1      |           |            | year 2      |           |            |
| unit 1      | soybean     | 1111      | 1112       | soybean     | 1211      | 1212       |
| unit 1      | maize       | 1121      | 1122       | maize       | 1221      | 1222       |
| …           |             |           |            |             |           |            |

(\#tab:clusHor) Horizontal clusters of the identifying variable
`period`.

``` r
list(clusters = 
       list(top = 1, left = c(2, 5), width = NULL, height = NULL,
            id = "period"),
     header = list(row = 1, rel = FALSE),
     meta = list(dec = NULL, na = NULL, types = NULL),
     variables = 
       list(territories = 
              list(type = "id", name = NULL, split = NULL,
                   row = NULL, col = 1, rel = FALSE),
            period = 
              list(type = "id", name = "year", split = NULL,
                   row = 1, col = NULL, rel = FALSE),
            ...))
```

### Vertical clusters

For vertically arranged clusters (Tab. @ref(tab:clusId)), just like for
the horizontal case, the respective rows, columns (and heights) need to
be provided.

|        | territories | commodities | harvested | production |
| :----- | :---------- | :---------- | :-------- | :--------- |
| year 1 |             |             |           |            |
|        | unit 1      | soybean     | 1111      | 1112       |
|        | unit 1      | maize       | 1121      | 1122       |
|        | …           |             |           |            |
| year 2 |             |             |           |            |
|        | unit 1      | soybean     | 1211      | 1212       |
|        | unit 1      | maize       | 1221      | 1222       |
|        | …           |             |           |            |

(\#tab:clusId) Vertical clusters of the identifying variable `period`.

``` r
list(clusters = 
       list(top = c(1, ...), left = 1, width = NULL, height = NULL,
            id = "period"),
     header = list(row = 1, rel = FALSE),
     meta = list(dec = NULL, na = NULL, types = NULL),
     variables =
       list(territories = 
              list(type = "id", name = NULL, split = NULL,
                   row = NULL, col = 2, rel = TRUE),
            period = 
              list(type = "id", name = "year", split = NULL,
                   row = NULL, col = 1, rel = TRUE),
            ...))
```

### Messy clusters

In case several clusters are neither aligned along a row nor a column,
and are all of differing size, the respective information need to be
provided at the same index of the respective property. For example,
three clusters, where the first cluster starts at (1,1) and is 3 by 4
cells in size, where the second clusters starts at (5,2) and is 5 by 5
cells in size, and so on, needs to be specified as below.

``` r
list(clusters = 
       list(top = c(1, 5, 1), left = c(1, 2, 5), 
            width = c(3, 5, 2), height = c(4, 5, 3),
            id = "period"),
     header = list(row = ..., rel = FALSE),
     meta = list(dec = NULL, na = NULL, types = NULL),
     variables =
       list(territories = 
              list(type = "id", name = NULL, split = NULL,
                   row = NULL, col = 2, rel = TRUE),
            period = 
              list(type = "id", name = "year", split = NULL,
                   row = NULL, col = 1, rel = TRUE),
            ...))
```

Additionally, given that at least the tables within each cluster are all
arranged in the same way, the contained variables can be specified so
that their row and column indices are given relative to the cluster
position (`rel = TRUE`). If also that is not the case, the row and
column values for each cluster need to be provided for the respective
variables in the same way as for cluster positions.

## Spreadsheet contains one table

When a spreadsheet contains only one table we can still have
disorganised messy data, for example when the variable names are not in
a single row, or in other words, if the table header has more than one
row. The names are in those cases arranged so that their order implies
some sort of nesting of the variables.

In those tables we have to distinguish tables where the values variable
are in seperate, tidy columns (*i.e, where the name is at the top of the
column and the values are below that*) from such tables where the values
variables are “long” (*i.e., the variable names are in a key and the
values are in another column*).

In both cases we have a “tidy” basic form, where all identifying
variables are in one column and several forms, where the identifying
variables’ *values* are used to establish the above mentioned nested
order (and where the names of those identifying variable are thus
ommited).

  - In case the values variables are in seperate columns we only have to
    gather potentially wide identifying variables into one column.
  - In case the values variables are listed, we first have to gather
    potentially wide identifying variables into one column and then have
    to spread out the listed value variable.

### Separated *measured variables*

In case the measured variables are arranged into individual columns
(Tab. @ref(tab:tidy)), we have tidy data (Wickham 2014), which are
already in the target arrangement. The variables in a tidy table may
however, still need different names, units and transformation factors.

| territories | period | commodities | harvested | production |
| :---------- | :----- | :---------- | :-------- | :--------- |
| unit 1      | year 1 | soybean     | 1111      | 1112       |
| unit 1      | year 1 | maize       | 1121      | 1122       |
| unit 1      | year 2 | soybean     | 1211      | 1212       |
| unit 1      | year 2 | maize       | 1221      | 1222       |
| …           |        |             |           |            |

(\#tab:tidy) A tidy table.

``` r
list(clusters =
       list(top = NULL, left = NULL, width = NULL, height = NULL,
            id = NULL),
     header = list(row = 1, rel = FALSE),
     meta = list(dec = NULL, na = NULL, types = NULL),
     variables =
       list(territories =
              list(type = "id", name = NULL, split = NULL,
                   row = NULL, col = 1, rel = FALSE),
            year =
              list(type = "id", name = "period", split = NULL,
                   row = NULL, col = 2, rel = FALSE),
            commodities =
              list(type = "id", name = NULL, split = NULL,
                   row = NULL, col = 3, rel = FALSE),
            harvested =
              list(type = "measured", unit = "ha", factor = 1,
                   row = NULL, col = 4, rel = FALSE,
                   key = NULL, value = NULL),
            production =
              list(type = "measured", unit = "t", factor = 1,
                   row = NULL, col = 5, rel = FALSE,
                   key = NULL, value = NULL)))
```

In case identifying variables are factors with a limited number of
levels, those levels may be used as names of other variables, where they
would be next to each other and thus "wide". The other variables (both
identifying and measured variables) would then be "nested" in those wide
identifying variables. In those cases we have to record the row and the
specific columns in which the identifying variables names are found,
because those values will be used to reconstruct the variable as "long"
variable. Beware that in those case, the header is not simple, so you
need to change the default header specification.

| territories | period | soybean   |            | maize     |            |
| :---------- | :----- | :-------- | :--------- | :-------- | :--------- |
|             |        | harvested | production | harvested | production |
| unit 1      | year 1 | 1111      | 1112       | 1121      | 1122       |
| unit 1      | year 2 | 1211      | 1212       | 1221      | 1222       |
| unit 2      | year 1 | 2111      | 2112       | 2112      | 2122       |
| unit 2      | year 2 | 2211      | 2212       | 2121      | 2222       |
| …           |        |           |            |           |            |

(\#tab:nest1) The values variables are nested within the identifying
variable `commodities`.

``` r
list(clusters =
       list(top = NULL, left = NULL, width = NULL, height = NULL,
            id = NULL),
     header = list(row = c(1, 2), rel = FALSE),
     meta = list(dec = NULL, na = NULL, types = NULL),
     variables =
       list(territories =
              list(type = "id", name = NULL, split = NULL,
                   row = NULL, col = 1, rel = FALSE),
            year =
              list(type = "id", name = "period", split = NULL,
                   row = NULL, col = 2, rel = FALSE),
            commodities =
              list(type = "id", name = NULL, split = NULL,
                   row = 1, col = c(3, 5), rel = FALSE),
            harvested =
              list(type = "measured", unit = "ha", factor = 1,
                   row = 2, col = c(3, 5), rel = FALSE,
                   key = NULL, value = NULL),
            production =
              list(type = "measured", unit = "t", factor = 1,
                   row = 2, col = c(4, 6), rel = FALSE,
                   key = NULL, value = NULL)))
```

In case several variables are nested within other variables, we have to
specify all wide variables and in which rows they sit.

| territories | year 1    |            |           |            | year 2    |            |           |            |
| :---------- | :-------- | :--------- | :-------- | :--------- | :-------- | :--------- | :-------- | :--------- |
|             | soybean   |            | maize     |            | soybean   |            | maize     |            |
|             | harvested | production | harvested | production | harvested | production | harvested | production |
| unit 1      | 1111      | 1112       | 1121      | 1122       | 1211      | 1212       | 1221      | 1222       |
| unit 2      | 2111      | 2211       | 2121      | 2221       | 2112      | 2212       | 2122      | 2222       |
| …           |           |            |           |            |           |            |           |            |

(\#tab:nest2) The identifying variable `commodities` is nested in the
identifying variable `period`. The target variable is spread across
those nested columns.

``` r
list(clusters =
       list(top = NULL, left = NULL, width = NULL, height = NULL,
            id = NULL),
     header = list(row = c(1:3), rel = FALSE),
     meta = list(dec = NULL, na = NULL, types = NULL),
     variables =
       list(territories =
              list(type = "id", name = NULL, split = NULL,
                   row = NULL, col = 1, rel = FALSE),
            year =
              list(type = "id", name = "period", split = NULL,
                   row = 1, col = c(2, 6), rel = FALSE),
            commodities =
              list(type = "id", name = NULL, split = NULL,
                   row = 2, col = c(2, 4, 6, 8), rel = FALSE),
            harvested =
              list(type = "measured", unit = "ha", factor = 1,
                   row = 3, col = c(2, 4, 6, 8), rel = FALSE,
                   key = NULL, value = NULL),
            production =
              list(type = "measured", unit = "t", factor = 1,
                   row = 3, col = c(3, 5, 7, 9), rel = FALSE,
                   key = NULL, value = NULL)))
```

### Listed *measured variables*

Some tables contain a column where the names of measured variables
(`harvested` and `production`) are treated as if they were the values of
an identifying variable (`dimension`), while the values are presented in
only one column (`values`) (Tab. @ref(tab:long)). To end up with tidy
data in those cases, we need to extract the values associated with the
measured variables. Thus, we define the measured variables and specify
the `key =` in which the variable names sit, and the `value =` the
variable name has, to extract that variable.

| territories | period | commodities | dimension  | values |
| :---------- | :----- | :---------- | :--------- | :----- |
| unit 1      | year 1 | soybean     | harvested  | 1111   |
| unit 1      | year 1 | maize       | harvested  | 1121   |
| unit 1      | year 1 | soybean     | production | 1112   |
| unit 1      | year 1 | maize       | production | 1122   |
| unit 1      | year 2 | soybean     | harvested  | 1211   |
| unit 1      | year 2 | maize       | harvested  | 1221   |
| unit 1      | year 2 | soybean     | production | 1212   |
| unit 1      | year 2 | maize       | production | 1222   |
| …           |        |             |            |        |

(\#tab:long) The variable names of the measured variable are treated as
if they were the values of an identifying variable.

``` r
list(clusters =
       list(top = NULL, left = NULL, width = NULL, height = NULL,
            id = NULL),
     header = list(row = 1, rel = FALSE),
     meta = list(dec = NULL, na = NULL, types = NULL),
     variables =
       list(territories =
              list(type = "id", name = NULL, split = NULL,
                   row = NULL, col = 1, rel = FALSE),
            year =
              list(type = "id", name = "period", split = NULL,
                   row = NULL, col = 2, rel = FALSE),
            commodities =
              list(type = "id", name = NULL, split = NULL,
                   row = NULL, col = 3, rel = FALSE),
            harvested =
              list(type = "measured", unit = "ha", factor = 1,
                   row = NULL, col = 5, rel = FALSE,
                   key = "dimension", value = "harvested"),
            production =
              list(type = "measured", unit = "t", factor = 1,
                   row = NULL, col = 5, rel = FALSE,
                   key = "dimension", value = "production")))
```

Moreover, (several) identifying variables may be wide and we have to
proceed as mentioned above, by providing the row and columns of the wide
identifying variables.

| territories | period | dimension  | soybean | maize |
| :---------- | :----- | :--------- | :------ | :---- |
| unit 1      | year 1 | harvested  | 1111    | 1112  |
| unit 1      | year 1 | production | 1121    | 1122  |
| unit 1      | year 2 | harvested  | 1211    | 1212  |
| unit 1      | year 2 | production | 1221    | 1222  |
| …           |        |            |         |       |

(\#tab:wideLong) The identifying variable `commodities` is treated as if
it were the observed variable.

``` r
list(clusters =
       list(top = NULL, left = NULL, width = NULL, height = NULL,
            id = NULL),
     header = list(row = 1, rel = FALSE),
     meta = list(dec = NULL, na = NULL, types = NULL),
     variables =
       list(territories =
              list(type = "id", name = NULL, split = NULL,
                   row = NULL, col = 1, rel = FALSE),
            year =
              list(type = "id", name = "period", split = NULL,
                   row = NULL, col = 2, rel = FALSE),
            commodities =
              list(type = "id", name = NULL, split = NULL,
                   row = 1, col = c(4, 5), rel = FALSE),
            harvested =
              list(type = "measured", unit = "ha", factor = 1,
                   row = NULL, col = c(4, 5), rel = FALSE,
                   key = "dimension", value = "harvested"),
            production =
              list(type = "measured", unit = "t", factor = 1,
                   row = NULL, col = c(4, 5), rel = FALSE,
                   key = "dimension", value = "production")))
```

An even more complicated case of listed values variables is present in a
clustered table where each measured variable is in its own cluster.
Here, we need to specify first of all in `clusters` `"id = "measured"`
to indicate that the measured variable is the cluster ID. Next, we need
to set up the measured variables so that they contain `"key = "cluster"`
and in `value` the number of the cluster this variable can be found in.
Moreover, we provide the column(s) and all rows that contain the values
of each measured variable. This is in contrast to nested measured
variables, where the rows of the variable names need to be provided.

|            | territories | period | commodities | values |
| :--------- | :---------- | :----- | :---------- | :----- |
| harvested  |             |        |             |        |
|            | unit 1      | year 1 | soybean     | 1111   |
|            | unit 1      | year 1 | maize       | 1121   |
|            | unit 1      | year 2 | soybean     | 1211   |
|            | unit 1      | year 2 | maize       | 1221   |
|            | …           |        |             |        |
| production |             |        |             |        |
|            | unit 1      | year 1 | soybean     | 1112   |
|            | unit 1      | year 1 | maize       | 1122   |
|            | unit 1      | year 2 | soybean     | 1212   |
|            | unit 1      | year 2 | maize       | 1222   |
|            | …           |        |             |        |

(\#tab:clusMeas) Vertical clusters of the values variables.

``` r
    list(clusters =
           list(top = c(3, 12), left = 2, width = NULL, height = 8,
                id = "measured"),
     header = list(row = 1, rel = FALSE),
     meta = list(dec = NULL, na = NULL, types = NULL),
         variables =
           list(territories =
                  list(type = "id", name = NULL, split = NULL,
                       row = NULL, col = 2, rel = FALSE),
                year =
                  list(type = "id", name = NULL, split = NULL,
                       row = NULL, col = 3, rel = FALSE),
                commodities =
                  list(type = "id", name = NULL, split = NULL,
                       row = NULL, col = 4, rel = FALSE),
                harvested =
                  list(type = "measured", unit = "ha", factor = 1,
                       row = c(3:10), col = 5, rel = FALSE,
                       key = "cluster", value = 1),
                production =
                  list(type = "measured", unit = "t", factor = 1,
                       row = c(13:20), col = 5, rel = FALSE,
                       key = "cluster", value = 2)))
```

### Distinct variables

Table: (\#tab:splitCol) Several variables are stored in the same column.

### Several variables in one column

Sometimes it may be the case that several information/variables are
stored in the same column, for example when a territorial unit is given
together with its parent (e.g. `unit1, year1`). In those cases, the
resulting variables in the output schema need to be specified so that
they point to that same column but extract information via a regular
expression (find more information
[here](https://edrub.in/CheatSheets/cheatSheetStringr.pdf)). For
example, `.+?(?=,)` gives everything up until the first comma and
`(?<=\s).*` everything after the white-space.

| unit           | commodities | harvested | production |
| :------------- | :---------- | :-------- | :--------- |
| unit 1, year 1 | soybean     | 1111      | 1112       |
| unit 1, year 1 | maize       | 1121      | 1122       |
| unit 1, year 2 | soybean     | 1211      | 1212       |
| unit 1, year 2 | maize       | 1221      | 1222       |
| …              |             |           |            |

(\#tab:splitCol) Several variables are stored in the same column.

``` r
list(clusters =
       list(top = NULL, left = NULL, width = NULL, height = NULL,
            id = NULL),
     header = list(row = 1, rel = FALSE),
     meta = list(dec = NULL, na = NULL, types = NULL),
     variables =
       list(territories =
              list(type = "id", name = NULL, split = NULL,
                   row = NULL, col = 1, rel = FALSE),
            year =
              list(type = "id", name = "period", split = ".+?(?=_)",
                   row = NULL, col = 2, rel = FALSE),
            commodities =
              list(type = "id", name = NULL, split = "(?<=\\_).*",
                   row = NULL, col = 2, rel = FALSE),
            harvested =
              list(type = "measured", unit = "ha", factor = 1,
                   row = NULL, col = 3, rel = FALSE,
                   key = NULL, value = NULL),
            production =
              list(type = "measured", unit = "t", factor = 1,
                   row = NULL, col = 4, rel = FALSE,
                   key = NULL, value = NULL)))
```

# References

<div id="refs" class="references hanging-indent">

<div id="ref-Codd1990">

Codd, EF. 1990. *The Relational Model for Database Management: Version
2*. Boston, MA, USA: Addison-Wesley Longman Publishing Co., Inc.

</div>

<div id="ref-Wickham2014">

Wickham, Hadley. 2014. “Tidy Data.” *Journal of Statistical Software* 59
(10): 1–23. <https://doi.org/10.18637/jss.v059.i10>.

</div>

</div>
