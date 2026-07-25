import os

rootdir = os.getcwd()

projfile = 'mt3.luaproj'
projpath = os.path.join(rootdir, projfile)
tmppath = os.path.join(rootdir, 'tmp')

allfiles = []
alldirs = []
for root, dirs, files in os.walk(rootdir):
    for d in dirs:
        p = os.path.relpath(os.path.join(root, d), rootdir)
        alldirs.append(p)
    for f in files:
        if os.path.splitext(f)[1] == '.lua':
            p = os.path.relpath(os.path.join(root, f), rootdir)
            allfiles.append(p)


n = 0
inScope = False
infp = open(projpath, 'rb')
outfp = open(tmppath, 'wb')
line = infp.readline()
while line:
    if line.decode().find('<ItemGroup>') >= 0:
        inScope = True
        outfp.write(line)
        n = n+1
        if n == 1:
            for d in alldirs:
                s = '    '+'<Folder Include="'+d+'\\" />\n'
                outfp.write(s.encode())
        elif n == 2:
            for f in allfiles:
                s = '    '+'<Compile Include="'+f+'" />\n'
                outfp.write(s.encode())
    elif line.decode().find('</ItemGroup>') >= 0:
        inScope = False
        outfp.write(line)
    elif inScope == False:
        outfp.write(line)
    line = infp.readline()
infp.close()
outfp.close()

os.remove(projpath)
os.rename(tmppath, projpath)

