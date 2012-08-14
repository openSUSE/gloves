#Gloves


##Project State

Currently, it is still in a research phase.
You can try it, but it is not for production use. We'd like to hear any comments.

##Documentation

Various written documenation is located at doc directory.

### Generated code documenation
[Fresh generated documenation] (http://rubydoc.info/github/openSUSE/gloves)

### How to try it from git
install rubygem dependencies from the OpenSUSE build system Ruby Extensions repositories

    sudo zypper ar http://download.opensuse.org/repositories/YaST:/Head:/YaST++/openSUSE_12.2
    sudo zypper in rubygem-ruby-augeas augeas-lenses rubygem-packaging_rake_tasks

    sudo rake install
    cd gloves-country
    ruby examples/timezone_conf


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
* doc - overall documentation
* libconfigagent - infrastructure and generators for config agents
* yast - contains modified YaST modules using Gloves
* gloves-* - contains high level configuration library
