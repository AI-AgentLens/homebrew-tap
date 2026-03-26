cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.50"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.50/agentshield_0.2.50_darwin_amd64.tar.gz"
      sha256 "9ef47b3e26097571628644e92a89c55840815a662265b200f216a67b1efa4d83"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.50/agentshield_0.2.50_darwin_arm64.tar.gz"
      sha256 "00ad8b7d7789e4aa9c412061f4239af15588cf5813c394b18add69a3d5ffe5d2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.50/agentshield_0.2.50_linux_amd64.tar.gz"
      sha256 "6a7cf4665fc6e59edaccd8f6c37e2064762c2ebfdbd17ba1c4a16f840c6cfec5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.50/agentshield_0.2.50_linux_arm64.tar.gz"
      sha256 "d64279c346f92ed1f870cbdfce8971d3d51383c7c1c3b63d4501324bd102cdf1"
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
