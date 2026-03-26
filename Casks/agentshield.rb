cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.19"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.19/agentshield_0.2.19_darwin_amd64.tar.gz"
      sha256 "3a0096863a39733990fb9bdb5b5e8281fcf4c4896ccf6e4a24ea2bd2f7355756"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.19/agentshield_0.2.19_darwin_arm64.tar.gz"
      sha256 "74f18ed550c036c9a2fa481053ad1ddb106eb441534ec6b06306ce1750bfce6b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.19/agentshield_0.2.19_linux_amd64.tar.gz"
      sha256 "ec2dbc05b1eb1fc1f3ea54b15845d06a18c8beadf8833223b9fa0495418c3c8a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.19/agentshield_0.2.19_linux_arm64.tar.gz"
      sha256 "74bd5554eb3900a28852be1ced418bc118b9b3e02831f16af7dadf4a07e23322"
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
