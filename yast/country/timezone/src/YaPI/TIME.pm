#--
# Copyright (c) 2009-2012 Novell, Inc.
# 
# All Rights Reserved.
# 
# This program is free software; you can redistribute it and/or modify it
# under the terms of version 2 of the GNU General Public License
# as published by the Free Software Foundation.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, contact Novell, Inc.
# 
# To contact Novell about this file by physical or electronic mail,
# you may find current contact information at www.novell.com
#++

package YaPI::TIME;

use strict;
use YaST::YCP qw(Boolean);
use YaPI;

textdomain("time");

# ------------------- imported modules
YaST::YCP::Import ("Language");
YaST::YCP::Import ("Timezone");
# -------------------------------------

our $VERSION            = '1.0.0';
our @CAPABILITIES       = ('SLES9');
our %TYPEINFO;

BEGIN{$TYPEINFO{Read} = ["function",
    ["map","string","any"],["map","string","string"]];
}
sub Read {
  my $self = shift;
  my $args = shift;
  my $ret = {};
  Timezone->Read();
  if (($args->{"zones"} || "") eq "true")
  {
    $ret->{"zones"} = Timezone->get_zonemap();
  }
  if (($args->{"utcstatus"} || "") eq "true"){
    if (Timezone->utc_only()){
      $ret->{"utcstatus"} = "UTConly";
    } elsif (Timezone->hwclock eq "-u") {
      $ret->{"utcstatus"} = "UTC";
    } else {
      $ret->{"utcstatus"} = "local";
    }
  }
  if (($args->{"currenttime"} || "") eq "true"){
    $ret->{"time"} = Timezone->GetDateTime(YaST::YCP::Boolean(1),YaST::YCP::Boolean(0));
  }
  if (($args->{"timezone"} || "") eq "true"){
    $ret->{"timezone"} = Timezone->timezone;
  }
  if (($args->{"language"} || "") ne "") {
    my $language	= $args->{"language"} || "";
    my $timezone_for_language = Timezone->GetTimezoneForLanguage ($language, "");
    # no timezone for this locale, try guessing only by language
    unless ($timezone_for_language) {
	my $lang_map	= Language->GetLanguagesMap(0);
	foreach my $lang (keys %$lang_map) {
	    if (substr ($lang, 0, 2) eq $language) {
		$timezone_for_language = Timezone->GetTimezoneForLanguage ($lang, "");
		last;
	    }
	}
    }
    $ret->{"timezone_for_language"}	= $timezone_for_language;
  }
  return $ret;
}

BEGIN{$TYPEINFO{Write} = ["function",
    "boolean",["map","string","string"]];
}
sub Write {
  my $self = shift;
  my $args = shift;
  Timezone->Read();
  if (defined $args->{"utcstatus"}){
    if (Timezone->utc_only()){
      #do nothink as utc cannot be change
    } elsif ($args->{"utcstatus"} eq "UTC") {
      Timezone->hwclock("-u");
    } else {
      Timezone->hwclock("--localtime");
    }
  }
  if (defined $args->{"timezone"}){
    Timezone->Set($args->{"timezone"},YaST::YCP::Boolean(1));
  }
  if (defined $args->{"currenttime"}){
#format yyyy-dd-mm - hh:mm:ss
    if ($args->{"currenttime"} =~ m/(\d+)-(\d+)-(\d+) - (\d+):(\d+):(\d+)/)
    {
      Timezone->SetTime(int($1),int($3),int($2),int($4),int($5),int($6));
    }
  }

  Timezone->Save();
  return 1;
}

1;
