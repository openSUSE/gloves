#
# spec file for package yast++lib-kerberos_client (Version 0.1.0)
#
# Copyright (c) 2011 SUSE LINUX Products GmbH, Nuernberg, Germany.
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#
# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


Name:           yast++lib-global_config
License:	      LGPL-2.1; LGPL-3
Group:          System/Management
URL:            https://github.com/yast/yast--
Autoreqprov:    on
Version:        0.1.0
Release:        0
Summary:        Support for global options for yast++ libraries like chroot directory
Source:         %{name}-%{version}.tar.bz2

BuildRoot:      %{_tmppath}/%{name}-%{version}-build
Requires:       libconfigagent
BuildRequires:  ruby
BuildRequires:  rubygem-packaging_rake_tasks

# This is for Hudson (build service) to setup the build env correctly
%if 0
BuildRequires:  rubygem-test-unit
BuildRequires:  rubygem-rcov >= 0.9.3.2
%endif

%description
Support for global options for yast++ libraries like chroot directory. Part of yast++ project.
Authors:
--------
    Josef Reidinger <jreidinger@suse.cz>


%prep
%setup

%build

%check

#---------------------------------------------------------------
%install
rake install[%{buildroot}/,%{rb_vendorlib}]

#---------------------------------------------------------------
%clean
rm -rf $RPM_BUILD_ROOT

#---------------------------------------------------------------
%files
%defattr(-,root,root)
%{rb_vendorlib}/y_lib

#---------------------------------------------------------------
%changelog
