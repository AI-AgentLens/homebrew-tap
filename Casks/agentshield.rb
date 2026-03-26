cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.58"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.58/agentshield_0.2.58_darwin_amd64.tar.gz"
      sha256 "6c5c89adf26817b079f71c470bbc865fae42c5a3a9d8c46216ab2ab2d87a4ffa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.58/agentshield_0.2.58_darwin_arm64.tar.gz"
      sha256 "c74acc02518774b5b3820ee2fdc75a223d6c5cd64a22284bd4da46602a65f1db"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.58/agentshield_0.2.58_linux_amd64.tar.gz"
      sha256 "149622d41ccc9876f1a2cb1e9531eb1014a53d5f572f0e62cd6758c35f5ecd47"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.58/agentshield_0.2.58_linux_arm64.tar.gz"
      sha256 "26c0234f776c78997c00ab6c89fe2817c2ac2df72155f5db3893d2b03aeaefd3"
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
