#include <iostream>

#include "CImg.h"
using namespace cimg_library;

unsigned char weights[] = {
    1,2,1,
    2,4,2,
    1,2,1
};

typedef unsigned long long ptr_type;

class Oracle {
public:
    Oracle(CImg<unsigned char>* in_img, unsigned int width_in, unsigned int height_in) : next_x(0), next_y(0), width_in(width_in), height_in(height_in) {
        result = new CImg<unsigned char>(width_in-2, height_in-2, 1, 1, 0);
        compute(in_img);
    }

    ~Oracle() {
        delete result;
    }

    unsigned char get_next() {
        unsigned char res = result->atXY(next_x++, next_y);
        if(next_x >= width_in-2) {
            next_x = 0;
            next_y++;
        }
        return res;
    }

private:
    unsigned int width_in;
    unsigned int height_in;
    unsigned int next_x;
    unsigned int next_y;
    CImg<unsigned char>* result;
    void compute(CImg<unsigned char>* in_img) {
        CImg<unsigned char> resimg = (*result);
        for(int h = 1; h < height_in-1; h++) {
            for(int w = 1; w < width_in-1; w++) {
                unsigned char assign = kernel(in_img, w, h);
                result->atXY(w-1, h-1) = assign;
            }
        }
    }

    unsigned char kernel(CImg<unsigned char>* img, int x, int y) {
        unsigned int sum = 0;
        for(int ky = -1; ky <= 1; ky++) {
            for(int kx = -1; kx <= 1; kx++) {
                sum += weights[(ky+1)*3+kx+1] * img->atXY(x+kx,y+ky);
            }
        }
        sum /= 16;
        return (unsigned char)sum;
    }
};

extern "C" {
    ptr_type oracle_create(ptr_type input_addr, unsigned int width, unsigned int height) {
        return (ptr_type)new Oracle((CImg<unsigned char>*)input_addr, width, height);
    }

    void oracle_delete(ptr_type oracle) {
        delete (Oracle*)oracle;
    }

    unsigned char oracle_get_next_pixel(ptr_type oracle) {
        return ((Oracle*)oracle)->get_next();
    }


    unsigned char getGaussResult(unsigned char* pixels) {
        uint16_t sum = 0;
        for(int i = 0; i < 9; i++) {
            sum += weights[i] * pixels[i];
        }
        sum /= 16;
        return (unsigned char)sum;
    }
}