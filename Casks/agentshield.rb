cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1003"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1003/agentshield_0.2.1003_darwin_amd64.tar.gz"
      sha256 "efd86828245111be63aae212fcfd9d09a7eb88dd186b4dc4da55ec630b554cda"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1003/agentshield_0.2.1003_darwin_arm64.tar.gz"
      sha256 "ccf2ab68522f680357c9179e97158042c2c6e56fba1ab2812d8c49de1226b09d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1003/agentshield_0.2.1003_linux_amd64.tar.gz"
      sha256 "71cb55a2206f867fe8aaf98b1b2578fe25df01ea38f356ae3bb7da5900710cd4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1003/agentshield_0.2.1003_linux_arm64.tar.gz"
      sha256 "9e9b64f744ddc99e348dfb4c70bee78c830dbf0752b4a1eb0bbefbd975b32ed3"
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
