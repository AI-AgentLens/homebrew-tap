cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.72"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.72/agentshield_0.2.72_darwin_amd64.tar.gz"
      sha256 "8d9b071f879f7eff724c61c02d30d4821e35919230157dc1cf90e35515695a51"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.72/agentshield_0.2.72_darwin_arm64.tar.gz"
      sha256 "57a9dbf93287f9419a821377fc49926c854ba75f17ebb01fafc514523be0f8db"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.72/agentshield_0.2.72_linux_amd64.tar.gz"
      sha256 "700f7cb5467efe0a2c5f89e32b791f1c1213892f300de60c37d95a2ecab99cd5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.72/agentshield_0.2.72_linux_arm64.tar.gz"
      sha256 "56050669d3f817b798d1910b39d980e1acca8ae45c40320a750447695e7fb619"
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
