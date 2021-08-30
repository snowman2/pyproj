from cpython.ref cimport PyObject

from math import radians, degrees


cdef double _DG2RAD = radians(1.)
cdef double _RAD2DG = degrees(1.)
cdef int _DOUBLESIZE = sizeof(double)


cdef extern from "math.h":
    ctypedef enum:
        HUGE_VAL


cdef extern from "Python.h":
    ctypedef enum:
        PyBUF_WRITABLE
    int PyObject_GetBuffer(PyObject *exporter, Py_buffer *view, int flags)
    void PyBuffer_Release(Py_buffer *view)


cdef class PyBuffWriteManager:
    cdef Py_buffer buffer
    cdef double* data
    cdef public Py_ssize_t len
    cdef readonly bint is_scalar
    cdef double scalar_data

    def __cinit__(self):
        self.data = NULL
        self.is_scalar = False

    def __init__(self, object data):
        if isinstance(data, float):
            self.scalar_data = data
            self.data = &self.scalar_data
            self.len = 1
            self.is_scalar = True
        else:
            if PyObject_GetBuffer(<PyObject *>data, &self.buffer, PyBUF_WRITABLE) <> 0:
                raise BufferError("pyproj had a problem getting the buffer from data.")
            self.data = <double *>self.buffer.buf
            self.len = self.buffer.len // self.buffer.itemsize

    def __dealloc__(self):
        if not self.is_scalar:
            PyBuffer_Release(&self.buffer)
        self.data = NULL
