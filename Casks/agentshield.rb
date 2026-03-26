cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.71"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.71/agentshield_0.2.71_darwin_amd64.tar.gz"
      sha256 "11f3617995f3dd28319ff1ca69001a093f1c515bce914f7fa8f61b9fcb45a736"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.71/agentshield_0.2.71_darwin_arm64.tar.gz"
      sha256 "300fc963936dc889b3f72c8cb47e5bf545b6eead9331448de74e6ce40ba5e6e1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.71/agentshield_0.2.71_linux_amd64.tar.gz"
      sha256 "4bbf7f4315de2fdae5ee124154d2b4438398c5f859822d33b08191b8d2a32875"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.71/agentshield_0.2.71_linux_arm64.tar.gz"
      sha256 "76acb016425bf230b11c79716354eb106ffb0d612d61055fd956d82769929b63"
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
