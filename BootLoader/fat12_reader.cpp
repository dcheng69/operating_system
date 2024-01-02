#include <iostream>
#include <fstream>
#include <iomanip>
using namespace std;

#define RET_SUCCESS         0

#define RET_ERROR_OPEN_FILE -1

#define BS_jmpBoot              3
#define BS_OEMName              8
#define BPB_BytesPerSec         2
#define BPB_SecPerClus          1
#define BPB_RsvdSecCnt          2
#define BPB_NumFATs             1
#define BPB_RootEntCnt          2
#define BPB_TotSec16            2
#define BPB_Media               1
#define BPB_FATSz16             2
#define BPB_SecPerTrk           2
#define BPB_NumHeads            2
#define BPB_HiddSec             4
#define BPB_TotSec32            4
#define BS_DrvNum              1
#define BS_Rserved1            1
#define BS_BootSig             1
#define BS_VolID               4
#define BS_VolLab              11
#define BS_FileSysType         8


int read_boot_sector_fat12(ifstream &file) {
    int ret = RET_SUCCESS;
    if (!file.is_open()) {
        cerr << "file not open!" << endl;
        ret = RET_ERROR_OPEN_FILE;
        return ret;
    }

    // read and display the boot sector
    char* bytes = new char[16];
    unsigned int u_int = 0;
    ostringstream hex_out;

    // read and ignore the first 3 bytes
    for (int i=0; i<BS_jmpBoot; i++) {
        file.read(&bytes[i], 1);
    }

    // read and display the OEM Name attribute
    cout << "BS_OEMName: ";
    for (int i=0; i<BS_OEMName; i++) {
        file.read(&bytes[i], 1);
        cout << bytes[i];
    }
    cout <<  endl;

    // read and display bytes per sector
    u_int = 0;
    cout << "BPB_BytesPerSec: ";
    for (int i=0; i<BPB_BytesPerSec; i++) {
        file.read(&bytes[i], 1);
        u_int |= static_cast<unsigned char>(bytes[i]) << (i*8);
    }
    cout << u_int ;
    cout <<  endl;

    // read and display sector per cluster
    u_int = 0;
    cout << "BPB_SecPerClus: ";
    for (int i=0; i<BPB_SecPerClus; i++) {
        file.read(&bytes[i], 1);
        u_int |= static_cast<unsigned char>(bytes[i]) << (i*8);
    }
    cout << u_int;
    cout <<  endl;

    // read and display number of reserved sectors
    u_int = 0;
    cout << "BPB_RsvdSecCnt : ";
    for (int i=0; i<BPB_RsvdSecCnt; i++) {
        file.read(&bytes[i], 1);
        u_int |= static_cast<unsigned char>(bytes[i]) << (i*8);
    }
    cout << u_int;
    cout <<  endl;

    // read and display number of FATs
    u_int = 0;
    cout << "BPB_NumFATs : ";
    for (int i=0; i<BPB_NumFATs; i++) {
        file.read(&bytes[i], 1);
        u_int |= static_cast<unsigned char>(bytes[i]) << (i*8);
    }
    cout << u_int;
    cout <<  endl;

    // read and display number of FATs
    u_int = 0;
    cout << "BPB_RootEntCnt : ";
    for (int i=0; i<BPB_RootEntCnt; i++) {
        file.read(&bytes[i], 1);
        u_int |= static_cast<unsigned char>(bytes[i]) << (i*8);
    }
    cout << u_int;
    cout <<  endl;

    // read and display number of FATs
    u_int = 0;
    cout << "BPB_TotSec16 : ";
    for (int i=0; i<BPB_TotSec16; i++) {
        file.read(&bytes[i], 1);
        u_int |= static_cast<unsigned char>(bytes[i]) << (i*8);
    }
    cout << u_int;
    cout <<  endl;

    // read and display descriptor of the disk
    u_int = 0;
    cout << "BPB_Media : ";
    for (int i=0; i<BPB_Media; i++) {
        file.read(&bytes[i], 1);
        u_int |= static_cast<unsigned char>(bytes[i]) << (i*8);
    }
    hex_out << "0x" << setw(4) << setfill('0') << hex << u_int;
    cout << hex_out.str();
    hex_out.str("");
    cout << endl;

    // read and display sectors per FAT
    u_int = 0;
    cout << "BPB_FATSz16 : ";
    for (int i=0; i<BPB_FATSz16; i++) {
        file.read(&bytes[i], 1);
        u_int |= static_cast<unsigned char>(bytes[i]) << (i*8);
    }
    cout << u_int;
    cout <<  endl;

    // read and display sectors per track
    u_int = 0;
    cout << "BPB_SecPerTrk: ";
    for (int i=0; i<BPB_SecPerTrk; i++) {
        file.read(&bytes[i], 1);
        u_int |= static_cast<unsigned char>(bytes[i]) << (i*8);
    }
    cout << u_int;
    cout <<  endl;

    // read and display number of heads
    u_int = 0;
    cout << "BPB_NumHeads : ";
    for (int i=0; i<BPB_NumHeads; i++) {
        file.read(&bytes[i], 1);
        u_int |= static_cast<unsigned char>(bytes[i]) << (i*8);
    }
    cout << u_int;
    cout <<  endl;

    // read and display number of hidden sectors
    u_int = 0;
    cout << "BPB_HiddSec: ";
    for (int i=0; i<BPB_HiddSec; i++) {
        file.read(&bytes[i], 1);
        u_int |= static_cast<unsigned char>(bytes[i]) << (i*8);
    }
    cout << u_int;
    cout <<  endl;

    // read and display number of FAT32
    u_int = 0;
    cout << "BPB_TotSec32: ";
    for (int i=0; i<BPB_TotSec32; i++) {
        file.read(&bytes[i], 1);
        u_int |= static_cast<unsigned char>(bytes[i]) << (i*8);
    }
    cout << u_int;
    cout <<  endl;

    // read and display drive number
    u_int = 0;
    cout << "BS_DrvNum: ";
    for (int i=0; i<BS_DrvNum; i++) {
        file.read(&bytes[i], 1);
        u_int |= static_cast<unsigned char>(bytes[i]) << (i*8);
    }
    cout << u_int;
    cout <<  endl;

    // Unused ignore
    for (int i=0; i<BS_Rserved1; i++) {
        file.read(&bytes[i], 1);
    }

    // read and display boot signature
    u_int = 0;
    cout << "BPB_BootSig : ";
    for (int i=0; i<BS_BootSig; i++) {
        file.read(&bytes[i], 1);
        u_int |= static_cast<unsigned char>(bytes[i]) << (i*8);
    }
    hex_out << "0x" << setw(4) << setfill('0') << hex << u_int;
    cout << hex_out.str();
    hex_out.str("");
    cout << endl;

    // read and display volume id
    u_int = 0;
    cout << "BS_VolID: ";
    for (int i=0; i<BS_VolID; i++) {
        file.read(&bytes[i], 1);
        u_int |= static_cast<unsigned char>(bytes[i]) << (i*8);
    }
    cout << u_int;
    cout <<  endl;

    // read and display the Volume Label
    cout << "BS_VolLab : ";
    for (int i=0; i<BS_VolLab; i++) {
        file.read(&bytes[i], 1);
        cout << bytes[i];
    }
    cout <<  endl;

    // read and display the Volume Label
    cout << "BS_FileSysType : ";
    for (int i=0; i<BS_FileSysType; i++) {
        file.read(&bytes[i], 1);
        cout << bytes[i];
    }
    cout <<  endl;

    // Get the new position in the file (bytes read after BS_FileSysType)
    int currentPosition = file.tellg();
    cout << endl << "Bytes read so far: " << currentPosition << endl;

    delete[] bytes;

    return ret;
}

int main(int argc, char* argv[]) {
    ifstream boot_loader("boot.img", ios::binary);
    return read_boot_sector_fat12(boot_loader);
}
