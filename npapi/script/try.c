#include <npfunctions.h>
#include <npruntime.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <X11/Xlib.h>

#define pname() fprintf(stderr, "\e[35m\e[1m%s is called\e[0m\n", __func__)

#define PLUGIN_NAME "Test NPAPI Plugin"
#define PLUGIN_DESCRIPTION PLUGIN_NAME " (Explore)"
#define PLUGIN_VERSION "0.0.0.1"

static NPNetscapeFuncs *browser;

NP_EXPORT(NPError)
NP_Initialize(NPNetscapeFuncs *bFuncs, NPPluginFuncs *pFuncs)
{
    pname();
    browser = bFuncs;

    if (pFuncs->size < (offsetof(NPPluginFuncs, setvalue) + sizeof(void*)))
        return NPERR_INVALID_FUNCTABLE_ERROR;

    pFuncs->version = 11;
    pFuncs->size = sizeof(pFuncs);
    pFuncs->newp = NPP_New;
    pFuncs->destroy = NPP_Destroy;
    pFuncs->setwindow = NPP_SetWindow;
    pFuncs->newstream = NPP_NewStream;
    pFuncs->destroystream = NPP_DestroyStream;
    pFuncs->asfile = NPP_StreamAsFile;
    pFuncs->writeready = NPP_WriteReady;
    pFuncs->write = (NPP_WriteProcPtr)NPP_Write;
    pFuncs->print = NPP_Print;
    pFuncs->event = NPP_HandleEvent;
    pFuncs->urlnotify = NPP_URLNotify;
    pFuncs->getvalue = NPP_GetValue;
    pFuncs->setvalue = NPP_SetValue;

    return NPERR_NO_ERROR;
}

NP_EXPORT(char*)
NP_GetPluginVersion()
{
    pname();
    return PLUGIN_VERSION;
}

NP_EXPORT(const char*)
NP_GetMIMEDescription()
{
    pname();
    return "application/x-test-plugin::Default";
}

NP_EXPORT(NPError)
NP_GetValue(void* future, NPPVariable var, void *val)
{
    switch (var) {
    case NPPVpluginNameString:
        *((char**)val) = PLUGIN_NAME;
        break;
    case NPPVpluginDescriptionString:
        *((char**)val) = PLUGIN_DESCRIPTION;
        break;
    default:
        return NPERR_INVALID_PARAM;
        break;
    }
    return NPERR_NO_ERROR;
}

NP_EXPORT(NPError)
NP_Shutdown()
{
    pname();
    return NPERR_NO_ERROR;
}

enum method_ids {
    PLUGIN_OPEN = 0,
    PLUGIN_RSTR,
    PLUGIN_COUNT
};

static const char *plugin_methods[] = {"open",
                                       "rstr",
                                       NULL};

static bool plugin_has_method(NPObject *obj, NPIdentifier methodName);
static bool plugin_invoke(NPObject *obj, NPIdentifier methodName,
                          const NPVariant *args, uint32_t argCount,
                          NPVariant *result);
static bool has_property(NPObject *obj, NPIdentifier propertyName);
static bool get_property(NPObject *obj, NPIdentifier propertyName,
                        NPVariant *result);
static NPObject *allocate(NPP npp, NPClass *klass);
static void deallocate(NPObject *obj);

typedef struct {
    NPObject obj;
    NPP instance;
} MNPObject;

static struct NPClass scriptablePluginClass = {
    .structVersion = NP_CLASS_STRUCT_VERSION,
    .allocate = allocate,
    .deallocate = deallocate,
    .invalidate = NULL,
    .hasMethod = plugin_has_method,
    .invoke = plugin_invoke,
    .invokeDefault = NULL,
    .hasProperty = has_property,
    .getProperty = get_property,
    .removeProperty = NULL,
    .enumerate = NULL,
    .construct = NULL,
};

//NPP Functions Implements
NPError
NPP_New(NPMIMEType pluginType, NPP instance, uint16_t mode,
        int16_t argc, char *argn[], char *argv[], NPSavedData *saved)
{
    pname();
    if(!instance->pdata) {
        instance->pdata = browser->createobject(instance,
                                                &scriptablePluginClass);
    }
    return NPERR_NO_ERROR;
}

NPError
NPP_Destroy(NPP instance, NPSavedData **save)
{
    pname();
    // If we created a plugin instance, we'll destroy and clean it up.
    NPObject *pluginInstance=instance->pdata;
    if(!pluginInstance) {
        browser->releaseobject(pluginInstance);
        pluginInstance = NULL;
    }

    return NPERR_NO_ERROR;
}

NPError
NPP_SetWindow(NPP instance, NPWindow *window)
{
    pname();
    return NPERR_NO_ERROR;
}

NPError
NPP_NewStream(NPP instance, NPMIMEType type, NPStream *stream,
              NPBool seekable, uint16_t *stype)
{
    pname();
    *stype = NP_ASFILEONLY;
    return NPERR_NO_ERROR;
}

NPError
NPP_DestroyStream(NPP instance, NPStream *stream, NPReason reason)
{
    pname();
    return NPERR_NO_ERROR;
}

int32_t
NPP_WriteReady(NPP instance, NPStream *stream)
{
    pname();
    return 0;
}

int32_t
NPP_Write(NPP instance, NPStream *stream, int32_t offset, int32_t len,
          void *buffer)
{
    pname();
    return 0;
}

void
NPP_StreamAsFile(NPP instance, NPStream *stream, const char *fname)
{
    pname();
}

void
NPP_Print(NPP instance, NPPrint *platformPrint)
{
    pname();
}


int16_t
NPP_HandleEvent(NPP instance, void *event)
{
    pname();
    return 0;
}

void
NPP_URLNotify(NPP instance, const char *url, NPReason reason, void *notifyData)
{
    pname();
}

NPError
NPP_GetValue(NPP instance, NPPVariable variable, void *value)
{
    pname();
    NPObject *pluginInstance=NULL;
    switch(variable) {
    case NPPVpluginScriptableNPObject:
        fprintf(stderr, "\e[35m\e[1mok\e[0m\n");
        // If we didn't create any plugin instance, we create it.
        pluginInstance=instance->pdata;
        if (pluginInstance) {
            browser->retainobject(pluginInstance);
        }
        *(NPObject**)value = pluginInstance;
        break;
    case NPPVpluginNeedsXEmbed:
        fprintf(stderr, "\e[35m\e[1mok\e[0m\n");
        *(NPBool*)value = true;
        break;
    default:
        fprintf(stderr, "\e[35m\e[1merror %d\e[0m\n", variable);
        return NPERR_GENERIC_ERROR;
    }
    return NPERR_NO_ERROR;
}

NPError
NPP_SetValue(NPP instance, NPNVariable variable, void *value)
{
    pname();
    return NPERR_GENERIC_ERROR;
}

static NPObject*
allocate(NPP npp, NPClass *klass)
{
    pname();
    MNPObject *obj = malloc(sizeof(MNPObject));
    obj->instance = npp;
    return (NPObject*)obj;
}

static void
deallocate(NPObject *obj)
{
    pname();
    free(obj);
}

static bool
plugin_has_method(NPObject *obj, NPIdentifier methodName)
{
    pname();
    NPUTF8 *name = browser->utf8fromidentifier(methodName);
    int i;
    bool result = false;

    for (i = 0;plugin_methods[i];i++) {
        if (!strcmp(name, plugin_methods[i])) {
            result = true;
            break;
        }
    }
    browser->memfree(name);
    return result;
}

static bool
plugin_invoke(NPObject *obj, NPIdentifier methodName,
              const NPVariant *args, uint32_t argCount, NPVariant *result)
{
    pname();
    bool res = false;

    NPUTF8 *name = browser->utf8fromidentifier(methodName);
    if (!strcmp(name, plugin_methods[PLUGIN_OPEN])) {
        if (argCount > 0 && NPVARIANT_IS_STRING(args[0])) {
            int i;
            NPString str = NPVARIANT_TO_STRING(args[0]);
            INT32_TO_NPVARIANT(str.UTF8Length, *result);
            for (i = 0;i < str.UTF8Length;i++) {
                fprintf(stderr, "\e[34m\e[1m%x\e[0m\n", str.UTF8Characters[i]);
            }
            fprintf(stderr, "\n");
        } else {
            BOOLEAN_TO_NPVARIANT(false, *result);
        }
        res = true;
    } else if (!strcmp(name, plugin_methods[PLUGIN_RSTR])) {
        if (argCount > 0 && NPVARIANT_IS_STRING(args[0])) {
            int i;
            NPString str = NPVARIANT_TO_STRING(args[0]);
            NPUTF8 *nstr = (NPUTF8*)browser->memalloc(sizeof(NPUTF8) *
                                                      (str.UTF8Length + 1));
            for (i = 0;i < str.UTF8Length;i++) {
                fprintf(stderr, "\e[31m\e[1m%x\e[0m\n", str.UTF8Characters[i]);
                nstr[i] = str.UTF8Characters[i];
            }
            nstr[i] = 0;
            STRINGZ_TO_NPVARIANT(nstr, *result);
        } else {
            BOOLEAN_TO_NPVARIANT(false, *result);
        }
        res = true;
    }
    browser->memfree(name);
    return res;
}

static bool
has_property(NPObject *obj, NPIdentifier propertyName)
{
    pname();
    return false;
}

static bool
get_property(NPObject *obj, NPIdentifier propertyName, NPVariant *result)
{
    pname();
    return false;
}
