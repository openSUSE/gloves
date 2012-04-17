require 'mkmf'

#
# ruby extconf.rb --with-glib-include=/usr/include/glib-2.0
#

GLIB_INCLUDES = [   '/usr/lib/glib-2.0',
                    '/usr/lib64/glib-2.0',
                ]

dir_config( 'glib', GLIB_INCLUDES)

if find_library( 'glib-2.0', 'g_shell_unquote', '/usr/lib/' '/usr/lib64') then
    create_makefile( "SysconfigGlibShell");
else
    puts 'Cannot find glib 2.0 lib, please install it.'
end
