#include <npapi.h>
#include <npfunctions.h>
#include <npruntime.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <X11/Xlib.h>

#define pname() fprintf(stderr, "\e[35m\e[1m%s is called\e[0m\n", __func__)

static NPNetscapeFuncs* browser;
enum method_ids {
    PLUGIN_OPEN = 0,
    PLUGIN_RSTR,
    PLUGIN_COUNT
};

static const char *plugin_methods[] = {"open",
                                       "rstr",
                                       NULL};

bool plugin_has_method(NPObject *obj, NPIdentifier methodName);
bool plugin_invoke(NPObject *obj, NPIdentifier methodName,
                   const NPVariant *args, uint32_t argCount, NPVariant *result);
bool hasProperty(NPObject *obj, NPIdentifier propertyName);
bool getProperty(NPObject *obj, NPIdentifier propertyName, NPVariant *result);
NPObject *allocate(NPP npp, NPClass *klass);
void deallocate(NPObject *obj);


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
    .hasProperty = hasProperty,
    .getProperty = getProperty,
    .removeProperty = NULL,
    .enumerate = NULL,
    .construct = NULL,
};

NPObject *allocate(NPP npp, NPClass *klass)
{
    MNPObject *obj = malloc(sizeof(MNPObject));
    obj->instance = npp;
    return (NPObject*)obj;
}

void deallocate(NPObject *obj)
{
    free(obj);
}


char*
NP_GetMIMEDescription()
{
    pname();
    return "test/x-open-with-default-plugin::";
}

NPError
NP_Initialize(NPNetscapeFuncs* bFuncs, NPPluginFuncs* pFuncs)
{
    pname();
    browser = bFuncs;

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

NPError
NP_Shutdown()
{
    pname();
    return NPERR_NO_ERROR;
}

bool
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

bool
plugin_invoke(NPObject *obj, NPIdentifier methodName,
              const NPVariant *args, uint32_t argCount, NPVariant *result)
{
    pname();
    bool res = false;

    NPUTF8 *name = browser->utf8fromidentifier(methodName);
    if (!strcmp(name, plugin_methods[PLUGIN_OPEN])) {
        if(argCount > 0 && NPVARIANT_IS_STRING(args[0])) {
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
        MNPObject *mobj = (MNPObject*)obj;
        XKeyEvent event = {
            .type = keypress;
            .serial = 0;
            .send_event = false;
            Display *display;
            Window window;
            Window root;
            Window subwindow;
            Time time;
            int x, y;
            int x_root, y_root;
            unsigned int state;
            unsigned int keycode;
            Bool same_screen;
        };
        NPN_HandleEvent(mobj->instance, &event, false);
        res = true;
    } else if (!strcmp(name, plugin_methods[PLUGIN_RSTR])) {
        if(argCount > 0 && NPVARIANT_IS_STRING(args[0])) {
            int i;
            NPString str = NPVARIANT_TO_STRING(args[0]);
            NPUTF8 *nstr = (NPUTF8*)NPN_MemAlloc(sizeof(NPUTF8) *
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

bool hasProperty(NPObject *obj, NPIdentifier propertyName) {
    pname();
    return false;
}

bool getProperty(NPObject *obj, NPIdentifier propertyName, NPVariant *result) {
    pname();
    return false;
}



//NPP Functions Implements
NPError NPP_New(NPMIMEType pluginType, NPP instance, uint16_t mode, int16_t argc, char* argn[], char* argv[], NPSavedData* saved)
{
    pname();
    // Create per-instance storage
    //obj = (PluginObject *)malloc(sizeof(PluginObject));
    //bzero(obj, sizeof(PluginObject));

    //obj->npp = instance;
    //instance->pdata = obj;

    if(!instance->pdata) {
        instance->pdata = browser->createobject(instance,
                                                &scriptablePluginClass);
    }
    return NPERR_NO_ERROR;
}

NPError NPP_Destroy(NPP instance, NPSavedData** save)
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

NPError NPP_SetWindow(NPP instance, NPWindow* window)
{
    pname();
    return NPERR_NO_ERROR;
}

NPError NPP_NewStream(NPP instance, NPMIMEType type, NPStream* stream, NPBool seekable, uint16_t* stype)
{
    pname();
    *stype = NP_ASFILEONLY;
    return NPERR_NO_ERROR;
}

NPError NPP_DestroyStream(NPP instance, NPStream* stream, NPReason reason)
{
    pname();
    return NPERR_NO_ERROR;
}

int32_t NPP_WriteReady(NPP instance, NPStream* stream)
{
    pname();
    return 0;
}

int32_t NPP_Write(NPP instance, NPStream* stream, int32_t offset, int32_t len, void* buffer)
{
    pname();
    return 0;
}

void NPP_StreamAsFile(NPP instance, NPStream* stream, const char* fname)
{
    pname();
}

void NPP_Print(NPP instance, NPPrint* platformPrint)
{
    pname();
}


int16_t NPP_HandleEvent(NPP instance, void* event)
{
    pname();
    return 0;
}

void NPP_URLNotify(NPP instance, const char* url, NPReason reason, void* notifyData)
{
    pname();
}

NPError NPP_GetValue(NPP instance, NPPVariable variable, void *value)
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
        *(NPObject **)value = pluginInstance;
        break;
    case NPPVpluginNeedsXEmbed:
        fprintf(stderr, "\e[35m\e[1mok\e[0m\n");
        *(NPBool *)value = true;
        break;
    default:
        fprintf(stderr, "\e[35m\e[1merror %d\e[0m\n", variable);
        return NPERR_GENERIC_ERROR;
    }

    if (false)
        NPN_HandleEvent(instance, NULL, false);

    return NPERR_NO_ERROR;
}

NPError NPP_SetValue(NPP instance, NPNVariable variable, void *value)
{
    pname();
    return NPERR_GENERIC_ERROR;
}
