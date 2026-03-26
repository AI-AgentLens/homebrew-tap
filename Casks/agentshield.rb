cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.57"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.57/agentshield_0.2.57_darwin_amd64.tar.gz"
      sha256 "fc8788576730c9f8d9815a4ba045f4daf320465c9909e8a44e661ec74a5c3b24"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.57/agentshield_0.2.57_darwin_arm64.tar.gz"
      sha256 "c233fbfde7b34781fe68108890c29f7a540c4588289e62e333edc9c009042651"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.57/agentshield_0.2.57_linux_amd64.tar.gz"
      sha256 "a4da79b6e6bb68cba0dadb952d782ad1686ae88cfc7cb812b2d277a067e41047"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.57/agentshield_0.2.57_linux_arm64.tar.gz"
      sha256 "4658921b59293509fd4bc8dd8b0899469b8444287f91809d572d56a0407fb9c2"
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
