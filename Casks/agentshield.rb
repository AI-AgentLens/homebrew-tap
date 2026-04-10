cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.531"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.531/agentshield_0.2.531_darwin_amd64.tar.gz"
      sha256 "88f86bed6c7879470c41ee8ed967fb178adaa9c1e55ad087ccfa7f53540b6e53"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.531/agentshield_0.2.531_darwin_arm64.tar.gz"
      sha256 "4e01f9de127ade94d58a1810adac114d7a405e4b8590353cc230cdb8d3f9b457"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.531/agentshield_0.2.531_linux_amd64.tar.gz"
      sha256 "58e084c324cb7600f7a06b19b8f322301d78553cd15528de7fd185adf2a9c1ea"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.531/agentshield_0.2.531_linux_arm64.tar.gz"
      sha256 "d690d7ad8466c5b8a24ad7a41e145b8cc902e86da8b1f4036658efbf4be275ee"
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
