cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.54"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.54/agentshield_0.2.54_darwin_amd64.tar.gz"
      sha256 "3fb7553341dcb0a2c09deb6b40d3317017142b08783103e6c1bbd8b3358122d5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.54/agentshield_0.2.54_darwin_arm64.tar.gz"
      sha256 "2b146adc9ef4803946e64f4330668c675cec872421a97973383b6034bce518d2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.54/agentshield_0.2.54_linux_amd64.tar.gz"
      sha256 "6f4b79c67f4d3357a900f4a78a010b045eaa834dd8fa5ca77a52e5dd5cf09f11"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.54/agentshield_0.2.54_linux_arm64.tar.gz"
      sha256 "db65cea8fbc01fc2cb1c42262dd5040e92d8d347fe3c623e426d4201cbcb870b"
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
