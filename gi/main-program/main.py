from gi.repository import Foo

Foo.hello(str(Foo))
Foo.hello("from, %s" % __file__)

print(Foo.hello)
