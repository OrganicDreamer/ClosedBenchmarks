mse_bar_plot <- function(){
	#install.packages("igraph")
	#install.packages("ggplot2")
	#install.packages("reshape")
	
	#Load dependencies 
	library(igraph)
	library(ggplot2)
	library(reshape)
	
	files <- list.files()   #List of MSE of algorithms available
	
	algorithms_results <- vector(mode = "list", length = length(files)) # Load results
	
	
	for(i in 1:length(files)){	#load all results to list
		algorithms_results[[i]] <- read.table(files[i], sep="-")
		

	}
	
	mu_values <- vector(mode = "list", length = 5) #create list to incorporate all results
	
	
	for(i in 1:length(mu_values)){#separation of muw and mut results into desired format
		mu_values[[i]] <- data.frame("mut"=character(), "BayesNMF"=numeric(), "Edgebetweenness"=numeric(), "Infomap"=numeric(), "Louvain" =numeric(), "Spinglass"=numeric(), stringsAsFactors=FALSE)
	}
	for(m in 1:length(algorithms_results)){
		for(i in 1:length(mu_values)){
			for(j in 1:length(mu_values)){
				mu_values[[i]][j,1] <- j/10
				mu_values[[i]][j,(m+1)] <- algorithms_results[[m]]$Mean_Square_Error[j+(5*(i-1))]
			}
		}
	}	
	
	
	
	processed <- vector(mode = "list", length = 5)	#initialize list of processed results


	for(i in 1:5){#process the results for graphing
		processed[[i]] <- melt(mu_values[[i]], id.vars='mut')
		colnames(processed[[i]]) <- colnames(processed[[i]]) <- c("mut","Algorithm", "MSE")
		}
		
	for(i in 1:length(processed)){	#plot each table and save to file with appropriate name
		plot <- ggplot(processed[[i]], aes(mut, MSE)) + geom_bar(aes(fill = Algorithm), position = "dodge", stat="identity") + labs(title=  paste0("muw=",i/10), x = "mut", y = "Mean Squared Error", colour = "Algorithm")
		ggsave(paste0("MSE_results_for_muw=",i/10,".jpeg"))
	}
	
}