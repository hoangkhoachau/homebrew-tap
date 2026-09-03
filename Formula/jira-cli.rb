class JiraCli < Formula
  desc "Interactive Jira command-line (fork with array custom field edit fix)"
  homepage "https://github.com/hoangkhoachau/jira-cli"
  url "https://github.com/hoangkhoachau/jira-cli.git",
      branch:   "fix/edit-array-string-custom-field",
      revision: "f6fe2be5e5af0536c9074bb493dde3dddfc0f64a"
  version "1.7.0-arraycf1"
  license "MIT"
  head "https://github.com/hoangkhoachau/jira-cli.git", branch: "fix/edit-array-string-custom-field"

  # `jira issue edit --custom` cannot set array custom fields whose items are
  # not options (labels, multi-checkbox, multi-picker): custom fields go into
  # the REST `update` block, which expects verb-value pairs, but that branch
  # emitted a bare JSON array and Jira rejected the request. Fixed upstream in
  # https://github.com/ankitpokhrel/jira-cli/pull/1026 -- once that ships,
  # delete this formula and go back to homebrew/core `jira-cli`.

  depends_on "go" => :build

  def install
    version_pkg = "github.com/ankitpokhrel/jira-cli/internal/version"
    source_date_epoch = Utils.safe_popen_read("git", "show", "-s", "--format=%ct").strip
    ldflags = %W[
      -X #{version_pkg}.Version=#{version}
      -X #{version_pkg}.GitCommit=#{Utils.git_head}
      -X #{version_pkg}.SourceDateEpoch=#{source_date_epoch}
    ]

    # Guard the reason this fork exists: an array/string custom field has to be
    # submitted as a `set` operation inside the REST `update` block. This test
    # pins the generated payload for every custom field datatype.
    system "go", "test", "./pkg/jira/", "-run", "TestGetRequestDataForEditCustomFields"

    system "go", "build", *std_go_args(ldflags: ldflags, output: bin/"jira"), "./cmd/jira"

    generate_completions_from_executable(bin/"jira", "completion")
  end

  test do
    assert_includes shell_output("#{bin}/jira version"), "Version=\"#{version}\""
    assert_match "--custom", shell_output("#{bin}/jira issue edit --help")
  end
end
