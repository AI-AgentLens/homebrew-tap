cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.29"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.29/agentshield_0.2.29_darwin_amd64.tar.gz"
      sha256 "6070c22284746cea51a052a0ded8f25a40d258073de6dc1616fac13dbd2c924c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.29/agentshield_0.2.29_darwin_arm64.tar.gz"
      sha256 "3949982c90023b6e2f92ca7107c6c46d19d9dcedcbc652ba97eb6fc5c986c7b7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.29/agentshield_0.2.29_linux_amd64.tar.gz"
      sha256 "e4f17d5f8a7374d7aa4a25dfb1b4a5f1030fc4245a671000df562ebbca40ad53"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.29/agentshield_0.2.29_linux_arm64.tar.gz"
      sha256 "e22d415211f5b4257104de18e87e3ea20fc0df7c50868be2217f115fd15f853b"
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
