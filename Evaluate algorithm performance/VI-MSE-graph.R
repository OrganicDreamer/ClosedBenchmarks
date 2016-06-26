

vigraph <- function(){
	#The working directory has to be set to the folder containing all the communities results folders and nothing else
	
	#Dependencies. Packages that need to be installed as functions within are used.
	#install.packages("igraph")
	#install.packages("ggplot2")
	#install.packages("reshape")
	
	#Loading the packages
	library(igraph)
	library(ggplot2)
	library(reshape)
	
	folders <- list.files()   #Vector of network folder names present in the directory (line 2 must be true)
	root_directory <- getwd() #variable with the name of the directory where all the network folders are
	new_dir <- "VI Infomap Results"	#Directory name to be changed depending on the algorithm 
	dir.create(new_dir) #new directory where the results will be saved
	

	stats <- data.frame("Network"=character(), Mean_Square_Error=numeric()) #initializing stats dataframe to to store the respective MSE of each network
	
	stats$Network <- as.character(stats$Network) #ensures that the network column of as a character type
	
	
	for(j in 1:length(folders)){  #to loop over all folders
		setwd(paste0(root_directory,"/",folders[j])) #set working directory to the folder[j] which would correspond to a network folder
		
	
	
	
		results <- data.frame("Intermediate_Percentage"=numeric(), VIE=numeric(), VEF=numeric(), Vbar =numeric(), VIF=numeric())	#new data frame to store VIs that will be calculated
		
		comm_initial <- read.table("network_initial.comm") #Load initial community structure from the closed benchmark
		comm_final <- read.table("network_final.comm")	#Load final community structure from the closed benchmark
	
		comm_initial <- comm_initial[order(comm_initial$V1),]	#order community structures based on node number inorder to ensure a standardized format
		comm_final <- comm_final[order(comm_final$V1),]
	
		MSE <- 0	#Initialize mean error value to 0
		sum_SE <- 0	#Initialize  error value to 0
		index<-1 #Initialize count of number of intermediate networks to 1
		
		for(i in 1:99){	#Loop over intermediate networks
		  
		  if(file.exists(paste0(i,"%_closed_bench.txt")))
		  {
			  comm_btwn <- read.table( paste((i), "%_infomap_communities.txt", sep="")) #load intermediate networks. 'infomap' has to be changed if another algorithm is used to the name of the algorithm.
			  comm_btwn <- comm_btwn[order(comm_btwn$V1),]	#order community structures based on node number inorder to ensure a standardized format
			
			  #Calculating and assigning the calculated Variation of information to the respective place in the dataframe 	
			  results[index, "Intermediate_Percentage"] <- i
			  results[index, "VIE"]<-compare(comm_initial$V2, comm_btwn$V2, method = "vi")
			  results[index, "VIF"]<-compare(comm_initial$V2, comm_final$V2, method = "vi")
			  results[index, "VEF"]<-compare(comm_btwn$V2, comm_final$V2, method ="vi")
			  results[index, "Vbar"] <- (results[index, "VIE"] + results[index, "VEF"])
			  results[index, "Sq_err"] <- (results[index, "VIF"] - results[index, "Vbar"])^2
			
			  sum_SE <- (sum_SE + results[index, "Sq_err"]) #Summing the square errors to later be divided by the number of intermediate networks 
			  index<-index+1 #increment count of number of intermediate networks
		  }
		 
		}
		MSE <- (sum_SE/(index-1))	
		stats[j, "Network"] <- paste0(root_directory,"/",folders[j])	#assigning network name in the network column
		stats[j, "Mean_Square_Error"] <- MSE	#assigning MSE value to the MSE column
		stats[j, "Network"] <- gsub(paste0(root_directory,"/"), "", stats[j, "Network"]) #Getting rid of the names of the folders/directories in which our network folder is nested
		
	
		to_plot <- data.frame(results["Intermediate_Percentage"], results["VIE"], results["VEF"], results["Vbar"], results["VIF"])		#Selection of variables to be plotted and assigning them to a new dataframe
		to_plot <- melt(to_plot ,  id.vars = 'Intermediate_Percentage', variable.name = 'variable')	#Transforming the data for plotting with the ggplot package
		
	
		plot <- ggplot(data = to_plot, aes(x = Intermediate_Percentage, y= value, group=variable)) + geom_line(aes(colour = variable))	#saving the plot to a variable. geom_line indicates a graph of lines (could be bars, box-plot etc...)
		plot + labs(title=  paste0("VI - ",folders[j]," (MSE =", stats[j, "Mean_Square_Error"],")"), x = "Intermediate %", y = "Variation of Information", colour = "VIs")#Assigning title, axis titles, and legend title
		ggsave(sub(pattern="Infomap_Results_for_","\\2", paste0(root_directory,"/",new_dir,"/",folders[j],".jpeg")))#save the plot to a file
		write.table(results, file = paste(root_directory,"/",new_dir, "/VI_", stats[j, "Network"], ".txt", sep=""), append=FALSE, col.names = TRUE, row.names = FALSE, quote = FALSE) #save results dataframe to a table
		setwd(root_directory) #reset working directory
	}

	write.table(stats, file = paste(root_directory,"/", new_dir, "/MSE_VI_Infomap", ".txt", sep=""), append=FALSE, col.names = TRUE, row.names = TRUE, quote = FALSE, sep="-") #save file with the stats of every network Again 'infomap' has to be changed if another algorithm is used

}


