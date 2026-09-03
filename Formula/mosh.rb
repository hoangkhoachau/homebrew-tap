class Mosh < Formula
  desc "Remote terminal application (jdrouhard fork with unicode fixes)"
  homepage "https://github.com/jdrouhard/mosh"
  url "https://github.com/jdrouhard/mosh.git",
      branch:   "patched",
      revision: "3d613c845cae0b8966a5d5dbadf2639a9e2f6fd8"
  version "1.4.0"
  license "GPL-3.0-or-later"
  head "https://github.com/jdrouhard/mosh.git", branch: "patched"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "pkgconf" => :build
  depends_on "protobuf"

  uses_from_macos "ncurses"
  uses_from_macos "perl"

  on_linux do
    depends_on "openssl@3" # Uses CommonCrypto on macOS
    depends_on "zlib-ng-compat"
  end

  def install
    # https://github.com/protocolbuffers/protobuf/issues/9947
    ENV.append_to_cflags "-DNDEBUG"
    # Keep C++ standard in sync with abseil.
    ENV.append "CXXFLAGS", "-std=gnu++17"
    # Avoid over-linkage to `abseil`.
    ENV.append "LDFLAGS", "-Wl,-dead_strip_dylibs" if OS.mac?

    # Teach mosh to locate mosh-client without referring to PATH, to support
    # launching outside a shell e.g. via a launcher.
    inreplace "scripts/mosh.pl", "'mosh-client", "'#{bin}/mosh-client"

    # Prevent mosh from reporting `-dirty` in the version string.
    inreplace "Makefile.am", "--dirty", "--dirty=-Homebrew"

    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}", "--enable-completion", "--disable-silent-rules"
    system "make", "install"
  end

  test do
    system bin/"mosh-client", "-c"
  end
end
