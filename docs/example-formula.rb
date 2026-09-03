# Template: copy to Formula/<name>.rb, rename the class to CamelCase of the file name.
class Example < Formula
  desc "One-line description, no leading article, no trailing period"
  homepage "https://github.com/hoangkhoachau/example"
  url "https://github.com/hoangkhoachau/example/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "REPLACE_WITH_SHA256"
  license "MIT"

  # Go project
  depends_on "go" => :build

  def install
    ldflags = "-s -w -X main.version=#{version}"
    system "go", "build", *std_go_args(ldflags: ldflags)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/example --version")
  end
end
