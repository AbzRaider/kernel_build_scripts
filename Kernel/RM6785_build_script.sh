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

tg() {
    curl -sX POST https://api.telegram.org/bot"${token}"/sendMessage -d chat_id="${chat_id}" -d parse_mode=Markdown -d disable_web_page_preview=true -d text="$1" &>/dev/null
}

tgs() {
        MD5=$(md5sum "$1" | cut -d' ' -f1)
        curl -fsSL -X POST -F document=@"$1" https://api.telegram.org/bot"${token}"/sendDocument \
             -F "chat_id=${chat_id}" \
             -F "parse_mode=Markdown" \
             -F "caption=$2 | *MD5*: \`$MD5\`"
}

# sticker plox
sticker() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendSticker" \
        -d sticker="CAACAgQAAxkBAAED3JFiApkFOuZg8zt0-WNrfEGwrvoRuAACAQoAAoEcoFINevKyLXEDhSME" \
        -d chat_id="${chat_id}"
}
# Send info plox channel
sendinfo() {
    tg "
• THUNDERSTORM CI Build •
*Building on*: \`Circle CI\`
*Date*: \`${DATE}\`
*Device*: \`${DEVICE} (${CODENAME})\`
*Branch*: \`$(git rev-parse --abbrev-ref HEAD)\`
*Last Commit*: [${COMMIT_HASH}](${REPO_URL}/commit/${COMMIT_HASH})
*Compiler*: \`${KBUILD_COMPILER_STRING}\`
*Build Status*: \`${STATUS}\`"
}
# Push kernel to channel
push() {
    cd AnyKernel || exit 1
    ZIP=$(echo *.zip)
    tgs "${ZIP}" "Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s). | For *${DEVICE} (${CODENAME})* | ${KBUILD_COMPILER_STRING}"
}
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
    
    git clone --depth=1 https://github.com/anupamroy777/AnyKernel33.git AnyKernel
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
push
