#include <JavaScriptCore/JSObjectRef.h>
#include <JavaScriptCore/JSValueRef.h>
#include <JavaScriptCore/JSStringRef.h>
#include <JavaScriptCore/JSContextRef.h>
#include <stdio.h>
#include <stdlib.h>

void
print_jsstr(JSStringRef jsstr)
{
    int length = JSStringGetMaximumUTF8CStringSize(jsstr);
    if (length > 0) {
        char buf[length + 1];
        JSStringGetUTF8CString(jsstr, buf, length);
        printf("%d: %s\n", length, buf);
    } else {
        printf("l <= 0\n");
    }
}

void
print_props(JSContextRef jsctx, JSValueRef jsvalue)
{
    int i;
    printf("a\n");
    JSObjectRef jsobject = JSValueToObject(jsctx, jsvalue, NULL);
    JSValueProtect(jsctx, jsobject);
    printf("b\n");
    printf("%lx\n", (long)jsobject);
    for (i = 0;i < 1000;i++) {
        JSPropertyNameArrayRef jsnames1 = JSObjectCopyPropertyNames(jsctx, jsobject);
        JSPropertyNameArrayRelease(jsnames1);
    }
    JSPropertyNameArrayRef jsnames = JSObjectCopyPropertyNames(jsctx, jsobject);
    printf("c\n");
    int n = JSPropertyNameArrayGetCount(jsnames);
    printf("d\n");
    for (i = 0;i < n;i++) {
        JSStringRef jsstr = JSPropertyNameArrayGetNameAtIndex(jsnames, i);
        print_jsstr(jsstr);
        //JSStringRelease(jsstr);
    }
    printf("e\n");
    JSPropertyNameArrayRelease(jsnames);
    JSValueUnprotect(jsctx, jsobject);
}

int
main()
{
    JSContextRef jsctx = JSGlobalContextCreate(NULL);
    /* JSStringRef jsstr = JSStringCreateWithUTF8CString( */
    /*     "{\"a\": 1, \"b\": 2, \"ccc\": \"asdf\", \"d\": [1, 2, \"d\"]}"); */
    JSStringRef jsstr = JSStringCreateWithUTF8CString(
        "{\"a\": 1, \"b\": 2, \"ccc\": \"asdf\"}");
    JSValueRef jsvalue = JSValueMakeFromJSONString(jsctx, jsstr);
    JSValueProtect(jsctx, jsvalue);
    JSStringRelease(jsstr);
    print_props(jsctx, jsvalue);
    print_props(jsctx, jsvalue);
    JSValueUnprotect(jsctx, jsvalue);
    return 0;
}
