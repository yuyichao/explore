#include <JavaScriptCore/JSObjectRef.h>
#include <JavaScriptCore/JSValueRef.h>
#include <JavaScriptCore/JSStringRef.h>
#include <JavaScriptCore/JSContextRef.h>
#include <stdio.h>
#include <stdlib.h>

void
print_js(JSContextRef ctx, JSValueRef jsvalue)
{
    if (!jsvalue)
        return;
    JSStringRef jsstr = JSValueToStringCopy(ctx, jsvalue, NULL);
    int length = JSStringGetMaximumUTF8CStringSize(jsstr);
    if (length > 0) {
        char buf[length + 1];
        JSStringGetUTF8CString(jsstr, buf, length);
        printf("%d: %s\n", length, buf);
    } else {
        printf("l <= 0\n");
    }
    if (jsstr)
        JSStringRelease(jsstr);
}

JSValueRef
get_property(JSContextRef ctx, JSValueRef self, const char *name)
{
    JSStringRef jsname;
    JSValueRef res;
    JSObjectRef jsobject;
    jsobject = JSValueToObject(ctx, self, NULL);
    if (!jsobject) {
        return NULL;
    }
    jsname = JSStringCreateWithUTF8CString(name);
    res = JSObjectGetProperty(ctx, jsobject, jsname, NULL);
    JSStringRelease(jsname);
    return res;
}

void
test_function(JSContextRef ctx, JSValueRef jsthis)
{
    const char *script = "function a() { return this; }; a;";
    JSStringRef jsscript = JSStringCreateWithUTF8CString(script);
    JSValueRef jsret = JSEvaluateScript(ctx, jsscript, NULL, NULL, 0, NULL);
    JSObjectRef jsfun = (JSObjectRef)jsret;
    jsret = (JSValueRef)JSObjectCallAsFunction(ctx, jsfun, (JSObjectRef)jsthis,
                                               0, NULL, NULL);
    JSStringRelease(jsscript);
    printf("%lx\n", (unsigned long)jsret);
    print_js(ctx, jsret);
}

int
main()
{
    JSContextRef ctx = JSGlobalContextCreate(NULL);
    JSValueRef jsvalue;
    JSObjectRef jsobject2;
    JSObjectRef jsobject3;
    JSValueRef jsvalue4;
    jsvalue = JSValueMakeNumber(ctx, 0.123456711111111111);
    print_js(ctx, jsvalue);
    jsvalue = JSValueMakeBoolean(ctx, 1);
    print_js(ctx, jsvalue);
    jsvalue = JSValueMakeBoolean(ctx, 0);
    print_js(ctx, jsvalue);
    jsvalue = JSValueMakeNull(ctx);
    print_js(ctx, jsvalue);
    jsvalue = JSValueMakeUndefined(ctx);
    /* JSObjectIsFunction(ctx, jsvalue); //segmentation fault */
    print_js(ctx, jsvalue);
    jsvalue = JSObjectMakeError(ctx, 0, NULL, NULL);
    printf("%lx\n", (unsigned long)jsvalue);
    printf("%lx\n", (unsigned long)(jsvalue =
                                    JSValueToObject(ctx, jsvalue, NULL)));
    printf("%lx\n", (unsigned long)(jsvalue =
                                    JSValueToObject(ctx, jsvalue, NULL)));
    print_js(ctx, jsvalue);
    jsvalue = JSObjectMake(ctx, NULL, NULL);
    print_js(ctx, jsvalue);
    jsobject2 = (JSObjectRef)get_property(ctx, jsvalue, "toString");
    print_js(ctx, jsobject2);
    jsobject3 = JSObjectMakeError(ctx, 0, NULL, NULL);
    /* jsobject3 = JSValueMakeBoolean(ctx, 0); */
    /* jsobject3 = JSValueMakeNull(ctx); */
    /* jsobject3 = JSValueMakeNumber(ctx, 0.123134123); */
    /* jsobject3 = JSValueMakeUndefined(ctx); */
    jsvalue4 = JSObjectCallAsFunction(ctx, jsobject2, jsobject3, 0, NULL, NULL);
    print_js(ctx, jsvalue4);
    printf("test_function\n");
    //test_function(ctx, jsobject3);

    JSStringRef jsstr;
    jsstr = JSStringCreateWithUTF8CString("abcdef");
    jsvalue = JSValueMakeString(ctx, jsstr);
    JSStringRelease(jsstr);
    printf("%lx\n", (unsigned long)jsvalue);
    print_js(ctx, jsvalue);
    printf("%lx\n", (unsigned long)JSValueToObject(ctx, jsvalue, NULL));
    print_js(ctx, JSValueToObject(ctx, jsvalue, NULL));
    JSObjectCopyPropertyNames(ctx, (JSObjectRef)jsvalue);
    return 0;
}
