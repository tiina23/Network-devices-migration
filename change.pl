#!/usr/bin/perl
use strict;
use warnings;

#Function to ask from user
sub promptUser {
  my($prompt, $default) = @_;
  my $defaultValue = $default ? "[$default]" : "";
  print "$prompt $defaultValue: ";
  chomp(my $input = <STDIN>);
  return $input ? $input : $default;
}
my $filename = &promptUser("Enter the wanted equipment name");
my $enr = &promptUser("Enter the number of equipment");
my $listname = &promptUser("Enter the PWHE listname");
my $p2p = &promptUser("Enter the p2p name");
my $xconnect = &promptUser("Enter the xconnect name");
my $address = &promptUser("Enter the PWHE ip address");
my $neighbor = &promptUser("Enter the neighbor ID");

#Open a file and assign the filehandle F
open(F, $filename) or die("can't open myfile.txt: $!\n");


#Read in the whole file into an array of lines
my @lines = ();
while(<F>) {
    push(@lines, $_);
}
close(F);   #Close the filehandle

my $rows = $#lines;
my $shutdown = 0;
my $increase = 1;

#If it's Brocade equipment
if($filename =~ /ces/)
{
for (my $i=0; $i <= $rows; $i++)
	{
        if ($lines[$i] =~ /interface ethernet/) 
        	{
         	$i++;
    		if ($lines[$i] !~ /;;NOMON/) 
      			{
       			my $prevrow = $lines[$i];
       			my $desc = substr $prevrow, 10;       
       			$i++;
       			$shutdown = 0;
       			while ($lines[$i] !~ /!/) 
        			{            
        			if ($lines[$i] !~ /disable/) 
					{
          				$i++;
        				}
				else
					{
         				$shutdown = 1;
         				$i++;
        				}
            			} 
           		if ($shutdown == 0) 
				{
           			my $vlan = $enr*100 + $increase;
           			print "interface TenGigE0/0/0/$enr.$vlan\n";
               			print "\tdescription $desc";
           			print "\tencapsulation dot1q $vlan\n";
           			print "\tbundle id $enr\n";
           			$increase ++;
          			}
                       	}         
        	}	 
	}	
 }

#If it's Cisco equipment
if($filename =~ /cs/){
for (my $i=0; $i <= $rows; $i++)
	{
        if ($lines[$i] =~ /interface/) 
        	{
         	$i++;
    		if ($lines[$i] !~ /;;NOMON/) 
      			{
       			my $prevrow = $lines[$i];       		 
       			$i++;
       			$shutdown = 0;
       			while ($lines[$i] !~ /!/) 
        			{            
        			if ($lines[$i] !~ /shutdown/) 
					{
          				$i++;
        				}
				else
					{
         				$shutdown = 1;
         				$i++;
        				}
            			} 
           		if ($shutdown == 0) 
				{
           			my $vlan = $enr*100 + $increase;
           			print "interface TenGigE0/0/0/$enr.$vlan\n";
           			print "\t $prevrow";
           			print "\tencapsulation dot1q $vlan\n";
           			print "\tbundle id $enr\n";
           			$increase ++;
          			}
                       
                       	}         
        	}
	}
 }
 
#If it's HP equipment
if($filename =~ /hp/){
for (my $i=0; $i <= $rows; $i++)
	{
        if ($lines[$i] =~ /interface/) 
        	{
         	$i++;
    		if ($lines[$i] !~ /disable/) 
      			{
			my $prevrow = $lines[$i];
			my $desc = substr $prevrow, 5;
			$shutdown = 0;	             
       			while ($lines[$i] !~ /exit/) 
        			{            
        			if ($lines[$i] !~ /;;NOMON/) 
					{
          				$i++;
        				}
				else
					{
         				$shutdown = 1;
         				$i++;
        				}
            			} 
           		if ($shutdown == 0) 
				{
           			my $vlan = $enr*100 + $increase;
           			print "interface TenGigE0/0/0/$enr.$vlan\n";
                  		print "\tdescription $desc";
           			print "\tencapsulation dot1q $vlan\n";
           			print "\tbundle id $enr\n";
           			$increase ++;
          			}                     
                       	}         
        	}
	}
 } 
 
 #If it's Mikrotik equipment
if($filename =~ /mt/){
for (my $i=0; $i <= $rows; $i++)
	{
        if ($lines[$i] =~ /find default-name=ether/ ) 
        	{
		my $prevrow = $lines[$i];
		my @row = split /[" "=]/, $prevrow;
		my $desc = $row[7];             
           	my $vlan = $enr*100 + $increase;
           	print "interface TenGigE0/0/0/$enr.$vlan\n";
           	print "\tdescription $desc\n";
           	print "\tencapsulation dot1q $vlan\n";
           	print "\tbundle id $enr\n";
           	$increase ++;                         	        
        	}
	}
 }         
         
my $list = "generic-interface-list $listname";
print "$list\n\t";
print "interface Bundle-Ether$enr\n"; 
my $pw = "interface PW-Ether$enr";
print "$pw\n";
print "\tipv4 address $address\n";
print "\tattach $list\n";
print "l2vpn\n";
print "\tpw-class $listname\n";
print "\t\tencapsulation mpls\n";
print "\t xconnect group $xconnect\n";
print "\t\tp2p $p2p\n";
print "\t\t\t$pw\n";
print "\t\t\tneighbor $neighbor pw-id $enr\n";       
