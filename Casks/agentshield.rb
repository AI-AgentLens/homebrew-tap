cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.36"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.36/agentshield_0.2.36_darwin_amd64.tar.gz"
      sha256 "efd8e228c0e4bf6af8dbb5b45ec37e1f7420ce4039f1ebb5c8b1a3c118ac8627"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.36/agentshield_0.2.36_darwin_arm64.tar.gz"
      sha256 "45360848936a5efec93c854969585ed1ec4e097de1af2e91a92d43b2597c1dd9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.36/agentshield_0.2.36_linux_amd64.tar.gz"
      sha256 "ecd088a831a7856ecb75681d95eded6fff7894128bfa8fc608ac5cd2bc422852"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.36/agentshield_0.2.36_linux_arm64.tar.gz"
      sha256 "d0afdf711975c27aaa501b226b49670d410473bdd4a229c3ac504a9a1bae9dfd"
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
