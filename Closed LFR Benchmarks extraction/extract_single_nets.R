#Extract all intermediate benchmarks for each network

extract_single_nets<-function()

{
  #set working directory to folder containing all benchmark network folders
  #setwd("C:/Users/fujitsu/Google Drive/Y3 Project/LFR-Closed benchmarks/Total file benchmarks")

  wdfolders<-list.files()
  
  #loop through all LFR folders
  for (i in 2:length(wdfolders)) 
  {
    #create a new directory containing a folder for each LFR benchmark
    new_dir<-paste0("C:/Users/fujitsu/Google Drive/Y3 Project/LFR-Closed benchmarks/Individual file benchmarks/",wdfolders[i])
    dir.create(new_dir)
    
    #load the list of dataframes for each LFR benchmark
    setwd(paste0("C:/Users/fujitsu/Google Drive/Y3 Project/LFR-Closed benchmarks/Total file benchmarks/",wdfolders[i]))
    load("COMPLETE CLOSED BENCHMARK.DAT")
    
    #loop over this list and save each dataframe representing a single intermediate network to its own text file
    for(i in 1:length(nets))
    {
      #save the text files to the new folders in the new directory
      write.table(nets[[i]], file = paste0(new_dir,"/",(i-1), "%_closed_bench.txt")
                ,append=FALSE, col.names = FALSE, row.names = FALSE)
    }
    
    #copy the initial and final network edgelists for each LFR into the new folders in the new directory as well
    final_comm<-read.table("network_final.comm")
    initial_comm<-read.table("network_initial.comm")
    
    save(final_comm, file = paste0(new_dir,"/","network_final.comm"))
    save(initial_comm,file = paste0(new_dir,"/","network_initial.comm"))
  }

}
