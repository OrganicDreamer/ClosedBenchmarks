load_closed_bench <- function() 
{
  #WORKING DIRECTORY MUST BE THE FOLDER WHERE ALL INITIAL, INTERMEDIATE AND FINAL BENCHMARKS ARE
  #FOR EACH CLOSED BENCHMARK
  
  #install and load gtools so mixedsort() can be used:
  #install.packages("gtools")
  library(gtools)
  
  #load and sort all file names and sort them in ascending numerical order (ie. 1 to 100)
  all_files <- mixedsort(as.character(list.files()))
  
  nets<-list()
  
  #start from 4th file in file names, where network files start to where they end, will vary depending on what directory looks like
  for (k in 6:(length(all_files)-2))
    {
    
    #read all the edge lists into R
    nets[k-5]<-list(read.delim(all_files[k],header=FALSE, fill=TRUE))
  
    }
  
  #loop through all networks for each closed benchmark and fill in missing values for the edge lists 
  #based on values found in previous intermediate's edge list:
  for (j in 2:length(nets))
    {
    
	  n_current<-data.frame(nets[j])
	  n_previous<-data.frame(nets[j-1])
	  
    
	  for (i in 1:nrow(n_current))	
	    {
	    
	    #when a missing weight is found
		  if (is.na(n_current[i,3]) ) 
		  {
			  node1 <- n_current[i,1]
			  node2 <- n_current[i,2]
			  
			  #fill the missing weight in the current edge list by finding the weight for the same connection
			  #in the previous intermediate network:
			  subn_current<-n_previous[which(n_current$V1==node1 & n_current$V2==node2),]
			  n_current[i,3]<-subn_current[1,3]
		  }
		  
	    #replace the current edge list with the same list but with all weights filled in 
	    nets[[j]]<- n_current
	    }
    }
#return nets with all intermediate networks having filled in weight values
save(nets,file="COMPLETE CLOSED BENCHMARK.dat")
return(nets)
}

