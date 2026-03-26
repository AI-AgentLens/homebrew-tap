cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.42"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.42/agentshield_0.2.42_darwin_amd64.tar.gz"
      sha256 "975c848cab33138de285dabcdb74dadc6a4426cc47ae65a0d649820caae0ec81"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.42/agentshield_0.2.42_darwin_arm64.tar.gz"
      sha256 "129ece63fc9b50a439b675c391308073dcc5225979bf8b68226003fd9843c6e4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.42/agentshield_0.2.42_linux_amd64.tar.gz"
      sha256 "205ce8b388ec87aa6fa86ce643594c6f4528aa2db2981683d2e80725b60d8cfb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.42/agentshield_0.2.42_linux_arm64.tar.gz"
      sha256 "528b125808604a738962ad62493989a1666ee64356e8d2a10feffa2cf05bbd75"
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
