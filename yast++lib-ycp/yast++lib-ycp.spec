#
# spec file for package yast++lib-ycp (Version 0.1.0)
#
# Copyright (c) 2011 SUSE LINUX Products GmbH, Nuernberg, Germany.
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#
# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


Name:           yast++lib-ycp
License:	LGPL-2.1 OR LGPL-3
Group:          System/Management
URL:            https://github.com/yast/yast--
Autoreqprov:    1
Version:        0.1.0
Release:        0
Summary:        YCP bindings to YLib


Requires:       yast++lib-global
BuildRequires:	yast2 yast++lib-global
BuildArchitectures: noarch


%description

#---------------------------------------------------------------
%install
mkdir -p $RPM_BUILD_ROOT/usr/share/YaST2/modules
ln -sf %{rb_vendorlib}/y_lib $RPM_BUILD_ROOT/usr/share/YaST2/modules/y_lib


#---------------------------------------------------------------
%files
%defattr(-,root,root)
%dir /usr/share/YaST2/modules/y_lib

#---------------------------------------------------------------
%changelog
