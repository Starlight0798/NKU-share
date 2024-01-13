import shutil
import string
import os
disk_list=[]
dstpath='./sample/'
def get_disklist():
    global disk_list
    for c in string.ascii_uppercase:
        disk = c + ':'
        if os.path.isdir(disk):
            disk_list.append(disk)

def mycopyfile(srcfile,dstpath):
    fpath,fname=os.path.split(srcfile)
    if not os.path.exists(dstpath):
        os.makedirs(dstpath)
    shutil.copy(srcfile, dstpath + fname)
    print ("copy %s -> %s"%(srcfile, dstpath + fname))

def scanDir(filePath):
    files = os.listdir(filePath)
    for file in files:
        file_d = os.path.join(filePath, file)
        try:
            if os.path.isdir(file_d):
                scanDir(file_d)
            else:
                suffix=os.path.splitext(file_d)[-1]
                if suffix=='.exe' or suffix=='.dll':
                    #print(file_d)
                    mycopyfile(file_d,dstpath)
        except:
            continue;

if __name__ == '__main__':
    # get_disklist()
    disk_list = ['C:', 'D:']
    #print(disk_list)
    for disk in disk_list:
        disk+='\\'
        scanDir(disk)
