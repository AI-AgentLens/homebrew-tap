cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.30"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.30/agentshield_0.2.30_darwin_amd64.tar.gz"
      sha256 "53ffd29b99f1e1ae990ca49cd7613ed936452a76697f5a135d8d79c6d7637b7a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.30/agentshield_0.2.30_darwin_arm64.tar.gz"
      sha256 "42df49d2051faf1ba87b42716a7479effc16047914471a124db6a992ae5d683d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.30/agentshield_0.2.30_linux_amd64.tar.gz"
      sha256 "f96d1bbca7251735275922e1d7b9ef6ce8e9820564b9150decdf3d92eed039c1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.30/agentshield_0.2.30_linux_arm64.tar.gz"
      sha256 "50c65346ff935918da258cfbb84d49df199f21977e9a4581a3fc57007b88c068"
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
