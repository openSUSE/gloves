#include <ruby.h>

int main(int a, char**v)
{
  ruby_init();
  ruby_script("ruby");
  ruby_init_loadpath();
  rb_require("system_agent/krb5_conf");
  VALUE module = rb_funcall(rb_funcall( rb_mKernel, rb_intern("const_get"), 1, rb_str_new2("SystemAgent")),rb_intern("const_get"),1,rb_str_new2("Krb5Conf"));
  rb_funcall2( module,rb_intern("read"),1,rb_cObject);
  rb_eval_string("SystemAgent::Krb5Conf.read({})");
  return 0;
}
