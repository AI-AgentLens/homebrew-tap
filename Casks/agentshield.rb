cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.65"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.65/agentshield_0.2.65_darwin_amd64.tar.gz"
      sha256 "9099bde90f6777f72168c61517f434e9086387ac8915fd238fa6f35b5b3b0220"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.65/agentshield_0.2.65_darwin_arm64.tar.gz"
      sha256 "fa28f5635f2bc0c5ea31af9720ba4ea6873229111ecb379ec14e5bc0a48ac196"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.65/agentshield_0.2.65_linux_amd64.tar.gz"
      sha256 "2a21aadfbf790fcb9c336af73ceb4078172c880eb43a125acdc73bde22cf08e0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.65/agentshield_0.2.65_linux_arm64.tar.gz"
      sha256 "b5bc4cf1a2aca27b26e9283db97b9749d8e1a1938fd5bbc596833619a1abcc27"
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
