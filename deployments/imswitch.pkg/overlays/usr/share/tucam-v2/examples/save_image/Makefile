# Native build on target (requires tucam-v2 installed).
CXX      ?= g++
CXXFLAGS += -O2 -Wall -DTUCAM_TARGETOS_IS_LINUX -std=c++11 -I/usr/include/tucam
LIBS     := -lTUCam -ludev -lpthread
TARGET   := save_image
SRC      := main.cpp

all: $(TARGET)
$(TARGET): $(SRC)
	$(CXX) $(CXXFLAGS) -o $@ $< $(LIBS)
clean:
	rm -f $(TARGET)
