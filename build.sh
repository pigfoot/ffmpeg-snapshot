#!/usr/bin/env bash

set -ex

LOCAL_BUILD_PREFIX="/sysroot"

(
  PKG_REPO="https://code.videolan.org/videolan/dav1d"
  PKG=${PKG_REPO##*/}
  cd /tmp
  [ ! -d "${PKG}" ] && git clone "${PKG_REPO}"
  cd "${PKG}" && git clean -fd && git restore . && git fetch
  VER="$(git tag | sed -En '/[0-9\.]+$/ s#(.*)#\1#p' | sort -t. -k 1,1n -k 2,2n -k 3,3n | sed '$!d')"
  git switch -C "${VER}" "tags/${VER}"
  cd .. && rm -rf "${PKG}_build" && mkdir "${PKG}_build" && cd "${PKG}_build"
  meson "../${PKG}" --prefix="${LOCAL_BUILD_PREFIX}" --libdir="${LOCAL_BUILD_PREFIX}/lib" --buildtype release --default-library=static \
    -Denable_tools=false -Denable_tests=false
  ninja -j$(nproc) install
) &

(
  PKG_REPO="https://aomedia.googlesource.com/aom"
  PKG=${PKG_REPO##*/}
  cd /tmp
  [ ! -d "${PKG}" ] && git clone "${PKG_REPO}"
  cd "${PKG}" && git clean -fd && git restore . && git fetch
  VER="$(git tag | sed -En '/^v[0-9\.]+$/ s#(.*)#\1#p' | sort -t. -k 1,1n -k 2,2n -k 3,3n | sed '$!d')"
  git switch -C "${VER}" "tags/${VER}"
  cd .. && rm -rf "${PKG}_build" && mkdir "${PKG}_build" && cd "${PKG}_build"
  cmake "../${PKG}" -G"Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="${LOCAL_BUILD_PREFIX}" -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DENABLE_DOCS=OFF -DENABLE_TESTS=OFF -DENABLE_EXAMPLES=OFF -DENABLE_NASM=ON
  make -j$(nproc) install
) &


(
  PKG_REPO="https://gitlab.com/AOMediaCodec/SVT-AV1"
  PKG=${PKG_REPO##*/}
  cd /tmp
  [ ! -d "${PKG}" ] && git clone "${PKG_REPO}"
  cd "${PKG}" && git clean -fd && git restore . && git fetch
  VER="v$(git tag | sed -En '/v[0-9\.]+$/ s#v(.*)#\1#p' | sort -t. -k 1,1n -k 2,2n -k 3,3n | sed '$!d')"
  git switch -C "${VER}" "tags/${VER}"
  #git switch -C "${VER}"
  cd .. && rm -rf "${PKG}_build" && mkdir "${PKG}_build" && cd "${PKG}_build"
  cmake "../${PKG}" -G"Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="${LOCAL_BUILD_PREFIX}" -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DBUILD_SHARED_LIBS=OFF -DBUILD_DEC=OFF
  make -j$(nproc) install
) &

(
  PKG_REPO="https://github.com/Netflix/vmaf"
  PKG=${PKG_REPO##*/}
  cd /tmp
  [ ! -d "${PKG}" ] && git clone "${PKG_REPO}"
  cd "${PKG}" && git clean -fd && git restore . && git fetch
  VER="v$(git tag | sed -En '/v[0-9\.]+$/ s#v(.*)#\1#p' | sort -t. -k 1,1n -k 2,2n -k 3,3n | sed '$!d')"
  git switch -C "${VER}" "tags/${VER}"
  cd .. && rm -rf "${PKG}_build" && mkdir "${PKG}_build" && cd "${PKG}_build"
  meson build "../${PKG}/lib${PKG}" --prefix="${LOCAL_BUILD_PREFIX}" --libdir="${LOCAL_BUILD_PREFIX}/lib" --buildtype release --default-library=static \
    -Denable_tests=false -Denable_docs=false
  ninja -vC build install
) &

(
  PKG_REPO="https://chromium.googlesource.com/webm/libvpx"
  PKG=${PKG_REPO##*/}  
  cd /tmp
  [ ! -d "${PKG}" ] && git clone "${PKG_REPO}"
  cd "${PKG}" && git clean -fd && git restore . && git fetch
  VER="v$(git tag | sed -En '/v[0-9\.]+$/ s#v(.*)#\1#p' | sort -t. -k 1,1n -k 2,2n -k 3,3n | sed '$!d')"
  git switch -C "${VER}" "tags/${VER}"
  cd .. && rm -rf "${PKG}_build" && mkdir "${PKG}_build" && cd "${PKG}_build"
  "../${PKG}/configure" --prefix="${LOCAL_BUILD_PREFIX}" --libdir="${LOCAL_BUILD_PREFIX}/lib" \
    --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm
  make -j$(nproc) install
) &

(
  PKG_REPO="https://github.com/silnrsi/graphite"
  PKG=${PKG_REPO##*/}
  cd /tmp
  [ ! -d "${PKG}" ] && git clone "${PKG_REPO}"
  cd "${PKG}" && git clean -fd && git restore . && git fetch
  VER="$(git tag | sed -En '/[0-9\.]+$/ s#(.*)#\1#p' | sort -t. -k 1,1n -k 2,2n -k 3,3n | sed '$!d')"
  git switch -C "${VER}" "tags/${VER}"
  cd .. && rm -rf "${PKG}_build" && mkdir "${PKG}_build" && cd "${PKG}_build"
  cmake "../${PKG}" -G"Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="${LOCAL_BUILD_PREFIX}" -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DBUILD_SHARED_LIBS=OFF
  make -j$(nproc) install
) &

(
  PKG_REPO="git://git.openssl.org/openssl"
  PKG=${PKG_REPO##*/}
  cd /tmp
  [ ! -d "${PKG}" ] && git clone "${PKG_REPO}"
  cd "${PKG}" && git clean -fd && git restore . && git fetch
  VER="openssl-$(git tag | sed -En '/openssl-[0-9\.]+$/ s#openssl-(.*)#\1#p' | sort -t. -k 1,1n -k 2,2n -k 3,3n | sed '$!d')"
  git switch -C "${VER}" "tags/${VER}"
  cd .. && rm -rf "${PKG}_build" && mkdir "${PKG}_build" && cd "${PKG}_build"
  "../${PKG}/config" --prefix="${LOCAL_BUILD_PREFIX}" --libdir="lib" no-shared no-autoload-config no-engine no-dso no-deprecated no-legacy
  make -j$(nproc)
  make install_sw
) &

libs=(
  libass.a libfdk-aac.a libfontconfig.a libfribidi.a libfreetype.a libharfbuzz.a libnuma.a
  libmp3lame.a libpng.a libogg.a libopus.a libvorbis.a libvorbisenc.a libx264.a
  libbrotlidec.a libbrotlicommon.a libexpat.a libpng.a libpng16.a libuuid.a libz.a
)
mkdir -p "${LOCAL_BUILD_PREFIX}/lib"
for lib in "${libs[@]}"; do
  ln -sf "/usr/lib/x86_64-linux-gnu/${lib}" "${LOCAL_BUILD_PREFIX}/lib/${lib}"
done

PKG_REPO="https://github.com/FFmpeg/FFmpeg"
PKG=${PKG_REPO##*/}
cd /tmp
[ ! -d "${PKG}" ] && git clone "${PKG_REPO}"
cd "${PKG}" && git clean -fd && git restore . && git fetch
VER="n$(git tag | sed -En '/n[0-9\.]+$/ s#n(.*)#\1#p' | sort -t. -k 1,1n -k 2,2n -k 3,3n | sed '$!d')"
#git switch -C "${VER}" "tags/${VER}"
#patch -p0 < /workspace/ffmpeg_reverse_banner.patch
git switch "release/5.1"
sed -Ei \
  -e '/^[[:space:]]*int hide_banner = 0;$/ s#= 0#= 1#' \
  -e '/^[[:space:]]*hide_banner = 1;$/ s#= 1#= 0#' "../${PKG}/fftools/cmdutils.c"
cd .. && rm -rf "${PKG}_build" && mkdir "${PKG}_build" && cd "${PKG}_build"
wait

# --extra-cxxflags="" --extra-libs=""

PKG_CONFIG_PATH=${LOCAL_BUILD_PREFIX}/lib/pkgconfig "../${PKG}/configure" \
  --extra-version=$(date +%Y%m%d) \
  --enable-gpl --enable-nonfree --enable-version3 --disable-doc --enable-pic \
  --disable-shared --enable-static --pkg-config-flags="--static" \
  --extra-cflags="-I${LOCAL_BUILD_PREFIX}/include" \
  --ld="g++" --extra-ldflags="-static-libstdc++ -static-libgcc -L${LOCAL_BUILD_PREFIX}/lib" \
  --enable-decoder=png \
  --enable-demuxer=concat,image2,matroska,mov,mp3,mpegts,ogg,wav \
  --enable-libass \
  --enable-libaom \
  --enable-libdav1d \
  --enable-libfdk-aac \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libsvtav1 \
  --enable-libvmaf \
  --enable-libvorbis \
  --enable-libvpx \
  --enable-libx264 \
  --enable-openssl
make -j$(nproc)

cp -av ffmpeg /workspace
cp -av ffprobe /workspace
