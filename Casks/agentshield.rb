cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.837"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.837/agentshield_0.2.837_darwin_amd64.tar.gz"
      sha256 "4303dc49bf06e0357e8c37463f3de18c9cdf19972542350ceafe4bbbddbc6799"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.837/agentshield_0.2.837_darwin_arm64.tar.gz"
      sha256 "89a005c3e90fc0dc6e483657f94f813c6e47727b9a15d546f07cdcb3dc137e17"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.837/agentshield_0.2.837_linux_amd64.tar.gz"
      sha256 "3d652b03a6b838501101157f152a34392389c5ddc5b6ea513114f98bf23625c0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.837/agentshield_0.2.837_linux_arm64.tar.gz"
      sha256 "feb8ea573a36b6f95d716d15cddc5e114d48f0429e668b239d67f37a83315faa"
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
