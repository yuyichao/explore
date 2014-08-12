//

template<int i>
inline int
extern_template()
{
    return i;
}
#ifndef __LIB_CPP_PRIVATE__
extern template int extern_template<0>();
#endif
