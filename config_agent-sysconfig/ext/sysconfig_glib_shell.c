/*
 *
 * Minimal required subset of stub functions extracted from ruby-gnome2 project (GLib2 gem).
 * Only unquoting is required for sysconfig agent, so GLib gem brings too much overhead.
 *
 * License LGPL 2.1.
 *
 */

#include <rbglib.h>

static VALUE t_unquote( VALUE self, VALUE quoted_string)
{
    GError *error = NULL;
    gchar *str = g_shell_unquote(RVAL2CSTR(quoted_string), &error);
    if (str == NULL)
        RAISE_GERROR(error);

    return CSTR2RVAL_FREE(str);
}

VALUE cTest;

void Init_SysconfigGlibShell()
{
    cTest = rb_define_class("SysconfigGlibShell", rb_cObject);
    rb_define_singleton_method(cTest, "unquote", t_unquote, 1);
}
