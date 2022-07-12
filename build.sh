#!/usr/bin/env bash

(
  cd /tmp
  git clone https://aomedia.googlesource.com/aom
  cd aom
  VER="v$(git tag | sed -En '/^v[0-9\.]+$/ s#(.*)#\1#p' | sort -t. -k 1,1n -k 2,2n -k 3,3n | sed '$!d')"
  git switch -c "${VER}"
  cd /tmp
  mkdir aom_build
  cd aom_build
  cmake ../aom -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DENABLE_TESTS=0
  make -j install
) &

(
  cd /tmp
  git clone https://code.videolan.org/videolan/dav1d.git
  cd dav1d
  VER="$(git tag | sed -En '/[0-9\.]+$/ s#(.*)#\1#p' | sort -t. -k 1,1n -k 2,2n -k 3,3n | sed '$!d')"
  git switch -c "${VER}"
  mkdir build
  cd build
  meson .. --default-library=static --prefix=/usr
  ninja install
) &

(
  cd /tmp
  git clone https://gitlab.com/AOMediaCodec/SVT-AV1.git
  cd SVT-AV1
  VER="v$(git tag | sed -En '/v[0-9\.]+$/ s#v(.*)#\1#p' | sort -t. -k 1,1n -k 2,2n -k 3,3n | sed '$!d')"
  git switch -c "${VER}"
  cd Build
  cmake .. -G"Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DBUILD_DEC=OFF -DBUILD_SHARED_LIBS=OFF
  make -j install
) &

(
  cd /tmp
  git clone https://github.com/Netflix/vmaf.git
  cd vmaf
  VER="v$(git tag | sed -En '/v[0-9\.]+$/ s#v(.*)#\1#p' | sort -t. -k 1,1n -k 2,2n -k 3,3n | sed '$!d')"
  git switch -c "${VER}"
  cd libvmaf
  meson build --buildtype release --default-library=static --prefix=/usr
  ninja -vC build install
) &

(
  cd /tmp
  git clone https://chromium.googlesource.com/webm/libvpx
  cd libvpx
  VER="v$(git tag | sed -En '/v[0-9\.]+$/ s#v(.*)#\1#p' | sort -t. -k 1,1n -k 2,2n -k 3,3n | sed '$!d')"
  git switch -c "${VER}"
  mkdir build
  cd build
  ../configure --prefix=/usr
  make -j install
) &

git clone https://github.com/FFmpeg/FFmpeg.git
cd FFmpeg
VER="n$(git tag | sed -En '/n[0-9\.]+$/ s#n(.*)#\1#p' | sort -t. -k 1,1n -k 2,2n -k 3,3n | sed '$!d')"
git switch -c "${VER}"
patch -p0 < ../ffmpeg_reverse_banner.patch

PKG_CONFIG_PATH=/usr/lib64/pkgconfig ./configure \
  --extra-version=$(date +%Y%m%d) \
  --enable-gpl --enable-nonfree --enable-version3 \
  --disable-shared --enable-static --extra-ldflags="-static" --ld="g++" --pkg-config-flags="--static" \
  --enable-decoder=png \
  --enable-demuxer=concat,image2,matroska,mov,mp3,mpegts,ogg,wav \
  --enable-gmp \
  --enable-libaom \
  --enable-libdav1d \
  --enable-libfdk-aac \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libsvtav1 \
  --enable-libtwolame \
  --enable-libvmaf \
  --enable-libvo-amrwbenc \
  --enable-libvorbis \
  --enable-libvpx \
  --enable-libwebp \
  --enable-libx264 \
  --enable-libass \
  --enable-openssl
make -j$(nproc)
