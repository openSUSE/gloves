#
# spec file for package gloves-ycp-bindings
#
# Copyright (c) 2011 SUSE LINUX Products GmbH, Nuernberg, Germany.
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#
# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


Name:           gloves-ycp-bindings
License:	LGPL-2.1 OR LGPL-3
Group:          System/Management
URL:            https://github.com/yast/yast--
Autoreqprov:    1
Version:        0.2.1
Release:        0
Summary:        YCP bindings to YLib


Requires:       gloves-global
BuildRequires:	yast2 gloves-global

%description

#---------------------------------------------------------------
%install
mkdir -p $RPM_BUILD_ROOT/usr/share/YaST2/modules
ln -sf %{rb_vendorlib}/glove $RPM_BUILD_ROOT/usr/share/YaST2/modules/glove


#---------------------------------------------------------------
%files
%defattr(-,root,root)
%dir /usr/share/YaST2/modules/glove

#---------------------------------------------------------------
%changelog
