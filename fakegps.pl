#!/usr/bin/perl

use Net::Telnet;

# (1) Get arguments!
$num_args = $#ARGV + 1;
if ($num_args != 2) {
	print "Gimme 2 args: latitude and longitude\n";
	exit;
}

$latitude = $ARGV[0];
$longitude = $ARGV[1];

$conn = new Net::Telnet(Timeout => 30, 
						Port =>5554,
						Prompt => "/OK/");
$conn->open("localhost");
$conn->cmd("auth R9pbxqeiKrShHA5M");
printf "Latitude: %.5f Longitude: %.5f\n", $latitude, $longitude;
$conn->cmd("geo fix " . $longitude . " " . $latitude . "\n");
$conn->close;
