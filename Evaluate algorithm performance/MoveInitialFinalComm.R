#WORKING DIRECTORY MUST BE SET TO FOLDER CONTAINING A DIRECTORY FOR ALL FOLDERS OF LFR BENCHMARKS AS WELL AS A DIRECTORY CONTAINING ALL FOLDERS OF LFR COMMuNITY MEMBERSHIP LISTS

#loop through all the benchmark folders for all 25 LFRs
setwd('./Individual File Benchmarks')

bench_nets<-list.files()

for (i in 1:length(bench_nets))
{
  if (i==1)
  {
    setwd(paste0('./',bench_nets[i]))
  }
  else
  {
    setwd(paste0('../',bench_nets[i]))
  }
  
  #store the initial and final community membership lists for the LFR
  initial<-read.table('network_initial.comm')
  final<-read.table('network_final.comm')
  
  #save the membership lists to the corresponding LFR's results folder
  write.table(initial,file=paste0('../../NMF_Results/BayesNMF_Results_for_',bench_nets[i],'/network_initial.comm'))
  write.table(final,file=paste0('../../NMF_Results/BayesNMF_Results_for_',bench_nets[i],'/network_final.comm'))
  
  
}