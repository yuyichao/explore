#!/usr/bin/env python

from gi.repository import Polkit, GLib, Gio, GObject
import os, sys

def on_time_out(loop):
    print("Time out, Exiting\n")
    loop.quit()

def check_authorization_cb(authority, res, loop):
    result = Polkit.Authority.check_authorization_finish(authority, res)
    if result.get_is_authorized():
        result_str = "authorized"
    elif result.get_is_challenge():
        result_str = "challenge"
    else:
        result_str = "not authorized"

    print("Authorization result is: %s" % result_str)
    GLib.timeout_add(10000, on_time_out, loop)

def do_cancel(cancellable):
    cancellable.cancel()
    return False

def main():
    action_id = sys.argv[1]
    loop = GObject.MainLoop()
    authority = Polkit.Authority.get_sync(None)
    ppid = os.getppid()
    subject = Polkit.UnixProcess.new(ppid)
    cancellable = Gio.Cancellable.new()
    GLib.timeout_add(10000, do_cancel, cancellable)
    # authority.check_authorization(
    #     subject, action_id, None,
    #     Polkit.CheckAuthorizationFlags.ALLOW_USER_INTERACTION, cancellable,
    #     check_authorization_cb, loop)
    authority.check_authorization(
        subject, action_id, None, Polkit.CheckAuthorizationFlags.NONE,
        cancellable, check_authorization_cb, loop)
    loop.run()
    return 0

if __name__ == '__main__':
    main()
