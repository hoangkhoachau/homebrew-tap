class PiRemoteDaemon < Formula
  desc "Control Pi sessions through a Codex app-server-compatible endpoint"
  homepage "https://github.com/hoangkhoachau/pi-remote-daemon"
  url "https://github.com/hoangkhoachau/pi-remote-daemon/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "38e5a778963674f042e5b7d67496f9f21852d4bb32d9082b0a838a2b35547d9c"

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    libexec.glob("lib/node_modules/pi-remote-daemon/node_modules/**/@mariozechner/clipboard-darwin-*").each(&:rmtree)
    libexec.glob("lib/node_modules/pi-remote-daemon/node_modules/**/@earendil-works/pi-tui/native").each(&:rmtree)
    pkgshare.install "extensions/pi-remote-bridge.ts"

    (bin/"pi-remote-daemon").write <<~SH
      #!/bin/sh
      exec "#{formula_opt_bin("node")}/node" "#{libexec}/lib/node_modules/pi-remote-daemon/src/main.mjs" "$@"
    SH
  end

  def caveats
    <<~EOS
      To enable graceful takeover of active Pi TUI sessions, install the optional extension:
        mkdir -p ~/.pi/agent/extensions
        cp #{pkgshare}/pi-remote-bridge.ts ~/.pi/agent/extensions/
    EOS
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/pi-remote-daemon --help")
  end
end
