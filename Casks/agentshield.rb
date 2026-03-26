cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.10"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.10/agentshield_0.2.10_darwin_amd64.tar.gz"
      sha256 "7c5a5a653a628eca10f828b24c645a8ffe439cf70cfab660559ea3a30c4ec31b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.10/agentshield_0.2.10_darwin_arm64.tar.gz"
      sha256 "0fa5d303e5cf0c01a132802c3ad4e7fa91b2cd5a81e9a002fbb9841f89777945"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.10/agentshield_0.2.10_linux_amd64.tar.gz"
      sha256 "31cfeca4bc4dce7bdb56934773c3320f3139645d6aef76f586d719a75158917a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.10/agentshield_0.2.10_linux_arm64.tar.gz"
      sha256 "faddf87c94579447fc7e1c3228724475910df3b869e900da2a63aa5c7c5bf3d7"
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
