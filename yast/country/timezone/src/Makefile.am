# Makefile.am for country/timezone/src

yncludedir = @yncludedir@/timezone

rncdir =  $(schemadir)/autoyast/rnc

client_DATA =			\
	timezone.ycp		\
	inst_timezone.ycp	\
	timezone_auto.ycp       \
        timezone_proposal.ycp

desktop_DATA =			\
	timezone.desktop

module_DATA = 			\
	Timezone.ycp

ynclude_DATA =			\
	dialogs.ycp

rnc_DATA = timezone.rnc

YaPI_perldir = @moduledir@/YaPI

YaPI_perl_DATA = \
    YaPI/TIME.pm

EXTRA_DIST = $(client_DATA) $(module_DATA) $(desktop_DATA) $(ynclude_DATA) $(YaPI_perl_DATA) $(rnc_DATA)

YCPCFLAGS = -M ../../language/src/modules

include $(top_srcdir)/Makefile.am.common
