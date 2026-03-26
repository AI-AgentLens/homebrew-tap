cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.22"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.22/agentshield_0.2.22_darwin_amd64.tar.gz"
      sha256 "7d4add71c39ac5069eb94116b2e6e3a90ff311b8d7c27115cb485a3de3e5e204"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.22/agentshield_0.2.22_darwin_arm64.tar.gz"
      sha256 "94213604d4bdf98d683288dc15d22ef87ac495dd0b62c71add9a58041d3df274"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.22/agentshield_0.2.22_linux_amd64.tar.gz"
      sha256 "86fff4b83d2c0298691220d91c9ac7c5da0a9207cde139c42dbfa8a415fbaec1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.22/agentshield_0.2.22_linux_arm64.tar.gz"
      sha256 "81e25e489ee48ff9773fe1bb3f84bff054fe8897fef2cf5583c3f6bb631db0c5"
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
