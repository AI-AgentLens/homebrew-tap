cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.11"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.11/agentshield_0.2.11_darwin_amd64.tar.gz"
      sha256 "4c07d46f5adae12c176f06b7f849c16bb2b5a0e8a53a8bfa7acb7830688c0b5f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.11/agentshield_0.2.11_darwin_arm64.tar.gz"
      sha256 "fbc7eb50cf704829a46485009f47774c030264732169688a8396a4850c7de55e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.11/agentshield_0.2.11_linux_amd64.tar.gz"
      sha256 "e906c780e35660d767b693e60b9b95a55dbc1028a0bdc5b5339e78f3d545d975"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.11/agentshield_0.2.11_linux_arm64.tar.gz"
      sha256 "0f47f8799b6fc6f836030b4a5100705154c8fc3e076932303f1f8ec180b3ae0e"
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
