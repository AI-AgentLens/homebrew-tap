cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.75"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.75/agentshield_0.2.75_darwin_amd64.tar.gz"
      sha256 "33db9ea7e4d65d60d229037c081b92fc2ed751c6446e433359232361fb0ad402"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.75/agentshield_0.2.75_darwin_arm64.tar.gz"
      sha256 "e1cd594e97ce101f4154884c05003cf16e0f198e4b33dc519a61770f8db5d536"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.75/agentshield_0.2.75_linux_amd64.tar.gz"
      sha256 "bf9be547a314f79ad69b5e8a931e14688361a4b1922833e4bf0348dbc086881b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.75/agentshield_0.2.75_linux_arm64.tar.gz"
      sha256 "c68e1bd349dbe6fc4ae8d04acb40b45f3d4b84a4663008025349d60a7f1ec927"
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
