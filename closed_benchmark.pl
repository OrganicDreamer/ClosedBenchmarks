#!/usr/bin/perl

##############################################################################
#                                                                            #
#  closed_benchmark.pl                                                       #
#   is a perl script that converts a given network into a second one         # 
#   with the same pattern of connections. As the process of conversion       #
#   advances, the program outputs the graph corresponding to each step       #
#   These two networks, together with those generated at the intermediate    #
#   steps, create a whole closed benchmark.                                  #
#                                                                            #
#                                                                            #
#  Copyright (C) 2012 Rodrigo Aldecoa <raldecoa@ibv.csic.es>, Ignacio        #
#  Marín <imarin@ibv.csic.es>                                                #
#                                                                            #
#   closed_benchmark is free software: you can redistribute it and/or modify #
#   it under the terms of the GNU General Public License as published by     #
#   the Free Software Foundation, either version 3 of the License, or        #
#   (at your option) any later version.                                      #
#                                                                            # 
#   closed_benchmark is distributed in the hope that it will be useful,      #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of           #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
#   GNU General Public License for more details.                             #
#                                                                            #
#   You should have received a copy of the GNU General Public License        #
#   along with closed_benchmark.pl.  If not, see                             # 
#   <http://www.gnu.org/licenses/>.                                          #
#                                                                            #
#                                                                            #
#                                                                            #
#   If you use this program, please cite:                                    #
#     Aldecoa R, Marín I (2012)                                              #
#     Closed benchmarks for network community structure characterization     #
#     Physical Review E 85, 026109                                           #
#                                                                            #
##############################################################################


use strict;
use warnings;
use Getopt::Long;

#use Math::Random::MT::Auto qw(rand);  # Uncomment this line if you have the 
                                       # Math::Random::MT package installed

use vars qw( $help $verbose $graph_file $points $comm_file $directed $weighted);


&GetOptions( "h|help" => \$help,
	     "g|graph_file=s" => \$graph_file,
	     "c|comm_file=s" => \$comm_file,
	     "p|points=i" => \$points,
	     "d|directed" => \$directed,
	     "w|weighted" => \$weighted
    );

my $Usage = <<END_USAGE;

Usage:
  $0: [options]
Options:
    -h   --help           this message
    -g   --graph_file     file containing the input network to be converted  
    -c   --comm_file      file containing the distribution of nodes per communities
    -p   --points         The program will print a certain number of intermediate
                          networks during the conversion (number of points)
    -w   --weighted       use this flag if dealing with a weighted graph
    -d   --directed       use this flag if dealing with a directed graph (still in Beta)

END_USAGE
    ;

if ( $help || !$graph_file || !$comm_file || !defined $points )
{
    die $Usage;
}

$directed = 0 unless defined $directed;
$weighted = 0 unless defined $weighted;

############################
# READ INITIAL COMMUNITIES #
############################
open(I, $comm_file) or die "Unable to open $comm_file";
my %node2comm; # Community of each node
my %comm;  # Nodes for each community 
while(<I>){
    my @tmp = split '\s', $_;
    if(scalar @tmp != 2){ die "Error in comm_file: Wrong format"; }
    if(defined $node2comm{$tmp[0]}){ die "Error in comm_file: node $tmp[0] repeated"; }
    $node2comm{$tmp[0]} = $tmp[1];
    push @{ $comm{$tmp[1]} }, $tmp[0];
}
close I;
my @labels = keys %node2comm;
my $nNodes = scalar @labels;



############################
# CREATE FINAL COMMUNITIES #
############################
my @flabels = @labels; # Final labels
&fisher_yates_shuffle(\@flabels);

# initial to final and vice versa mapping
my (%i2f, %f2i);
for(my $i = 0; $i < $nNodes; $i++){
    $i2f{$labels[$i]} = $flabels[$i];
    $f2i{$flabels[$i]} = $labels[$i];
}

# final communities
my %fnode2comm; # Communitiy of each final node
my %fcomm; # Final nodes for each community
foreach my $n (@labels){
    my $fnode = $i2f{$n}; # Final node maps the current node 
    my $c = $node2comm{$n}; # Community of the current node
    $fnode2comm{$fnode} = $c; # The final node belongs to the same community
    push @{ $fcomm{$c} }, $fnode;
}


#################################
# WRITE INITIAL AND FINAL COMMS #
#################################
my $name = $graph_file;
$name =~ s/\.\w*$//;

open(I, ">$name\_initial.comm");
open(F, ">$name\_final.comm");
foreach(sort {$a cmp $b} @labels){
    print I "$_\t".$node2comm{$_}."\n";
    print F $i2f{$_}."\t".$fnode2comm{$i2f{$_}}."\n";
}
close I;
close F;



################
# CREATE GRAPH #
################

# Read graph
my %g;
my @weight;
open(G, "$graph_file") or die "Unable to open $graph_file";
my @graph;
while(<G>){
    my @tmp = split '\s', $_;
    if(!$weighted && scalar @tmp != 2){ print "Error in graph_file: Wrong format\n"; die;}
    if($weighted && scalar @tmp != 3){ print "Error in comm_file: Wrong format\n"; die;}
    my $A = $tmp[0];
    my $B = $tmp[1];
    push @graph, [$A, $B];
    if( $directed ){
	$g{$A}{$B} = 1;
    }else{
	$g{$A}{$B} = $g{$B}{$A} = 1;
    }
    if( $weighted ){
	$weight[$A][$B] = $weight[$B][$A] = $tmp[2];
    }
}
close G;


my @noGraph; # Links of the final graph which are not in the initial graph (they will be added)
for(my $i = 0; $i < $nNodes; $i++){
    my $A = $i2f{$labels[$i]};
    for(my $j = $i + 1; $j < $nNodes; $j++){
	my $B = $i2f{$labels[$j]};
	if(exists($g{$labels[$i]}{$labels[$j]}) && !exists($g{$A}{$B})){
	    push @noGraph, [$A, $B];
	}
	# For directed graphs
	if( $directed ){
	    if(exists($g{$labels[$j]}{$labels[$i]}) && !exists($g{$B}{$A})){
		push @noGraph, [$B, $A];
	    }
	}
    }
}  


# Let's shuffle
my $nLinks = scalar @noGraph;
my $removed = 0;


if ($nLinks eq 0){
    print "\nThe final community structure (randomly selected) is exactly the same as the original one.\n";
    print "No changes will be performed. Try running the program again.\n";
}
else{
    my $limit = $points + 1;
    my $step;
    if($nLinks < $limit){
	print "\nThe final community structure (randomly selected) differs with the original one in\n";
	print "just $nLinks link(s). Changing the number of intermediate points to ".($nLinks - 1)."\n";
	$step = 100 / $nLinks;
    }
    else{
	$step = 100 / ($points + 1);
    }


    for(my $i = $step; $i <= 100; $i += $step){
	my $links2shuffle = int( ($i * $nLinks / 100) ) - $removed;
	if( ($i * $nLinks /100) ne int( ($i * $nLinks / 100) ) ){
	    my $rr = int(rand(2));
	    if($rr eq 1){
		$links2shuffle++;
	    }
	}

	$removed += $links2shuffle;

	while($links2shuffle){
	    my $r = int(rand(scalar @graph));
	    my $A = $f2i{$graph[$r]->[0]};
	    my $B = $f2i{$graph[$r]->[1]};
	    if(!exists($g{$A}{$B})){
		splice(@graph, $r, 1);
		$r = int(rand(scalar @noGraph));
		my @newLink = splice(@noGraph, $r, 1);
		push @graph, @newLink;
		$links2shuffle--;
	    }
	}
	
	open O, ">$name\_$i.pairs";
	foreach(@graph){
	    print O $_->[0]."\t".$_->[1]."\t";
	    if($weighted){
		print O $weight[$f2i{$_->[0]}][$f2i{$_->[1]}];
	    }
	    print O "\n";
	}
	close O;
    }
}





###################################
###################################
# Subroutine for shuffling an array
sub fisher_yates_shuffle{
    my $array = shift;
    my $i;
    for ($i = @$array; --$i; ) {
        my $j = int rand ($i+1);
        next if $i == $j;
        @$array[$i,$j] = @$array[$j,$i];
    }
}
