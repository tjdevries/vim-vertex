#!/usr/bin/perl 
# program to trace the history of a line through a git repository 
# 
# useage findlines pattern filespec 
# 
# finds all occurances of the pattern in the file and then uses git blame 
#  to find where those lines were introduced. It then takes a step back and 
#  looks at what the line replaced (if anything) and does a git blame on those 
#  lines as well 
# 
# written by David Lang and released under GPLv2 
# 
$target = shift @ARGV; 
$file = shift @ARGV; 
open($infile,"<$file"); 
$linecount=0; 
# find all lines in the file that match the target pattern 
# we have been provided. add them to a stack of items to research 
while(<$infile>){ 
   $linecount++; 
   if ($_ =~ /$target/) { 
     $items[++$#items]{line} = $linecount; 
     $items[$#items]{tree} = "HEAD"; 
     chomp; 
     $items[$#items]{target} = $_; 
   } 
} 
# go through all the items and research them in turn 
#  (note that more items may be added to the list while inside this loop) 
for ($i=0;$i<=$#items;$i++) { 
# do a git blame to find where the lines came from 
   $result = `git blame -b -l -L "$items[$i]{line}",+1 -M  $file 
$items[$i]{tree}` ; 
   print "in ".$items[$i]{tree}." found:\n$result"; 
   $commit=substr($result,0,40); 
   # if this is not the root commit, 
   #  do a diff to find what lines may have been replaced by the line we are looking for 
   if($commit ne "                                        "){ 
     $diff=`git diff -U0 $commit^..$commit $file`; 
     @lines=split("\n",$diff); 
     #strip the first four lines from the diff (as they just talk about the file) 
     shift(@lines); 
     shift(@lines); 
     shift(@lines); 
     shift(@lines); 
     $match=0; 
     $hunk=''; 
     # find what hunk of the diff introduced the lines we are looking for, 
     #  add the lines that they replaced to the list of items to examine 
     foreach(@lines){ 
       if ($_ =~ /^\@\@/ ) { 
         if ($match) { 
           process_hunk(); 
         } else { 
           $hunk = ''; 
         }; 
       } else { 
         $hunk .= $_."\n"; 
         if ($_ =~ /$items[$i]{target}/) { 
           $match = 1; 
         } 
       } 
     } 
     if ($match) { 
       process_hunk(); 
     } 
   } 
} 
sub process_hunk(){ 
   # find lines in the hunk of diff that are being replaced 
   foreach (split("\n",$hunk)){ 
     if ($_ =~ /^-/ ){ 
       # for now queue the line contents for further processing. 
       #   this really should be the line number becouse otherwise 
       #   git blame will use the first match it finds. since we are 
       # matching the entire line this is less of a problem than it could be. 
       $items[++$#items]{line} = "/".substr($_,1)."/"; 
       $items[$#items]{target} = substr($_,1); 
       $items[$#items]{tree} = "$commit^"; 
     } 
   } 
} 
