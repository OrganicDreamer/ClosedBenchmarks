cola<-c()
colb<-c()
result<-c()
load("COMPLETE CLOSED BENCHMARK.dat")

#loop through all the networks for a single LFR benchmark
for (i in 1:length(nets))
{
  net<-(nets[[i]])
  
  #for each intermediate network count the number of unique nodes listed in the entire edgelist, should be 1650 for each network
  cola<-net[,1]
  colb<-net[,2]
  result[i]<-length(unique(c(cola,colb)))
}

#loop through the list of the number of unique nodes in each intermediate's edgelist
#identify any networks which are missig nodes (ie. they don't have 1650 nodes )
unique(result)

bad_nets<-c()

for (i in 1:length(result))
{
  if (result[i]<1650)
  {
    bad_nets[i]<-i
  }
}

bad_nets