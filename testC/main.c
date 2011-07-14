#include <ruby.h>

int main(int a, char**v)
{
  ruby_init();
  ruby_script("yast");
  ruby_init_loadpath();
  rb_eval_string("require(\"system_agent/krb5_conf\")");
  VALUE module = rb_funcall(rb_funcall( rb_mKernel, rb_intern("const_get"), 1, rb_str_new2("SystemAgent")),rb_intern("const_get"),1,rb_str_new2("Krb5Conf"));
  rb_funcall2( module,rb_intern("read"),0,0);
  return 0;
}
