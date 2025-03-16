#include "webview.h"
#include <caml/alloc.h>
#include <caml/callback.h>

extern "C" {

CAMLprim value ocaml_webview_create(value debug_v, value unit_v) {
  CAMLparam2(debug_v, unit_v);
  CAMLlocal1(result);
  int debug = Int_val(debug_v);
  webview_t handle = webview_create(debug, NULL);
  result = caml_copy_nativeint((intnat)handle);
  CAMLreturn(result);
}

CAMLprim value caml_webview_run(value w) {
  CAMLparam1(w);
  webview_t webview = (webview_t)Nativeint_val(w);
  int result = webview_run(webview);
  CAMLreturn(Val_int(result));
}

CAMLprim value caml_webview_set_title(value w, value title) {
  CAMLparam2(w, title);
  webview_t webview = (webview_t)Nativeint_val(w);
  const char *c_title = String_val(title);
  int result = webview_set_title(webview, c_title);
  CAMLreturn(Val_int(result));
}

CAMLprim value caml_webview_set_size(value w, value width, value height,
                                     value hint) {
  CAMLparam4(w, width, height, hint);
  webview_t webview = (webview_t)Nativeint_val(w);
  int c_width = Int_val(width);
  int c_height = Int_val(height);
  webview_hint_t c_hint =
      (webview_hint_t)Int_val(hint); // Cast to the correct enum type
  int result = webview_set_size(webview, c_width, c_height, c_hint);
  CAMLreturn(Val_int(result));
}

CAMLprim value caml_webview_set_html(value w, value html) {
  CAMLparam2(w, html);
  webview_t webview = (webview_t)Nativeint_val(w);
  const char *c_html = String_val(html);
  int result = webview_set_html(webview, c_html);
  CAMLreturn(Val_int(result));
}

CAMLprim value caml_webview_destroy(value w) {
  CAMLparam1(w);
  webview_t webview = (webview_t)Nativeint_val(w);
  int result = webview_destroy(webview);
  CAMLreturn(Val_int(result));
}

CAMLprim value caml_webview_terminate(value w) {
  CAMLparam1(w);
  webview_t webview = (webview_t)Nativeint_val(w);
  int result = webview_terminate(webview);
  CAMLreturn(Val_int(result));
}

void binder_wrapper(const char *id, const char *req, void *arg) {
  const static value *closure_f = NULL;
  if (closure_f == NULL) {
    closure_f = caml_named_value("BINDER");
    if (closure_f == NULL) {
      printf("ERR: No callback registered");
      return;
    }
  }
  value caml_id = caml_copy_string(id);
  value caml_req = caml_copy_string(req);
  caml_callback2(*closure_f, caml_id, caml_req);
}

CAMLprim value caml_webview_bind(value w, value name) {
  CAMLparam2(w, name);
  webview_t webview = (webview_t)Nativeint_val(w);
  const char *cname = String_val(name);
  int result = webview_bind(webview, cname, binder_wrapper, NULL);
  CAMLreturn(Val_int(result));
}

CAMLprim value caml_webview_eval(value w, value js) {
  CAMLparam2(w, js);
  webview_t webview = (webview_t)Nativeint_val(w);
  const char *c_js = String_val(js);
  int result = webview_eval(webview, c_js);
  CAMLreturn(Val_int(result));
}
}
