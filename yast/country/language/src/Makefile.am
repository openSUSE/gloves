# Makefile.am for country/language/src

rncdir =  $(schemadir)/autoyast/rnc

module_DATA = 				\
	Language.ycp

client_DATA =			\
	language.ycp		\
	inst_language.ycp	\
	select_language.ycp	\
	language_auto.ycp       \
        language_proposal.ycp	\
        country_simple_proposal.ycp	\
        language_simple_proposal.ycp

desktop_DATA =			\
	yast-language.desktop

rnc_DATA =	language.rnc

YaPI_perldir = @moduledir@/YaPI

YaPI_perl_DATA = \
    YaPI/LANGUAGE.pm


EXTRA_DIST = $(module_DATA) $(client_DATA) $(desktop_DATA) $(YaPI_perl_DATA) $(rnc_DATA)

include $(top_srcdir)/Makefile.am.common
