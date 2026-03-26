cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.15"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.15/agentshield_0.2.15_darwin_amd64.tar.gz"
      sha256 "9a00c1f29eba6d27e309760f450aea2f653d1ccce8b8e8dbbda732795780772d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.15/agentshield_0.2.15_darwin_arm64.tar.gz"
      sha256 "989555d5f323d60ba0fa10bffa9f246a2c0a2067de13fb13927f5f161ddda5d1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.15/agentshield_0.2.15_linux_amd64.tar.gz"
      sha256 "a77ea1cb6a9dacae1b48c42afc3fdfb881c4cfadd45c99475b0791f1d76bceac"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.15/agentshield_0.2.15_linux_arm64.tar.gz"
      sha256 "b14c1542bebada4f22dc7860dfa66b7d645706398747955e4a700e400f498e4a"
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
