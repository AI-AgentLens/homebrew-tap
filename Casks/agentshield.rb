cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.27"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.27/agentshield_0.2.27_darwin_amd64.tar.gz"
      sha256 "ed818feb2d0f44dae339ca0854680326215382672b67fcbe7f4ae9858a99ac5c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.27/agentshield_0.2.27_darwin_arm64.tar.gz"
      sha256 "5d7a1f408e9bb6fd5f2979e3fdf0783d3ddc2c0ae1e152588082fbd2296b779b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.27/agentshield_0.2.27_linux_amd64.tar.gz"
      sha256 "c8f6fe13151448b88bddca65cc21afa9fd3033086210483b1910eaddc81dcc3c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.27/agentshield_0.2.27_linux_arm64.tar.gz"
      sha256 "676f1b5a33ecaa1186874c007f17c02dfec96e7f08e7de84081adfbe295c5b12"
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
