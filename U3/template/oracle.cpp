#include <iostream>

unsigned char weights[] = {
    1,2,1,
    2,4,2,
    1,2,1
};

extern "C" {
    unsigned char getGaussResult(unsigned char* pixels) {
        uint16_t sum = 0;
        for(int i = 0; i < 9; i++) {
            sum += weights[i] * pixels[i];
        }
        sum /= 16;
        return (unsigned char)sum;
    }
}