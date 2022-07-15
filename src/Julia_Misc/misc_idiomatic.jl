n = 5 
x = rand(n) 
for i in 1:n 
    println(i)
end
# Same as:
for i in eachindex(x) 
    println(i)
end
# Different than:
for i in x 
    println(i) # "i" = x[i]
end

x = rand(5) 
acc = 0 
for i in eachindex(x) 
    acc += x[i] # = acc + x[i]
end
acc
sum(z)

x = rand(5) 
acc = 0 
for i in x
    acc += i # = acc + "i"
end
acc
sum(x)

fz(x) = [p = p * 2 for p in x]
fz([1; 2; 3])

x = [1; 2; 3]
[p = p * 2 for p in x]







