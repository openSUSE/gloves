#
# spec file for package yast++lib-ycp-kerberos_client (Version 0.1.0)
#
# Copyright (c) 2011 SUSE LINUX Products GmbH, Nuernberg, Germany.
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#
# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


Name:           yast++lib-ycp-kerberos-client
License:	LGPLv2.1 or LGPLv3
Group:          System/Management
URL:            https://github.com/yast/yast--
Autoreqprov:    1
Version:        0.1.0
Release:        0
Summary:        YCP bindings to yast++lib-kerberos-client


Requires:	yast++lib-kerberos-client
BuildRequires:	yast++lib-kerberos-client yast2
BuildArchitectures: noarch


%description

#---------------------------------------------------------------
%install
mkdir -p $RPM_BUILD_ROOT/usr/share/YaST2/modules/YLib
ln -sf %{rb_vendorlib}/y_lib/kerberos_client.rb $RPM_BUILD_ROOT/usr/share/YaST2/modules/YLib/KerberosClient.rb


#---------------------------------------------------------------
%files 
%defattr(-,root,root)
%dir /usr/share/YaST2/modules/YLib
/usr/share/YaST2/modules/YLib/KerberosClient.rb

#---------------------------------------------------------------
%changelog
