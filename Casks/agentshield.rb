cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2498"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2498/agentshield_0.2.2498_darwin_amd64.tar.gz"
      sha256 "d51be4147db8be9562f648a911483e0f0e7ccc5dbfbf4ede211748195e7c6da6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2498/agentshield_0.2.2498_darwin_arm64.tar.gz"
      sha256 "88ffad2fb31985b29675338b02b847e1f70dd0858c4ac6d7243b85f942a0a05a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2498/agentshield_0.2.2498_linux_amd64.tar.gz"
      sha256 "893dd3521b6a549da99f7a330b21aaafefbbc7edefb1538c83f765e2d8de3b31"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2498/agentshield_0.2.2498_linux_arm64.tar.gz"
      sha256 "b16f6da57b20e000cbaee8768378aa02172e42896d79d5788b0c08ec124b0fb2"
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
