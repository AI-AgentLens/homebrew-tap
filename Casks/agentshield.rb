cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.56"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.56/agentshield_0.2.56_darwin_amd64.tar.gz"
      sha256 "16af3a0978325bb7a02e4d5e708f9cdfc3a638259a21f8698600abee726280c9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.56/agentshield_0.2.56_darwin_arm64.tar.gz"
      sha256 "71b2dc21f5c5f790a5f18848ab51172c24ce3ad6c501962c304692f7a7749e35"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.56/agentshield_0.2.56_linux_amd64.tar.gz"
      sha256 "3b123da5d52e813a9d6807fdbae7b4266c7f49f190dceb7ca2a994130ee001e5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.56/agentshield_0.2.56_linux_arm64.tar.gz"
      sha256 "e94d4aa36842c043971a912a2b51ee3d87fa07d5659ebf0503eae266ba95e918"
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
