#!/usr/bin/env python2

class Obj(dict):
    def __init__(self, name=''):
        self._name = name
    def __hasitem__(self, key):
        print('%s:has %s' % (self._name, key))
        if key.startswith('reg_'):
            print('return True')
            return True
        res = dict.__hasitem__(self, key)
        print('return', res)
        return res
    def __getitem__(self, key):
        print('%s:get %s' % (self._name, key))
        if key.startswith('reg_'):
            print('return True')
            return True
        value = dict.__getitem__(self, key)
        print('return', value)
        return value
    def __setitem__(self, key, value):
        print('%s:set %s' % (self._name, key))
        if key.startswith('reg_'):
            raise AttributeError('readonly')
        return dict.__setitem__(self, key, value)
    # def __str__(self):
    #     return self._name
    def keys(self):
        keys = dict.keys(self)
        print('%s:keys %s' % (self._name, repr(keys)))
        return keys

code = '''
import os
print(os)
#print(globals())
print(locals())
print(reg_a)
_a = 1
print(dir())
global b
b = 3
globals()["a"] = 1
print(globals()["a"])
print(globals()["b"])
print(locals())
'''

def main():
    bcode = compile(code, '', 'exec')
    try:
        exec(bcode, Obj('glob'), {})
    except:
        pass
    print('\n')
    try:
        exec(code, Obj('glob'), {})
    except:
        pass
    print('\n')
    exec(bcode, Obj('glob'), Obj('loc'))
    print('\n')
    exec(code, Obj('glob'), Obj('loc'))

if __name__ == '__main__':
    main()
