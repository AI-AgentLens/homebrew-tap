cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.63"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.63/agentshield_0.2.63_darwin_amd64.tar.gz"
      sha256 "02adb813727e61572cb0ac4a0b47e742f05017db64d670b937738e8d7d081ed9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.63/agentshield_0.2.63_darwin_arm64.tar.gz"
      sha256 "a129476093d78ca1388b180f055ac260a098d156e72e3c4a96fa9e516748cc88"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.63/agentshield_0.2.63_linux_amd64.tar.gz"
      sha256 "673d65ac1e1901d978af8611afdfc15908e22b495e3d559f0134b5ef5576c250"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.63/agentshield_0.2.63_linux_arm64.tar.gz"
      sha256 "f706500d02e7aa218c974330b2708f685e7c364d9fd2782869bc4a9abc8f5ee3"
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
