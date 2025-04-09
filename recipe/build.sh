#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
ln -sf ${DOTNET_ROOT}/dotnet ${PREFIX}/bin
ln -sf ${PREFIX}/bin/Husky ${PREFIX}/bin/dotnet-husky

# Build package with dotnet publish
rm -rf global.json
rm -rf .config/dotnet-tools.json
framework_version="$(dotnet --version | sed -e 's/\..*//g').0"
dotnet publish --no-self-contained src/Husky/Husky.csproj --output ${PREFIX}/libexec/${PKG_NAME} --framework net${framework_version}
rm ${PREFIX}/libexec/${PKG_NAME}/Husky
rm ${PREFIX}/bin/dotnet-husky

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
