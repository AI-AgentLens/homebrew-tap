cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.28"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.28/agentshield_0.2.28_darwin_amd64.tar.gz"
      sha256 "d8c2357bc81ebad41461a8599e77ce1954a62eebfb2bc41f89a7f08d7c639033"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.28/agentshield_0.2.28_darwin_arm64.tar.gz"
      sha256 "bb6b9b7036012ad98c4e5e793531191b4f3cde7229eec029cd5e6afc81e11a62"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.28/agentshield_0.2.28_linux_amd64.tar.gz"
      sha256 "8eee947c36d348778aad56b8dc3346ea12e30b7fa6f960622767bced3d557d4a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.28/agentshield_0.2.28_linux_arm64.tar.gz"
      sha256 "612d3a4f32e87381469428e8c85b6b678beed75fc13ad9b4ff77cb8c03a9467d"
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
