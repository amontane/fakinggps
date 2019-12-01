#!/usr/bin/perl

use Term::ReadKey;
use Net::Telnet;

# (1) Get arguments!
$num_args = $#ARGV + 1;
if ($num_args != 2) {
	print "Gimme 2 args: latitude and longitude\n";
	exit;
}

$ctrlc = 3;
$wkey = 119;
$akey = 97;
$dkey = 100;
$skey = 115;

$latitude = $ARGV[0];
$longitude = $ARGV[1];
$speed = 15.0; #km/h
$degrees_per_step = 5.0;
$ori_degrees = 0.0;
$ori_direction = N;


$conn = new Net::Telnet(Timeout => 30, 
						Port =>5554,
						Prompt => "/OK/");
$conn->open("localhost");
$conn->cmd("auth R9pbxqeiKrShHA5M");
sub deg2rad {
	$degrees = shift;
	return ($degrees / 180) * 3.14159265358979;
}

sub updateState {
	printf "Latitude: %.5f Longitude: %.5f Speed: %.1f Km/h. Orientation: %.3fº ($ori_direction)           \015", $latitude, $longitude, $speed, $ori_degrees;
	# TODO: launch command!
	$response = $conn->cmd("geo fix " . $longitude . " " . $latitude . "\n");
}

sub processKey {
	$key = shift;

	if ($key eq $akey) {
		$ori_degrees = $ori_degrees - $degrees_per_step;
	} elsif ($key eq $dkey) {
		$ori_degrees = $ori_degrees + $degrees_per_step;
	} elsif ($key eq $wkey) {
		$latitude = $latitude + ($straight_step * cos(deg2rad($ori_degrees)));
		$longitude = $longitude + ($straight_step * sin(deg2rad($ori_degrees)));
	} elsif ($key eq $skey) {
		$latitude = $latitude - ($straight_step * cos(deg2rad($ori_degrees)));
		$longitude = $longitude - ($straight_step * sin(deg2rad($ori_degrees)));
	}

	if ($ori_degrees >= 360) {
		$ori_degrees = $ori_degrees - 360;
	} elsif ($ori_degrees < 0) {
		$ori_degrees = $ori_degrees + 360;
	}

	if (($ori_degrees >= 0.0 && $ori_degrees < 22.5) || ($ori_degrees >= 337.5) && ($ori_degrees < 360)){
		$ori_direction = N;
	} elsif ($ori_degrees >= 22.5 && $ori_degrees < 67.5){
		$ori_direction = NE;
	} elsif ($ori_degrees >= 67.5 && $ori_degrees < 112.5){
		$ori_direction = E;
	} elsif ($ori_degrees >= 112.5 && $ori_degrees < 157.5){
		$ori_direction = SE;
	} elsif ($ori_degrees >= 157.5 && $ori_degrees < 202.5){
		$ori_direction = S;
	} elsif ($ori_degrees >= 202.5 && $ori_degrees < 247.5){
		$ori_direction = SW;
	} elsif ($ori_degrees >= 247.5 && $ori_degrees < 292.5){
		$ori_direction = W;
	} elsif ($ori_degrees >= 292.5 && $ori_degrees < 337.5){
		$ori_direction = NW;
	}
}


# 1 degree = 111.111 km
# 1 second = 10 keyboard strokes
# 1 minute = 600 keyboard strokes
# 1 hour = 36000 keyboard strokes

$straight_step = $speed / (111.111 * 36000);

print "\n";
updateState();


ReadMode 'raw';
do {
    $key = ReadKey(0);
    $OrdKey = ord($key);
    processKey($OrdKey);
    updateState();
}  while ($OrdKey != 3);

$conn->close;
ReadMode 'restore';
print "\n";
