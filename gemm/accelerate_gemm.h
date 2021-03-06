#pragma once

#include <Accelerate/Accelerate.h>
#include <type_traits>

#include "gemm.h"

template <class T> class AccelerateGEMM : public GEMM<T>
{
protected:
    size_t n;
    T *a;
    T *b;
    T *c;

public:
    AccelerateGEMM(size_t n)
        : n(n), a(new (std::align_val_t{128}) T[n * n]),
          b(new (std::align_val_t{128}) T[n * n]),
          c(new (std::align_val_t{128}) T[n * n])
    // : n(n), a(new T[n * n]), b(new T[n * n]), c(new T[n * n])
    {
    }

    ~AccelerateGEMM()
    {
        delete[] a;
        delete[] b;
        delete[] c;
    }

    virtual void run()
    {
        if constexpr (std::is_same<T, float>::value) {
            cblas_sgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans, n, n, n, 1.0,
                        a, n, b, n, 0.0, c, n);
        } else if (std::is_same<T, double>::value) {
            cblas_dgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans, n, n, n, 1.0,
                        a, n, b, n, 0.0, c, n);
        } else {
        }
    }

    virtual void init_matrices()
    {
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < n; j++) {
                a[i * n + j] = static_cast<T>(1.0);
                b[i * n + j] = static_cast<T>(1.0);
                c[i * n + j] = static_cast<T>(0.0);
            }
        }
    }
};
