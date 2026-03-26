cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.82"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.82/agentshield_0.2.82_darwin_amd64.tar.gz"
      sha256 "bd089a8833ee35f93ef32eb3c72047ee70514f215a5a990ae8d8d05e5ae18446"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.82/agentshield_0.2.82_darwin_arm64.tar.gz"
      sha256 "2ba39172cbbb299267c1911f7faca4c53d5f6b33db2dba42699f7d8de32b70ce"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.82/agentshield_0.2.82_linux_amd64.tar.gz"
      sha256 "eb7ecfd33a56e163a6de174f59e227913ff4137427c6713c26500850e410db36"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.82/agentshield_0.2.82_linux_arm64.tar.gz"
      sha256 "47f7452c4297d7d7aad50028087aa463f454d4b8acf263e806e936d1ba3d727b"
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
