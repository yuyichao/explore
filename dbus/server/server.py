#!/usr/bin/env python

from gi.repository import Gio

def a_cb(connection, name, *args):
    print(name + ' is ready')
    print(len(args))


def l_cb(connection, name, *args):
    print(name + ' is lost')
    print(len(args))

xml_node='''
<node>
<interface name='org.yuyichao.text.if'>
<method name='a'>
<arg type='s' name='i' direction='in'/>
<arg type='s' name='i' direction='out'/>
</method>
</interface>
</node>
'''

ses_bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)

node_info = Gio.DBusNodeInfo.new_for_xml(xml_node)

vtable = Gio.DBusInterfaceVTable()

def random(*args):
    print(str(args))
    

#ses_bus.register_object('/a', node_info.interfaces, vtable, None, random)

#nameid = Gio.bus_own_name_on_connection(ses_bus, 'org.yuyichao.text', Gio.BusNameOwnerFlags.NONE, a_cb, l_cb)


#Gio.bus_own_name_sync
