#include <utility>

#ifndef __UTILS_H__
#define __UTILS_H__

template<typename T>
using remove_ref_t = typename std::remove_reference<T>::type;

#endif
