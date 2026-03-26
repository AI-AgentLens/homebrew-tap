cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.20"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.20/agentshield_0.2.20_darwin_amd64.tar.gz"
      sha256 "94f01db337231f47293feafbe574292599904bb227904f69ec5989c5e803c5bf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.20/agentshield_0.2.20_darwin_arm64.tar.gz"
      sha256 "c1e69ec6bc63045c49922eb443d909be2c8c4a63cfa4ea17889065eff1951f3e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.20/agentshield_0.2.20_linux_amd64.tar.gz"
      sha256 "34151e89080a8244b749c9783121d541dff65ef1546821cc326d5ebd7ff2be58"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.20/agentshield_0.2.20_linux_arm64.tar.gz"
      sha256 "098ee3eea586cc0a709f3ecd8dc80febc394a1525699b46e40b14f954ba8667b"
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
