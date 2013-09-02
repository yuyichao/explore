#!/usr/bin/env python

from gi.repository import Gtk, WebKit2, GLib
from os import path as _path
import sys

def main():
    window = Gtk.Window()
    view = WebKit2.WebView()
    settings = view.get_settings()
    window.connect('destroy', Gtk.main_quit)
    window.add(view)
    view.load_uri(GLib.filename_to_uri(_path.abspath(sys.argv[1]), None))
    window.show_all()
    Gtk.main()

if __name__ == '__main__':
    main()
