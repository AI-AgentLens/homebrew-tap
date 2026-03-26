cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.18"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.18/agentshield_0.2.18_darwin_amd64.tar.gz"
      sha256 "ee458f5df2b2a63f25707f73ebac61df438686f7cc6cc2a8e0e299441b4458c8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.18/agentshield_0.2.18_darwin_arm64.tar.gz"
      sha256 "c719ba4e533f4924eca517f52ee8a11911b41127f14a41d0ba175d38e1edf341"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.18/agentshield_0.2.18_linux_amd64.tar.gz"
      sha256 "984a6306d47b2536e4c9fd3e48af0db79753fc62d601d86ec976299b28ea03c6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.18/agentshield_0.2.18_linux_arm64.tar.gz"
      sha256 "1417c829cc2b75f53768e7ee02ac8588cb500001466993bf9c67626d12e83323"
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
