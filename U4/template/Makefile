CXXFLAGS=-O3 -Wall -Wno-unused -D_FILE_OFFSET_BITS=64 -fPIC -Wno-uninitialized -fpermissive -std=c++11 -D_GLIBCXX_USE_CXX11_ABI=0
BSC_CXXFLAGS=$(patsubst %,-Xc++ %,$(CXXFLAGS))
SIMDIR=sim
BDIR=$(SIMDIR)

sim_all: bluesim_AcceleratorChecker bluesim_AcceleratorTb bluesim_GaussTb bluesim_GaussChecker bluesim_BufferTb

bluesim_%: bsv_compile_% imageReader.o imageWriter.o oracle.o
	bsc -bdir $(BDIR) -simdir $(SIMDIR) $(BSC_CXXFLAGS) -parallel-sim-link 2 -sim -e mk$* -Xl "imageReader.o" -Xl "imageWriter.o" -Xl "oracle.o" -Xl -lpng -Xl -lz -Xl -lX11 -Xl -lpthread -o $*_bluesim

bsv_compile_%: sim
	bsc -bdir $(BDIR) -simdir $(SIMDIR) -u -sim -g mk$* $*.bsv

oracle.o: oracle.cpp
	c++ $(CXXFLAGS) -c -o "oracle.o" "oracle.cpp"

imageReader.o: imageReader.cpp
	c++ $(CXXFLAGS) -c -o "imageReader.o" "imageReader.cpp"

imageWriter.o: imageWriter.cpp
	c++ $(CXXFLAGS) -c -o "imageWriter.o" "imageWriter.cpp"

sim:
	mkdir sim

clean:
	rm -rf *.*o *.*a *.cxx *mk*.h imported_BDPI_functions.h *.v sim *_bluesim *.log *Out*.png