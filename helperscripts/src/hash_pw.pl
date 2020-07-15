#! /usr/bin/perl -w

use Crypt::Eksblowfish::Bcrypt;
use Crypt::Random;

$num_args = $#ARGV + 1;
if ($num_args != 1) {
  print "\nUsage:\thash_pw.pl password\n";
  exit
}
$salt = Crypt::Eksblowfish::Bcrypt::en_base64(Crypt::Random::makerandom_octet(Length=>16));
print Crypt::Eksblowfish::Bcrypt::bcrypt($ARGV[0],"\$2a\$08\$$salt") . "\n";