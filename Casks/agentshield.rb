cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.40"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.40/agentshield_0.2.40_darwin_amd64.tar.gz"
      sha256 "6bde7ccf83745a199e61d72a03e96bc228d61b0d7ad97ebf7fe4970ea09c25a9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.40/agentshield_0.2.40_darwin_arm64.tar.gz"
      sha256 "c79d223026a91eb542b32206b04f162e4bac46e0355b5c9f83f0074f63261ac4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.40/agentshield_0.2.40_linux_amd64.tar.gz"
      sha256 "ca67c191ca16e07d4f90d9d602e8b6626ecda5028ffc5ab25e4cea2b8ff1beac"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.40/agentshield_0.2.40_linux_arm64.tar.gz"
      sha256 "92c5fcc52a90fbd6b30596f6360e3c7b09437b5ecb5eacb9722ecd9fb78009ff"
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
