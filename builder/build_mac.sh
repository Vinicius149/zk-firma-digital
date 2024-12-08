 
#!/bin/zsh

source /etc/profile
export LC_ALL="en_US.UTF-8"

cd src
pyinstaller zk-firma-digital.spec

mkdir -p dist/package/usr/local/zk-firma-digital/os_libs/macos/
mkdir -p dist/package/usr/local/zk-firma-digital/certs
mkdir -p dist/package/usr/local/zk-firma-digital/etc/Athena/
mkdir -p dist/scripts

cp -a dist/zk-firma-digital.app dist/package/usr/local/zk-firma-digital/
cp -a CA-certificates/ dist/package/usr/local/zk-firma-digital/
cp -a os_libs/macos/libASEP11.dylib dist/package/usr/local/zk-firma-digital/os_libs/macos/
cp -a os_libs/Athena/IDPClientDB.xml  dist/package/usr/local/zk-firma-digital/etc/Athena/
tar -C dist/ -cf dist/package/usr/local/zk-firma-digital/zk-firma-digital.app.tar zk-firma-digital.app

tee -a dist/scripts/postinstall << END
#!/bin/sh
tar -C /Applications -xf /usr/local/zk-firma-digital/zk-firma-digital.app.tar
mv /Applications/zk-firma-digital.app  /Applications/zk-firma-digital.app
mkdir -p /etc/Athena/
cp /usr/local/zk-firma-digital/etc/Athena/IDPClientDB.xml /etc/Athena/

[ \! -e /usr/local/lib/libASEP11.dylib -o -L /usr/local/lib/libASEP11.dylib ] && cp /usr/local/zk-firma-digital/os_libs/macos/libASEP11.dylib /usr/local/lib/libASEP11.dylib

exit 0 # all good
END
chmod u+x dist/scripts/postinstall

cd dist

pkgbuild --root ./package --identifier cr.zk-firma-digital  --script ./scripts --version 0.2 --install-location / ./zk-firma-digital.pkg

