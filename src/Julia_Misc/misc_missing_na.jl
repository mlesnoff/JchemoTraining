using StatsBase, DataFrames

x = [rand(5) ; missing]
maximum(x)
maximum(skipmissing(x))
sum(skipmissing(x))

x = [rand(5) ; missing]
y = copy(x)
s = ismissing.(y)
y[s] .= -100
y 

y = copy(x)
replace(y, missing => -100)
replace!(y, missing => -100)
y

x1 = [missing ; rand(5) ; missing]
x2 = rand(7)
X = hcat(x1, x2)
maximum(X)
maximum(skipmissing(X))
sum(skipmissing(X))

Y = copy(X)
s = ismissing.(Y)
#s = findall(ismissing.(Y))
Y[s] .= -100
Y 

Y = copy(X)
replace(Y, missing => -100)
replace!(Y, missing => -100)
Y

Y = copy(X)
for col in eachcol(Y)
    replace!(col, missing => -100)
end
Y

Y = copy(X)
for row in eachrow(Y)
    replace!(row, missing => -100)
end
Y

############# NaN 

x = [rand(5) ; NaN]
replace(x, NaN => -100)
y = replace(x, NaN => missing)  # The inplace version does not accept to create missing 
                                # in a Float64 object

############# DATAFRAMES
                                
# https://www.roelpeters.be/replacing-nan-missing-in-julia-dataframes/  

@benchmark df[ismissing.(df.a), :a] = 0 # Median time: 38.7 µs
@benchmark collect(Missings.replace(df[:a], 0)) # 32.6 µs
@benchmark df.a = coalesce.(df.a, 0) # Median time: 5.4 µs
@benchmark df.a = replace(df.a, missing => 0) # Median time: 0.2 µs
@benchmark replace!(df.a, missing => 0) # Median time: 0.08 µs (!)

## REPLACE MISSING VALUES IN ALL COLUMS
## The following example uses the fastest solution (see above) in a for loop. 
## I wish there was some more elegant solution that can do it in one line of code, 
## but I haven’t been able to find one. Unsurprisingly, list comprehension 
## and map() return two vectors, instead of a DataFrame.

x1 = [missing ; rand(5) ; missing]
x2 = rand(7)
df = DataFrame(hcat(x1, x2), :auto)
for col in eachcol(df)
    replace!(col, missing => 0)
end
df

## Replace NaN in a DataFrame
## Using the R-ish solution and the isnan function, we can easily do it as follows:

df[isnan.(df.a), :a] .= 0

## However, there is a drawback. The isnan function only accepts a Float-type column, 
## and not a String column, nor missing. If you pass it a string column, it will generate an error:
## MethodError: no method matching isnan(::String)
## That’s why I prefer the following solution. In the next chunk of code I give the 
## solution for both a specific column and for all columns.

replace!(df.a, NaN => 0)

df = DataFrame(:A => [5, 10, NaN, NaN, 25], :B => ["A", "B", "A", missing, missing])
dropmissing(df)
df
dropmissing!(df)
df

df = DataFrame(:A => [5, missing, NaN, NaN, 25], :B => ["A", "B", "A", missing, missing])
filter(:A => x -> !(ismissing(x) || isnothing(x) || isnan(x)), df)
filter(:A => x -> !any(f -> f(x), (ismissing, isnothing, isnan)), df)

df = DataFrame(y1 = [5. ; 10 ; NaN ; NaN ; 25], y2 = [0 ; 12. ; .7 ; 0 ; 2])
for col in eachcol(df)
    replace!(col, NaN => 0)
end
df
allowmissing!(df)
for col in eachcol(df)
    replace!(col, 0 => missing)
end
df 

