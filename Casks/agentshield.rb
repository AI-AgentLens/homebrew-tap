cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.70"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.70/agentshield_0.2.70_darwin_amd64.tar.gz"
      sha256 "394cb036d6f2c87f2730549cd78b7c7232f43b65b5cb9add949e76a612533125"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.70/agentshield_0.2.70_darwin_arm64.tar.gz"
      sha256 "b17c6330a34f438c9e726c8afa3bbc5f8c156f2f0414ddacaca4974851cbfb01"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.70/agentshield_0.2.70_linux_amd64.tar.gz"
      sha256 "7fb0de40c54d4de389ac10c85ed354f2220f38edf61ecc9ddbd15fd6b303566e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.70/agentshield_0.2.70_linux_arm64.tar.gz"
      sha256 "b61cf25eb6bd8542003e83ca0ad530e53f013523a0c71cf4d1b07a415af147ef"
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
