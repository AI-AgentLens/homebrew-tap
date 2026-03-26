cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.81"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.81/agentshield_0.2.81_darwin_amd64.tar.gz"
      sha256 "00bea0c5f8fde4dadf9391b45e0a81e2d070a89219e97fef6b9d94859854d94c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.81/agentshield_0.2.81_darwin_arm64.tar.gz"
      sha256 "6cecfed4e5024c85c226924eeeb13d3b74dd4578bdc4ef92ee3936aa23f04dab"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.81/agentshield_0.2.81_linux_amd64.tar.gz"
      sha256 "df796196d6a1748448c95ab3c66c60d695ae46636ea9fd255ac15932176f1869"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.81/agentshield_0.2.81_linux_arm64.tar.gz"
      sha256 "9525ce3d37fb2ea05c953b33fa8b52f70389849964d01d918c0e9ba9373243c9"
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
