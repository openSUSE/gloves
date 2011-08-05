#
# Makefile.am for devtools/devtools/skeletons/config/src
#

yncludedir = @yncludedir@/kerberos-client

rncdir =  $(schemadir)/autoyast/rnc

client_DATA =			\
	kerberos.ycp    	\
	kerberos-client.ycp 	\
	kerberos-client_auto.ycp

ynclude_DATA =			\
	wizards.ycp 		\
	dialogs.ycp

desktop_DATA =			\
	kerberos.desktop

module_DATA =			\
	Kerberos.ycp

rnc_DATA = kerberos.rnc

EXTRA_DIST = $(client_DATA) $(module_DATA) $(ynclude_DATA) $(desktop_DATA) $(rnc_DATA)

include $(top_srcdir)/Makefile.am.common
