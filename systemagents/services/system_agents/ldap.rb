require 'rubygems'
require 'augeas'

aug = Augeas::open(nil, "", Augeas::NO_MODL_AUTOLOAD)
aug.transform(:lens => "Spacevars.simple_lns", :incl => "/etc/ldap.conf")

aug.load

base = aug.get("/files/etc/ldap.conf/base")
