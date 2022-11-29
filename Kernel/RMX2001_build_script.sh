#!/usr/bin/env bash

# clone repo
git clone --depth=1 https://github.com/AbzRaider/android_kernel_realme_RMX2001.git -b Q
cd android_kernel_realme_RMX2001
# Dependencies
deps() {
    echo "Cloning dependencies"
        
    if [ ! -d "clang" ];then
	    git clone --depth=1 https://github.com/kdrag0n/proton-clang.git clang
	    KBUILD_COMPILER_STRING="Proton Clang 13"
	    fi
    echo "Done"
}

IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
DATE=$(date +"%Y%m%d-%H%M")
START=$(date +"%s")
KERNEL_DIR=$(pwd)
CACHE=1
export CACHE
PATH="${PWD}/clang/bin:${PATH}"
export KBUILD_COMPILER_STRING
ARCH=arm64
export ARCH
KBUILD_BUILD_HOST=AbzRaider
export KBUILD_BUILD_HOST
KBUILD_BUILD_USER="AbzRaider"
export KBUILD_BUILD_USER
REPO_URL="https://github.com/AbzRaider/android_kernel_realme_RMX2001.git"
export REPO_URL
DEVICE="Realme 6/6i/6s"
export DEVICE
CODENAME="NEMO"
export CODENAME
DEFCONFIG="RMX2001_defconfig"
export DEFCONFIG
COMMIT_HASH=$(git rev-parse --short HEAD)
export COMMIT_HASH
PROCS=$(nproc --all)
export PROCS
STATUS=BETA
export STATUS
source "${HOME}"/.bashrc && source "${HOME}"/.profile




# Find Error
finderr() {
		LOG=$(echo *.log)
        tgs "${LOG}" "Build throw an error(s)"
    exit 1
}
# Compile plox
compile() {

    if [ -d "out" ];then
	rm -rf out && mkdir -p out
    fi
    
make O=out ARCH="${ARCH}" "${DEFCONFIG}"


	make -j"${PROCS}" O=out \
                      	ARCH=$ARCH \
                      	CC="clang" \
			LD=ld.lld \
                      	CROSS_COMPILE=aarch64-linux-gnu- \
                      	CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
		      	AR=llvm-ar \
		      	NM=llvm-nm \
		      	OBJCOPY=llvm-objcopy \
			OBJDUMP=llvm-objdump \
			STRIP=llvm-strip
			CLANG_TRIPLE=aarch64-linux-gnu- \
                   	CONFIG_NO_ERROR_ON_MISMATCH=y 2>&1 | tee error.log 


    if ! [ -a "$IMAGE" ]; then
        finderr
        exit 1
    fi
    
    cd AnyKernel 
git clone --depth=1 https://github.com/AbzRaider/AnyKernel33.git -b rui1
cd /
 cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
}
# Zipping
zipping() {
    cd AnyKernel || exit 1
    zip -r9 Azrael-Test-OSS-"${BRANCH}"-KERNEL-"${CODENAME}"-"${DATE}".zip ./*
    curl -sL https://git.io/file-transfer | sh
    ./transfer wet Azrael-Test-OSS-"${BRANCH}"-KERNEL-"${CODENAME}"-"${DATE}".zip
    cd ..
}

deps
sendinfo
compile
zipping
END=$(date +"%s")
DIFF=$(($END - $START))
