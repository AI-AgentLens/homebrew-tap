cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.51"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.51/agentshield_0.2.51_darwin_amd64.tar.gz"
      sha256 "78bc670f01893d169a26743d6c3a5090a1239e2dd207a7c96938a69ab3c123cb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.51/agentshield_0.2.51_darwin_arm64.tar.gz"
      sha256 "4328b4d70aca56c772cd1eb0ce2f39120aab1294117ba2529810d97398863249"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.51/agentshield_0.2.51_linux_amd64.tar.gz"
      sha256 "7b6a4afed4db7311e1789ab055812b7eb85f0ae64c09ba4f39ea52baaea8364f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.51/agentshield_0.2.51_linux_arm64.tar.gz"
      sha256 "c87fcd3ac56ded0d691bf163ad8c09e4d295248751ebcffa44052b11d3596509"
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
