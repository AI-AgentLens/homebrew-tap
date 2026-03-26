cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.76"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.76/agentshield_0.2.76_darwin_amd64.tar.gz"
      sha256 "d56236bca9e2646ec6951421242c6267c0f0c5e8c15db574cf3fb633b1927099"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.76/agentshield_0.2.76_darwin_arm64.tar.gz"
      sha256 "40761206ea309bc014247f3603a4a81140b4fdb72a4ed783d073f02e41adb4f5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.76/agentshield_0.2.76_linux_amd64.tar.gz"
      sha256 "e29eb8209736ed2ee051d3e7ea932e32c870d5a1cf970eac9c07e639c22828f2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.76/agentshield_0.2.76_linux_arm64.tar.gz"
      sha256 "31b92cb914ff0e1388d33b39e3e0e6f933c8fff0225a95c763107f3bb3718fba"
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
