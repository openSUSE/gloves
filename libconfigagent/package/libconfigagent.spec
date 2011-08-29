#
# spec file for package libconfigagent (Version VERSION_TEMPLATE)
#
# Copyright (c) 2011 SUSE LINUX Products GmbH, Nuernberg, Germany.
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#
# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


Name:           libconfigagent
Requires:       rubygem-ruby-dbus
License:	      LGPLv2.1 or LGPLv3
Group:          Libraries/System
URL:            https://github.com/yast/yast--
Autoreqprov:    on
Version:        VERSION_TEMPLATE
Release:        0
Summary:        libconfigagent - framework for config agents
Source:         libconfigagent-%{version}.tar.bz2

BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildRequires:  rubygem-packaging-rake-tasks

# This is for Hudson (build service) to setup the build env correctly
%if 0
BuildRequires:  rubygem-test-unit
BuildRequires:  rubygem-rcov >= 0.9.3.2
%endif

%package devel
Group:    Development/Code Generators
Requires: webyast-base-ws = %{version}
Summary:  Generator of new config agents


%description
libconfigagent - Framework needed by each config agent. Provide way to easy
way to call agent attached to dbus in transparent way.
Authors:
--------
    Josef Reidinger <jreidinger@suse.cz>

%description devel
Contain generator for new config agents. It generates neccessary dbus and polkit configartion,
code which call proper parts of code and stubs for methods.

%prep
%setup

%build

%check

#---------------------------------------------------------------
%install
rake install

#---------------------------------------------------------------
%clean
rm -rf $RPM_BUILD_ROOT

#---------------------------------------------------------------
%files 
%defattr(-,root,root)
%doc COPYING COPYING.LESSER
%{ruby_sitelib}/dbus_clients
%{ruby_sitelib}/dbus_services


%files testsuite
%defattr(-,root,root)
/usr/lib/config-agent-generator
/usr/bin/config-agent-generator

#---------------------------------------------------------------
%changelog
