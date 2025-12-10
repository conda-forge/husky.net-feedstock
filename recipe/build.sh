#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
ln -sf ${DOTNET_ROOT}/dotnet ${PREFIX}/bin

# Build package with dotnet publish
rm -rf global.json
sed -i 's/0.7.0/0.8.0/' .config/dotnet-tools.json
framework_version="$(dotnet --version | sed -e 's/\..*//g').0"
dotnet publish --no-self-contained src/Husky/Husky.csproj --output ${PREFIX}/libexec/${PKG_NAME} --framework net${framework_version}
rm ${PREFIX}/libexec/${PKG_NAME}/Husky

# Create bash and batch wrappers
tee ${PREFIX}/bin/dotnet-husky << EOF
#!/bin/sh
exec \${DOTNET_ROOT}/dotnet exec \${CONDA_PREFIX}/libexec/husky.net/Husky.dll "\$@"
EOF
chmod +x ${PREFIX}/bin/dotnet-husky

tee ${PREFIX}/bin/dotnet-husky.cmd << EOF
call %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\husky.net\Husky.dll %*
EOF

dotnet-project-licenses --input src/Husky/Husky.csproj -t -d license-files

rm ${PREFIX}/bin/dotnet
