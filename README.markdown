#Gloves


##Project State

Currently, it is still in a research phase.
You can try it, but it is not for production use. We'd like to hear any comments.

##Documentation

Various written documenation is located at doc directory.

### Generated code documenation
[Fresh generated documenation] (http://rubydoc.info/github/yast/yast--)

### How to try it from git
install rubygem dependencies from the OpenSUSE build system's Ruby Extensions repository

    sudo zypper ar http://download.opensuse.org/repositories/devel:/languages:/ruby:/extensions/openSUSE_12.1/devel:languages:ruby:extensions.repo
    sudo zypper in rubygem-ruby-augeas augeas-lenses rubygem-open4 rubygem-packaging_rake_tasks rubygem-ruby-dbus

    sudo rake install
    cd yast++lib-kerberos-client
    ruby examples/kerberos_conf


#### How to obtain permission for common user:
    su
    mkdir -p /etc/polkit-1/localauthority/50.local.d
    cp doc/org.opensuse.config_agent.pkla /etc/polkit-1/localauthority/50.local.d
    #replace <yourcooluser> with real user in /etc/polkit-1/localauthority/50.local.d/org.opensuse.config_agent.pkla

### How to try it from packages
[OpenSUSE Build Service project with packages](https://build.opensuse.org/project/show?project=YaST:Head:YaST%2B%2B)
TODO create pattern

  


###Directory structure
* config_agent-* - contains packages with config agents
* doc - overall yast++ documentation
* libconfigagent - infrastructure and generators for config agents
* yast - contains modified yast modules to use yast++
* yast++lib* - contains high level configuration library
