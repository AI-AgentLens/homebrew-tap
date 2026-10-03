cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2331"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2331/agentshield_0.2.2331_darwin_amd64.tar.gz"
      sha256 "3cd63d5cab9740b3fb29ed706a629b66252688aae8e34d1cd29d942f93a39dd5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2331/agentshield_0.2.2331_darwin_arm64.tar.gz"
      sha256 "ed6a36da7911745a2e218b13adcb759481b87185eb286a6682dc094711441b79"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2331/agentshield_0.2.2331_linux_amd64.tar.gz"
      sha256 "59e81a4ebd4e861f3c19f84327e3641d956d54f10040a57e6afb720733a6f821"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2331/agentshield_0.2.2331_linux_arm64.tar.gz"
      sha256 "757ea3f8782340743cf091bd02897c3d727ddcb829609fc7ba9f88d781dd891a"
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
