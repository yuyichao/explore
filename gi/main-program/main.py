from gi.repository import Foo
import sys

Foo.hello(str(Foo))
Foo.hello("from, %s" % __file__)
print(sys.executable)
print(sys.argv)
print(__name__)

print(Foo.hello)
