// Copyright 2023 Sycuricon Group
// Author: Phantom (phantom@zju.edu.cn)

#include <stdio.h>
typedef unsigned float_bits;
float float_negate(float f);

int main() {
    printf("%f\n",float_negate(32.0));
    printf("%f\n",float_negate(-12.8));
    printf("%f\n",float_negate(0.0));
    return 0;
}
