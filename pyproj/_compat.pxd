cdef str cstrdecode(const char *instring)
cdef const char *to_cstr(str pystr) except *


IF CTE_PYTHON_IMPLEMENTATION == "CPython":
    from cpython cimport array
    cdef array.array empty_array(int npts)

ELSE:
    # https://github.com/pyproj4/pyproj/issues/854
    cdef empty_array(int npts)
