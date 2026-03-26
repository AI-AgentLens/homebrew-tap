cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.55"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.55/agentshield_0.2.55_darwin_amd64.tar.gz"
      sha256 "61e9486dd2bfcdb71678b66557b339feef1ff048b8e43c223e3a20cfa11f5932"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.55/agentshield_0.2.55_darwin_arm64.tar.gz"
      sha256 "36ab48256e638186d87d3c7947f70871c27a7a4e469250dd945ced36d32847b8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.55/agentshield_0.2.55_linux_amd64.tar.gz"
      sha256 "e9af7925d4e6a7b5597870eb088ea67cdd8f926c231b3a56aff5ea81b55fc383"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.55/agentshield_0.2.55_linux_arm64.tar.gz"
      sha256 "120df4aa7471f390d469a955820065d73ef10e96acbd01ebc0557e6419210684"
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
