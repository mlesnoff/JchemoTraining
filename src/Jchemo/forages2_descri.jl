mypath = dirname(dirname(pathof(JchemoData)))
db = joinpath(mypath, "data", "forages2.jld2") 
@load db dat
pnames(dat)
  
X = dat.X    
Y = dat.Y
wl = names(X)
wl_num = parse.(Float64, wl)
ntot = nro(X)
summ(Y)
typ = Y.typ
test = Y.test

freqtable(typ, test)

s = Bool.(test)
Xtrain = rmrow(X, s)
Ytrain = rmrow(Y, s)
Xtest = X[s, :]
Ytest = Y[s, :]
ntrain = nro(Xtrain)
ntest = nro(Xtest)
(ntot = ntot, ntrain, ntest)

##### Spectra 

plotsp(X, wl_num; nsamp = 10,
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

fm = pcasvd(X, nlv = 15) ; 
pnames(fm)
res = summary(fm, X) ;
pnames(res)
z = res.explvar
plotgrid(z.pc, 100 * z.pvar; step = 1,
    xlabel = "nb. PCs", ylabel = "% variance explained").f

T = fm.T
plotxy(T[:, 1], T[:, 2]; color = (:red, .5),
    xlabel = "PC1", ylabel = "PC2").f
plotxy(T[:, 1], T[:, 2], typ; ellipse = true,
    xlabel = "PC1", ylabel = "PC2").f

## X-distribution: Train vs Test

nlv = 15
fm = pcasvd(Xtrain, nlv = nlv) ; 

Ttrain = fm.T
Ttest = Jchemo.transform(fm, Xtest)
T = vcat(Ttrain, Ttest)
group = vcat(repeat(["Train";], ntrain), repeat(["Test";], ntest))
i = 1
plotxy(T[:, i], T[:, i + 1], group;
    xlabel = "PC1", ylabel = "PC2").f

res_sd = scordis(fm) ; 
sdtrain = res_sd.dis
sdtest = Jchemo.predict(res_sd, Xtest).dis
res_od = odis(fm, Xtrain; nlv = nlv) ;
odtrain = res_od.dis
odtest = Jchemo.predict(res_od, Xtest).dis
f = Figure(resolution = (500, 400))
ax = Axis(f, xlabel = "SD", ylabel = "OD")
scatter!(ax, sdtrain.dstand, odtrain.dstand, label = "Train")
scatter!(ax, sdtest.dstand, odtest.dstand, color = (:red, .5), label = "Test")
hlines!(ax, 1; color = :grey, linestyle = "-")
vlines!(ax, 1; color = :grey, linestyle = "-")
axislegend(position = :rt)
f[1, 1] = ax
f

zres = res_sd ; nam = "SD"
#zres = res_od ; nam = "OD"
sdtrain = zres.dis
sdtest = Jchemo.predict(zres, Xtest).dis
f = Figure(resolution = (500, 400))
ax = Axis(f, xlabel = nam, ylabel = "Nb. observations")
hist!(ax, sdtrain.d; bins = 50, label = "Train")
hist!(ax, sdtest.d; bins = 50, label = "Test")
vlines!(ax, zres.cutoff; color = :grey, linestyle = "-")
axislegend(position = :rt)
f[1, 1] = ax
f

##### Variable y

nam = "dm"
#nam = "ndf"
y = Y[:, nam]
summ(y)

aggstat(y; group = test, fun = mean).X

ytrain = Float64.(Ytrain[:, nam])
ytest = Float64.(Ytest[:, nam])

f = Figure(resolution = (500, 400))
ax = Axis(f, xlabel = uppercase(nam), ylabel = "Nb. observations")
hist!(ax, ytrain; bins = 50, label = "Train")
hist!(ax, ytest; bins = 50, label = "Test")
axislegend(position = :rt)
f[1, 1] = ax
f

f = Figure(resolution = (500, 400))
offs = [30; 0]
Axis(f[1, 1], xlabel = uppercase(nam), ylabel = "Nb. observations",
    yticks = (offs, ["Train" ; "Test"]))
hist!(ytrain; offset = offs[1], bins = 50)
hist!(ytest; offset = offs[2], bins = 50)
f

f = Figure(resolution = (500, 400))
Axis(f[1, 1], xlabel = uppercase(nam), ylabel = "Density",
    yticks = (offs, ["Train" ; "Test"]))
density!(ytrain; color = :blue, label = "Train")
density!(ytest; color = (:red, .5), label = "Test")
axislegend(position = :rt)
f

f = Figure(resolution = (500, 400))
offs = [.4; 0]
Axis(f[1, 1], xlabel = uppercase(nam), ylabel = "Density",
    yticks = (offs, ["Train" ; "Test"]))
density!(ytrain; offset = offs[1], color = (:slategray, 0.5),
    bandwidth = 0.2)
density!(ytest; offset = offs[2], color = (:slategray, 0.5),
    bandwidth = 0.2)
f

zgroup = Int64.(zeros(ntot)) ; zgroup[s] .= 1
f = Figure(resolution = (500, 400))
ax = Axis(f, xlabel = "Group", ylabel = uppercase(nam))
boxplot!(ax, zgroup, y; show_notch = true)
f[1, 1] = ax
f

