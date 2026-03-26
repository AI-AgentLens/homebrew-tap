cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.68"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.68/agentshield_0.2.68_darwin_amd64.tar.gz"
      sha256 "e767eb325e1a40e875764f712dfedddce1cef181251f32a216baa1ce49cf81e2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.68/agentshield_0.2.68_darwin_arm64.tar.gz"
      sha256 "a6f17331fc9d5f18558194ac0599b87d01b6d406553eaa0d68ca9dc7d16e4acc"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.68/agentshield_0.2.68_linux_amd64.tar.gz"
      sha256 "cd2847e77841b1056d787ffd7a691c491d3a61c48a5135d339eb572d27c86e22"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.68/agentshield_0.2.68_linux_arm64.tar.gz"
      sha256 "b8c09f464d8b114e087f74ee712cbfa0847a09353ee98c1cb01c57ddb43a0e7a"
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
