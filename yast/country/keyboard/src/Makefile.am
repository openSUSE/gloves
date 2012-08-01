# Makefile.am for country/keyboard/src

yncludedir = @yncludedir@/keyboard

rncdir =  $(schemadir)/autoyast/rnc

client_DATA =				\
	keyboard.ycp			\
	keyboard_auto.ycp               \
        keyboard_proposal.ycp           \
        keyboard_simple_proposal.ycp

ynclude_DATA =				\
	dialogs.ycp

rnc_DATA = keyboard.rnc

desktop_DATA =                  \
        keyboard.desktop

module_DATA = 				\
	Keyboard.ycp

EXTRA_DIST = $(module_DATA) $(client_DATA) $(ynclude_DATA) $(rnc_DATA) $(desktop_DATA)

include $(top_srcdir)/Makefile.am.common
