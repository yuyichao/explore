#include <stdio.h>
#include <stdlib.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xos.h>
#include <X11/Xatom.h>
#include <X11/keysym.h>
#include <X11/extensions/Xfixes.h>

int xfixes_base;

void
process_xfixes_selection(XFixesSelectionNotifyEvent *xfixes_event)
{
    switch (xfixes_event->subtype) {
    case XFixesSetSelectionOwnerNotify:
        printf("%s, XFixesSetSelectionOwnerNotify\n", __func__);
        break;
    case XFixesSelectionWindowDestroyNotify:
        printf("%s, XFixesSelectionWindowDestroyNotify\n", __func__);
        break;
    case XFixesSelectionClientCloseNotify:
        printf("%s, XFixesSelectionClientCloseNotify\n", __func__);
        break;
    }
    char *name = XGetAtomName(xfixes_event->display, xfixes_event->selection);
    printf("%s\n", name);
    XFree(name);
}

Bool
process_xfixes(XEvent *event)
{
    switch (event->type - xfixes_base) {
    case XFixesSelectionNotify:
        process_xfixes_selection((XFixesSelectionNotifyEvent*)event);
        return True;
    default:
        break;
    }
    return False;
}

int
main() {
    Display *disp = XOpenDisplay(NULL);
    Atom primary = XInternAtom(disp, "PRIMARY", False);
    Atom clipboard = XInternAtom(disp, "CLIPBOARD", False);
    Window win = XCreateSimpleWindow(disp, DefaultRootWindow(disp),
                                     0, 0, 1, 1, 0, 0, 0);
    int ignore;
    XEvent report;
    XFixesSelectSelectionInput(disp, win, primary,
                               XFixesSetSelectionOwnerNotifyMask |
                               XFixesSelectionWindowDestroyNotifyMask |
                               XFixesSelectionClientCloseNotifyMask);
    XFixesSelectSelectionInput(disp, win, clipboard,
                               XFixesSetSelectionOwnerNotifyMask |
                               XFixesSelectionWindowDestroyNotifyMask |
                               XFixesSelectionClientCloseNotifyMask);
    if (!XFixesQueryExtension(disp, &xfixes_base, &ignore)) {
        printf("%s xfixes not found\n", __func__);
        return 1;
    }

    while (1)  {
        XNextEvent(disp, &report);
        if (process_xfixes(&report))
            continue;
    }
    return 0;
}
