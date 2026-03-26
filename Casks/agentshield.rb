cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.61"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.61/agentshield_0.2.61_darwin_amd64.tar.gz"
      sha256 "e21fecf037c5400e4893d65534f69dc4ec7913fdf1cd4338d6307421c8b1169e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.61/agentshield_0.2.61_darwin_arm64.tar.gz"
      sha256 "24f950cc13d0853a03e50a626efad94e3d9740ef8ca73687a9bcb26209a0b774"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.61/agentshield_0.2.61_linux_amd64.tar.gz"
      sha256 "0512e93239b76432ca8abe6ed325d0e4cf4b33513af83d7831e08681a6588e19"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.61/agentshield_0.2.61_linux_arm64.tar.gz"
      sha256 "ea49672925f8a71a58c999c98f4a5e665ff885bb068065f23401d792cb0265b7"
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
