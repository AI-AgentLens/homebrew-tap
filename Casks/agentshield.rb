cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.24"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.24/agentshield_0.2.24_darwin_amd64.tar.gz"
      sha256 "818838f6e450e216d83a0666bad4656493fa84879bb200aca88264818395344d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.24/agentshield_0.2.24_darwin_arm64.tar.gz"
      sha256 "13af009bd6e3ca5178b1a43b39862564e50255de0e6cd40f33bed3b1ed380758"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.24/agentshield_0.2.24_linux_amd64.tar.gz"
      sha256 "e617905838e72b28f86d6c852618d6669c22167d993f31c35b31554602d754a3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.24/agentshield_0.2.24_linux_arm64.tar.gz"
      sha256 "c30177abee59c9f178d4e85055adb50e2be93f6bef1392226ccea77f731a7f8f"
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
