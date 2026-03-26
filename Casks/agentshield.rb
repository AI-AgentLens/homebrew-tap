cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.34"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.34/agentshield_0.2.34_darwin_amd64.tar.gz"
      sha256 "4e490bba0b61fc33402cc7e529ed6849219d8869cc725363be6972d31adef461"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.34/agentshield_0.2.34_darwin_arm64.tar.gz"
      sha256 "4c0cfd0d20f6b51350371b64bedc928ac9746d18d2c5ba2eb068fd52cec5a592"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.34/agentshield_0.2.34_linux_amd64.tar.gz"
      sha256 "5c601d85d1778be14a88b4a4a8c2fd6c8c399429a6ad19a5928d524a8ff81de6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.34/agentshield_0.2.34_linux_arm64.tar.gz"
      sha256 "d3802638041e81c499bf86c486e3ae3d4c0d8afa69087ee76f6a592cd0808ef9"
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
