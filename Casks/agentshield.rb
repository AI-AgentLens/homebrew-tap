cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2504"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2504/agentshield_0.2.2504_darwin_amd64.tar.gz"
      sha256 "792d8c0c7e61f1cd4417faad3f79ebac011928273a91ffac90e2256b78ff4fa3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2504/agentshield_0.2.2504_darwin_arm64.tar.gz"
      sha256 "995a46bc4de7f1b2239949bbf4cdd1c269851ad859c45443dab23795a5cf6add"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2504/agentshield_0.2.2504_linux_amd64.tar.gz"
      sha256 "057f415eb415e8c99ee7ba60934f862a2d742b317645488fe824d4e2fc6787d8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2504/agentshield_0.2.2504_linux_arm64.tar.gz"
      sha256 "b6de1c05945095ab2d4ca88122fefaa53bc85141a6b1460472611b6cb516cf5d"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
