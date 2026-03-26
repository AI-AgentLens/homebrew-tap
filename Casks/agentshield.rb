cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.49"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.49/agentshield_0.2.49_darwin_amd64.tar.gz"
      sha256 "75c7877f31f80ee418c9ae14b8600a4cfcb4ade4529a816323e901051fde7a9d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.49/agentshield_0.2.49_darwin_arm64.tar.gz"
      sha256 "a556d0c9605b065278199dc1aa87d54f12ffd57ea0c02c4207f7109c9a2a00f7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.49/agentshield_0.2.49_linux_amd64.tar.gz"
      sha256 "15f493e95f02bb552a0cc83adf013ca64997b19714a85278a4305aaf07b63901"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.49/agentshield_0.2.49_linux_arm64.tar.gz"
      sha256 "bee08254f626ca17f192c4b374239f90d0db884fa6a353f527efb2481ee0551d"
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
