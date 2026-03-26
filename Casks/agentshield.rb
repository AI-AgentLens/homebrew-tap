cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.21"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.21/agentshield_0.2.21_darwin_amd64.tar.gz"
      sha256 "45173af1266c5d3148f65f9f2f8838b24b9c1a680dab9319475b0a888b1df003"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.21/agentshield_0.2.21_darwin_arm64.tar.gz"
      sha256 "754cf3bb53bf07519996d35408e295e8fa106b4333c6b8e5973e5a26c0ad4301"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.21/agentshield_0.2.21_linux_amd64.tar.gz"
      sha256 "ebbe51d81cd5b6910316e68a1de253ae29a10b6db2ce618c6ceaf2c7b6754a6a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.21/agentshield_0.2.21_linux_arm64.tar.gz"
      sha256 "7dc62e125d604a258e9740db9de9607846e2cefa8f0d0cbf9ca81eaebe12d4e3"
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
